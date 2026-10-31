# [seaneshbaugh.com](https://seaneshbaugh.com/)

This is the repository for my personal website.

## Runtime versions

This branch uses Ruby 4.0.9, Rails 8.1.4, Node.js 26.13.0 LTS, Yarn 1.22.22,
Bundler 4.0.23, and PostgreSQL 17.11 on Bookworm. Runtime versions are pinned in
`.tool-versions`, `.ruby-version`, and Dockerfile/Compose; exact library versions
belong in `Gemfile.lock` and `yarn.lock`.
The container includes libvips for Active Storage variants; no host installation
is needed for the Compose workflow.

## Local development setup

Use Docker Compose as the primary development workflow. On a new checkout, copy
`.env.example` to `.env`; keep existing `.env` values if already configured.
The example uses separate development/test databases and the `db` hostname
reachable inside Compose. PostgreSQL initialization credentials only apply to a
new data directory. They do not change users/passwords in an existing database.

Start the database and local mail server, then build the app images:

```bash
docker compose up -d db mail
docker compose build web shakapacker
docker compose run --rm --no-deps web bin/setup --skip-server
docker compose up -d web shakapacker
```

If PostgreSQL is still starting, retry the setup command after it is ready.
`bin/setup` installs locked dependencies and creates/migrates development and test
databases without loading the historical seeds. It also clears local logs/temp
files, so save diagnostic logs first if needed. It stops if dependency installation
fails. Existing records are retained.

Visit the website at <http://localhost:3000> and Mailcatcher at
<http://localhost:1080>. Optional pgAdmin: `docker compose up -d pgadmin`, then
<http://localhost:5555> (credentials are in Compose).

The web and Shakapacker services share a Docker-managed `node_modules` volume.
It initializes from the image on first use. After changing JS manifests/lockfiles,
refresh it explicitly; rebuilding an image does not update an existing volume:

```bash
docker compose run --rm --no-deps shakapacker yarn install --frozen-lockfile
docker compose restart shakapacker
```

For a large dependency-tree change, Yarn can leave stale nested packages in an
existing volume even after a forced install. To initialize a clean cache from the
rebuilt image, stop/remove only the application containers and their dependency
volume:

```bash
docker compose build web shakapacker
docker compose stop web shakapacker
docker compose rm -f web shakapacker
docker volume ls --filter label=com.docker.compose.volume=node_modules
# Verify the volume belongs to this project. With the default project name:
docker volume rm portfolio_node_modules
docker compose up -d web shakapacker
```

This refreshes cached JavaScript dependencies. Keep the database directory and
uploaded files. A custom Compose project name changes the volume name.

### Dependency updates

The Gemfile generally omits versions; Rails and transitional Shakapacker retain
documented compatibility ranges. `bundle install` uses the committed lockfile;
use `bundle update <gem names>` for intentional updates. Docker installs gems in
frozen mode so a build cannot silently rewrite the lockfile.

Most JavaScript declarations use compatible version ranges, with exact installs
provided by `yarn.lock` and `--frozen-lockfile`. The temporary React, Materialize,
and Shakapacker UI stack retains its tested versions until replacement. See the
[dependency inventory](docs/dependencies/README.md) for before/after versions,
retained/transitional packages, compatibility exceptions and update commands.

### Sample content and local admin

For representative content and a local image attachment, run:

```bash
docker compose exec web bundle exec rails development:sample_data
```

This development-only task adds a sample author, page, post, gallery/picture and
tagged link. Repeated runs reuse existing matching records without overwriting
content. The sample author has an unknown random password and no admin role.
Images come from tracked test fixtures, use local `storage/`, and need no S3 access.
Visit `/local-demo-page`, `/posts/local-demo-post`, `/pictures/local-demo-gallery`,
`/links/2025/5`, and `/links?tag=local-demo`.

The historical `db:seed` / `db:seed_fu` fixtures update fixed IDs, set a shared
password and require untracked files under `db/fixtures/files/pictures`. They
are opt-in; do not use them to initialize a normal development checkout.
`db:reseed`, `db:truncate`, and `db:schema:load` can replace existing local data.

To create your own local admin without a password in shell history, open:

```bash
docker compose exec web bundle exec rails console
```

Then enter the following in the console (choose your own local email if desired):

```ruby
raise 'Development only' unless Rails.env.development?
require 'io/console'
email = 'local-admin@example.test'
raise 'Account already exists; choose another email' if User.exists?(email: email)
password = IO.console.getpass('New local admin password (at least 6 characters): '); nil
user = User.create!(email: email, first_name: 'Local', last_name: 'Admin', password: password, password_confirmation: password)
user.add_role(:admin)
password = nil
nil
```

Sign in at `/login`. This creates a separate account and leaves existing users
unchanged. Development SMTP points to the Compose Mailcatcher service (`mail:1025`).
Contact submission is currently disabled in the controller: it renders thanks
without validation or delivery. That behavior has been preserved.

### Optional native process launcher

`bin/dev` uses `Procfile.dev` to run Rails and Shakapacker with Foreman when
running Ruby/Node on the host. Supply the database environment yourself (both
hosts should be `localhost` when using Compose's published PostgreSQL port),
install the pinned dependencies and libvips, and use `bin/setup --skip-server`
first. Compose is the verified path; native setup is optional.

## Tests

Start the remote Firefox service alongside the development containers:

```bash
docker compose up -d selenium
docker compose exec web bundle exec rails test
docker compose exec web bundle exec rails test:system
# Or run everything together (sequentially):
docker compose exec web bundle exec rails test:all
```

To check the development asset connection separately, with web and Shakapacker
running:

```bash
docker compose exec web ruby bin/check-development-assets
```

This checks public/admin CSS and JavaScript through Rails' development proxy.
System tests use static packs and cannot detect a broken development proxy.

Selenium connects to the test server at `http://web:3001`. Port 3001 does not
need to be published to the host. Run only one system-test command at a time.
Running `test:all` also makes the other tests sequential; use the separate
commands when you want to retain the non-system suite's independent execution
settings.

The test helper compiles static assets into `public/packs-test`, so system tests
do not need the Shakapacker development server. Fixtures use a separate test
database, local `tmp/storage` attachments, and Rails' in-memory mail delivery;
they do not use development content, S3, or Mailcatcher. The upload helper purges
attachments created by each system test, since transaction rollback alone cannot
remove files from disk.

Use `fill_in_ace 'page_body', with: '<p>Content.</p>'` from
`test/support/editor_system_test_helpers.rb` for Ace fields. It sets the Ace
editor's value, exercises its change callback, and checks the hidden Rails field.
This avoids Ace's automatic tag/bracket insertion when typing complete source.
Image chooser tests transfer real fixture files to Firefox; the drop test supplies
a browser `File`/`DataTransfer`. Gallery ordering uses a pointer gesture plus an
explicit `dragend` event because the remote Firefox gesture leaves the relocated
source in its dragging state. Neither helper changes React state directly.

Rails saves failure screenshots under `tmp/screenshots`. The application-specific
diagnostics mixin also saves captured console output there; capture starts after
each `visit` and is limited to that document. Server exceptions are in
`log/test.log`.

`.github/workflows/ci.yml` uses the same Compose browser configuration with locked
dependencies, an isolated database, a development asset proxy check, separate
existing/system test steps, and a production asset build. Existing suite failures keep CI red but do not prevent
the browser and build steps from reporting results. The legacy suite still has
deferred failures/errors; see TODO.md for the recorded baseline.

## Troubleshooting

#### Missing webpack or JavaScript dependencies

Refresh the shared dependency volume with the locked Yarn install command above,
then restart Shakapacker. Do not remove database volumes to refresh JavaScript.

#### `no space left on device`

This happens from time to time. Dead containers and unused images can be cleaned up with:

    $ docker ps --filter status=dead --filter status=exited -aq | xargs docker rm -v
    $ docker images --no-trunc | grep '<none>' | awk '{ print $3 }' | xargs docker rmi

## Linting

### Ruby

    $ docker compose run --rm web bundle exec rubocop

### HAML

    $ docker compose run --rm web bundle exec haml-lint

### SCSS

    $ docker compose run --rm web  yarn run sass-lint --verbose --no-exit --config .sass-lint.yml

## Contacts

* [Sean Eshbaugh](mailto:seaneshbaugh@gmail.com)
