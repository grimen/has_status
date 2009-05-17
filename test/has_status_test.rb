require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'monkeyspecdoc'

require File.join(File.dirname(__FILE__), 'test_helper')

class HasStatusTest < Test::Unit::TestCase
  
  def setup
    @post = Post.new
  end
  
  context "initialization" do
    should "extend ActiveRecord::Base" do
      assert_respond_to ActiveRecord::Base, :has_status
    end
    
    should "declare has_status-constants" do
      assert_equal [:draft, :published], Post::PUBLISHED_STATUSES
      assert_equal :published, Post::DEFAULT_PUBLISHED_STATUS
    end
    
    should "declare has_status-methods" do
      assert_respond_to @post, :draft?
      assert_respond_to @post, :draft!
      assert_respond_to @post, :published?
      assert_respond_to @post, :published!
      
      assert_respond_to @post, :has_published_status?
      assert_respond_to @post, :set_published_status!
      
      assert_respond_to @post, :next_published_status!
      assert_respond_to @post, :previous_published_status!
      
      assert_respond_to @post, :reset_published_status!
      
      assert_respond_to @post, :published_statuses_for_select
    end
  end
  
  context "functionality" do
    
    # TODO: Get default value to work. Maybe use dependency "default_values" as gem.
    # should "set default value as start value if specified" do
    #   assert_equal :published, @post.published_status
    # end
    
    should "return true only if current status is VALUE for :VALUE?" do
      @post.published_status = :draft
      assert @post.draft?
      
      @post.published_status = :published
      assert !@post.draft?
    end
    
    should "set status to correct value with :VALUE!" do
      @post.published_status = :draft
      @post.published!
      assert_equal :published, @post.published_status
    end
    
    should "return true only if current status is VALUE for :has_X?(VALUE)" do
      @post.published_status = :draft
      assert @post.has_published_status?(:draft)
      
      @post.published_status = :published
      assert !@post.has_published_status?(:draft)
    end
    
    should "set status to correct value with :set_X!(VALUE)" do
      @post.published_status = :draft
      @post.set_published_status!(:published)
      assert_equal :published, @post.published_status
    end
    
    should "return next status in order with :next_X!" do
      @post.order = :first
      @post.next_order!
      assert_equal @post.order.to_sym, :second
      
      @post.order = :third
      @post.next_order!
      assert_equal :first, @post.order.to_sym
    end
    
    should "return previous status in order with :previous_X!" do
      @post.order = :third
      @post.previous_order!
      assert_equal :second, @post.order.to_sym
      
      @post.order = :first
      @post.previous_order!
      assert_equal :third, @post.order.to_sym
    end
    
    should "reset the status to the default value with :reset_X!" do
      @post.published_status = :some_crazy_value
      @post.reset_published_status!
      assert_equal Post::DEFAULT_PUBLISHED_STATUS, (@post.published_status.to_sym rescue nil)
    end
    
    should "generate correct form select options" do
      assert_equal [['Draft', 'draft'], ['Published', 'published']], @post.published_statuses_for_select
    end
    
    should "generate custom and correct form select options for custom labels" do
      assert_equal [['Artikel', 'article'], ['Notering', 'note']], @post.types_for_select
    end
    
  end
  
end