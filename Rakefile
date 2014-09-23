# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Rails.application.load_tasks

# Rubocop task
require 'rubocop/rake_task'
RuboCop::RakeTask.new :lint

# Default rake task - if this passes, build passes
task default: [] do
  Rake::Task[:test].execute
  Rake::Task[:lint].execute
end
