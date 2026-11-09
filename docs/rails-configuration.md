# Rails 8.1 configuration alignment

The baseline is Rails **8.1.4**, PostgreSQL, importmap/Hotwire and Tailwind, with
Kamal and Thruster excluded. The goal is generated defaults with documented,
necessary exceptions. Wishlist was inspected read-only as a reference for Docker
and proxy adaptations. Portfolio retains its identity, existing data and Haml.
Rancher Machine deployment work belongs to TODO section 9.

## Reproducing the reference

Generated outside the application in the running Ruby 4.0.9 container:

```sh
rails _8.1.4_ new /tmp/portfolio-rails-reference/test_app \
  -d postgresql --skip-kamal --skip-thruster --css tailwind \
  --skip-bundle --skip-git --no-rc
```

`--no-rc` excludes personal generator options. `--skip-git` only avoids creating a
nested repository. To avoid resolving a second dependency set, installation was
completed with Portfolio's locked bundle (`BUNDLE_GEMFILE=/portfolio/Gemfile`),
using the installed importmap, Turbo and Stimulus templates and the Tailwind and
Solid install tasks. No reference database was created or connected. The install
steps ran only inside the disposable reference directory. Reference credentials
and generated files are not copied into the repository.

Installer versions: importmap-rails 2.2.3, turbo-rails 2.0.23, stimulus-rails 1.3.4,
tailwindcss-rails 4.7.0 / tailwindcss-ruby 4.3.4, solid_cache 1.0.10,
solid_queue 1.7.0 and solid_cable 4.1.0. This is a reproducible comparison of the
installed versions, rather than whatever a new unconstrained bundle resolves.

## Configuration decisions

| File/area | Generated default and previous difference | Result and reason |
| --- | --- | --- |
| `config/application.rb` | `rails/all`, `load_defaults 8.1`; Portfolio selected frameworks and loaded 8.0 defaults | Adopt both defaults. Keep Central time for existing dates/jobs and Pundit's forbidden-response mapping. |
| `config.autoload_lib` | Ignore assets/tasks; an old `lib/ext` Active Storage reopening does not define its matching namespace | Also ignore `ext`. This permits eager loading without accidentally activating a dormant patch. Reworking EXIF extraction is outside configuration alignment. |
| `config/boot.rb`, `environment.rb`, `config.ru`, `Rakefile` | Standard entrypoints | Retain; no alternate boot mechanism is needed. |
| Development | Standard cache/reload/log settings; custom evented watcher and strict translations | Adopt generated watcher and translation settings, asset quieting and redirect logging. Keep Mailcatcher SMTP and Docker web-console access because those services are reached over container networking. |
| Test environment | Generated `example.com` mail URL and normal translation handling | Adopt defaults. Keep route host `test`: `Picture` and serializers generate absolute attachment URLs without a controller request. Remote Firefox setup and sequential execution remain unchanged. |
| Route URL defaults | Not present in generated app | Keep development localhost/3000 and production domain as well as test host for model/presenter/serializer URL helpers. These are distinct from mailer URL settings. |
| Production logging | One tagged stdout logger, info level | Remove old `/proc/1/fd/1`/environment logger replacement, custom formatter and debug default. Use the generated logger and `RAILS_LOG_LEVEL` override. |
| Production assets/SSL | Static files enabled by Rails, SSL-terminating proxy assumed, SSL forced | Remove inherited static-serving environment gate. Keep default SSL settings. Proxy forwarding, health-check routing and host allowlist need the actual Rancher/proxy topology in section 9. |
| Production integrations | Placeholder domain, local storage and unconfigured SMTP | Keep Portfolio's domain, credential-backed SMTP, DigitalOcean Spaces/S3 storage, required master key and exception notifications. Do not copy Wishlist's host/provider/SMTP settings. Contact remains disabled. |
| Puma | Three threads, env worker count, optional in-Puma queue, PID env override | Adopt exact generated file. No custom worker/process defaults added. |
| Database YAML | PostgreSQL and `max_connections`, four production databases | Adopt `max_connections`. Keep existing `PORTFOLIO_*` connection variables, safe test defaults, database names and service migration paths for the container workflow and persisted data. Set `seeds: false` so `db:prepare` does not automatically run historical fixtures; explicit seeding remains available. |
| Cache/queue | Solid adapters in production, queue worker poll interval 1 second | Keep default adapter/database wiring and adopt default worker polling and recurring finished-job cleanup. This changes no contact submission behavior. |
| Cable | Generated Solid Cable in production, async in development | Replace production async with generated Solid Cable settings. Existing cable database/schema already exists in source; it must be prepared in deployment. No new application channels or service containers introduced. |
| Solid schemas | Current generated cache schema; newer queue batching schema | Cache already matches. Add generated, additive queue migration under `db/queue_migrate` and update fresh queue schema. Keep the historical extra cable channel index: dropping a persisted index solely for textual parity serves no application need. |
| `assets.rb` | Standard version/comment-only initializer; importmap automatically adds JS paths | Restore generated initializer. Remove duplicate app/vendor JavaScript paths. |
| CSP initializer | Generated commented policy; a development-only connect policy was left over | Restore generated commented template. A new enforced policy would require a separate decision about stored CMS scripts/styles. |
| Filter parameters/inflections | Standard filtering and default inflection template | Retain. |
| Devise/FriendlyId | Application-specific gem configuration absent from a new app | Retain account behavior, sender, Turbo response statuses and global slug/reserved-word rules used by existing models/content. This phase does not redesign authentication or slug semantics. |
| Rolify | Default Active Record roles, dynamic shortcuts off | Remove initializer enabling unused `is_role?` shortcuts; application policies use the standard `has_role?` API. |
| Haml/PaperTrail | No initializers in new app | Keep Haml and model PaperTrail declarations; remove obsolete Haml attribute-wrapper setting and empty PaperTrail initializer. Rendered attributes remain double quoted. |
| PostgreSQL task initializer | Generated Rails task implementation | Remove the global database-drop monkey patch. It is unnecessary for normal boot/tests and should not silently terminate connections. Operators must stop database clients before an intentional drop. |

## Assets and JavaScript

| Area | Default | Required exception/result |
| --- | --- | --- |
| Propshaft/importmap paths | Gem-managed `app/javascript` and `vendor/javascript` | No manual duplicate paths or old bundler manifest/configuration. |
| Stimulus application | Generated `Application.start()` module | Retain generated-style application. Replace explicit registration list with `stimulus-loading` discovery. |
| Controller discovery | Installer eagerly discovers controllers | Use its supported lazy discovery so public pages do not fetch Ace, upload and gallery code. New controllers require only their normal filenames/data attributes. |
| Entry points | One `application` entrypoint | Keep tiny public/admin entrypoints and shared Hotwire import: public initializes GLightbox; admin does not fetch it. Layout changes already enforce appropriate Turbo document reloads. |
| Importmap preloads | Enabled by default | Restore shared Hotwire preloads; scope application/admin/GLightbox pins to the relevant entrypoint. Leave lazy controllers, editor libraries and Ace pins unpreloaded. Mapping a module does not fetch it. |
| Layout asset tags | `stylesheet_link_tag :app`, importmap tags | Keep explicit stylesheets: `:app` would apply Tailwind's reset to ordinary public CMS content. Admin/auth load Tailwind; public uses small plain CSS and GLightbox CSS. Preserve CSRF, user-boundary metadata and CMS full-reload handling. |
| Tailwind | `app/assets/tailwind/application.css` → `app/assets/builds/tailwind.css`, native gem tasks | Keep standard input/output/tasks. Explicit source paths are required for utility literals in Ruby helpers/builders/presenters, as well as Haml/JS. |
| Vendored browser libraries | `vendor/javascript` local pins | Keep Ace modes/theme/workers and GLightbox, licenses/version inventory and the regeneration script. They are application features, not legacy build-system configuration. |
| Node | Not required for this generator combination | Still required by server-side CSS validation and the deliberate browser-vendoring workflow. No JS or CSS bundler is reintroduced. |
| Test asset build | Gem hooks `test:prepare` | Keep test-helper build for direct test-file invocations which bypass that Rake hook. |

## Bin scripts and tooling

- `bin/rails`, `rake`, `importmap`, `jobs`, `rubocop` and `brakeman` already match
  their generated equivalents. Keep their executable modes.
- `bin/dev` now matches the Tailwind installer: Foreman, default port, and lazy
  remote-debug settings. Compose still launches web/CSS separately until section 9.
- Remove inherited `bin/bundle`; use the installed, lockfile-aware Bundler.
- Add generated `bin/ci`, `bin/bundler-audit` and audit configuration, including the
  unpinned development/test `bundler-audit` dependency (locked to 0.9.3). Native CI
  runs the sequential system suite and deliberately omits seed replanting. Existing
  GitHub Docker CI remains the container workflow; it is not replaced by Wishlist CI.
- `bin/setup` retains the standard structure and `--skip-server`, with necessary
  Yarn install/Tailwind steps. It uses standard `db:prepare`, with automatic seed
  loading disabled in database configuration. It deliberately offers no reset,
  since Rails reset runs explicit seeding even with that setting.
- `bin/docker-entrypoint` drops the old jemalloc search and matches the generated
  command dispatch and `db:prepare`. Database configuration prevents automatic
  SeedFu loading. The current
  development Dockerfile does not install it as ENTRYPOINT; final server arguments,
  database preparation and jemalloc runtime setup belong to section 9.
- Keep `bin/vendor-assets` (run via Node) and `bin/check-development-assets` as
  application-specific maintenance/check tools. Default generator examples such as
  a destructive seed CI step are not automatically appropriate for this database.

## Rails 8.1 defaults and validation

The installed transition template and `Rails::Application::Configuration` were
reviewed: production-only YJIT default, JSON response/separator escaping, missing
finder-order errors, path-relative redirect rejection, Ruby template dependency
tracking and hidden-field autocomplete removal. No compatibility overrides are
needed. The API post test compares parsed JSON rather than requiring the former
HTML-escaped representation. Other legacy failures remain outside this phase.

Validation results and remaining deployment prerequisites are recorded in TODO
section 8. Disposable production-style databases use the explicit
`portfolio_alignment_20261108*` prefix. Real deployment databases/credentials,
content, attachment storage and the Wishlist checkout are not modified.

Before deploying in section 9: prepare all four databases, migrate an existing
queue with `db:migrate:queue`, verify worker/recurring-job operation (Central time),
confirm proxy/host/health-check configuration, and exercise the actual production
image and mail delivery without enabling contact submission. A fresh schema load
is not a substitute for the existing-data migration rehearsal.
