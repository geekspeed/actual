namespace :app do
  desc "Seeds, sets up admin accounts and other"
  task setup: :environment do
    Rake::Task["db:seed"].invoke
    Rake::Task["app:build:super_admins"].invoke
  end

  desc "Resets and bootstraps db with default data"
  task bootstrap: :environment do
    Rake::Task["db:purge"].invoke
    Rake::Task["app:setup"].invoke
  end
end