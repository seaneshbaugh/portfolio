# [seaneshbaugh.com](http://seaneshbaugh.com/)

This is the repository for my personal website.

## Ruby Version

This application is intended to be run on Ruby 1.8.7-p173. Due to limitations of my current host Ruby 1.9 is not directly supported.

## Rails Version

This application uses Rails 3.2.14

## Required Gems

The following gems are required to run this application:

* rails (3.2.14)
* mysql2
* acts-as-taggable-on
* cancan
* devise
* exception_notification (~> 3.0.1)
* highline
* honeypot-captcha
* kaminari
* nokogiri (~> 1.5.10)
* paper_trail
* paperclip (~> 2.7)
* ransack
* sanitize (2.0.3)
* simple_form
* yaml_db
* jquery-fileupload-rails
* jquery-rails
* less-rails
* less-rails-bootstrap
* therubyracer
* uglifier
* capistrano (~> 2.15.5)
* capistrano-ext
* mailcatcher
* quiet_assets
* capybara (~> 2.0.3)
* database_cleaner
* factory_girl (~> 2.0)
* rspec-rails
* shoulda-matchers (~> 1.5.6)
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
