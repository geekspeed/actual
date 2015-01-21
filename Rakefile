#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

begin
  require 'vlad'
  Vlad.load :scm => :git
rescue LoadError
  # do nothing
end
begin
  require 'resque/tasks'
  require 'resque_scheduler/tasks'
rescue
  puts "Unable to load Resque Tasks"
end
require File.expand_path('../config/application', __FILE__)

Apptual::Application.load_tasks
