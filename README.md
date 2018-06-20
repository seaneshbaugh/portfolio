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

cd into the project directory. If you don't have Ruby 2.5.0 already you will want to install it before doing this.

    $ cd portfolio

Install the necessary gems.

    $ bundle install

Create the databases.

    $ rails db:create

Add the database tables.

    $ rails db:migrate

Seed the database.

    $ rails db:seed

## Linting

### Ruby

    $ rubocop

### SCSS

    $ yarn run sass-lint --verbose --no-exit --config .sass-lint.yml

## Contacts

* [Sean Eshbaugh](mailto:seaneshbaugh@gmail.com)
