# [seaneshbaugh.com](http://seaneshbaugh.com/)

This is the repository for my personal website.

## Ruby Version

This application is intended to be run on Ruby 1.8.7-p173. Due to limitations of my current host Ruby 1.9 is not directly supported.

## Rails Version

This application uses Rails 3.2.13

## Required Gems

The following gems are required to run this application:

* rails (3.2.13)
* mysql2
* cancan
* devise
* exception_notification
* highline
* honeypot-captcha
* kaminari
* paper_trail
* paperclip (~2.7)
* ransack
* sanitize
* simple_form
* yaml_db
* coffee-rails
* jquery-rails
* twitter-bootstrap-rails
* uglifier
* capistrano
* capistrano-ext
* mailcatcher
* quiet_assets
* capybara
* database_cleaner
* factory_girl_rails (~2.0)
* rspec-rails
* shoulda-matchers
* simplecov

## Local Development Installation

Clone the repository.

    $ git clone git@github.com:seaneshbaugh/portfolio.git portfolio

cd into the project directory. If you don't have Ruby 1.8.7-p173 already you will want to install it before doing this.

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
