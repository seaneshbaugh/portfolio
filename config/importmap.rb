# Separate entrypoints keep admin controllers and Ace out of public requests.
pin "application", preload: false
pin "admin", preload: false
pin "shared", preload: false
pin "flash_messages", preload: false
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: false
pin "@rails/activestorage", to: "activestorage.esm.js", preload: false
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: false
pin "@materializecss/materialize", to: "materialize.js", preload: false
pin "glightbox", to: "lib/glightbox.js", preload: false
pin "glightbox/browser", to: "glightbox.js", preload: false
pin "controllers", to: "controllers/index.js", preload: false
pin_all_from "app/javascript/controllers", under: "controllers", preload: false
pin_all_from "app/javascript/lib", under: "lib", preload: false
%w[core mode-css mode-html mode-javascript mode-text mode-rhtml theme-github].each do |file|
  pin "ace/#{file}", to: "ace/#{file}.js", preload: false
end
