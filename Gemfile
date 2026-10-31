source "https://rubygems.org"

ruby file: ".tool-versions"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.1.0"
# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
# gem "propshaft"
# Use postgresql as the database for Active Record
gem "pg"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma"
# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
# gem "importmap-rails"
# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
# gem "turbo-rails"
# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
# gem "stimulus-rails"
# Build JSON APIs with ease [https://github.com/rails/jbuilder]
# gem "jbuilder"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
# gem "tzinfo-data", platforms: %i[ windows jruby ]

# Use the database-backed adapters for Rails.cache, Active Job, and Action Cable
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
# gem "kamal", require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
# gem "thruster", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
gem "image_processing"
gem "ruby-vips"

gem "acts-as-taggable-on"
gem "aws-sdk-s3", require: false
gem "classnames"
gem "devise"
gem "exception_notification"
gem "exifr"
gem "filesize"
gem "friendly_id"
gem "git"
gem "haml"
gem "jsonapi-serializer"
gem "kaminari"
gem "paper_trail"
gem "pundit"
gem "ransack"
gem "rolify"
gem "sanitize"
gem "seed-fu"
# Transitional: keep the gem and npm package on the same release until removal.
gem "shakapacker", "~> 8.2.0"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", require: false

  gem "modloc"
  gem "rubocop", require: false
  gem "rubocop-minitest", require: false
  gem "rubocop-performance", require: false
  gem "rubocop-rails", require: false
end

group :development do
  gem "haml_lint", require: false
  gem "listen"
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "minitest"
  gem "minitest-matchers"
  gem "minitest-reporters"
  gem "minitest-spec-rails"
  gem "selenium-webdriver"
  gem "shoulda-matchers"
  gem "simplecov", require: false
end
