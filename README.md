# [seaneshbaugh.com](http://seaneshbaugh.com/)

This is the repository for my personal website.

## Ruby Version

This application is intended to be run on Ruby 2.5.0.

## Rails Version

This application uses Rails 5.1.5.

## Dependencies

* [vips](https://jcupitt.github.io/libvips/)

## Local Development Installation

Clone the repository.

    $ git clone git@github.com:seaneshbaugh/portfolio.git portfolio

cd into the project directory.

    $ cd portfolio

Start the Docker containers.

    $ docker-compose up -d --build

Create the development and test databases.

    $ docker-compose run web rails db:create

Load the database schema.

    $ docker-compose run web rails db:schema:load

Seed the database.

    $ docker-compose run web rails db:seed_fu

## Deploying

Set up a docker machine \(apparently this is already deprecated?\).

    $ docker-machine create --driver=digitalocean --digitalocean-access-token=$DIGITAL_OCEAN_TOKEN -digitalocean-size=2gb portfolio

Use the docker machine in the current shell.

    $ eval $(docker-machine env portfolio)

Start the Docker containers.

    $ docker-compose -f docker-compose.production.yml up -d --build

## Linting

### Ruby

    $ rubocop

### HAML

    $ haml-lint

### SCSS

    $ yarn run sass-lint --verbose --no-exit --config .sass-lint.yml

## Contacts

* [Sean Eshbaugh](mailto:seaneshbaugh@gmail.com)
