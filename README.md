# [seaneshbaugh.com](https://seaneshbaugh.com/)

This is the repository for my personal website.

## Ruby Version

This application uses Ruby 2.7.1.

## Rails Version

This application uses Rails 6.0.3.2.

## Node.js Version

This application uses Node.js 14.9.0.

## Dependencies

* [vips](https://jcupitt.github.io/libvips/)

## Local Development Setup

Clone the repository.

    $ git clone git@github.com:seaneshbaugh/portfolio.git

cd into the project directory.

    $ cd portfolio

Start the Docker containers.

    $ docker-compose up -d --build

Create the development and test databases.

    $ docker-compose run --rm web rails db:create

Load the database schema.

    $ docker-compose run --rm web rails db:schema:load

Seed the database.

    $ docker-compose run --rm web rails db:seed_fu

## Troubleshooting

#### `Node Sass could not find a binding for your current environment: Linux 64-bit with Node.js 12.x`

or

#### `Module build failed: ModuleBuildError: Module build failed: Error: Node Sass does not yet support your current environment: Linux 64-bit with Unsupported runtime (72)`

If you update `/package.json` and run `yarn install` on the host machine it will overwrite the contents of `/node_modules` and in the process will rebuild Node Sass for the host machine. If the host machine is not the same OS as the Docker container you will see this error. This can be fixed by running `docker-compose run --rm web yarn install --force` and then restarting the `web` and `webpacker` containers.

#### `no space left on device`

This happens from time to time. Dead containers and unused images can be cleaned up with:

    $ docker ps --filter status=dead --filter status=exited -aq | xargs docker rm -v
    $ docker images --no-trunc | grep '<none>' | awk '{ print $3 }' | xargs docker rmi

## Linting

### Ruby

    $ docker-compose run --rm web bundle exec rubocop

### HAML

    $ docker-compose run --rm web bundle exec haml-lint

### SCSS

    $ docker-compose run --rm web  yarn run sass-lint --verbose --no-exit --config .sass-lint.yml

## Contacts

* [Sean Eshbaugh](mailto:seaneshbaugh@gmail.com)
