# Builds must respect the same dependency lock as Docker and local installation.
Rake::Task["css:install"].clear
namespace :css do
  task :install do
    sh "yarn install --frozen-lockfile"
  end
end
