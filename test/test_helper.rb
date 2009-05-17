require 'rubygems'
require 'acts_as_fu'
require File.join(File.dirname(__FILE__), '..', 'lib', 'has_status')

build_model :posts do
  string  :published_status
  string  :order
  string  :type
  
  has_status :published_status, [:draft, :published], :default => :published
  has_status :order, [:first, :second, :third]
  has_status :type, [:article, :note], :labels => {:article => 'Artikel', :note => 'Notering'}
end