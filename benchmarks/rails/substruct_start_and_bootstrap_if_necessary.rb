# currently we need a lotta gems
# require them up front just in case they're not installed
require 'thread'
$:.unshift '19_compat' if RUBY_VERSION >= '1.9.0'
$: << '.' if RUBY_VERSION >= '1.9.2'
begin
  require 'rubygems'
rescue LoadError => e
 raise 'you must install rubygems in order to be able to run rails at all' + e.to_s
end

for gem in ["RedCloth", "fastercsv", "mime/types", "mini_magick", "ezcrypto"] do
# not necessary anymore
# require gem
end

startup_path = File.join(Dir.pwd, 'substruct', 'config', 'boot') # avoid a weird
# File.dirname bug in older versions of 1.8.7, and in 1.8.6, by computing this before chdir.
# http://redmine.ruby-lang.org/issues/show/1226

ENV['RAILS_ENV'] ||= 'production'

Dir.chdir 'substruct'
require startup_path

require 'config/environment'
require 'application_controller'

begin
 raise if defined?(DROP_DB_EACH_TIME)
 Product.first # raising here means the DB doesn't exist
 puts 'database appears initialized'
rescue Exception
     # bundled rake version
     $:.unshift(File.expand_path(File.dirname(__FILE__) + "/lib/rake-0.8.7/lib"))
     puts 'recreating database'
     require 'rake'
     require 'rake/testtask'
     require 'rake/rdoctask'
     require 'tasks/rails'
     require 'fileutils'
     Dir.mkdir 'db' unless File.directory? 'db'
     FileUtils.cp "vendor/plugins/substruct/db/schema.rb", "db"
     Rake::Task['db:drop'].invoke if defined?(DROP_DB_EACH_TIME)
     Rake::Task['db:create'].invoke
     Rake::Task['substruct:db:bootstrap'].invoke
     Rake::Task['db:migrate'].invoke
end
Product.destroy_all
Variation.destroy_all
Session.destroy_all
