require 'rubygems'
require 'acts_as_fu'
require 'activerecord'
require 'logger'
require File.join(File.dirname(__FILE__), '..', 'lib', 'has_status')


build_model :posts do
  string  :published_status
  string  :order
  string  :type
  
  has_status :published_status, [:draft, :published], :default => :published
  has_status :order, [:first, :second, :third]
  has_status :type, [:article, :note], :labels => {:article => 'Artikel', :note => 'Notering'}
end
# 
# ActiveRecord::Base.configurations = {'sqlite3' => {:adapter => 'sqlite3', :database => ':memory:'}}
# ActiveRecord::Base.establish_connection('sqlite3')
# 
# ActiveRecord::Base.logger = Logger.new(STDERR)
# ActiveRecord::Base.logger.level = Logger::WARN
# 
# ActiveRecord::Schema.define(:version => 0) do
#   
#   create_table :posts do |t|
#     t.string  :published_status
#     t.string  :order
#     t.string  :type
#   end
#   
# end

# class Post < ActiveRecord::Base
#   
#   has_status :published_status, [:draft, :published] #, :default => :published
#   has_status :order, [:first, :second, :third]
#   has_status :type, [:article, :note], :labels => {:article => 'Artikel', :note => 'Notering'}
#   
# end