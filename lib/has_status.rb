require 'rubygems'
require 'activerecord'
require 'activesupport'

module HasStatus
  def self.included(base)
    base.class_eval do
      extend ClassMethods
    end
  end
  
  module ClassMethods
    
    #  In your model:
    #
    #  class Post < ActiveRecord:Base
    #    has_status :publish_status, [:draft, 'published'], :default => :draft
    #  end
    #  
    #  =>
    #  
    #  Methods:
    #
    #    - draft?
    #    - draft!
    #
    #    - published?
    #    - published!
    #
    #    - reset_publish_status!
    #    - next_publish_status!
    #    - previous_publish_status!
    #    - has_publish_status?(value)
    #    - set_publish_status!(value)
    #    - publish_statuses_for_select
    #  
    #  Constants:
    #
    #    - PUB_STATUSES
    #    - DEFAULT_PUB_STATUS
    #  
    def has_status(field, values, options = {})
      
      # Set option defaults
      options = options.reverse_merge!(:default => nil)
      
      values.collect! { |value| value.to_sym }
      
      # Generate labels based on status id, or optionally specified by options
      default_labels = {}
      values.uniq.map { |value| default_labels.merge!(value.to_sym => value.to_s.humanize) }
      options[:labels] = (options[:labels] || {}).reverse_merge!(default_labels)
      
      status_field_name = field.to_s
      
      # Define: STATUSES
      # Holding available status values
      values_const_name = "#{status_field_name.pluralize.upcase}".to_sym
      const_set(values_const_name, values)
      const_get(values_const_name).freeze
      
      # Define: DEFAULT_STATUSES
      # Holding default status value
      default_value_const_name = "DEFAULT_#{status_field_name.upcase}".to_sym
      const_set(default_value_const_name, (options[:default].to_sym rescue nil))
      const_get(default_value_const_name).freeze
      
      # Defined using migration: value=, value (ActiveRecord)
      
      # Define: has_{status}?(value)
      # Equivalent with: value?
      has_status_method_name = "has_#{status_field_name}?".to_sym
      define_method(has_status_method_name) do |value|
        self.send(status_field_name.to_sym).to_s == value.to_s
      end
      
      # Define: set_{status}!(value)
      # Equivalent with: value!
      set_status_method_name = "set_#{status_field_name}!".to_sym
      define_method(set_status_method_name) do |value|
        self.send(:"#{status_field_name}=", value.to_sym)
      end
      
      # Define: reset_{status}!
      reset_value_method_name = "reset_#{status_field_name}!".to_sym
      define_method(reset_value_method_name) do
        default_status = self.class.const_get(default_value_const_name)
        self.send(set_status_method_name, default_status)
      end
      
      # Define: next_{status}!
      # Easy status toggling, a.k.a. very simplistic state machine
      next_value_method_name = "next_#{status_field_name}!".to_sym
      define_method(next_value_method_name) do
        status_values = self.class.const_get(values_const_name)
        # current_value = @{status}
        current_status_value = self.send("#{status_field_name}".to_sym)
        # current_index = {STATUS}_VALUES.index(value)
        current_status_index = status_values.send(:index, current_status_value) || 0
        # next_value = {STATUS}_VALUES.at(index) || {STATUS}_VALUES.at(0)
        next_status_value = status_values.send(:at, current_status_index + 1)
        next_status_value ||= status_values.send(:at, 0)
        # @{status} = next_value
        self.send(set_status_method_name, next_status_value)
      end
      
      # Define: previous_{status}!
      # Easy status toggling, a.k.a. very simplistic state machine
      previous_value_method_name = "previous_#{status_field_name}!".to_sym
      define_method(previous_value_method_name) do
        status_values = self.class.const_get(values_const_name)
        # current_value = @{status}
        current_status_value = self.send("#{status_field_name}".to_sym)
        # current_index = {STATUS}_VALUES.index(value)
        current_status_index = status_values.send(:index, current_status_value) || -1
        # previous_value = {STATUS}_VALUES.at(index) || {STATUS}_VALUES.at(0)
        previous_status_value = status_values.send(:at, current_status_index - 1)
        previous_status_value ||= status_values.send(:at, -1)
        # @{status} = previous_value
        self.send(set_status_method_name, previous_status_value)
      end
      alias_method "prev_#{status_field_name}!".to_sym, previous_value_method_name
      
      # Define: {status}_for_select
      for_select_method_name = "#{status_field_name.pluralize}_for_select".to_sym
      define_method(for_select_method_name) do
        status_values = self.class.const_get(values_const_name)
        status_values.uniq.collect { |value| [options[:labels][value.to_sym], value.to_s] }
      end
      
      # Define the methods for each status value
      values.uniq.each do |value|
        value_method_name = value.to_s.tableize.singularize
        
        # Define: {value}?
        query_value_method_name = "#{value_method_name}?".to_sym
        define_method(query_value_method_name) do
          self.send(has_status_method_name, value)
        end
        
        # Define: {value}!
        set_value_method_name = "#{value_method_name}!".to_sym
        define_method(set_value_method_name) do
          self.send(set_status_method_name, value)
        end
      end
      
      # TODO: Set default value. Rails seem to overwrite this - or?
      #self.send(reset_value_method_name.to_sym)
    end
  end
end

ActiveRecord::Base.class_eval do
  include HasStatus
end
