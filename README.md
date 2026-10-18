# [seaneshbaugh.com](https://seaneshbaugh.com/)

This is the repository for my personal website.

## Runtime versions

This branch uses Ruby 3.4.2, Rails 8.0.2, Node.js 23.9.0, Yarn 1.22.22,
Bundler 2.6.2, and PostgreSQL 17.4. Versions are pinned in `.tool-versions`,
`.ruby-version`, the dependency manifests/lockfiles, and Dockerfile/Compose.
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

With the development containers running:

    $ docker compose exec web bundle exec rails test

The test helper compiles Shakapacker assets for the test environment before
running the suite. The suite currently runs to completion with failures and
errors; see TODO.md for the recorded upgrade baseline.

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
