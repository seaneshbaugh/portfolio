# Dependency inventory and upgrade policy

Snapshot: 2026-10-30. This is an application: commit `Gemfile.lock` and `yarn.lock`
and use them for exact, reproducible installs. A manifest expresses compatibility;
an intentional update changes the lockfile. Unpinned gems do not automatically
update on every `bundle install`. See [Bundler's application guide](https://bundler.io/guides/using_bundler_in_applications.html)
and [Yarn Classic's version ranges](https://classic.yarnpkg.com/lang/en/docs/dependency-versions/).

The complete before/after inventories include every locked package name, not just
direct dependencies: [Ruby CSV](ruby.csv) and [JavaScript CSV](javascript.csv).
`before` is the pre-upgrade lockfile; `locked` includes all versions of that name
in the resulting lockfile. JavaScript can legitimately contain several versions
because different parents require different ranges. `latest_direct_release` was
queried from the upstream registry for direct packages; an empty cell is not a
claim that a transitive dependency is current. The lockfiles retain dependency
edges and integrity metadata. These CSVs are a dated assessment, not additional
dependency manifests to maintain on every commit.

## Runtime choices

| Component | Before | Selected | Reason |
| --- | --- | --- | --- |
| Ruby | 3.4.2 | 4.0.9 | Current stable; Wishlist already uses Ruby 4 |
| Rails | 8.0.2 | 8.1.4 | Current Rails 8 minor, matching Wishlist's 8.1 target |
| Bundler | 2.6.2 | 4.0.23 | Current stable, locked and explicitly installed in Docker |
| Node | 23.9.0 | 26.13.0 | Current LTS replaces the unsupported odd-numbered release |
| Yarn | 1.22.22 | 1.22.22 | Preserve the current lockfile/toolchain until the bundler is retired |
| PostgreSQL | 17.4 | 17.11-bookworm | Current maintenance release within the existing major and OS |

Sources: [Ruby downloads](https://www.ruby-lang.org/en/downloads/),
[Rails releases](https://rubyonrails.org/category/releases),
[Node releases](https://nodejs.org/en/about/previous-releases),
[Bundler on RubyGems](https://rubygems.org/gems/bundler),
[PostgreSQL versioning](https://www.postgresql.org/support/versioning/).

PostgreSQL 18 is a separate data migration, not an image-tag change: existing
major-version data directories require dump/restore or `pg_upgrade`. Keep that
decision with the Docker/deployment phase. The 17.11 image explicitly retains
Bookworm to avoid changing the database's OS/collation library along with this
maintenance update. No existing databases are reset or seeded by this work.

Rails now runs 8.1, but `config.load_defaults 8.0` remains deliberate. Adopt 8.1
configuration defaults individually during TODO section 8 rather than silently
changing framework behavior with the gem update.

[Solid Queue's upgrade notes](https://github.com/rails/solid_queue/blob/main/UPGRADING.md)
make the new 1.7 batching tables optional until 2.0. Add/rehearse that migration
with the queue database in section 8 before using batching. Also verify recurring
schedules there: from 1.5, unspecified zones follow the application zone rather
than the system zone. This batch does not enable new Solid features or run
production database migrations.

## Ruby ownership and constraints

| Group | Direct dependencies | Plan |
| --- | --- | --- |
| Runtime/framework | rails, pg, puma, bootsnap, solid_cache, solid_queue, solid_cable | Retain; review Solid runtime wiring in configuration/deployment phases |
| Authentication/authorization | devise, pundit, rolify | Retain |
| CMS/data | acts-as-taggable-on, friendly_id, haml, jsonapi-serializer, kaminari, paper_trail, ransack, sanitize, classnames | Retain |
| Images/storage | image_processing, ruby-vips, aws-sdk-s3, exifr, filesize | Retain; `ruby-vips` is now explicit because Image Processing 2 does not install a backend |
| Diagnostics | exception_notification, git | Retain |
| Historical seeds | seed-fu | Retain until the owner's manual seed follow-up; do not execute seeds during upgrades |
| Development | debug, brakeman, modloc, rubocop, rubocop-rails-omakase, rubocop-minitest, rubocop-performance, rubocop-rails, haml_lint, listen, web-console | Retain |
| Tests | capybara, selenium-webdriver, minitest, minitest-matchers, minitest-reporters, minitest-spec-rails, shoulda-matchers, simplecov | Retain; modernizing the legacy spec/matcher layer is separate work |
| Assets/Hotwire | propshaft, importmap-rails, cssbundling-rails, stimulus-rails, turbo-rails | Retain Propshaft/Hotwire; replace the temporary Sass build during Tailwind migration |

There are no exact active gem pins. Rails `~> 8.1.0` is the only explicit
compatibility range, keeping updates within the selected minor while defaults
and deployment configuration are aligned. Shakapacker and its proxy adapter have
been removed. `bin/check-development-assets` verifies import-map modules, CSS,
workers, images and fonts through Rails' Propshaft server.


Minitest is unpinned in the Gemfile. Bundler selects 5.27.0 because the current
`minitest-matchers` gem requires `minitest ~> 5.0`; reaching Minitest 6 requires
replacing/updating that parent, not forcing a conflicting direct version.
Similarly, RuboCop's parser requirements currently keep Prism on 1.x, and Rails
8.1 keeps Marcel on 1.x. Do not override a parent's compatibility constraints just
to make an outdated report empty.

Major retained-gem upgrades include Devise 5, Ransack 6, PaperTrail 17, Haml 7,
Puma 8, Image Processing 2, Git 6, Solid Cable 4, Shoulda Matchers 8 and SimpleCov 1.
Compatibility changes in application code are limited to Pundit's supported
authorization include, the explicit image backend, SimpleCov's renamed grouping
API, the development proxy adapter, and Devise's corrected invalid-login
capitalization in the system test.

[Devise 5's release notes](https://github.com/heartcombo/devise/blob/main/CHANGELOG.md)
change its default token secret selection to `Rails.application.secret_key_base`.
Before updating, the development instance's old Devise selection was confirmed
equal to the application key without printing either value. Retain the production
application key at deployment and verify the production selection then; local
password-reset tests cannot establish production token compatibility.

## JavaScript ownership and constraints

| Group | Packages | Plan |
| --- | --- | --- |
| Retained functionality | ace-builds, @rails/activestorage, glightbox, normalize.css, css | Keep through migration. Ace is now explicit rather than borrowed from react-ace; `css` remains a server-side Node requirement for CSS validation |
| Materialize/design | @materializecss/materialize, material-design-icons, animate.css | Retire or deliberately retain effects/icons during Tailwind work; do not couple a visual-library minor upgrade to this dependency batch |
| CSS build | sass | Transitional Dart Sass build; replace/remove with the Materialize/Tailwind migration |
| Existing lint tooling | eslint, sass-lint | Review/removal candidates: no ESLint configuration or script is currently wired; sass-lint is legacy and documented but has no newer release |

`react-ace` and its unused transitive dependencies were removed during the direct
Ace/Stimulus migration. Ace modes/theme and explicit worker URLs live in
`app/javascript/lib/ace.js`; worker URLs now use Propshaft asset references.
The direct Redux dependency, React Redux and Moment were removed with the
uploader/list replacement; Rails now renders picture rows and timestamps, while
Stimulus handles uploads. The gallery migration subsequently removed the remaining
React/ReactDOM, React DnD/backends (including their transitive Redux), prop-types,
immutability-helper and classnames dependencies. React-only Babel presets/plugins
and JSX resolution entries were also removed. All active admin widgets now use
Stimulus and Rails-rendered markup; Propshaft and import maps own asset delivery.

JavaScript does not support omitting a dependency's value as Gemfile does. Caret
ranges are the normal compatible-major equivalent; Yarn still installs exact
lockfile versions with `--frozen-lockfile`. Most package declarations now use those
ranges. Rails' Active Storage package uses `~8.1.400` to track the selected Rails
minor. Materialize retains its exact temporary version until replacement; the
React and Shakapacker dependency trees have been removed.
`packageManager` and Docker continue to pin the executable Yarn version.

The original dependency-upgrade batch included webpack 5, Babel 7, Sass 1, dev-server 5,
loaders and browser data. Babel 8, Shakapacker 10, React Ace 15, Materialize 2.4,
webpack CLI 7/dev-server 6, CSS minimizer 8, manifest plugin 6, Sass loader 17 and
ESLint 10 were intentionally excluded from that original batch. The bundler
packages have since been removed; retained tools remain separate upgrade decisions.

Removed unused direct packages: `webpacker-react`, `form-serialize`,
`@rails/actioncable` and `prismjs`. There are no imports/active initializers for
them; the active UI now uses Stimulus and does not use an Action Cable client.
This does not remove Rails' Action Cable framework. Transitive copies that
another package still needs can remain in `yarn.lock`.

## Update and verification commands

```sh
# Normal installs must keep the lockfiles unchanged.
docker compose exec web bundle install
docker compose exec web yarn install --frozen-lockfile

# Intentional, bounded updates; inspect both manifest and lockfile diffs.
docker compose exec web bundle update devise pundit ransack paper_trail
docker compose exec web yarn upgrade glightbox

# After runtime or dependency changes:
docker compose build web css
docker compose up -d db web css selenium
docker compose exec web bundle exec rails test
docker compose exec web bundle exec rails test:system
docker compose exec -e RAILS_ENV=production -e NODE_ENV=production -e SECRET_KEY_BASE_DUMMY=1 web bundle exec rails assets:precompile
docker compose exec web bundle exec rails assets:clobber
docker compose exec web yarn build:css
docker compose restart web css
```

Docker installs gems in frozen mode and JavaScript with `--frozen-lockfile`, so
image builds reject manifest/lockfile drift. A shared `node_modules` volume is
separate from the image: rebuilding alone does not replace existing dependencies.
See the main README for refreshing that cache. Do not delete database volumes to
refresh packages. Run tests after installs finish; do not update packages while
the asset compiler or tests are reading them.

CI retains separate legacy and system-test steps so the known legacy failures do
not hide browser/build results. The passing system suite is the frontend migration
gate; remaining legacy test repairs are still recorded separately in TODO.md.

## Propshaft and import maps (2026-11-03)

Propshaft 1.3.2 and importmap-rails 2.2.3 now deliver application assets. The
transitional cssbundling-rails 1.4.3 build compiles the existing Sass/Materialize
styles separately. All three gems remain unpinned in Gemfile and locked normally.

Browser dependency delivery is local: import-map pins use Rails-gem modules for
Stimulus, Active Storage and UJS, plus checked-in npm browser distributions for
Materialize/GLightbox/Ace. `vendor/javascript/versions.json` records exact browser
versions, `vendor/licenses` retains licenses, and `node bin/vendor-assets` updates
the reviewed subset after an intentional lockfile update. JavaScript/font changes
must be committed with their matching metadata. No CDN resolution runs at runtime.

Node/Yarn remain for Sass, browser vendoring and the server-side `css` validator.
Webpack/Shakapacker and their dependency tree have been removed; application
layouts, tests, development watch and production precompilation use Propshaft and
Sass. The dated CSV snapshots above intentionally describe the earlier upgrade
batch and retain the removed packages as historical inventory.

## Turbo and UJS replacement (2026-11-06)

Added unpinned `turbo-rails`, locked at 2.0.23. Its Rails-provided browser module
replaces the UJS pin; the unused `@rails/ujs` npm dependency is removed. All other
locked gem/npm versions remain unchanged. Drive covers normal link/form
navigation; explicit full-document boundaries preserve public/admin modules,
authentication changes and script-bearing CMS content. The disabled contact form
keeps its inert full-page response. See README and TODO section 6 for lifecycle
cleanup, cache restoration and verification details.

## Shakapacker removal (2026-11-06)

Removed the Shakapacker gem and its now-unused package_json, rack-proxy and
semantic_range dependencies. Removed 29 direct npm build-tool declarations and
their unused transitive tree: webpack/dev-server/CLI, Babel, PostCSS, CSS/file/URL
loaders, extraction/minification/compression/manifest plugins, browser data and
bundler types. Exact locked npm package/version pairs drop from 814 to 265, with
no new versions introduced. Retained gem versions are unchanged as well.

Deleted webpack/Babel/PostCSS configuration, binstubs, the legacy Compose service
and host environment/port settings, and the development CSP port exception.
Generated `public/packs`, `public/packs-test` and Shakapacker cache/lock artifacts
are cleared. Existing Sass/lint tools and runtime/vendor dependencies are retained;
no browser bundle or JavaScript transpilation is part of the application build.
