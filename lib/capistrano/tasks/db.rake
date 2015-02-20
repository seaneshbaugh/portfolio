namespace :db do
  desc 'Create the database'
  task :create do
    on roles(:db), in: :sequence, wait: 5 do
      execute "cd #{current_path} && bundle exec rake db:create"
    end
  end

  desc 'Drop the database'
  task :drop do
    on roles(:db), in: :sequence, wait: 5 do
      execute "cd #{current_path} && bundle exec rake db:drop"
    end
  end

  desc 'Truncate the database tables'
  task :truncate do
    on roles(:db), in: :sequence, wait: 5 do
      execute "cd #{current_path} && bundle exec rake db:truncate"
    end
  end

  desc 'Remigrate the database'
  task :remigrate do
    on roles(:db), in: :sequence, wait: 5 do
      execute "cd #{current_path} && bundle exec rake db:remigrate"
    end
  end

  desc 'Seed the database'
  task :seed do
    on roles(:db), in: :sequence, wait: 5 do
      execute cd "#{current_path} && bundle exec rake db:seed_fu"
    end
  end

  desc 'Clean and then seed the database'
  task :reseed do
    on roles(:db), in: :sequence, wait: 5 do
      execute cd "#{current_path} && bundle exec rake db:reseed"
    end
  end
end
