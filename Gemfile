source "https://rubygems.org"

ruby file: ".tool-versions"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "8.0.2"
# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
# gem "propshaft", "1.1.0"
# Use postgresql as the database for Active Record
gem "pg", "1.5.9"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", "6.6.0"
# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
# gem "importmap-rails", "2.1.0"
# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
# gem "turbo-rails", "2.0.13"
# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
# gem "stimulus-rails", "1.3.4"
# Build JSON APIs with ease [https://github.com/rails/jbuilder]
# gem "jbuilder", "2.13.0"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "3.1.20"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
# gem "tzinfo-data", platforms: %i[ windows jruby ]

# Use the database-backed adapters for Rails.cache, Active Job, and Action Cable
gem "solid_cache", "1.0.7"
gem "solid_queue", "1.1.5"
gem "solid_cable", "3.0.7"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", "1.18.4", require: false

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
# gem "kamal", "2.5.3", require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
# gem "thruster", "0.1.13", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
gem "image_processing", "1.14.0"

gem "acts-as-taggable-on", "12.0.0"
gem "aws-sdk-s3", "1.183.0", require: false
gem "classnames", "1.0.1"
gem "devise", "4.9.4"
gem "exception_notification", "5.0.0"
gem "exifr", "1.4.1"
gem "filesize", "0.2.0"
gem "friendly_id", "5.5.1"
gem "git", "3.0.0"
gem "haml", "6.3.0"
# gem "honeypot-captcha", "1.0.1"
gem "jsonapi-serializer", "2.2.0"
gem "kaminari", "1.2.1"
gem "paper_trail", "16.0.0"
gem "pundit", "2.5.0"
gem "ransack", "4.3.0"
gem "rolify", "6.0.1"
gem "sanitize", "7.0.0"
gem "seed-fu", "2.3.9"
gem "shakapacker", "8.2.0"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", "1.10.0", platforms: %i[ mri windows ], require: "debug/prelude"

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", "7.0.2", require: false

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", "1.1.0", require: false

  gem "modloc", "1.0.0"
  gem "rubocop", "1.75.3", require: false
  gem "rubocop-minitest", "0.38.0", require: false
  gem "rubocop-performance", "1.25.0", require: false
  gem "rubocop-rails", "2.31.0", require: false
end

group :development do
  gem "haml_lint", '0.62.0', require: false
  gem "listen", "3.9.0"
  gem "web-console", "4.2.1"
end

group :test do
  gem "minitest", "5.25.5"
  gem "minitest-matchers", "1.4.1"
  gem "minitest-reporters", "1.7.1"
  gem "minitest-spec-rails", "7.4.1"
  gem "shoulda-matchers", "6.4.0"
  gem "simplecov", "0.22.0", require: false
end
