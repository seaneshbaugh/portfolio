# Application review — 2026-11-10

This review began as an analysis pass following the Rails 8.1/Ruby 4 deployment.
The test assertions, direct-upload access control, publication boundaries and
public rendering defects (R3–R5) and list N+1 queries (R12) have since been corrected as recorded below. Other findings remain open. Production deployment,
TLS, login and editing are owner-confirmed. Server-wide backups are being handled
separately and are outside this review's remediation work.

Reviewed controllers/routes/policies, models, serializers, presenters, validators,
helpers/builders, public/admin view paths, first-party JavaScript and the tests.
Findings below distinguish reproduced defects from follow-up design decisions.
No requests or probes were sent to production or Spaces. Runtime probes used the
local test database, rolled-back transactions and dummy attachment metadata.

Priority: P1 = address promptly (access/storage boundary); P2 = functional/query
correctness; P3 = maintenance or hardening. The owner confirmed that
`visible: false` means unpublished and must return 404 from public content routes.
Pages' separate `show_in_menu` flag controls navigation independently.

## Evidence and test baseline

- Full local suite: **225 tests, 783 assertions, 30 failures, 7 errors, 0 skips**.
  All 55 system tests pass. There were no new failures in this review.
- The 30 failures are **29 RecordNotFound expectations and one RoutingError
  expectation**, rather than 30 independently broken application paths.
- All seven errors are Contact validation matchers invoking missing `assert_must`.
- Temporary copies of the affected controller tests plus Contact tests, with only
  the proposed assertion changes, pass: **123 tests, 229 assertions, zero failures
  or errors**. These copies were under /tmp, not committed or substituted into
  the application. The complete suite has not been run with fixes applied, because
  this pass intentionally leaves application/tests unchanged.
- Brakeman reports **zero security warnings and zero scan errors**. That does not
  establish route-level authorization: the direct-upload issue below is reproduced
  despite a clean static scan.
- SQL measurements used `sql.active_record`, excluded schema/cache hits, and
  disabled query caching for the measurement. They count association access after
  the root records were loaded; they are not total HTTP request query counts.

## Confirmed findings

### R1 — P1: anonymous direct uploads can allocate blobs and obtain upload URLs (access control resolved)

References: `config/routes.rb` (Active Storage engine routes),
`app/javascript/controllers/picture_uploads_controller.js:68`,
`app/views/admin/pictures/index.html.haml`, `app/controllers/admin/pictures_controller.rb:5`.

At initial review the admin picture action was protected, but the standard
`POST /rails/active_storage/direct_uploads` endpoint was not authenticated or
policy-checked by this application. In a fresh anonymous test session, with
forgery protection explicitly enabled and a genuine CSRF token read from the
public home page, this endpoint returned HTTP 200 and a blob `signed_id`.
The test metadata described a text file, which also received a response.

The test service was Disk; production uses the same controller path to obtain
Spaces upload credentials. An anonymous caller can therefore reach the upload
allocation/signing boundary independently of admin picture creation. Rejecting
files in the browser does not protect that endpoint. This allows storage/database
abuse even if the subsequent admin picture POST is forbidden.

Suggested fix: authenticate and authorize direct-upload creation using the
existing admin Picture create policy. Ensure the default engine endpoint is
protected too. Decide supported image types/byte limits and enforce them at the
server boundary, including the ordinary multipart form path. Preserve intended
public signed read URLs.

Regression tests: anonymous visitor (including valid CSRF token), signed-in
non-admin, admin; rejected metadata; valid direct upload plus picture persistence;
no unauthorized blob creation. Do not exercise this against the live bucket.

### R2 — P1: unpublished content is accessible through public detail endpoints (resolved)

References: `app/controllers/pages_controller.rb:5`,
`app/controllers/posts_controller.rb:17`, `app/controllers/api/v1/posts_controller.rb:13`,
`app/controllers/pictures_controller.rb:5` and `:9`.

At initial review, setting an existing Page/Post to `visible: false` still
produced HTTP 200 for its public HTML detail URL; the API post detail also returned
HTTP 200. The normal post
index filters unpublished records, so direct access is inconsistent with listing.
The public gallery index/show relations also omit `Gallery.published`; the hidden
fixture gallery can be selected by both. Child membership visibility does not
substitute for parent gallery publication.

Suggested fix: consistently scope public lookup relations to published records.
Use an authenticated preview path if draft previews are needed. Confirm whether
public API picture/tag enumeration intentionally includes unassigned uploads/tags;
there is no picture-level publication flag, so that is a separate product decision.

Regression tests: published/unpublished HTML and API detail, gallery index and
show, hidden children, navigation/sitemap consistency, and any explicit preview
contract. Expect 404 for unpublished public lookups if they are drafts.

### R3 — P2: a gallery whose memberships are all hidden can crash the index (resolved)

References: `app/views/pictures/index.html.haml:3`, `app/models/gallery.rb:35`.

The view keeps galleries with any membership, including hidden ones, then calls
`gallery.featured_or_first_picture.medium_image_path` without a nil guard.
A gallery with memberships but no published membership passes the first condition
and has a nil cover. Both states were reproduced. Rendering that expression raises
NoMethodError instead of producing an empty gallery state.

Suggested fix: derive cover selection and index eligibility from the same visible
membership set. Decide whether empty published galleries should be omitted or
shown with an explicit placeholder. Coordinate this with R2 and the query fixes.

Regression tests: no memberships, all hidden, hidden featured with visible fallback,
and visible featured cover; no nil dereference or hidden-image disclosure.

### R4 — P2: the RSS feed raises on Rails 8 (resolved)

Reference: `app/views/posts/index.rss.builder:14`.

`post.created_at.to_s(:rfc822)` raises ArgumentError on the installed version.
A request to `/posts.rss` reproduces an ActionView template error when posts exist.
Use `to_fs(:rfc822)` or an explicit RSS-compatible date formatter.

Regression test: request the RSS format with a published post and parse the XML,
checking its publication date and exclusion of unpublished posts. Empty-feed status
checks alone would not exercise this line.

### R5 — P2: gallery sitemap entries use `<lock>` instead of `<loc>` (resolved)

Reference: `app/views/sitemap/index.xml.builder:77`.

`xml.lock picture_url(gallery)` emits a literal `<lock>` element. With a published
gallery, the response is HTTP 200 but contains this invalid URL entry. The default
fixture gallery is hidden, so the existing status-only test misses the branch.
Use `xml.loc` and verify the parsed sitemap's namespace/elements and URL values.

### R6 — P2: the picture selector cannot reach pictures beyond its first page

References: `app/controllers/admin/pictures_controller.rb:10`,
`app/views/shared/admin/_picture_selector.html.haml:1`,
`app/javascript/controllers/picture_selector_controller.js:31`.

The modal fetches `/admin/pictures.json`, which is capped at 25 records. It has no
page/search/load-more control. With 28 pictures, the authenticated request returned
25; the remaining pictures cannot be chosen through this UI. This affects both
Ace insertion and gallery management.

Suggested fix: add paginated selection/search using the existing endpoint and
stable ordering, or deliberately return all records for this small application.
Prefer an explicit bounded design over silently making the entire admin index
unpaginated. Test selection of record 26+ and preserve modal cancellation/focus.

### R7 — P2: a missing link date fails at the database instead of validation

References: `app/models/link.rb:8`, `db/schema.rb` (links.published_at NOT NULL),
`app/controllers/admin/links_controller.rb:31`.

A Link with valid text/URL but `published_at: nil` is model-valid. Saving it raises
ActiveRecord::NotNullViolation. Clearing the native date field can therefore
escape the normal 422 form-error path.

Suggested fix: validate presence of published_at and retain the database
constraint. Test empty date on both create and update, including preservation of
entered text/URL and the displayed field error.

### R8 — P2: a leading read-more marker displays the entire body

Reference: `app/presenters/post_presenter.rb:33`.

For `<!--more--><p>FULL_BODY_MARKER</p>`, the range becomes `0..-1`, selecting the
whole body. Reproduced with the presenter's link renderer stubbed so the assertion
isolates truncation. Use a length slice or split with an explicit first segment.
Test beginning/middle/end markers and absent markers.

### R9 — P2: link tag URLs do not encode the query parameter

Reference: `app/presenters/link_presenter.rb:20`.

Interpolating the tag into `"#{base_path}?tag=#{tag}"` creates `/links?tag=C++`.
Rack decodes this as `C  `, not `C++`. Ampersands and other query characters have
similar problems. The post presenter already uses a route helper with parameters.
Use a route/query builder and test tags containing plus, ampersand and Unicode.

### R10 — P2: null page color raises instead of producing validation errors

Reference: `app/validators/css_color_validator.rb:10`.

`Page.new(..., color: nil).valid?` raises NoMethodError in `value.match?`, despite
the model having a presence validation. Handle nil/type-invalid input without
raising; use whole-string anchors for the color pattern. Test nil, blank, multiline
and ordinary valid colors. The normal color widget hides this case, but controller
parameters can still contain nil.

### R11 — P2: role sorting duplicates admin user rows

References: `app/controllers/admin/users_controller.rb:10`,
`app/views/admin/users/index.html.haml:25`.

Sorting with `roles_name asc` joins the HABTM collection. When an admin also has
the user role, the result has three rows for two users. This produces duplicate
rows and incorrect pagination counts/boundaries.

Suggested fix: define the intended sort key for a multi-role user and build a
unique-user query accordingly. A blanket DISTINCT with ORDER BY roles.name needs
care on PostgreSQL; test the generated query rather than assuming it fixes sorting.
Cover two roles on one user, filters, sort directions and pagination.

### R12 — P2: multiple list paths have confirmed N+1 queries (resolved)

| Path | Cause | Local measurement / evidence | Suggested change |
| --- | --- | --- | --- |
| Gallery index covers | `Gallery#featured_picture` / `first_picture` apply fresh scopes/joins to an already preloaded collection, returning fresh Picture objects | Five eager-loaded galleries caused 15 further queries when selecting featured covers and accessing their attachment | Select from the preloaded visible membership set, or introduce a batch cover lookup; preserve visible fallback/order semantics |
| Public post tags | HTML relation includes users, but the presenter calls tag_list without the corresponding tagging preload | Seven loaded posts caused 14 tag queries | Preload the association path actually used by acts-as-taggable-on, or render from preloaded tags; verify the measured path stops querying |
| Admin post authors | Admin index does not preload `:user` | Five posts with distinct authors caused five author queries | Add the author preload to the paginated result |
| Admin user roles | Role collection is not preloaded before `UserPresenter#roles` | Five users caused five role queries | Preload roles and render the loaded collection; remeasure alongside R11 |
| Picture lists / JSON selection / public API | Root Picture relations do not preload attachment/blob, while every row/serializer accesses them | Two loaded pictures caused two attachment lookups even before reading blob data | Use `with_attached_image` / equivalent verified attachment/blob preload for rendered collections |
| Admin gallery edit/show | `find_gallery` preloads pictures but not their image attachment/blob; field partial renders thumbnail per membership | Confirmed association omission and per-row thumbnail traversal (not separately counted as a full HTTP request) | Preload attachments/blobs for memberships actually displayed |
| Link month/tag lists | Presenter traverses tags per link; relation does not preload tags | Static traversal confirmed; not separately profiled | Preload the tags used by the presenter and add a bounded query test |

Keep optimizations proportionate to this small database. Do not replace N+1s with
unbounded eager loading of full image collections solely to display one cover.
Use 1-vs-5/10 record regression checks with distinct associations, excluding schema
queries and fixture setup; avoid brittle exact counts for whole rendered requests.

### R13 — P3: obsolete endpoints and restoration UI are incomplete

- `Admin::PicturesController#selector` calls `authorize Picture, :create` rather
  than `:create?`: reproduced NoMethodError on Admin::PicturePolicy. No selector
  template exists either. The current modal uses index.json, so remove this unused
  route/action or implement a coherent supported endpoint.
- `/admin/tags.json?q[name_cont]=a` raises the installed Ransack's explicit
  allowlist error for ActsAsTaggableOn::Tag. Current forms use text tag fields;
  either remove the old autocomplete endpoint or configure a narrow allowlist and
  authorization. The public tags API is a separate intentional read endpoint.
- `versions/:id/revert` points at a missing VersionsController. The unused shared
  version partials call missing `revert?` policies and `admin_revert_version_path`,
  while the route helper is `revert_version_path`; they retain old UJS/markup too.
  PaperTrail recording can remain, but restoration is not a completed feature.
  Remove dead UI/routes or implement authorized version restore as separate work.
- The EXIF reopening under `lib/ext` is intentionally excluded from autoloading
  and is not required anywhere. New uploads therefore use the stock analyzer;
  the presenter still expects custom `metadata['exif']`. Decide whether EXIF display
  should return; implement an explicit supported analyzer rather than autoloading
  an old reopening that expects the former image interface.

## Original failing tests and their remediation

### 30 failures: assert HTTP outcomes in request tests

`config/environments/test.rb:26` uses the generated
`config.action_dispatch.show_exceptions = :rescuable`. Requests for missing records
render 404; they do not raise into the integration test. A missing page returned
404 in the local probe.

For the 29 ActiveRecord::RecordNotFound cases and the one invalid-year
ActionController::RoutingError case, replace the exception wrapper with the
request followed by `assert_response :not_found`.

```ruby
get page_url(id: "does-not-exist")
assert_response :not_found
```

Keep exception assertions in genuine model/unit tests of methods that raise.
Do not globally switch show_exceptions to :none just to satisfy old request
assertions. Add response-body/format assertions where JSON or HTML errors differ.
The affected cases span the six admin CRUD controllers, public pages/posts/
galleries, API pictures/posts, and the links year boundary.

### Seven errors: replace the incompatible generic `.must` matcher bridge

`test/models/contact_test.rb:11` and the other six validation assertions use
`_(contact).must validate_...`. The current combination calls an `assert_must`
method that does not exist on the test context. This is test integration failure,
not seven missing Contact validations.

A tested explicit form is:

```ruby
matcher = validate_presence_of(:name)
assert matcher.matches?(contact), -> { matcher.failure_message }
```

For useful failures, retain the matcher in a variable and pass its failure message,
or use straightforward valid/invalid value assertions. The temp-copy run proves
all seven existing matcher intentions can pass without changing contact behavior.
Keep the intentionally disabled ContactController POST inert and preserve its
existing request/system tests. Spam prevention and re-enabling contact remain
separate decisions.

## Improvements and design decisions after confirmed fixes

1. **Expand meaningful coverage.** Page/Post/Gallery/GalleryPicture/User model test
   files are empty; ContactJobTest is empty. The 55 useful browser tests cover normal
   admin workflows, but not publication boundaries, 26+ selector records, RSS/XML
   semantics, empty gallery covers or the missing date. Add targeted regressions
   above, then job failure/deleted-record cases, association constraints and API
   response contracts. Directory `test/contollers` is misspelled; Rails discovers
   it, but conventional paths reduce surprises for test tooling.
2. **Declare the CMS trust model.** Administrator-authored HTML/CSS/JS is an
   intentional product capability. `html_safe` on those fields is not automatically
   a defect requiring removal. HTML validation is syntax validation, not a security
   sanitizer. Preserve that capability while ensuring only authorized authors can
   write content and unpublished content follows the chosen visibility contract.
3. **Harden model/data invariants.** Most application associations have indexes
   but no foreign keys (the schema ends with only the variant-record blob FK).
   Audit existing orphans before adding the appropriate Post/User, gallery/picture
   membership and role join constraints. Decide whether duplicate pictures per
   gallery and multiple featured memberships are allowed: JavaScript currently
   enforces one featured selection, while the model/database do not. These are
   policy decisions, not grounds for silently rewriting existing data.
4. **Simplify parent validation.** `validates_associated :user` on Post and
   `validates_associated :gallery` on GalleryPicture revalidate persisted parent
   objects during child validation. Keep only actual business requirements;
   association presence plus database foreign keys often express these invariants
   more directly. Verify nested gallery invalid-state behavior before removing it.
5. **Use explicit delegation and failures.** ApplicationPresenter's method_missing
   rescues all NoMethodError, including errors raised inside a model method, and
   forwards no keyword arguments explicitly. Prefer a conventional delegation
   mechanism with preserved error provenance and Ruby 4 keyword behavior. Remove
   redundant `nil?` checks following find, which already raises.
6. **Make controller success handling truthful.** CRUD destroy actions announce
   success without checking whether destroy succeeded. No current abort callback
   was reproduced, so this is hardening, not a demonstrated deletion failure.
   Links/Posts invalid renders use `flash` rather than `flash.now`, which can leave
   the validation error in the next response. Align these with the other forms.
7. **Bound and shape API work.** Public posts/tags API lists are unbounded and
   serializer arrays are an application-specific envelope rather than a single
   JSON:API document. Preserve consumers while deciding the contract, pagination
   and field exposure; avoid rewriting the API merely for architectural fashion.
8. **Treat validators as maintained application code.** UrlValidator advertises
   mailto but requires a host; `mailto:owner@example.test` fails. Either support
   hostless schemes explicitly or narrow the documented schemes. Use argv form
   for JavaScript checking, inspect exit status, and define subprocess failure/
   timeout handling. Test the old npm CSS parser against CSS syntax the CMS should
   accept before replacing/removing Node. No RCE claim follows from its current
   fixed-prefix tempfile command.
9. **Keep admin UI lifecycle behavior.** The Stimulus upload code tracks requests
   per connection, aborts on disconnect, and uses textContent for error text; the
   gallery manager has keyboard ordering alternatives. Preserve those behaviors
   while fixing selection pagination. Direct uploads interrupted before Picture
   persistence can leave unattached blobs; define a retention/cleanup policy that
   does not purge uploads still in flight. This is application storage hygiene,
   distinct from the separately managed backup system.
10. **Avoid unrelated rewrites.** Rails-default configuration, Haml conversion,
    seeds rework, public styling, deployment operations and backup automation are
    separate workstreams. No need to add a service layer, replace Ransack or swap
    the serializer library to fix the concrete issues above.

## Suggested implementation order

1. Apply the small test-only assertion fixes and confirm the full suite is green.
2. Add/fix direct-upload authorization and publication-boundary regressions.
3. Fix gallery cover eligibility, RSS and sitemap, then missing-date/color,
   read-more and query-encoded tag links with focused tests.
4. Implement usable selector pagination/search and correct multi-role sorting.
5. Fix measured list preloads with query-growth checks, then remove/complete the
   obsolete routes/features deliberately.
6. Work through the chosen model/API/delegation hardening separately, preserving
   intended CMS functionality and keeping tests green after each group.

R1/R2 are the highest-priority behavior changes even though the assertion cleanup
is a convenient short first commit. This report is not a claim that every possible
bug or security issue has been found; no concurrency/load test, live-host scan or
dependency-vulnerability audit was performed. Static review includes lower-risk
notes explicitly labelled as decisions or unmeasured paths rather than reproduced
failures.

## Test remediation completed — 2026-11-10

Applied the 30 request-test 404 assertions and seven explicit Contact matcher
assertions. Matcher failure messages are lazy, because some Shoulda matchers
only provide failure details after an unsuccessful match. Rails exception
configuration and application behavior are unchanged.

`docker compose exec -T web bundle exec rails test:all` passes: **225 tests,
790 assertions, 0 failures, 0 errors, 0 skips**, including all 55 system tests.
RuboCop passes for all 18 files in the controller-test directories plus the
Contact model test. Other review findings remain open.

## Direct-upload access control completed — 2026-11-11

The standard Active Storage direct-upload POST path now routes to
`Admin::DirectUploadsController`, which inherits Rails' upload implementation and
requires Devise authentication plus `Admin::PicturePolicy#create?` before blob
creation. The route is unconditional and precedes the engine route, so anonymous
requests cannot fall through to an unprotected engine endpoint. Existing helpers,
JSON responses, CSRF checks and public signed read routes remain supported.

Seven integration tests cover the standard and .json paths, anonymous requests
with a valid public CSRF token, non-admin rejection, successful admin allocation,
CSRF rejection/acceptance and public signed blob reads. Rejected requests do not
allocate blobs; ordinary authorization checks also assert no attachments/pictures
are created. File-type and byte-limit policy remains a separate hardening item.

Full verification: **232 tests, 833 assertions, 0 failures, 0 errors, 0 skips**,
including all 55 existing system tests and their real browser upload workflows.
RuboCop passes for the controller, routes and new integration test. No live
production requests, changes or Spaces uploads were performed.

## Publication boundaries completed — 2026-11-11

The owner confirmed hidden content must return 404. Public Page/Post HTML detail
and Post API detail now use their published scopes before FriendlyId lookup.
Public gallery listings and detail also require a published Gallery, retaining
the existing child-membership visibility filtering. Both slugs and numeric IDs
return 404 for hidden content, including for signed-in members and administrators.
Admin show/edit actions retain access to hidden records through admin URLs.

Eight integration tests cover those lookup boundaries, navigation/list/API/sitemap
exclusion, independent page menu visibility, admin access, and visible gallery
membership rendering/cover fallback. The old public-gallery success test now
explicitly publishes its otherwise-hidden fixture. The separate R3 empty-cover
issue and public signed attachment read behavior are unchanged.

Full suite: **240 tests, 896 assertions, 0 failures, 0 errors, 0 skips**, including
all 55 system tests. Focused public/controller coverage passes (19 tests,
75 assertions), as does RuboCop for all six changed Ruby files. No production data
was modified or automatically republished.

## Public rendering fixes completed — 2026-11-12

R3–R5 are resolved. The gallery index selects its cover before rendering and
omits galleries with no published picture, including empty galleries and those
whose memberships are all hidden. Existing featured/first-visible selection is
preserved. RSS publication dates use `to_fs(:rfc822)`, and gallery sitemap URLs
use the standard `<loc>` element.

No new tests were added, as requested. Manual requests inside a rolled-back local
test database transaction confirmed HTTP 200 for the empty/all-hidden gallery
index, valid RSS XML and parseable publication dates, and a namespaced sitemap
gallery `<loc>` with no `<lock>` elements. The existing suite passes: **240 tests,
896 assertions, 0 failures, 0 errors, 0 skips**, including all 55 system tests.
RuboCop passes for both modified Builder templates; `git diff --check` passes.

## Query efficiency pass completed — 2026-11-12

Revisited controllers, models, presenters, serializers, layouts, list/detail views,
policies and the installed tagging/attachment implementations. R12's seven paths
are addressed:

- Gallery covers use a PostgreSQL `DISTINCT ON (gallery_id)` association, ordered
  by visible featured first, then membership order/creation time (ID breaks exact
  ties). The index preloads only those selected memberships, pictures and image
  attachments/blobs. It does not load every gallery image to show one cover.
  Empty/all-hidden galleries remain omitted. Standalone `featured_picture` and
  `first_picture` remain individual lookups; active list rendering uses the batch
  cover association instead.
- Public HTML post lists preload `unowned_tags`. Unlike `tag_list`, this scoped
  association can use Rails' preload cache. The presenter uses it when loaded and
  retains the gem's existing `tag_list` behavior for other paths, including unsaved
  tag edits. Tagger-owned tags stay excluded, matching the original behavior.
- Admin posts preload authors; admin users preload roles. Rails' loaded collection
  `pluck(:name)` in UserPresenter uses that preload. R11's multi-role sorting and
  duplicate-user behavior remains a separate decision.
- Admin picture HTML/JSON, public picture API collections and the legacy picture
  selector relation use `with_attached_image`, including Rails' variant preloads.
- Admin gallery lookup now also loads each picture's attachment/blob for form
  thumbnails. Public gallery detail already loaded the complete rendering path.
- Link month/tag lists preload tags; archive menu routes avoid unused tag loading.

Additional improvements: removed unused author preloads from public HTML/RSS;
navigation selects only ID/title/slug/color; sitemap queries select only
ID/slug/updated_at; tag JSON endpoints pluck names without instantiating Tag models.
No response pagination, publication or authorization rules were changed.

The extra pass found no further N+1 paths in active rendering beyond these paths.
The unused version-reification UI remains R13, rather than a live performance
claim. Large root result sets in RSS, the public posts API and link lists remain
unbounded; choosing limits/pagination changes behavior and is recorded in TODO.md.
That file also records concrete cover/list/search index candidates and the plan
measurements needed before adding migrations. No schema changes were made.

Six regression tests compare SQL growth after adding distinct authors, roles,
posts/tags, pictures, galleries and memberships. Measurements clear the query
cache, exclude schema/cached events and check per-table growth, rather than fixed
whole-request totals or timings. They cover tagged routes, both picture JSON
paths, admin gallery editing, cover selection and owned-tag exclusion. Cover
traversal after preload issues zero further SELECTs, and the full membership
collection remains unloaded. Focused query checks: 6 tests, 76 assertions pass.

Full verification: **246 tests, 972 assertions, 0 failures, 0 errors, 0 skips**,
including all 55 system tests. RuboCop passes for all 16 changed Ruby files;
`git diff --check` passes. No production queries or schema changes were performed.
