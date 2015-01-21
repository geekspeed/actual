# Required variables
set :application, "apptual"

task :staging do
  set :user, "root"
  set :environment, "staging"

  set :repository, 'git@github.com:crowdmixx/apptualruby.git'
  set :revision, "origin/#{environment}"

  set :domain,    "root@server2180.railsvserver.de"
  set :deploy_to, "/var/www/#{application}"
end

task :prod do
  set :user, "apptual"
  set :environment, "production"

  set :repository, 'git@github.com:crowdmixx/apptualruby.git'
  set :revision, "origin/#{environment}"

  set :domain,    "apptual@162.13.152.39"
  set :deploy_to, "/var/www/#{application}"
end

namespace :vlad do

  remote_task :symlink_db, :roles => :app do
    run "rm -f #{current_path}/config/mongoid.yml && ln -s #{shared_path}/config/mongoid.yml #{current_path}/config/mongoid.yml"
  end

  remote_task :symlink_solr, :roles => :app do
    run "rm -rf #{current_path}/solr/data && ln -s #{shared_path}/solr/data #{current_path}/solr/data"
    run "rm -rf #{current_path}/solr/default && ln -s #{shared_path}/solr/default #{current_path}/solr/default"
    run "rm -rf #{current_path}/solr/development && ln -s #{shared_path}/solr/development #{current_path}/solr/development"
    run "rm -rf #{current_path}/solr/test && ln -s #{shared_path}/solr/test #{current_path}/solr/test"
    run "rm -rf #{current_path}/solr/pids && ln -s #{shared_path}/solr/pids #{current_path}/solr/pids"
  end

  desc "Symlinks the upload folder"
  remote_task :symlink_assets, :roles => :web do
    %w(uploads).each do |file|
      run "ln -s #{shared_path}/#{file} #{current_path}/public/#{file}"
    end
    
    run "ln -s #{current_path}/public/images #{current_path}/public/assets"
  end

  desc "Install dependencies"
  remote_task :bundle, :roles => :app do
    run "cd #{current_path} && bundle install"
  end

  desc "Start unicorn server"
  remote_task :start_unicorn, :roles => :app do
    run "cd #{current_path} && bundle exec unicorn_rails -c #{current_path}/config/unicorn.rb -E #{environment} -D"
  end

  desc "Stop unicorn server"
  remote_task :stop_unicorn, :roles => :app do
    run "kill -9 `cat #{shared_path}/pids/unicorn.pid`"
  end

  desc "Update crontab"
  remote_task "crontab:update", :roles => :app do
     run "cd #{current_path} && whenever --set environment=#{environment} --update-crontab"
  end

  desc "Full deployment cycle: Update, migrate, restart, cleanup"
  remote_task :deploy, :roles => :app do
    Rake::Task['vlad:update'].invoke
    Rake::Task['vlad:bundle'].invoke
    Rake::Task['vlad:stop_unicorn'].invoke
    Rake::Task['vlad:symlink_db'].invoke
    Rake::Task['vlad:symlink_solr'].invoke
    Rake::Task['vlad:start_unicorn'].invoke
    Rake::Task['vlad:crontab:update'].invoke
    Rake::Task['vlad:symlink_assets'].invoke
    Rake::Task['vlad:cleanup'].invoke
    Rake::Task['vlad:resque:stop'].invoke
    Rake::Task['vlad:resque:stop_scheduler'].invoke
  end

  desc "stop solr search"
  remote_task "sunspot:solr:stop" => :app do
    run "cd #{current_path} && RAILS_ENV=#{environment} rake sunspot:solr:stop"
  end

  desc "start solr search"
  remote_task "sunspot:solr:start" => :app do
    run "cd #{current_path} && RAILS_ENV=#{environment} rake sunspot:solr:start"
  end

  desc "solr search indexing database"
  remote_task "sunspot:reindex" => :app do
    run "cd #{current_path} && RAILS_ENV=#{environment} rake sunspot:reindex"
  end
  
  desc "Reset redis community feed caching"
  remote_task "app:community_feed:reset" => :app do
    run "cd #{current_path} && RAILS_ENV=#{environment} rake app:community_feed:reset_cache"
  end

  desc "Stop Redis"
  remote_task "redis:stop" => :app do
    run "kill -9 `cat /var/run/redis.pid`"
  end

  desc "Start Redis"
  remote_task "redis:start" => :app do
    run "redis-server /etc/redis/redis.conf"
  end

  desc "ReStart Redis"
  remote_task "redis:restart" => :app do
    Rake::Task['vlad:redis:stop'].invoke
    Rake::Task['vlad:redis:start'].invoke
  end

  desc "Configtest Nginx"
  remote_task "nginx:config" => :app do
    run "/etc/init.d/nginx configtest"
  end

  desc "ReStart Nginx"
  remote_task "nginx:restart" => :app do
    run "/etc/init.d/nginx restart"
  end

  desc "Stop MongoDB"
  remote_task "mongodb:stop" => :app do
    run "kill -9 `cat /var/run/mongod.pid`"
  end

  desc "Start MongoDB"
  remote_task "mongodb:start" => :app do
    run "mongod --config /etc/mongodb/mongod.conf"
  end

  desc "ReStart MongoDB"
  remote_task "mongodb:restart" => :app do
    Rake::Task['vlad:mongodb:stop'].invoke
    Rake::Task['vlad:mongodb:start'].invoke
  end

  desc "start resque"
  remote_task "resque:start" => :app do
    run "cd #{current_path} && RAILS_ENV=#{environment} BACKGROUND=yes PIDFILE=#{shared_path}/pids/resque.pid QUEUE=* nohup bundle exec rake environment resque:work >> #{shared_path}/log/resque.out"
  end

  desc "stop resque"
  remote_task "resque:stop" => :app do
    run "kill -9 `cat #{shared_path}/pids/resque.pid`"
  end

  desc "ReStart resque"
  remote_task "resque:restart" => :app do
    Rake::Task['vlad:resque:stop'].invoke
    Rake::Task['vlad:resque:start'].invoke
  end

  desc "start resque scheduler"
  remote_task "resque:start_scheduler" => :app do
    run "cd #{current_path} && RAILS_ENV=#{environment} BACKGROUND=yes PIDFILE=#{shared_path}/pids/resque_scheduler.pid QUEUE=* nohup bundle exec rake environment resque:scheduler >> #{shared_path}/log/resque_scheduler.out"
  end

  desc "stop resque scheduler"
  remote_task "resque:stop_scheduler" => :app do
    run "kill -9 `cat #{shared_path}/pids/resque_scheduler.pid`"
  end

  desc "ReStart resque scheduler"
  remote_task "resque:restart" => :app do
    Rake::Task['vlad:resque:stop_scheduler'].invoke
    Rake::Task['vlad:resque:start_scheduler'].invoke
  end
end

#RAILS_ENV=production BACKGROUND=yes PIDFILE=tmp/pids/resque.pid QUEUE=* nohup bundle exec rake environment resque:work >> ./log/resque.out
#RAILS_ENV=staging BACKGROUND=yes PIDFILE=tmp/pids/resque.pid QUEUE=* nohup bundle exec rake environment resque:work >> ./log/resque.out
#########
#resque-scheduler
#RAILS_ENV=staging BACKGROUND=yes PIDFILE=tmp/pids/resque_scheduler.pid QUEUE=* nohup bundle exec rake environment resque:scheduler >> ./log/resque_scheduler.out
