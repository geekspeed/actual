# unicorn_rails -c /data/github/current/config/unicorn.rb -E production -D
 
rails_env = ENV['RAILS_ENV'] || 'production'
 
# 16 workers and 1 master
worker_processes (rails_env == 'production' ? 7 : 2)
 
# Load rails+github.git into the master before forking workers
# for super-fast worker spawn times
preload_app true
 
# Restart any workers that haven't responded in 30 seconds
timeout 30

if ["production", "staging"].include? rails_env
  # Listen on a Unix data socket
  listen "/var/www/apptual/current/tmp/sockets/unicorn.sock", :backlog => 2048
else
  listen 8080, :tcp_nopush => true
end

# feel free to point this anywhere accessible on the filesystem
pid "./tmp/pids/unicorn.pid"

# By default, the Unicorn logger will write to stderr.
# Additionally, ome applications/frameworks log to stderr or stdout,
# so prevent them from going to /dev/null when daemonized here:
stderr_path "./log/unicorn.stderr.log"
stdout_path "./log/unicorn.stdout.log"
 
 
##
# REE
 
# http://www.rubyenterpriseedition.com/faq.html#adapt_apps_for_cow
if GC.respond_to?(:copy_on_write_friendly=)
  GC.copy_on_write_friendly = true
end
 
 
before_fork do |server, worker|
  ##
  # When sent a USR2, Unicorn will suffix its pidfile with .oldbin and
  # immediately start loading up a new version of itself (loaded with a new
  # version of our app). When this new Unicorn is completely loaded
  # it will begin spawning workers. The first worker spawned will check to
  # see if an .oldbin pidfile exists. If so, this means we've just booted up
  # a new Unicorn and need to tell the old one that it can now die. To do so
  # we send it a QUIT.
  #
  # Using this method we get 0 downtime deploys.
 
  old_pid = Rails.root + '/tmp/pids/unicorn.pid.oldbin'
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end
 
 
after_fork do |server, worker|
  ##
  # Unicorn master loads the app then forks off workers - because of the way
  # Unix forking works, we need to make sure we aren't using any of the parent's
  # sockets, e.g. db connection
 
  # ActiveRecord::Base.establish_connection
  # CHIMNEY.client.connect_to_server
  # Redis and Memcached would go here but their connections are established
  # on demand, so the master never opens a socket
end