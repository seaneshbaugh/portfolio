# Docker development and production

## Development

The development image uses Ruby 4.0.9, Node 26.13.0, Yarn 1.22.22 and Bundler
4.0.23. It installs the committed Ruby/JS locks; `bin/dev` runs Rails and the
standalone Tailwind watcher under Foreman, matching Wishlist's workflow. Source
is mounted at `/app`. There is no separate CSS service. Compose's init process
forwards stop signals and reaps child processes.

```sh
cp .env.example .env  # new checkouts only; retain existing local values
docker compose build web
docker compose run --rm web bin/setup --skip-server
docker compose up -d web mailpit
```

The setup command waits on PostgreSQL's health check through Compose. It installs
or checks dependencies and runs `db:prepare`. `seeds: false` prevents automatic
historical SeedFu loading. Normal setup preserves existing records; the explicit
`--reset` option invokes Rails' reset/seed tasks and is a separate opt-in operation.
Mailpit SMTP is `mailpit:1025`, with its UI at localhost:8025. PostgreSQL is still
17.11; this phase does not change its major version. Optional pgAdmin uses the
`tools` profile. Remote Firefox retains its existing `system-test` profile and
web:3001 server configuration; system tests remain sequential.

Volumes:

| Volume/path | Purpose |
| --- | --- |
| `postgres_data` | PostgreSQL cluster; preserve when rebuilding app images |
| `bundle` | Ruby gem cache, initially populated from the image |
| `node_modules` | Locked JS dependencies, initially populated from the image |
| Checkout `storage/` | Development uploads, outside image builds |
| Checkout `tmp/` | Temporary/test files, outside image builds |

An existing dependency volume does not refresh when the image is rebuilt. Use
`bundle install` and `yarn install --frozen-lockfile` in `web` after changing locks,
then restart `web`. For intentional Ruby updates use `bundle update GEM_NAMES`;
for JS upgrades update package.json/yarn.lock and rerun `node bin/vendor-assets`
when a vendored browser library changes. Source and locks are bind-mounted, so
review the resulting diff. Do not change the database volume to refresh gems.
If a dependency cache needs replacement, stop/remove only `web`, identify the
project's `bundle`/`node_modules` volumes, and remove only those caches before
starting `web` again. Never remove `postgres_data` as part of that process.

### Existing checkout's database migration

The original `tmp/db` cluster was backed up with `pg_dumpall`, PostgreSQL was
stopped, and its files were copied into the new `postgres_data` volume using the
same PostgreSQL 17.11 image. After startup the normalized logical dump matched
exactly: roles, databases, schema and data were retained. Original `tmp/db` files
remain untouched. The private logical backup is
`/tmp/portfolio-before-docker-alignment.sql` (mode 0600, outside version control).

That directory is a snapshot, not a live mirror of the named volume. To revert
the mount, first back up any newer changes and stop `web`, pgAdmin and `db`.
A local Compose override can replace the database mount at the same target:

```yaml
services:
  db:
    volumes:
      - ./tmp/db:/var/lib/postgresql/data
```

Use the main Compose file first and this override second. Retain the named volume
until the rollback is verified. Never copy PostgreSQL data files while its server
is running, and do not use this physical-copy procedure across major versions.
New checkouts simply initialize a fresh named volume using `.env` credentials.

## Production image and services

```sh
docker compose -f docker-compose.production.yml build web
```

`Dockerfile.production` follows the Rails 8.1 multi-stage template: native gem
build tools remain in the build stage, Bootsnap/assets are precompiled, jemalloc
is enabled, and the final app runs as UID/GID 1000. It includes libvips and the
PostgreSQL client. Node is required by the application's CSS/JavaScript validators;
only the locked `css` Node dependency tree is installed at runtime. Yarn remains
available for the existing admin runtime diagnostics. Ace/GLightbox browser assets
are already vendored; production does not build them from npm.

`.dockerignore` excludes local `.env` files, master keys, host dependency caches,
uploads, database dumps, developer credential directories and existing compiled
assets. Encrypted Rails credentials remain in the image. Production compilation
uses Rails' `SECRET_KEY_BASE_DUMMY` and command-local database placeholders; no
runtime key, live database or production credential is supplied to the build.
The placeholders are not persisted as image environment settings.

Copy `.env.production.example` to a private runtime environment file or supply
the equivalent settings through Rancher Machine. `RAILS_MASTER_KEY` must decrypt
this application's credentials, including secret_key_base, S3 access keys and
SMTP credentials. Existing domain, Spaces bucket/endpoint and mail behavior are
retained. Never deploy `SECRET_KEY_BASE_DUMMY` or build-only database values.

The production Compose file is an **app-service template pending the actual
Rancher stack/network configuration**. It does not provision or guess a production
database, reverse proxy, registry, certificates or host port bindings. Build can
run without `.env.production`; starting the app requires real runtime settings.

- `web`: immutable app image, generated entrypoint and `./bin/rails server`.
  In production Puma binds to the container interface on port 3000. The entrypoint
  runs standard, seed-safe `db:prepare` for the default server command.
- `worker`: the same image running `./bin/jobs`, after web passes `/up`. This starts
  the Solid Queue dispatcher, workers and recurring scheduler. Keep
  `SOLID_QUEUE_IN_PUMA` unset with a separate worker to avoid duplicate supervisors.
- PostgreSQL: private network access from both services; the primary, `_cache`,
  `_queue` and `_cable` databases use the configured connection credentials. The
  database role must be able to prepare the service databases, or they must be
  provisioned before release.
- Proxy: terminate HTTPS and forward Host, X-Forwarded-Proto and client forwarding
  headers to web:3000. Rails retains assume_ssl/force_ssl and serves fingerprinted
  static assets. `/up` is an HTTP container liveness check, not a database-readiness
  or worker-health check. Verify it through the actual proxy as well.
- Storage/mail: keep the existing S3/Spaces service and SMTP credentials. Web and
  worker need access to the same bucket. Contact submissions remain disabled;
  verification must capture mail locally or use an explicitly chosen test recipient.

Both services have bounded Docker logs and graceful stop periods. Queue jobs interrupted during a release
must be reconciled through Solid Queue's normal process/failure handling. Do not
run arbitrary old worker images against an incompatible upgraded schema.

## Release, backup and rollback

Before adapting the template, obtain the current Rancher Machine Compose/network,
PostgreSQL version/ownership, proxy routes/TLS handling and image registry details.
Do not replace existing production topology based on the standalone template.

For a staging release using that topology:

1. Build/tag an immutable image from the reviewed lockfiles. Retain the previous
   image/tag and its asset manifest. Confirm runtime secrets are external.
2. Quiesce writers and workers before a coordinated backup of the four databases.
   Use custom-format `pg_dump` for each and a private globals/role backup where
   relevant. Preserve attachment storage separately; database dumps contain blob
   references, not S3 objects. Protect backups like credentials.
3. Restore into newly named staging databases and verify users/content, role
   ownership, attachment references and service tables before using the backup as
   a rollback plan. Do not test restore commands against the live databases.
4. Run the new image's `./bin/rails db:prepare` as a release operation before
   enabling new web/worker processes. Existing queue databases need the generated
   batching migration (`./bin/rails db:migrate:queue`); schema loading alone does
   not upgrade existing tables. Existing extra Cable indexes need not be dropped.
5. Start web, verify `/up`, public rendering, login/admin CRUD, editors/uploads and
   an attachment variant through the proxy. Start/rehearse the real queue worker,
   captured mail, recurring cleanup and Central-time scheduling. Readiness of web
   alone does not prove queue/cache/cable databases are operational.
6. Decide asset retention with the proxy before rolling releases: each image
   contains only its own fingerprinted assets. Cached pages or a mixed-version
   rollout may need old assets retained at the proxy/CDN. Turbo reload tags do not
   replace a release asset-retention strategy.
7. Roll back application images only if the migrated schema remains compatible.
   Otherwise restore the tested database/attachment backup with writers stopped,
   then start the matching old images. Account for writes made since the backup;
   never assume an application-image rollback reverses database migrations.

Actual production deployment, backup access and proxy/registry changes require the
owner's stack configuration and are not performed by this local Docker work.

## Local validation

The normal full suite runs in the development container using the existing
Wishlist-style remote Firefox harness. Clean bootstrap is rehearsed in a separate
Compose project with fresh source, dependency and PostgreSQL volumes, avoiding
this checkout's logs/data. Production is rehearsed in another project using the
built image, dummy encrypted credentials, TLS nginx, Mailpit and local Disk
attachments. The temporary fixture changes only that stack's storage/mail/URL
settings; the image retains real production S3/SMTP configuration.

This local rehearsal does not validate access to the real Spaces bucket, SMTP
provider or Rancher proxy. The results and remaining deployment checks are listed
in TODO section 9.

Validation performed on 2026-11-09: full suite 225 tests / 783 assertions, with
55 system tests passing and the unchanged 30 legacy failures / 7 errors. Clean
bootstrap and seed-free setup pass. The production image passes TLS browser
login/admin/Ace form saves, image variants, real queue mail capture, recurring
cleanup and a four-database backup/restore rehearsal. Restored content, roles,
attachments, cache/Cable data and queue configuration survive idempotent prepare.
Disposable stacks are removed afterward; the development stack remains running.
