# Rails 8 upgrade TODO

## Scope and baseline

Preserve this application and its history. First restore the existing public and
admin experience using the current stack; then replace frontend technologies in
small, independently verifiable steps. General bug finding and code review are
outside this plan. Address failures encountered while bringing up or migrating
the application, and record unrelated work separately.

Owner's styling direction (2026-11-07): prioritize functional, conventional
Tailwind admin/forms over visual parity. Keep public custom CSS small; the owner
will convert it to utilities and polish the design later. Resolve routine markup
choices directly, but pause and ask when a translation/design choice is unclear.

Assessment: 2026-10-16, branch `rails_8_upgrade`, commit `2fad994`; production
reference: local `master` at `dcbf028`. Implementation status below is based on
source and git history, not a running browser or passing test suite. No dependency
installation, database operations, containers, or tests were run for this assessment.
Version numbers describe this checkout; “latest” must be resolved when updating.

The history starts in June 2011. This upgrade began in April 2025 and already
includes Rails/configuration updates, Webpacker → Shakapacker, maintained
Materialize, React mounting and DnD changes, and visual/Ace fixes through June 2025.
Retain those changes as the starting point.

## Status against the proposed plan

| Workstream | Existing implementation | Remaining work |
| --- | --- | --- |
| Public startup | Rails 8.0.2, Ruby 3.4.2, application pack and public layout retained; asset paths and date formatting updated | Restore executable dependencies, boot, visit all public routes with representative content |
| Admin startup | Admin pack/layout retained; Ransack allowlists added | Verify authentication, dashboard, all admin screens and dependent JSON requests |
| Rendering parity | Materialize fork installed; header, footer, classes, Sass and image paths partly adjusted | Compare desktop/mobile screenshots against master; validate both stylesheet entrypoints |
| React and Ace | React/ReactDOM 19.1.0; createRoot, modern DnD API, deferred DOM access, Ace webpack resolver added | Exercise every active widget, persistence and worker requests in a browser |
| Dependencies | Broad April/May 2025 updates; explicit gem pins and Yarn lockfile | Resolve current supported versions, update in bounded groups, remove replaced dependencies |
| Import maps / default assets | Proposed gems commented in Gemfile; packs still own JS, CSS, images and fonts | Add Propshaft/import maps and migrate asset consumers; remove Shakapacker after last consumer |
| Stimulus / Turbo | Gems commented; no controllers or importmap configuration | Replace active React widgets and Rails UJS behavior; add navigation lifecycle handling |
| Tailwind | Not installed; Materialize styles and classes throughout | Establish CSS build, replace components/templates and legacy stylesheet dependencies |
| Rails configuration | load_defaults 8.0, autoload_lib, environments, Puma, health route and Solid config/schema files added | Compare with selected Rails template; complete runtime wiring and preserve intentional customizations |
| Development Docker | Ruby/Node/Postgres images and Compose services updated | Fix dependency visibility now; later align with wishlist setup |
| Production Docker | Dockerfile partly resembles generated template but still builds/runs development | Create production build/runtime path and verify assets, services, storage, migration and release workflow |
| System tests | Wishlist-compatible remote Firefox harness and 27 system tests now cover principal public/admin flows and React widgets | Expand remaining validation/error cases and verify the new CI workflow on GitHub |

## Sequence and acceptance rules

Agreed sequence: restore local startup and the existing frontend; establish initial
system tests before replacements; replace React widgets incrementally while
Shakapacker remains; resolve Sass compilation and Ace worker delivery before
removing webpack. Update retained dependencies in compatible groups throughout.

- [ ] Work in small commits: local boot → existing tests/public/admin smoke tests →
      rendering/widget parity → migration slices → production readiness.
- [ ] Run the existing suite at the first runnable baseline, record failures and
      distinguish pre-existing failures from regressions. Resolve upgrade-related
      blockers before progressing; do not describe an unrun suite as passing.
- [ ] Add system coverage while restoring functionality, then expand it before
      each replacement. Do not defer all browser tests until the final phase.
- [ ] For each subsequent slice, run `bin/rails test`, affected system tests and
      the relevant asset build. Run the complete system suite at phase boundaries.
- [ ] Keep a working development boot and production-mode asset build at each
      asset transition; a working dev server alone is insufficient.
- [ ] Avoid a blanket update of libraries about to be removed. Update retained
      dependencies early in compatible groups; update/remove migration-only
      dependencies as needed and do a final currency pass at the end.

## 1. Restore local startup on the existing stack

### Shakapacker executable (first task)

Progress: confirmed the bind mount hid webpack. Added a shared `node_modules`
volume for web/Shakapacker and verified it initializes from the existing image:
webpack 5.99.7 is executable and both services restart. Pinned Dockerfile Yarn
to 1.22.22 and switched to `--frozen-lockfile`; that image change still needs a
rebuild verification. README documents dependency-volume refresh commands.
Materialize Sass imports are now updated for the scoped package, its renamed
`colorFunc` helper, and current component/module structure. Added the Sass
`node_modules` load path and public theme tokens. Migrated application Sass to
modules and removed unnecessary global assignments; both packs now compile without
Sass warnings, with matching compiled CSS declarations and fewer duplicate rules.
Removed the blanket global-builtin warning suppression and restarted Shakapacker.
The asset server returns HTTP 200 for its manifest with admin/application
entrypoints. The home page loads according to manual verification by the owner;
full visual parity remains unverified. Test startup is now fixed by replacing
`Webpacker.compile` with `Shakapacker.compile` in `test/test_helper.rb:26`.
On 2026-10-17, `docker compose exec web bundle exec rails test` completed:
156 tests, 285 assertions, 31 failures, 13 errors, 0 skips (seed 50011).
These are individual test failures/errors rather than a suite startup exception.
The run also reports a missing Node `css` module and a Pundit deprecation;
investigating/fixing the remaining test results is separate follow-up work.

`Dockerfile` installs JavaScript dependencies under `/portfolio`, but both `web`
and `shakapacker` bind-mount `.:/portfolio` in `docker-compose.yml`. The checkout
currently has no `node_modules` directory. The mount therefore hides dependencies
installed in the image, which is the leading explanation for the reported missing
`/portfolio/node_modules/.bin/webpack`. Webpack is already declared in
`package.json` devDependencies; first verify dependency visibility and installation.

- [x] Inspect the running service mounts and check `node_modules/.bin/webpack`,
      Node/Yarn versions, installation logs and devDependency inclusion inside
      the Compose service. Do not print `.env` contents or credentials.
- [x] For the immediate recovery, install the locked JS dependencies through the
      Compose service into the mounted checkout, or implement a container-managed
      dependency volume shared by web and Shakapacker. Choose one documented model;
      account for volume initialization and refresh after lockfile changes.
- [x] Reconcile Yarn Classic's `packageManager` pin (`1.22.22`) with Dockerfile's
      `YARN_VERSION=latest`, `yarn set version`, and `--immutable` install option.
      Use install flags belonging to the selected Yarn version and preserve the lock.
- [x] Restart Shakapacker; verify webpack executable, successful compilation,
      browser access on port 3035 and web-container access via service DNS.
- [x] Verify `config/shakapacker.yml` host/WebSocket settings from the browser;
      retain the current stack until parity is established.

### Rails, data and initial tests

- [x] Verify Ruby/Bundler/Node versions against `.tool-versions`, `.ruby-version`,
      `Gemfile.lock` and Dockerfile; build and boot web and supporting services.
- [x] Document required environment variable names from `config/database.yml`
      and Compose in a safe example file. Confirm test DB host/user are valid
      from inside Docker (the fallback host is localhost).
- [x] Prepare development and isolated test databases without replacing existing
      local data. Inspect `db/seeds.rb` and `db/fixtures/` before using seeds;
      document a safe local admin account setup and representative content.
- [x] Confirm local Active Storage uses `storage/` and libvips can generate variants;
      provide local sample attachments without depending on production S3.
- [x] Check `bin/setup`'s dependency failure handling and selected package manager.
      Choose/document Compose as the initial launch path; reconcile `bin/dev`
      with its referenced but absent `Procfile.dev` when supporting that path.
- [x] Reconcile the legacy `Webpacker.compile` in `test/test_helper.rb` with the
      installed Shakapacker interface and test pack preparation; run the suite.
- [x] Verify `/up`, `/`, a post, a CMS page, `/pictures`, picture detail, `/links`
      (all/year/month/tag variants), `/contact`, `/posts.rss`, `/sitemap.xml`,
      and authentication pages. Use `config/routes.rb` as the route inventory.
- [x] Verify the intentionally disabled contact behavior: submissions render thanks
      without validation or mail. Keep it disabled; any future re-enabling is a
      separate decision after the low-priority spam-prevention investigation.

Verification on 2026-10-17:

- Built and booted web/Shakapacker images; Ruby 3.4.2, Bundler 2.6.2,
  Node 23.9.0 and Yarn 1.22.22 match the pins. Postgres/mail/pgAdmin remain up.
- `.env.example` documents local settings; actual development/test connections
  use separate databases (`portfolio_development` / `portfolio_test`) on `db`.
  Both have no pending migrations; `bin/setup --skip-server` completes.
- Setup uses create/migrate rather than automatically running historical SeedFu
  seeds. Locked Yarn install now fails fast. `Procfile.dev` supplies the previously
  missing native launcher configuration; Compose is the verified workflow.
- Added and ran `development:sample_data`: one author (not admin), page, post,
  picture, gallery/membership and tagged link. Repeated runs retain those counts.
  Historical fixed-ID seeds were inspected but not executed; existing data was
  not reset. README explains separate local admin creation with a prompted password.
- Local disk storage and libvips 8.14.1 verified. Sample 100/500 px variants process
  and the gallery image returns HTTP 200 (`image/jpeg`), without S3 access.
- HTTP 200: `/up`, `/`, `/posts/local-demo-post`, `/local-demo-page`, `/pictures`,
  `/pictures/local-demo-gallery`, `/links`, `/links/2025`, `/links/2025/5`,
  `/links?tag=local-demo`, `/contact`, `/posts.rss`, `/sitemap.xml`, `/login`,
  `/reset-password`, and `/update-password?reset_password_token=local-smoke`.
  Password edit without a token redirects to login as expected.
- Fixed an encountered auth-page loading blocker: legacy password views called
  uninstalled Simple Form and missing translations. They now use Rails form helpers
  and local translations; invalid submissions redisplay with HTTP 422.
- Contact remains intentionally disabled in `ContactController#create`: valid and
  invalid submissions both render thanks (HTTP 200), and Mailcatcher receives no
  messages. The owner confirmed this was intentional because of spam; preserve the disabled
  form handling. Do not treat it as verified working mail delivery.
- Existing suite rerun: 156 tests, 285 assertions, 31 failures, 13 errors, 0 skips,
  matching the previous baseline counts. Failures remain deferred. HTTP checks
  do not establish browser interaction or visual parity.

## 2. Restore admin loading and current frontend parity

The owner considers the current appearance close enough for this phase. Remaining
unchecked visual/reference/control-state checks below are deferred to the owner
for manual review; exact master parity is not a release requirement because
Tailwind and markup changes are planned before merging/releasing.

- [x] Check `/login`, logout, reset-password flow, authenticated `/admin`, account
      show/edit and authorization-dependent navigation using local test accounts.
- [x] Visit index/show/new/edit screens for posts, pages, pictures, galleries,
      links and users; exercise create/update/delete, search/sort/pagination and
      validation redisplay with temporary local records.
- [x] Check version UI status: legacy partials exist in `app/views/shared/admin/versions/`
      but are not rendered by the current admin views. There is no active version
      UI to compare. Do not introduce a new restore/revert feature during parity work.
- [x] Verify widget JSON requests (`/admin/pictures.json`, `/admin/tags.json`) and
      `/api/v1/pictures`, `/api/v1/posts`, `/api/v1/tags` return successfully.
- [ ] Finish full master/runtime reference screenshots. Initial same-content style
      references are captured using master SCSS + its pinned Materialize 1.0.0 on
      the current markup. This isolates CSS regressions but does not validate
      master Ruby/JS behavior. No production/admin data was changed.
- [ ] Finish visual comparison across every screen and state (long content, empty
      results, validation, logged-in public navigation, images, responsive dialogs).
      Initial 1440px/390px comparisons cover home, contact, post list/new and new
      picture screens; full visual parity is not yet established.
- [x] Trace public/admin/shared packs and resolve Sass against the installed
      `@materializecss/materialize` fork. Legacy import paths are removed.
- [ ] Complete the rendering checklist for all Materialize controls. Initial
      compatibility styles restore legacy columns, form spacing/labels, button
      sizing/colors, link colors, admin typography/navbar colors and white pages.
      Keep the branch's responsive header sizing and cover wrapped mobile nav links.
      Datepicker/select/dialog/focus states and remaining screen comparisons still
      need broader review.
- [x] Verify pack helpers, shared icon/font requests and GLightbox in the browser;
      production-mode packs compile. Prism is a dependency but has no active
      initialization in current application code; do not add new highlighting
      behavior as part of restoring existing wiring.
- [x] Check stored HTML/CSS/JavaScript with temporary page/post rendering fixtures
      through `app/presenters/concerns/front_end.rb`; stored CSS applies and scripts
      execute. This checks rendering, not the separate CSS/JS validators.

Verification and changes on 2026-10-17:

- Fixed the React picture-list mount target and slug-based admin user lookup.
- Completed explicit Ransack attribute/association allowlists for existing form
  filters and sorting, including user/role sorting; no credential fields exposed.
- Corrected delete flash translation keys (`destroy` rather than `delete`).
- Blank password fields no longer prevent account/user profile edits; admin role
  checkbox selections are now permitted and covered by a regression test.
- Browser CRUD checks pass for all six resource types, including 303 redirects,
  persisted edits and deletion. Sorting/date ordering and second-page requests
  return HTTP 200. Regression tests also assert compound filters/role filtering.
- Browser checks confirm account edits, logout and signed-out redirects. Password
  recovery is captured by local Mailcatcher, completed, and the new password works
  in a fresh session. Ordinary members receive 403 on protected resource pages;
  their navigation shows only Admin Home, Site Home, My Account and Logout.
- Image selector opens and inserts an image; uploader and picture table mount;
  gallery lightbox opens, icons load, and inspected pages have no unexpected
  JavaScript/network errors. Deeper widget behavior remains in section 3.
- Screenshots/metrics are in gitignored `tmp/upgrade-parity/`, including initial
  master-style references and final desktop/mobile admin post screenshots. The
  comparison uses the same local content and upgraded markup; it is not a full
  boot of master. Temporary tooling/dependencies live only in the container.
- Temporary browser-check accounts and content were removed afterward; the local
  sample author, post, page, picture, gallery and link remain unchanged.
- Development packs compile without Sass warnings. Production-mode compilation
  passes with three webpack bundle-size/performance warnings. Development assets
  were restored afterward (the manifest is shared even with a temporary output path).
- Seven focused integration tests in `test/integration/admin_upgrade_test.rb`
  pass (26 assertions). Full suite: 163 tests, 341 assertions, 31 failures,
  7 errors, 0 skips. Remaining pre-existing test failures stay deferred.

## 3. Verify all existing React features

- [x] Inventory active mounts in `admin_form_builder.jsx`, `galleries/index.js`
      and `pictures/index.js`; identify inactive components separately (tag-list
      mounting is commented out). Do not reintroduce inactive features by default.
- [x] Picture selector (`components/picture_selector*`): open/close/reopen,
      load pictures, select an image, overlay behavior, insertion into editors
      and selection in galleries.
- [x] Ace (`admin_form_builder.jsx`, `app/builders/admin_form_builder.rb`): check
      every used mode/theme, initial values, editing, textarea synchronization,
      save/reload, validation redisplay, and inserted picture markup.
- [x] Verify Ace JS/CSS worker URLs and MIME types; retain the existing
      `ace-builds/webpack-resolver`/`file-loader` fix until its replacement works.
- [x] Image upload/list (`pictures/index.js`, components, actions and reducer):
      file selection/drop, Active Storage direct upload, list update and persisted
      picture; check visible validation/upload failures and CSRF behavior.
- [x] Gallery manager: add/remove/reorder, visibility/featured flags, submitted
      nested fields and persisted ordering after reload. Exercise React DnD.
- [x] Check mount timing, browser support for current deferred initialization,
      duplicate initialization and console/network errors during these scenarios.

Verified on 2026-10-19 using temporary local records and Chromium:

- Active mounts: Ace + picture inserters in `admin_form_builder.jsx`, gallery
  manager/DnD/checkboxes in `galleries/index.js`, and upload/list/Redux in
  `pictures/index.js`. Tag-list mounting remains commented out and inactive.
- Selector opens/reopens, loads images, closes with its button/Escape/overlay,
  inserts valid HTML including alt text, and displays fetch failures. The close
  control now has a real handler and sits above the modal body.
- Ace selectors mount from the editor-ready callback rather than idle timing;
  DOM readiness handles both already-loaded and loading documents, with one-shot
  event listeners. Inserted HTML is serialized through a DOM image element.
- Used modes are RHTML/CSS/JavaScript with the GitHub theme; loaded HTML/text modes
  also switch successfully. Values synchronize with submitted textareas and survive
  save/reload and invalid-form redisplay. CSS/JS worker scripts return HTTP 200 with
  JavaScript MIME types; JavaScript syntax errors produce worker annotations.
- File selection, multiple files and drag/drop upload successfully, update the
  Redux picture table and persist on reload. Uploads send CSRF headers. Invalid
  file types, direct-upload failure, server validation and network failure display
  errors without adding invalid items to the list. JSON validation now returns 422.
- Fixed new-gallery nested membership validation (association presence rather than
  an ID that cannot exist before saving the parent), plus unsaved-membership
  timestamp serialization so validation redisplay does not crash. Added regression
  tests for valid/invalid nested gallery creation and JSON upload validation.
- Real HTML5 drag reordering changes submitted picture order. Featured/visible
  flags and order persist; removing saved and unsaved memberships works. Stable
  client keys support repeated selections of the same image without React key errors.
- Removed obsolete uploader lifecycle/debug logging and the idle-callback dependency.
  With `requestIdleCallback` unavailable, all active pages initialize; repeated
  DOM-ready events and back/forward navigation do not create duplicate roots.
- Success-path console checks are clean. The in-container browser needed a temporary
  TCP forward for localhost:3035 to the separate asset container; host-browser
  Compose configuration was left unchanged. Chromium was exercised; other browser
  engines and touch dragging remain candidates for later system-test coverage.
- Editor saves exposed a missing runtime `css` parser dependency. Added its pin,
  passed CSS through stdin instead of embedding it in a shell command, and added
  a quoted-CSS regression test. Node/parser failures now produce validation errors.
  Retain this Node runtime requirement when retiring Shakapacker, or replace the
  validator separately; removing bundling alone will not remove it.
- Focused checks: 13 tests, 38 assertions, no failures/errors. Full suite:
  167 tests, 351 assertions, 30 failures, 7 errors, 0 skips. Existing remaining
  failures stay deferred. Development packs compile successfully without Sass warnings.
- Browser tooling remains temporary; the reusable Rails system-test harness is
  still section 4. Temporary test accounts/content/uploads were cleaned up afterward.

## 4. Establish browser coverage and continuous checks

- [x] Add Capybara/Selenium dependencies, `test/application_system_test_case.rb`
      and `test/system/`; choose browser placement and driver/app-host settings
      compatible with Compose and later CI. Provide test assets and libvips.
- [x] Start with public navigation, login, an admin edit/save, image selection and
      Ace persistence; add upload and gallery reordering before replacing React.
- [x] Cover principal public navigation, post tag filtering/pagination, links
      year/month/tag views, gallery/lightbox, disabled contact submission, login/
      logout/password reset, permission denial, account editing, and CRUD for all
      six admin resources. Check page/gallery invalid-form recovery and user search.
- [ ] Expand remaining boundary/error cases: validation on posts/links/users/
      pictures, selector/network/direct-upload failures, password reset invalid
      inputs, permissions across resource types, and admin pagination/sort variants.
      Keep API/feed assertions in request tests. The pagination test encountered
      `/posts.rss` failing with populated posts because `index.rss.builder` still
      calls `created_at.to_s(:rfc822)`; address that alongside feed request coverage.
- [x] Use deterministic local fixtures and attachments, test mail delivery and
      isolated databases/storage; keep external SMTP/S3 out of routine tests.
- [x] Assert meaningful persisted results, not only rendered elements. Capture
      screenshots and browser logs on failure; keep visual parity review separate
      from functional assertions.
- [x] Add CI in `.github/workflows/ci.yml` for locked installs,
      database preparation, existing tests, system tests and production asset build.
      Define one documented command set for each upgrade gate.
- [ ] Verify the workflow on GitHub after pushing. The local checks below verify
      its test/build commands, not GitHub runner provisioning. Existing suite
      failures intentionally keep the job red; browser/build steps still execute.

Implemented and verified on 2026-10-28:

- Retained the owner's Wishlist remote Firefox configuration, Compose service,
  networking, sequential execution, and existing helper methods. The only addition
  to `test/application_system_test_case.rb` is requiring/including an application
  diagnostics mixin; driver configuration is unchanged. README documents startup,
  separate `test` / `test:system` commands and sequential `test:all`.
- `test/support/editor_system_test_helpers.rb` sets Ace's value through its editor
  API and asserts the synchronized Rails textarea. Complete-source typing triggers
  Ace's automatic tag completion, so setting the editor value gives exact fixtures
  while exercising its change callback. Tests persist/reopen body, CSS, JavaScript,
  gallery/link descriptions and inserted image attributes, including quoted alt text.
- `test/system/admin/` covers all resource types, dashboard navigation, account
  changes, combined-name search, filtering/sorting/empty results, delete confirmation,
  image selection, chooser uploads, drop uploads, rejected files, and simulated save
  validation responses. The normal upload requests and storage writes are real.
- Gallery coverage checks nested creation/validation, saved/unsaved removal, real
  pointer reordering, featured exclusivity and visibility persistence. Remote Firefox
  leaves the relocated source in its dragging state after the WebDriver gesture;
  the test completes the `dragend` DOM event explicitly, without modifying React state.
- Public/authentication coverage is in `public_navigation_test.rb` and
  `authentication_test.rb`. Password reset follows the delivered test email, updates
  the password and verifies login. Contact still sends no mail and enqueues no jobs.
- System tests use fixture images, the isolated test database/local storage and
  in-memory mail. `SystemTestUploads` removes blobs/attachments created by each test,
  including unattached failed uploads. Screenshots and captured console output are
  saved under `tmp/screenshots`; console capture starts after `visit`, so it is not
  a complete record of initial page-load errors. Server logs remain in `log/test.log`.
- Fixed blockers encountered by these tests: home pagination now explicitly uses
  the root route rather than generating RSS links; uploads tolerate Rails omitting
  CSRF meta tags when test forgery protection is disabled; role checkboxes are outside
  Materialize's floating text-input wrapper so labels no longer overlap.
- `rails test:system`: **27 tests, 169 assertions, no failures/errors/skips**
  (seed 10776). `rails test:all`: **194 tests, 520 assertions, 30 failures, 7 errors,
  0 skips**. The combined run retains the prior legacy failure/error counts; all
  new system tests pass together with the existing suite. Legacy repairs remain
  deferred. Hosted CI and the additional error cases above remain unverified.
- Production `assets:precompile` succeeds with the CI command and no Sass warnings.
  Existing Node/Browserslist currency and webpack bundle-size notices remain for
  the dependency/asset migration phases. Restarted Shakapacker afterward to restore
  the development manifest. The workflow YAML parses successfully.

## 5. Update retained dependencies in controlled groups

- [x] Inventory direct/transitive Ruby and JS dependencies from both manifests
      and lockfiles; classify retained, transitional and removal candidates.
- [x] At implementation time check official release notes/support requirements
      for target Ruby, Rails, PostgreSQL, Node and Yarn, and resolve what “latest”
      means: latest stable compatible releases, with major upgrades called out.
- [x] Decide explicitly whether the target is Rails 8.0 or a later Rails 8 minor;
      use that same target for the generated configuration/Docker comparison.
- [x] Update Ruby/Rails and server-side gems in testable groups; update runtime
      pins, Docker images and lockfiles together. Check Devise, Haml, Ransack,
      PaperTrail, tagging, storage and test-tool compatibility as part of updates.
- [x] Keep Shakapacker gem/npm versions synchronized while used. Update React,
      Materialize and loaders only as required for parity or the migration.
- [ ] Repeat dependency currency checks after removals; retain lockfiles only
      for the package managers still used. Record commands and tested versions.
      The current inventory/update pass is complete; repeat this check after the
      planned React/Materialize/Shakapacker removals in sections 6–7.

Implemented and verified on 2026-10-30:

- [Dependency inventory and policy](docs/dependencies/README.md) documents direct
  ownership, compatibility exceptions, upstream sources, update commands, and
  retirement plans. Its Ruby/JavaScript CSVs include every before/after locked
  package name, including transitive versions and removed packages.
- Removed all exact active gem pins. Gemfile.lock supplies exact versions;
  only Rails `~> 8.1.0` and transitional Shakapacker `~> 8.2.0` retain explicit
  compatibility ranges. Most npm declarations now use compatible-major ranges
  with yarn.lock providing exact installs. Kept the temporary UI stack's tested
  versions instead of introducing another frontend major/minor migration.
- Selected **Ruby 4.0.9, Rails 8.1.4, Bundler 4.0.23, Node 26.13.0 LTS, Yarn
  1.22.22 and PostgreSQL 17.11-bookworm**. Rebuilt web/Shakapacker, refreshed the
  stale dependency-only volume, and restarted services. PostgreSQL remains on
  major 17 and its original Bookworm OS; existing data directories were retained.
  Docker installs gems frozen and JS with `--frozen-lockfile`. Yarn is explicitly
  installed with npm instead of relying on bundled Corepack.
- Updated framework/runtime, CMS/authentication/search, and development/test gem
  groups, then refreshed compatible transitives. Major changes include Devise 5,
  PaperTrail 17 (required for Rails 8.1 support), Ransack 6, Haml 7, Git 6, Puma 8,
  Image Processing 2, Solid Cable 4, Shoulda Matchers 8 and SimpleCov 1. Added
  ruby-vips explicitly after the image backend stopped being a transitive gem.
  Updated the Pundit include, SimpleCov grouping API and Devise message assertion.
- Current `bundle outdated --parseable` reports only four explained exceptions:
  Minitest 5 is required by minitest-matchers, Prism 1 by rubocop-ast, Marcel 1 by
  Active Storage, and Shakapacker 8 is being retired. No extra direct Minitest
  constraint was needed. All other direct gems resolve to current stable releases.
- Updated compatible Babel 7, webpack 5, Sass 1, browser data and loader/tooling
  releases. Rails' Active Storage npm package now matches Rails 8.1. Ace is an
  explicit dependency because application code imports it directly. Removed unused
  webpacker-react, form-serialize, @rails/actioncable and prismjs declarations.
  Do not force Babel/Shakapacker/UI majors just to empty an outdated report.
- `config.load_defaults 8.0` deliberately remains until section 8's configuration
  review; that review now targets Rails 8.1. Solid Queue 1.7's optional batching
  migration and recurring-schedule time zone behavior are recorded for that phase.
  Production databases/queue workers were not migrated or exercised here.
- Full `rails test:all`: **194 tests, 520 assertions, 30 failures, 7 errors,
  0 skips**, matching the pre-upgrade baseline counts. All 27 system tests pass
  within that run. Focused admin checks also passed after the framework group.
  Development/test assets compile successfully without Sass warnings; production
  `assets:precompile` succeeds with only webpack size/performance notices.

Remaining deployment checks: preserve/verify production's Devise secret selection
before release, rehearse Solid database/worker configuration, and verify this new
image on hosted CI. Local password reset and asset tests are not substitutes for
those deployment checks.

Follow-up on 2026-10-31: rack-proxy 2's explicit-backend requirement caused
development `/packs/` requests to return 502 with Shakapacker 8 despite successful
compilation. Configured the backend from Shakapacker's dev-server settings in an
ordered application initializer. Added `bin/check-development-assets` and a CI
step that starts Shakapacker and checks both packs through Rails. Static system
packs had not exercised this development-only proxy path. Remove the compatibility
initializer/check when retiring Shakapacker.
Verified after restarting both application services: all 10 public/admin CSS/JS
entrypoint files return HTTP 200 with expected content types through Rails.
System suite rerun: 27 tests, 169 assertions, no failures/errors/skips (seed 39676).

## 6. Replace React and migrate asset ownership incrementally

Recommended order: add Stimulus with Shakapacker still compiling it; replace
widgets one at a time; then finish import maps and remove the bundler. If a
retained package requires bundling, resolve that before removing Shakapacker.

- [x] Add `stimulus-rails` and controllers; mount through existing packs initially
      if that gives the smallest working step. Keep old/new ownership explicit.
- [x] Replace picture selector with a Stimulus controller and server-rendered
      HTML/partial or existing JSON contract; preserve editor/gallery callbacks.
- [x] Replace React Ace with direct Ace integration in a Stimulus controller.
      Plan explicit module/theme/worker URLs; the webpack resolver cannot survive
      bundler removal. Test worker loading in production as well as development.
- [x] Replace uploader/list Redux state with Stimulus + Active Storage and Rails
      responses/Turbo updates. Preserve upload validation and list persistence.
- [x] Replace gallery manager with server-rendered nested fields and Stimulus;
      choose an import-map-compatible ordering approach with keyboard/touch
      behavior, persisted order and visibility/featured controls.
- [x] Remove React, ReactDOM, react-ace, React DnD, Redux, React Redux and related
      helpers only after checking remaining imports and passing widget tests.
- [x] Add Propshaft/importmap-rails; create `app/assets` structure,
      `config/importmap.rb`, JS entrypoints and appropriate asset paths. Migrate
      shared/public/admin images and fonts and replace layout pack helpers with
      Rails asset helpers/import-map tags. Preserve admin/public load boundaries.
- [x] Resolve browser-compatible imports for Materialize (if still present),
      GLightbox, Prism, Ace and Active Storage; pin or vendor explicit versions.
      Import maps handle JavaScript, not Sass compilation or webpack loaders.
- [x] Keep a temporary CSS build while Sass/Materialize remains, or complete
      Tailwind conversion before retiring that build. Test font/image URLs and
      content-specific assets after each move.
- [x] Add Turbo after controllers/widgets tolerate reconnects. Replace Rails UJS
      method/confirmation behavior in layouts/views with Turbo-compatible forms
      or attributes, then remove UJS. Test logout, deletes and invalid submissions.
- [x] Implement connect/disconnect cleanup for Ace, dialogs, lightboxes and other
      widgets; test navigation/back/forward, Turbo cache restoration and stored
      CMS scripts. Decide explicit opt-outs for incompatible content.
- [x] Remove Shakapacker gem/npm package, pack helpers, webpack/Babel/PostCSS
      configs and binstubs, service/port 3035 and obsolete generated packs only
      after all consumers and production builds pass through the new pipeline.

First migration slice (2026-10-31):

- Added stimulus-rails 1.3.4 and @hotwired/stimulus 3.2.2 without running an
  installer over existing entrypoints. `app/javascript/controllers/application.js`
  starts the application; `controllers/index.js` explicitly registers controllers.
  Only the admin pack imports this entrypoint for now.
- Replaced the React picture selector and its button/modal/picture components
  with `shared/admin/_picture_selector.html.haml` and
  `controllers/picture_selector_controller.js`. The existing `/admin/pictures.json`
  contract supplies the list; thumbnail requests use its same-origin path field.
  Native buttons support keyboard selection; modal Escape/button/backdrop close,
  focus restoration, Tab wrapping, disabled/loading state and visible retry errors
  remain in the controller. Disconnect aborts pending fetches and closes the UI.
- `AdminFormBuilder#picture_inserter` renders the shared partial. React Ace's
  existing ready callback and the gallery manager consume `picture-selector:select`
  events. The selector's readiness value is enabled only after those temporary
  consumers attach their listeners. The gallery selector sits outside its React
  root; its selection listener is removed when React cleans up the effect.
- Removed four obsolete selector JSX components. React Ace, gallery nested fields,
  React DnD and uploader/Redux remain for their own slices. No Turbo navigation or
  import-map/asset ownership changes have been introduced yet.
- Removed Babel's legacy `forceAllTransforms` setting: its loose class transform
  called Stimulus's native superclass as a function, preventing controller startup.
  Babel now follows the existing Browserslist targets; React remains covered by the
  same browser tests. Recompiled test assets explicitly after the config change.
- Expanded browser coverage for selector load failure/retry, actual thumbnail
  loading, keyboard selection, backdrop dismissal/focus, and cancelling a pending
  load across removal/reconnection without duplicate insertion. Existing post/page
  insertion and gallery add/reorder/remove persistence checks exercise both bridges.
  Updated builder assertions for the server-rendered control/target contract.
- Full `rails test:all`: **197 tests, 546 assertions, 30 failures, 7 errors,
  0 skips**. All 30 system tests pass within that run; legacy failure/error counts
  remain unchanged. Production assets compile successfully with the existing
  webpack size/performance notices and no Sass warnings. Targeted Ruby formatting
  checks passed after applying the repository's quote style.
- Both Docker images rebuild with frozen dependencies. After recreating web and
  Shakapacker, the development proxy check returns HTTP 200 for all 10 public/admin
  CSS/JS entrypoint files; the rebuilt image also passes frozen `bundle check`.

Direct Ace migration (2026-10-31):

- `controllers/ace_editor_controller.js` now initializes Ace directly from the
  builder's Stimulus targets/values, preserves the submitted textarea, modes,
  GitHub theme, wrapping and 300px height, and consumes picture selection events.
  Disconnect synchronizes the draft, removes selection/change listeners and
  destroys the editor/session (including workers); reconnect restores the draft.
- `lib/ace.js` imports the supported modes/theme and declares only CSS, HTML and
  JavaScript worker URLs using webpack asset modules. Removed the catch-all
  `webpack-resolver`, obsolete `admin_form_builder.jsx`, `react-ace` and its unused
  transitive dependencies. Ace now consistently uses the direct 1.45.2 dependency.
  These worker URLs still need Rails asset helpers/URLs when Shakapacker retires.
- Updated the builder contract and shared Ace system-test helper. Added browser
  checks for mode/theme setup, real CSS/JavaScript worker annotations and editor
  disconnect/reconnect with draft preservation and exactly one picture insertion.
  RHTML intentionally has no validation worker in Ace; keep that existing behavior.
- Full `rails test:all`: **199 tests, 563 assertions, 30 failures, 7 errors,
  0 skips**; all 32 system tests pass and the legacy failure/error counts are
  unchanged. The two new editor tests also pass against the minified production
  bundles using a temporary manifest override in the test process; the shared
  system-test configuration remains unchanged. Production compilation succeeds
  with the same three webpack size/performance warnings. Development entrypoint
  proxy checks and all three worker URL/MIME checks pass. Targeted Ruby formatting
  and `git diff --check` pass.

Uploader/list migration (2026-11-01):

- `controllers/picture_uploads_controller.js` handles chooser/multiple-file/drop
  uploads through Active Storage, per-file validation/errors, pending status and
  the existing 25-row limit. Each connection owns its requests: disconnect aborts
  both Active Storage XHRs and picture-save fetches, resets pending UI, and ignores
  late callbacks even after reconnect. Already-committed saves remain in Rails;
  refresh reconciles the list. Unattached-blob retention/cleanup remains a separate
  operational decision; aborting a browser request cannot roll back a completed upload.
- `admin/pictures/index.html.haml` renders upload controls and the initial table
  using `_picture.html.haml`. The partial uses existing route/policy/icon/presenter
  helpers and same-origin thumbnail paths. Timestamps now follow the existing Rails
  presenter used by other admin indexes instead of browser-local Moment formatting.
  Successful HTML/XHR picture creates return one row; validation failures return
  JSON errors. Regular HTML redirects and JSON serializer responses are preserved.
- New rows prepend to the current page, matching the old uploader. Search and
  pagination remain server-owned and refresh applies their current query/counts;
  the first upload hides the empty-list message. No Turbo dependency or system-test
  configuration changes were introduced; Turbo navigation remains a later task.
- Removed the React uploader/list components, mount, Redux actions/reducer/store,
  and now-unused direct `redux`, `react-redux`, `moment` dependencies. React/DnD
  and their remaining helpers stay for the gallery migration; DnD still brings
  its own transitive Redux dependency until then.
- Expanded picture browser coverage from five to eleven tests: thumbnails and row
  actions, direct-upload failure/retry with the same file, empty-list updates,
  page-size/search/pagination, aborting Active Storage, and rejecting stale save
  callbacks across reconnect. Added controller tests for escaped row HTML, JSON
  validation errors, and preserving JSON create responses.
- Full `rails test:all`: **208 tests, 622 assertions, 30 failures, 7 errors,
  0 skips**; all 38 system tests pass, preserving the legacy failure/error counts.
  All eleven picture tests also pass against the minified production bundles
  (64 assertions), using only a process-local manifest override. Production assets
  compile with the existing three webpack size/performance warnings; the restored
  development proxy returns HTTP 200 for all ten CSS/JS entrypoint assets. Yarn
  integrity, targeted Ruby formatting and `git diff --check` pass.

Gallery migration and remaining React removal (2026-11-01):

- `controllers/gallery_pictures_controller.js` manages Rails nested fields from
  `admin/galleries/_gallery_picture_fields.html.haml`. New selections clone a
  server-rendered template and replace its field-index placeholder; membership
  IDs, picture IDs and checkbox names remain stable through reordering. Hidden
  order values are recomputed from active rows after adding, removing or moving.
- Saved removals retain hidden `_destroy` fields, including after validation
  errors; unsaved removals delete their fields. Template defaults preserve visible
  and unfeatured selections, repeated selections have unique input/label IDs, and
  selecting Featured clears that flag on other active rows. Existing thumbnails
  and newly selected thumbnails both use same-origin paths.
- Native drag-and-drop replaces React DnD. Move up/Move down buttons provide
  keyboard and touch activation without another sorting dependency, keep focus
  on the moved control and announce position through a live status. Touch ordering
  uses buttons; native touch dragging is not required. Disconnect disables the
  selector and clears drag state; reconnect preserves draft fields and unique keys.
- Removed the final React mount, gallery components, checkbox and long-inactive
  commented tag-list component. Removed React/ReactDOM, DnD/backends, prop-types,
  immutability-helper and classnames, plus React-only Babel presets/plugins and
  JSX resolution entries. The transitive DnD Redux dependency is gone as well.
  Shakapacker/Babel remain for the current assets; no Turbo or import maps yet.
- Expanded gallery browser tests from three to seven: native drag events and
  persistence, keyboard/button moves and focus, featured exclusivity, duplicate
  selections/unique fields, validation recovery with saved removals and reordered
  additions, loaded thumbnails, and selection across reconnect. Remote Firefox
  WebDriver omits drop/drag-end after its real pointer drag-over; the test completes
  the DOM drop event, without modifying controller state or hidden fields. The
  shared Wishlist-style system-test configuration remains unchanged.
- Updated `AdminUpgradeTest` to assert the retained server-rendered nested fields
  after validation instead of the removed React JSON data attribute.
- Full `rails test:all`: **212 tests, 659 assertions, 30 failures, 7 errors,
  0 skips**; all 42 system tests pass, preserving the legacy failure/error counts.
  All seven gallery tests also pass against minified production bundles (63
  assertions), using a process-local manifest override. Production assets compile
  with the same three webpack size/performance warnings. Yarn integrity, Ruby
  formatting and `git diff --check` pass. After restoring/restarting development
  services, all ten public/admin CSS/JS entrypoint assets return HTTP 200 through
  the proxy. No React imports, dependencies or JSX entrypoints remain.

Propshaft/import-map migration (2026-11-03):

- Added unpinned `propshaft` 1.3.2, `importmap-rails` 2.2.3 and transitional
  `cssbundling-rails` 1.4.3; lockfile changes add only these gems. Public/admin
  layouts now use Rails stylesheet helpers and their own import-map entrypoints.
  Shared initialization loads Rails UJS, Materialize and flash handlers; public
  modules load GLightbox, while admin modules load Stimulus and Ace. Pins disable
  preloading so a public page does not fetch admin controllers or Ace.
- Moved images/fonts to `app/assets`, Sass to `app/assets/stylesheets`, and kept
  generated CSS in ignored `app/assets/builds`. Replaced webpack font URLs with
  Propshaft-resolved URLs, preserved shared/theme styling, and made the public
  GLightbox stylesheet explicit. Sass sources are excluded from served assets.
- `config/importmap.rb` maps Rails-gem Stimulus/Active Storage/UJS modules and
  locally vendored Materialize 2.2.2, GLightbox 3.3.1 and Ace 1.45.2 browser builds.
  `bin/vendor-assets` copies a reviewed subset from locked npm dependencies and
  records versions/licenses; fonts come from material-design-icons 3.0.1. There
  are no CDN imports. There is no active Prism import/package to migrate.
- Ace core/modes/theme load as native modules through a small global adapter.
  Root-relative `RAILS_ASSET_URL` worker references are compiled by Propshaft.
  The CSS and JavaScript syntax-checking workers execute successfully in Firefox.
  Connect/disconnect behavior and the Rails UJS transition remain covered.
- `cssbundling-rails` builds CSS for precompilation, using a frozen Yarn install
  task. `bin/setup` builds initial CSS; `Procfile.dev` and the new `css` Compose
  service watch it. CI builds/starts web + css. Test helper CSS preparation replaces
  Shakapacker compilation; the shared system-test configuration is unchanged.
- Removed obsolete pack entrypoints and JS/image/Sass import wrappers. Disabled
  Shakapacker precompilation, removed the unused proxy adapter, and moved its old
  service behind `legacy-webpack`; normal development needs no port 3035. The
  Shakapacker gem/npm packages, configs/binstubs and generated pack cleanup remain
  for the explicit removal task, together with their obsolete CSP exception.
- `bin/check-development-assets` now resolves and fetches all 43 import-map,
  stylesheet, worker, image and font assets through Rails, checking HTTP/MIME/body.
  Added system coverage for loaded fonts/local imports and public/admin module
  boundaries. Development docs explain vendoring, CSS watch/build and clearing a
  precompiled manifest before source-based development.
- Full `rails test:all`: **214 tests, 667 assertions, 30 failures, 7 errors,
  0 skips**; all 44 system tests pass, preserving the legacy failure/error counts.
  All 44 system tests also pass against the production manifest's static resolver
  (**292 assertions, no failures/errors**). Production precompilation succeeds
  without webpack or Sass warnings. Both images rebuild with frozen dependencies;
  Ruby formatting and `git diff --check` pass. After clearing generated production
  assets, rebuilding the CSS outputs cleared by clobber, and restarting Rails, the 43-asset HTTP/MIME check passes again in source
  development mode. Hosted GitHub CI remains unverified locally.

Turbo Drive and UJS replacement (2026-11-06):

- Added `turbo-rails` 2.0.23 without a Gemfile constraint, using its local
  `turbo.min.js` import-map pin. Replaced UJS startup and removed its npm dependency.
  Logout and delete links use Turbo method/confirmation attributes; the existing
  Devise 422/303 responses support normal Turbo form submissions. Updated the
  server-rendered picture-row assertion for its Turbo delete attribute.
- Both layout stylesheets are tracked for reload, maintaining public/admin module
  boundaries. A tracked current-user meta tag also creates a fresh document when
  authentication changes, including public-layout logout. Ordinary same-layout
  navigation uses Drive; browser marker tests verify it preserves the document.
- Ace's before-cache action synchronizes input and destroys the editor/worker,
  with idempotent disconnect and clean mount markup. Selectors close and abort
  loading; upload operations abort without leaving pending UI; gallery fields
  keep their values/keys and clear drag state. Stimulus reconnects fresh instances
  on restored snapshots. Materialize instances are destroyed before cache/render
  and reinitialized on load. GLightbox closes synchronously on teardown and opens
  normally after restoration. Flash handling delegates once, and flash markup is
  temporary so old success/error messages do not return on Back.
- `cms_requires_full_reload?` conservatively detects public page/post script fields
  and inline body scripts, including post-index content. Those responses require
  a fresh document, opt out of caching, and use full outgoing navigation, preserving
  stored globals/DOMContentLoaded behavior. This does not disable Drive for normal
  content. The intentionally disabled contact form explicitly opts out of Turbo
  to preserve its inert 200 thanks response without adding mail, jobs or endpoints.
- Added nine browser tests covering document-preserving navigation, editor drafts
  and one-time picture insertion after Back, gallery flags/order/selection through
  Back/Forward, aborted uploads and retry, lightbox restoration, Materialize select
  restoration, cancel/confirm delete, layout/authentication reloads, and field/body
  CMS scripts. Logout tests now wait for its asynchronous response before making
  another visit. Shared Wishlist-style system-test configuration is unchanged.
- Full `rails test:all`: **223 tests, 756 assertions, 30 failures, 7 errors,
  0 skips**; all 53 system tests pass, preserving the legacy failure/error counts.
  All 53 system tests also pass against the precompiled production manifest
  (**381 assertions, zero failures/errors**). Production assets compile without
  Sass/webpack warnings; both locked Docker images build successfully. Ruby
  formatting and `git diff --check` pass. After clobbering production output,
  rebuilding CSS and recreating web/css, all 43 asset URLs pass the development
  HTTP/MIME check with Turbo in place of UJS.

Shakapacker removal (2026-11-06):

- Removed Shakapacker from Gemfile/lock along with its unused `package_json`,
  `rack-proxy` and `semantic_range` dependencies; retained gem versions are unchanged.
- Removed 29 direct npm webpack/Babel/PostCSS build-tool dependencies, including
  loaders, extraction/minification/compression/manifest plugins, types and browser
  data. Removed package.json's Babel/Browserslist config. Locked npm package/version
  pairs drop from 814 to 265; no new package versions were introduced. Retained
  Sass, browser-vendoring, runtime validator and existing lint dependencies.
- Deleted `config/shakapacker.yml`, `config/webpack/webpack.config.js`, root
  `babel.config.js`/`postcss.config.js`, and both Shakapacker binstubs. Pack helpers
  and JS pack entrypoints had already been replaced by Propshaft/import maps.
- Removed the legacy Compose service/container and its host/port environment
  settings. Dropped port 3035/WebSocket exceptions from the development CSP while
  preserving the remaining self/HTTPS connection policy. Removed obsolete pack
  ignore entries and cleared generated `public/packs`, `public/packs-test`,
  `tmp/shakapacker` and `tmp/shakapacker.lock` only; database/uploads are preserved.
- Updated current setup/dependency documentation and verification commands. Dated
  inventory CSVs and earlier migration notes remain historical records.
- Full `rails test:all`: **223 tests, 756 assertions, 30 failures, 7 errors,
  0 skips**; all 53 system tests pass, preserving the legacy failure/error counts.
  Production assets compile successfully through Propshaft/Sass. Both images build
  with frozen dependencies, and the recreated services pass Bundler/Yarn integrity
  checks. Rails boots without Shakapacker or proxy middleware; webpack, Babel and
  PostCSS cannot resolve from node_modules, while the CSS validator's parser works.
  After clearing production output and rebuilding CSS, all 43 asset URLs pass
  HTTP/MIME checks in development. Ruby formatting and `git diff --check` pass.
  No application behavior or shared system-test configuration was changed.

Next slice: replace Materialize with Tailwind. Keep the working Sass build until
its remaining styles have moved.

## 7. Replace Materialize with Tailwind

- [x] Choose a Rails-integrated Tailwind build (for example `tailwindcss-rails`)
      and document its build/watch processes. Compare default Rails asset handling
      with this deliberate CSS framework addition.
- [x] Inventory Materialize markup and initialization in layouts, admin CRUD
      views, Devise forms, pagination, shared flashes and `AdminFormBuilder`;
      include helper/form-builder/Stimulus classes; React has already been removed.
- [x] Establish spacing, typography, colors, responsive layout, focus, forms,
      buttons, tables, dialogs and icon treatment before converting screens.
- [x] Convert public/shared screens and admin sections in bounded slices; follow
      the owner's functional-first Tailwind direction rather than visual parity.
- [x] Replace Materialize JS interactions with Stimulus/native elements; Tailwind
      provides styling rather than dialog/dropdown/form behavior.
- [x] Replace document-level flash handlers in `app/javascript/flash_messages.js`
      with a small Stimulus controller and actions on each flash message in
      `app/views/shared/_flash_messages.html.haml`, following the Wishlist approach.
      Preserve dismissal/animation behavior and `data-turbo-temporary` so dismissed
      or cached flashes do not reappear.
- [x] Address dynamically built classes in helpers and database-stored content:
      configure explicit sources/class inclusion or retain ordinary scoped CSS.
      Check Tailwind reset effects on CMS content and Ace.
- [x] Remove Materialize Sass imports, AutoInit, obsolete variables/overrides and
      dependencies after the last consumer. Remove Sass tooling if no longer used;
      keep small custom CSS where it serves existing content or widgets.

Implementation (2026-11-07):

- Added `tailwindcss-rails` 4.7.0 / standalone `tailwindcss-ruby` 4.3.4, replacing
  cssbundling-rails, Sass, and the Node CSS scripts. The `css` Compose service and
  Procfile use Tailwind watch; setup/test/production tasks build its standard input
  into ignored `app/assets/builds/tailwind.css`. Kept the Wishlist system-test
  configuration unchanged.
- Admin uses slate/white surfaces, blue primary and red destructive actions,
  wrapping navigation, responsive search grids, scrollable tables and explicit
  typography/spacing utilities. Reused AdminFormBuilder for CRUD/search/Devise
  fields with labels above controls, native selects/checks/file/color/date inputs,
  focus outlines and a shared utility palette. Date values submit ISO calendar
  dates; picture/gallery keys, flags/order, validation and authorization stay intact.
- Replaced font icons with labelled inline SVG actions. Selector/upload/gallery
  presentation uses utilities while retaining Stimulus hooks and cleanup. Ace is
  bordered/responsive and its internal input receives its visible field label.
- Public site keeps a small ordinary stylesheet (~3.6 KB), native CMS typography,
  responsive gallery columns and existing branding; no Tailwind reset on regular
  public pages. Auth screens load Tailwind for their forms. GLightbox CSS is a
  separate unchanged vendor asset. Stored CSS/scripts and full-reload exceptions
  remain supported. Existing database Materialize-class snippets can be revisited
  manually with the owner's later public-content styling work; none were rewritten.
- Added the small shared flash Stimulus controller, binding to each message with
  a keyboard-accessible dismiss control, opacity transition/reduced-motion handling,
  timer cleanup and temporary Turbo markup. Removed document-level flash handlers.
- Explicit Tailwind source paths cover views/helpers/builders/presenters/JS; helper
  palettes use complete literal classes. Removed AutoInit, all Materialize/Sass
  source/overrides, icon fonts, animation/normalizer packages and obsolete lint/build
  tasks. Vendoring now retains only Ace and GLightbox JS/CSS with their licenses.
- Updated tests to use native controls and semantic editor/SVG assertions. Added
  mobile viewport/native checkbox and flash dismissal/restoration coverage. Logout
  tests wait for the navbar as well as the URL to avoid racing a same-URL response.
  Reviewed desktop/mobile form, user-table and public screenshots; temporary preview
  harness was removed, with images retained only under ignored tmp/screenshots.
- Validation: all 55 system tests pass against precompiled production assets
  (400 assertions). The full suite runs 225 tests / 783 assertions with the same
  30 legacy failures and 7 errors. Development and production images build;
  production asset precompilation and checks of 40 development asset URLs pass.
  All 15 changed Ruby files pass RuboCop. Restored source-based development assets
  and the running Tailwind watcher after production verification.

## 8. Complete Rails configuration alignment

Goal: match a default Rails 8.1 application as closely as possible. Keep only
configuration required by this application's code, retained gems, data/content or
Docker runtime. Historical preferences alone are not reasons to retain overrides.
Retain Haml in this phase. Deployment uses Rancher Machine, not Kamal or Thruster.

- [x] Generate an isolated reference app using this checkout's locked Rails version
      (currently 8.1.4): `rails _8.1.4_ new test_app -d postgresql --skip-kamal
      --skip-thruster --css tailwind`. Record Rails and installer/gem versions and
      actual generation options; use an isolated environment so local `.railsrc`
      options cannot silently change the baseline. Do not run `app:update` or
      overwrite this application with generator output. Generating/building the
      reference must not prepare or connect to Portfolio databases.
- [x] Compare the reference against Portfolio and the read-only Wishlist checkout
      at `/home/sean/Projects/wishlist`. The generated app is the authority for
      defaults; Wishlist illustrates justified container/production adaptations,
      rather than being copied wholesale (it also has customizations).
- [x] Record a concise file/setting inventory in `docs/rails-configuration.md`:
      generated default, current difference, proposed action and concrete reason
      for each retained exception. Classify changes as adopt default, retain
      required exception, or defer pending deployment context. Resolve consequential
      behavior choices with the owner before implementing them.
- [x] Align `config/application.rb`, boot/environment files and framework loading.
      Move `config.load_defaults 8.0` to 8.1 after reviewing the installed Rails
      upgrade notes/default changes and their effects on this existing app/data.
      Compare selective railties with generated `rails/all`; do not retain selective
      loading simply because it is historical. Preserve required Central time,
      locale loading, Pundit response mapping and application identity.
- [x] Compare development/test settings individually: reload/watch behavior,
      asset logging, redirect logging, translation errors, exception rendering,
      mail URLs, route URL defaults, caching and Docker web-console access.
      Prefer template settings unless the code/tests or container workflow require
      a difference. Keep the Wishlist-style sequential remote-browser test setup.
- [x] Audit every initializer against generated defaults and the retained gems:
      Devise, Haml, FriendlyId, Rolify, PaperTrail, parameter filtering, inflections,
      CSP and assets. Remove obsolete/redundant settings; verify whether the
      PostgreSQL database-task monkey patch is still required before retaining it.
      Keep this focused on configuration compatibility, not general code review.
- [x] Give assets/JavaScript a dedicated comparison: Propshaft's automatically
      provided paths versus `config/initializers/assets.rb`; importmap pins,
      preloading, local vendoring, controller discovery and Stimulus startup;
      `application.js`/`admin.js`/`shared.js`; layout importmap/stylesheet tags;
      Tailwind input/output/source discovery; setup/test/build/watch hooks.
      Remove redundant paths/settings and adopt standard installer conventions
      wherever possible. Verify whether separate public/admin entrypoints and
      manual controller loading remain necessary to keep Ace/admin assets off
      public pages; document any required exception rather than preserving the
      current architecture automatically. Retain working CMS script/style content,
      Turbo lifecycle cleanup and native-form behavior while simplifying setup.
- [x] Compare every `bin/*` file, executable bit, shebang and argument forwarding
      with the generated counterpart, including rails/rake/importmap/jobs,
      setup/dev/docker-entrypoint and lint/security/CI launchers. Restore default
      bodies where possible. Check legacy `bin/bundle`, extra tooling scripts,
      Foreman setup and package installation/build steps for actual necessity.
      Keep custom asset verification/vendoring scripts only where still required.
      Preserve the protection against automatically loading historical SeedFu data
      using `seeds: false` and default `db:prepare`; do not introduce `db:reset`
      or destructive bootstrap behavior for parity.
- [x] Align Puma, database configuration/pooling, Active Storage, mail and
      Solid Cache/Queue/Cable with the reference. Preserve existing database names,
      credentials interfaces, S3 attachments and persisted data. Compare schema and
      migration requirements for existing databases as well as fresh setup.
      Prefer default Solid Cable production configuration; identify operational
      prerequisites before changing the currently async production adapter.
- [x] Review Solid Queue 1.7's optional batching migration before using batching
      (`solid_queue:update`, then review the generated migration for the queue DB).
      Compare recurring-job configuration with the template, including cleanup and
      application time zone. Validate queue/cache/cable schemas and worker startup;
      rehearse migrations and real worker delivery in section 9.
- [x] Align production logging, static asset serving, SSL/proxy settings, host
      handling, health checks and mail with the template. In particular, reconcile
      the duplicate logger override and debug log default. Use Wishlist's stdout,
      reverse-proxy and runtime-environment patterns where applicable, preserving
      Portfolio's domain, S3/mail integration and exception notifications.
      Contact submission remains disabled. Record deployment-dependent decisions
      for section 9 instead of assuming Rancher/proxy details or enabling Kamal.
- [x] Apply agreed changes in small groups: Rails/environment defaults and
      initializers; assets/JavaScript; binstubs; production/data-service config.
      After each group, run relevant checks and compare to the known test baseline.
      Finish with eager loading, all system tests, production asset compilation,
      public/admin/auth/CMS/editor/upload/gallery smoke checks and development
      watch/reload/asset checks. Verify bootstrap only against disposable databases.
      Document retained exceptions and section 9 prerequisites; no production
      deployment or destructive database operations in this phase.

Implementation (2026-11-08):

- Generated an isolated Rails 8.1.4/PostgreSQL/Tailwind reference with Kamal,
  Thruster and personal railsrc options excluded. Used the installed locked asset
  and Solid installers to finish it; inspected Wishlist read-only. File/setting
  decisions and retained exceptions are in `docs/rails-configuration.md`.
- Adopted `rails/all`, 8.1 defaults, generated environment logging/watcher settings,
  Puma and CSP/assets initializers. Removed duplicate production logging/static
  serving overrides, the PostgreSQL drop monkey patch, obsolete Haml and empty
  PaperTrail initializers, and unused Rolify dynamic-shortcut configuration.
- Kept required route-host defaults (Picture URLs outside requests), Central time,
  gem/account/slug configuration, Docker mail/console access and production
  domain/S3/SMTP/exception handling. Excluded dormant `lib/ext` reopenings from
  Zeitwerk rather than activating an unrelated historical analyzer patch.
- Replaced manual controller registration with Rails-supported lazy discovery;
  restored shared/scoped preloads and removed redundant JS asset paths. Preserved
  public/admin separation, local vendor libraries, selective CSS/reset loading,
  Tailwind's Ruby source scanning and CMS/Turbo lifecycle behavior.
- Standardized dev/entrypoint/tool binstubs; removed `bin/bundle`; added generated
  native CI/audit launchers and locked bundler-audit 0.9.3. Setup/entrypoint now use
  `db:prepare`, with automatic historical seeding disabled by database configuration.
  Explicit seeding remains opt-in and automated reset/replanting remains excluded.
- Adopted production Solid Cable, default queue polling and recurring cleanup.
  Added the generated batching migration under `db/queue_migrate` and current
  fresh queue schema. On disposable databases, verified default `db:prepare`
  creates all four schemas without historical seed users, cache writes, async
  cable persistence and queue enqueueing. Separately verified migrating the old
  queue schema preserves an existing queued job.
- Validation: 55 system tests / 400 assertions pass against precompiled production
  assets; the non-system suite runs 170 tests / 383 assertions with the unchanged
  30 legacy failures / 7 errors. Updated one JSON assertion for Rails 8.1's default
  escaping and the asset assertion for controller discovery. Eager loading, image
  builds, changed Ruby lint and 41 development asset URL checks pass.
- Actual Rancher/proxy host/health checks, production database migration release
  steps, worker/recurring-job process rehearsal and mail delivery remain section 9
  work. Existing development/production data and disabled contact remain intact.

## 9. Align development and production Docker

### Development (Wishlist reference available)

- [x] Use the reviewed Wishlist Dockerfile/Compose/entrypoint as a reference;
      confirm the desired workflow before adopting its container conventions.
- [x] Align bind mounts/dependency volumes, runtime pins, database readiness,
      startup/database preparation (`seeds: false` keeps historical fixtures opt-in),
      mail, optional pgAdmin and asset watcher.
- [x] Keep test database credentials and browser-driver networking explicit;
      verify edit/reload, clean-machine bootstrap and lockfile refresh behavior.
- [x] Keep current runtime versions, Compose commands, cache/volume instructions
      and troubleshooting documented in README and `docs/docker.md`.

### Production

- [x] Build a separate production target/path using a selected Rails template:
      multi-stage dependency/asset build, lean non-root runtime, production env,
      required libvips/Postgres client libraries, and explicit entrypoint/CMD.
- [x] Reconcile `bin/docker-entrypoint` database preparation with the actual server
      command; the production Dockerfile now installs it as ENTRYPOINT.
- [x] Compile assets in the build stage with safe build-only secret handling;
      verify compilation never needs production data or exposes runtime credentials.
- [x] Update `.dockerignore` for `.env`, host dependencies and local/credential
      material; deliberately supply runtime secrets instead of copying the checkout.
- [x] Define deployment topology for web, queue workers, database and proxy;
      preserve S3 attachments, mail, exception notifications, SSL and static assets.
      Target Rancher Machine; do not introduce Kamal or Thruster.
- [x] Rehearse database backups/restores, multi-database preparation and schema
      migrations in staging, including `db:migrate:queue` for existing Solid Queue
      databases; rehearse the worker and recurring cleanup using Central time.
      Document release and rollback commands and asset
      compatibility across deploys. Do not perform destructive production changes.
- [x] Boot the built image in production mode, run `/up`, public/admin smoke and
      browser checks, contact job/mail checks and attachment variant requests.

Implementation (2026-11-09):

- Confirmed Wishlist-style development workflow: `web` runs Rails and Tailwind
  through Foreman, source at `/app`, named gem/Node dependency volumes, Mailpit,
  PostgreSQL health checks, optional pgAdmin and unchanged remote-Firefox setup.
  Kept PostgreSQL 17.11. Backed up/stopped/copied the original `tmp/db` cluster to
  a named volume and verified its logical contents match exactly; original data
  directory and private backup remain available for rollback.
- Added `Dockerfile.production` using the generated Rails multi-stage layout,
  non-root runtime, libvips/Postgres client, jemalloc and precompiled assets.
  Retained pinned Node and only the locked CSS validator's npm dependency tree
  at runtime; no JS/CSS bundler. Explicitly created writable non-root storage.
- Added a production web/worker Compose template, runtime env example and
  build-context exclusions for keys/env/dependency/data/cache files. Assets build
  without production secrets or a database. CI now builds the actual production
  image rather than compiling into development's mounted asset directory.
- Validation: 225 tests / 783 assertions, with all 55 system tests passing and the
  unchanged 30 legacy failures / 7 errors. Fresh isolated source/dependency/database
  volumes pass normal bootstrap without historical seeds; 41 development asset
  URLs and both Compose definitions pass checks.
- The actual production image passed isolated TLS browser login/admin/Ace CRUD,
  native CSS/JS validation and libvips attachment variant requests. A separate
  worker delivered a synthetic contact job to Mailpit, registered the Central-time
  recurring scheduler and executed finished-job cleanup. Four synthetic databases
  were backed up/restored under new names; content, roles, attachment references,
  cache/Cable data and queue configuration survived repeat `db:prepare`.
- `docs/docker.md` records setup, volume migration/rollback, runtime configuration,
  topology assumptions, coordinated backup/restore and release/asset retention.
  Local production checks use dummy credentials, a TLS proxy, captured SMTP and
  local attachment storage; real Spaces/Gmail access is not claimed as verified.
- Remaining unchecked production items need the current Rancher Machine stack,
  database ownership/version, proxy/network/TLS and registry details. Rehearse
  against an actual staging backup and those integrations before deployment;
  no production service, data, credentials or proxy configuration was changed.

## Context to collect as needed

- [x] Confirm which Wishlist development workflow conventions should be matched;
      its source is available read-only at `/home/sean/Projects/wishlist`.
- [x] Current production deploy/proxy/container configuration, environment variable
      names, database version and job process setup (sanitized, no secret values).
- [ ] Representative local content/attachments and safe admin access; whether
      master exactly matches deployed production, and screenshots where it does not.
- [ ] Intended visual parity versus redesign during Tailwind replacement, supported
      browsers/devices, and any CMS content relying on global Materialize/JS APIs.
- [x] Remaining Rancher Machine/proxy deployment details; Rails 8.1 is the
      configuration target and Kamal/Thruster are explicitly excluded.

## Low-priority follow-ups (after the upgrade)

- [ ] Remove Haml in a separate, low-priority pass: convert layouts/views and
      helper-generated templates to ERB, remove its initializer/gems/lint tooling,
      and verify rendering/forms with the system suite. Retain Haml throughout
      configuration alignment; do not combine template conversion with section 8.

- [ ] Investigate the current state of spam prevention for contact forms, including
      automated/LLM-assisted submissions, maintenance burden, accessibility, false
      positives and alternatives to operating a form. Keep contact submission
      disabled throughout this investigation; re-enabling it is optional and
      requires a separate decision. Document the tradeoffs and
      whether operating a form is worthwhile; do not re-enable it during research.
- [ ] **Very low priority — manual work by the owner:** revisit/rework the historical
      seeds in `db/seeds.rb`, `db/fixtures/*.rb` and their content/image files.
      Decide which historical content to retain and how to provide it locally
      without fixed-ID overwrites, shared passwords or untracked dependencies.
      Keep this out of the current upgrade; the additive development sample task
      is sufficient for now.
