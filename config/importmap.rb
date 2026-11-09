# Pin npm packages by running ./bin/importmap

# Public entrypoint adds GLightbox; admin loads only the shared Hotwire setup.
pin "application", preload: "application"
pin "admin", preload: "admin"
pin "shared"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@rails/activestorage", to: "activestorage.esm.js", preload: false
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin "glightbox", to: "lib/glightbox.js", preload: "application"
pin "glightbox/browser", to: "glightbox.js", preload: "application"
pin "controllers", to: "controllers/index.js"
pin_all_from "app/javascript/controllers", under: "controllers", preload: false
pin_all_from "app/javascript/lib", under: "lib", preload: false
%w[core mode-css mode-html mode-javascript mode-text mode-rhtml theme-github].each do |file|
  pin "ace/#{file}", to: "ace/#{file}.js", preload: false
end
