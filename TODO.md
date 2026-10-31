# Rails 8 upgrade TODO

## Scope and baseline

Preserve this application and its history. First restore the existing public and
admin experience using the current stack; then replace frontend technologies in
small, independently verifiable steps. General bug finding and code review are
outside this plan. Address failures encountered while bringing up or migrating
the application, and record unrelated work separately.

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

- [ ] Inventory direct/transitive Ruby and JS dependencies from both manifests
      and lockfiles; classify retained, transitional and removal candidates.
- [ ] At implementation time check official release notes/support requirements
      for target Ruby, Rails, PostgreSQL, Node and Yarn, and resolve what “latest”
      means: latest stable compatible releases, with major upgrades called out.
- [ ] Decide explicitly whether the target is Rails 8.0 or a later Rails 8 minor;
      use that same target for the generated configuration/Docker comparison.
- [ ] Update Ruby/Rails and server-side gems in testable groups; update runtime
      pins, Docker images and lockfiles together. Check Devise, Haml, Ransack,
      PaperTrail, tagging, storage and test-tool compatibility as part of updates.
- [ ] Keep Shakapacker gem/npm versions synchronized while used. Update React,
      Materialize and loaders only as required for parity or the migration.
- [ ] Repeat dependency currency checks after removals; retain lockfiles only
      for the package managers still used. Record commands and tested versions.

## 6. Replace React and migrate asset ownership incrementally

Recommended order: add Stimulus with Shakapacker still compiling it; replace
widgets one at a time; then finish import maps and remove the bundler. If a
retained package requires bundling, resolve that before removing Shakapacker.

- [ ] Add `stimulus-rails` and controllers; mount through existing packs initially
      if that gives the smallest working step. Keep old/new ownership explicit.
- [ ] Replace picture selector with a Stimulus controller and server-rendered
      HTML/partial or existing JSON contract; preserve editor/gallery callbacks.
- [ ] Replace React Ace with direct Ace integration in a Stimulus controller.
      Plan explicit module/theme/worker URLs; the webpack resolver cannot survive
      bundler removal. Test worker loading in production as well as development.
- [ ] Replace uploader/list Redux state with Stimulus + Active Storage and Rails
      responses/Turbo updates. Preserve upload validation and list persistence.
- [ ] Replace gallery manager with server-rendered nested fields and Stimulus;
      choose an import-map-compatible ordering approach with keyboard/touch
      behavior, persisted order and visibility/featured controls.
- [ ] Remove React, ReactDOM, react-ace, React DnD, Redux, React Redux and related
      helpers only after checking remaining imports and passing widget tests.
- [ ] Add Propshaft/importmap-rails; create `app/assets` structure,
      `config/importmap.rb`, JS entrypoints and appropriate asset paths. Migrate
      shared/public/admin images and fonts and replace layout pack helpers with
      Rails asset helpers/import-map tags. Preserve admin/public load boundaries.
- [ ] Resolve browser-compatible imports for Materialize (if still present),
      GLightbox, Prism, Ace and Active Storage; pin or vendor explicit versions.
      Import maps handle JavaScript, not Sass compilation or webpack loaders.
- [ ] Keep a temporary CSS build while Sass/Materialize remains, or complete
      Tailwind conversion before retiring that build. Test font/image URLs and
      content-specific assets after each move.
- [ ] Add Turbo after controllers/widgets tolerate reconnects. Replace Rails UJS
      method/confirmation behavior in layouts/views with Turbo-compatible forms
      or attributes, then remove UJS. Test logout, deletes and invalid submissions.
- [ ] Implement connect/disconnect cleanup for Ace, dialogs, lightboxes and other
      widgets; test navigation/back/forward, Turbo cache restoration and stored
      CMS scripts. Decide explicit opt-outs for incompatible content.
- [ ] Remove Shakapacker gem/npm package, pack helpers, webpack/Babel/PostCSS
      configs and binstubs, service/port 3035 and obsolete generated packs only
      after all consumers and production builds pass through the new pipeline.

## 7. Replace Materialize with Tailwind

- [ ] Choose a Rails-integrated Tailwind build (for example `tailwindcss-rails`)
      and document its build/watch processes. Compare default Rails asset handling
      with this deliberate CSS framework addition.
- [ ] Inventory Materialize markup and initialization in layouts, admin CRUD
      views, Devise forms, pagination, shared flashes and `AdminFormBuilder`;
      include classes embedded in React while migration overlaps.
- [ ] Establish spacing, typography, colors, responsive layout, focus, forms,
      buttons, tables, dialogs and icon treatment before converting screens.
- [ ] Convert public/shared screens and admin sections in bounded slices; preserve
      the approved appearance unless a design change is explicitly agreed.
- [ ] Replace Materialize JS interactions with Stimulus/native elements; Tailwind
      provides styling rather than dialog/dropdown/form behavior.
- [ ] Address dynamically built classes in helpers and database-stored content:
      configure explicit sources/class inclusion or retain ordinary scoped CSS.
      Check Tailwind reset effects on CMS content and Ace.
- [ ] Remove Materialize Sass imports, AutoInit, obsolete variables/overrides and
      dependencies after the last consumer. Remove Sass tooling if no longer used;
      keep small custom CSS where it serves existing content or widgets.

## 8. Complete Rails configuration alignment

- [ ] Compare against a separately generated application for the selected Rails
      version, recording intentional differences. Do not run an unattended
      generator overwrite across this historical application.
- [ ] Review `config/application.rb`, environment files, Puma, initializers,
      boot/setup/dev/jobs/entrypoint scripts and asset config against that template.
      Preserve Haml, Devise, policies, time zone, locales, URL settings and storage.
- [ ] Verify Solid Cache/Queue/Cable as a complete operational choice: database
      creation/schema loading, config and worker processes. Queue/cache are wired
      in production; `config/cable.yml` currently still uses `async` there.
      Decide whether unused Cable needs a database/service rather than enabling
      everything solely because the template includes it.
- [ ] Verify contact jobs run through the intended production worker and mail
      transport; verify migrations for existing production data, not only schema
      loading on a fresh database.
- [ ] Consolidate inherited production overrides with template settings where
      appropriate (logger, static serving, SSL/proxy behavior). Validate `/up`
      through the actual proxy and retain necessary custom configuration.

## 9. Align development and production Docker

### Development (wishlist comparison pending)

- [ ] Obtain wishlist Dockerfile/Compose/entrypoint and expected workflow before
      adopting its conventions. The immediate dependency fix does not depend on it.
- [ ] Align bind mounts/dependency volumes, runtime pins, database readiness,
      startup/database preparation, mail, optional pgAdmin and asset watcher.
- [ ] Keep test database credentials and browser-driver networking explicit;
      verify edit/reload, clean-machine bootstrap and lockfile refresh behavior.
- [ ] Update README version claims (currently Ruby 2.7/Rails 6/Node 14), Compose
      commands and troubleshooting; replace obsolete Node Sass instructions.

### Production

- [ ] Build a separate production target/path using a selected Rails template:
      multi-stage dependency/asset build, lean non-root runtime, production env,
      required libvips/Postgres client libraries, and explicit entrypoint/CMD.
- [ ] Reconcile `bin/docker-entrypoint` database preparation with the actual server
      command; the current Dockerfile does not install it as ENTRYPOINT.
- [ ] Compile assets in the build stage with safe build-only secret handling;
      verify compilation never needs production data or exposes runtime credentials.
- [ ] Update `.dockerignore` for `.env`, host dependencies and local/credential
      material; deliberately supply runtime secrets instead of copying the checkout.
- [ ] Define deployment topology for web, queue workers, database and proxy;
      preserve S3 attachments, mail, exception notifications, SSL and static assets.
      Treat Kamal/Thruster as deployment choices rather than required rewrites.
- [ ] Rehearse database backups/restores, multi-database preparation and schema
      migrations in staging; document release and rollback commands and asset
      compatibility across deploys. Do not perform destructive production changes.
- [ ] Boot the built image in production mode, run `/up`, public/admin smoke and
      browser checks, contact job/mail checks and attachment variant requests.

## Context to collect as needed

- [ ] Wishlist development setup and which aspects should be matched.
- [ ] Current production deploy/proxy/container configuration, environment variable
      names, database version and job process setup (sanitized, no secret values).
- [ ] Representative local content/attachments and safe admin access; whether
      master exactly matches deployed production, and screenshots where it does not.
- [ ] Intended visual parity versus redesign during Tailwind replacement, supported
      browsers/devices, and any CMS content relying on global Materialize/JS APIs.
- [ ] Desired Rails 8 minor target and deployment constraints. These choices do
      not block restoring the currently pinned application locally.

## Low-priority follow-ups (after the upgrade)

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
