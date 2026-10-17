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
| System tests | Existing Minitest unit/controller/integration-style coverage; no system test harness | Add browser infrastructure and progressively cover public/admin behavior before replacing it |

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
`node_modules` load path and public theme tokens. Both packs compile successfully
(21 warnings); the restarted asset server returns HTTP 200 for its manifest with
admin/application entrypoints. Browser rendering remains unverified. Attempting
`bundle exec rails test` stops before tests run at the existing
`Webpacker.compile` call in `test/test_helper.rb:26` (NameError).

`Dockerfile` installs JavaScript dependencies under `/portfolio`, but both `web`
and `shakapacker` bind-mount `.:/portfolio` in `docker-compose.yml`. The checkout
currently has no `node_modules` directory. The mount therefore hides dependencies
installed in the image, which is the leading explanation for the reported missing
`/portfolio/node_modules/.bin/webpack`. Webpack is already declared in
`package.json` devDependencies; first verify dependency visibility and installation.

- [ ] Inspect the running service mounts and check `node_modules/.bin/webpack`,
      Node/Yarn versions, installation logs and devDependency inclusion inside
      the Compose service. Do not print `.env` contents or credentials.
- [ ] For the immediate recovery, install the locked JS dependencies through the
      Compose service into the mounted checkout, or implement a container-managed
      dependency volume shared by web and Shakapacker. Choose one documented model;
      account for volume initialization and refresh after lockfile changes.
- [ ] Reconcile Yarn Classic's `packageManager` pin (`1.22.22`) with Dockerfile's
      `YARN_VERSION=latest`, `yarn set version`, and `--immutable` install option.
      Use install flags belonging to the selected Yarn version and preserve the lock.
- [ ] Restart Shakapacker; verify webpack executable, successful compilation,
      browser access on port 3035 and web-container access via service DNS.
- [ ] Verify `config/shakapacker.yml` host/WebSocket settings from the browser;
      retain the current stack until parity is established.

### Rails, data and initial tests

- [ ] Verify Ruby/Bundler/Node versions against `.tool-versions`, `.ruby-version`,
      `Gemfile.lock` and Dockerfile; build and boot web and supporting services.
- [ ] Document required environment variable names from `config/database.yml`
      and Compose in a safe example file. Confirm test DB host/user are valid
      from inside Docker (the fallback host is localhost).
- [ ] Prepare development and isolated test databases without replacing existing
      local data. Inspect `db/seeds.rb` and `db/fixtures/` before using seeds;
      document a safe local admin account setup and representative content.
- [ ] Confirm local Active Storage uses `storage/` and libvips can generate variants;
      provide local sample attachments without depending on production S3.
- [ ] Check `bin/setup`'s dependency failure handling and selected package manager.
      Choose/document Compose as the initial launch path; reconcile `bin/dev`
      with its referenced but absent `Procfile.dev` when supporting that path.
- [ ] Reconcile the legacy `Webpacker.compile` in `test/test_helper.rb` with the
      installed Shakapacker interface and test pack preparation; run the suite.
- [ ] Verify `/up`, `/`, a post, a CMS page, `/pictures`, picture detail, `/links`
      (all/year/month/tag variants), `/contact`, `/posts.rss`, `/sitemap.xml`,
      and authentication pages. Use `config/routes.rb` as the route inventory.
- [ ] Exercise contact submission and confirm mail in Mailcatcher; check
      invalid form redisplay. Record only encountered startup/upgrade failures.

## 2. Restore admin loading and current frontend parity

- [ ] Check `/login`, logout, reset-password flow, authenticated `/admin`, account
      show/edit and authorization-dependent navigation using local test accounts.
- [ ] Visit index/show/new/edit screens exposed by routes for posts, pages,
      pictures, galleries, links and users; exercise create/update/delete where
      supported, search/sort/pagination, validation redisplay and version UI.
- [ ] Verify JSON requests used by widgets: `/admin/pictures`, `/admin/tags.json`,
      and relevant `/api/v1/*` routes. Preserve contracts during later replacements.
- [ ] Capture reference screenshots from master in a separate checkout/environment
      or from production for read-only public pages. Obtain safe admin references
      locally or from supplied screenshots; do not modify production for comparison.
- [ ] Compare identical content and viewport sizes, including narrow screens,
      long text, empty lists, validation messages, logged-in public navigation,
      and images. Record intentional differences before approving parity.
- [ ] Follow `app/javascript/packs/{application,admin}.js` through application,
      admin and shared entrypoints. Verify Sass import resolution against the
      installed `@materializecss/materialize` fork: stylesheet entrypoints still
      reference `~materialize-css/...`. Choose a consistent compatibility approach.
- [ ] Inspect build output for Sass/import warnings; check variables, typography,
      grid, headers, form labels, buttons, tables, pagination, dialogs and flashes
      in `app/javascript/{application,admin,shared}/stylesheets/` and Haml views.
- [ ] Verify pack paths in both layouts and helpers, icon/font URLs, GLightbox,
      syntax highlighting and static images, including production compilation.
- [ ] Include stored HTML/CSS/JavaScript in posts/pages in parity fixtures;
      `app/presenters/concerns/front_end.rb` renders content-specific styling/scripts.
      Preserve their behavior as CSS and navigation change later.

## 3. Verify all existing React features

- [ ] Inventory active mounts in `admin_form_builder.jsx`, `galleries/index.js`
      and `pictures/index.js`; identify inactive components separately (tag-list
      mounting is commented out). Do not reintroduce inactive features by default.
- [ ] Picture selector (`components/picture_selector*`): open/close/reopen,
      load pictures, select an image, overlay behavior, insertion into editors
      and selection in galleries.
- [ ] Ace (`admin_form_builder.jsx`, `app/builders/admin_form_builder.rb`): check
      every used mode/theme, initial values, editing, textarea synchronization,
      save/reload, validation redisplay, and inserted picture markup.
- [ ] Verify Ace JS/CSS worker URLs and MIME types; retain the existing
      `ace-builds/webpack-resolver`/`file-loader` fix until its replacement works.
- [ ] Image upload/list (`pictures/index.js`, components, actions and reducer):
      file selection/drop, Active Storage direct upload, list update and persisted
      picture; check visible validation/upload failures and CSRF behavior.
- [ ] Gallery manager: add/remove/reorder, visibility/featured flags, submitted
      nested fields and persisted ordering after reload. Exercise React DnD.
- [ ] Check mount timing, browser support for current deferred initialization,
      duplicate initialization and console/network errors during these scenarios.

## 4. Establish browser coverage and continuous checks

- [ ] Add Capybara/Selenium dependencies, `test/application_system_test_case.rb`
      and `test/system/`; choose browser placement and driver/app-host settings
      compatible with Compose and later CI. Provide test assets and libvips.
- [ ] Start with public navigation, login, an admin edit/save, image selection and
      Ace persistence; add upload and gallery reordering before replacing React.
- [ ] Expand to all public route behaviors in phase 1 and all supported admin
      actions in phase 2, including permission denial, invalid input, session and
      password flows. Keep API/feed assertions in request tests where appropriate.
- [ ] Use deterministic local fixtures and attachments, test mail delivery and
      isolated databases/storage; keep external SMTP/S3 out of routine tests.
- [ ] Assert meaningful persisted results, not only rendered elements. Capture
      screenshots and browser logs on failure; keep visual parity review separate
      from functional assertions.
- [ ] Add CI (no `.github` workflow exists in this checkout) for locked installs,
      database preparation, existing tests, system tests and production asset build.
      Define one documented command set for each upgrade gate.

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
