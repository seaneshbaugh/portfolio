# [seaneshbaugh.com](http://seaneshbaugh.com/)

This is the repository for my personal website.

## Ruby Version

This application is intended to be run on Ruby 2.2.0.

## Rails Version

This application uses Rails 4.2.0

## Local Development Installation

Clone the repository.

    $ git clone git@github.com:seaneshbaugh/portfolio.git portfolio

cd into the project directory. If you don't have Ruby 2.2.0 already you will want to install it before doing this.

    $ cd portfolio

Install the necessary gems.

    $ bundle install

Create the databases.

    $ rake db:create:all

Add the database tables.

    $ rake db:migrate
    $ RAILS_ENV=test rake db:migrate

Seed the database.

    $ rake db:seed

## Contacts

* [Sean Eshbaugh](mailto:seaneshbaugh@gmail.com)
