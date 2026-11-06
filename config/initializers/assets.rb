Rails.application.config.assets.paths << Rails.root.join("app/javascript")
Rails.application.config.assets.paths << Rails.root.join("vendor/javascript")
# Sass sources are compiled by cssbundling-rails; serve only its CSS output.
Rails.application.config.assets.excluded_paths << Rails.root.join("app/assets/stylesheets")
