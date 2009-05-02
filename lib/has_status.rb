module HasStatus
  def self.included(base)
    base.extend ClassMethods
  end
  
  module ClassMethods
    
    #  In your model:
    #
    #  class Post < ActiveRecord:Base
    #    has_status :published_status, [:draft, 'published'], :default => :draft
    #  end
    #  
    #  ...gives:
    #  
    #  Methods:
    #    - draft (migration)
    #    - draft= (migration)
    #    - draft?
    #    - draft!
    #    ---
    #    - published (migration)
    #    - published= (migration)
    #    - published?
    #    - published!
    #    ---
    #    - reset_published_status!
    #    - next_published_status!
    #    - previous_published_status!
    #    - has_published_status?(value)
    #    - set_published_status!(value)
    #    - published_status_for_select
    #  
    #  Constants:
    #    - SYSTEM_STATUSES
    #    - DEFAULT_SYSTEM_STATUS
    #  
    def has_status(field, values, options = {})
      # Set option defaults
      options = options.reverse_merge!(
          :default => nil
        )
      # Generate labels based on status id, or optionally specified by options
      options[:labels] = values.uniq.map { |value| { value.to_sym => value.humanize } }.reverse_merge!(options[:labels])
      
      # Define: STATUSES
      # Holding available status values
      values_const_name = "#{field.to_s.pluralize.upcase}".to_sym
      const_set values_const_name, values unless const_defined?(field.to_s.pluralize.upcase)
      self.send(values_const_name).send(:freeze)
      
      # Define: DEFAULT_STATUSES
      # Holding default status value
      default_value_const_name = "DEFAULT_#{field.to_s.singularize.upcase}".to_sym
      const_set default_value_const_name, options[:default].to_s unless options[:default].nil?
      self.send(default_value_const_name).send(:freeze)
      
      # Defined using migration: value=, value (ActiveRecord)
      
      status_field_name = field.to_s.singularize
      
      # Define: has_{status}?(value)
      # Equivalent with: value?
      has_status_method_name = "has_#{status_field_name}?".to_sym
      define_method_with_args(has_status_method_name, query_value) do
        self.send(field) == query_value.to_s
      end unless method_defined?(has_status_method_name)
      
      # Define: set_{status}!(value)
      # Equivalent with: value!
      set_status_method_name = "set_#{status_field_name}!".to_sym
      define_method_with_args(set_status_method_name, to_value) do
        #self.send(field) = to_value.to_s
        self.send("#{field}=", value.to_s)
      end unless method_defined?(set_status_method_name)
      
      # Define: reset_{status}!
      reset_value_method_name = "reset_#{status_field_name}!".to_sym
      define_method(reset_value_method_name) do
        self.send(set_status_method_name, const_get(default_value_const_name))
      end unless method_defined?(reset_value_method_name)
      
      # Define: next_{status}!
      # Easy status toggling, a.k.a. very simplistic state machine
      next_value_method_name = "next_#{status_field_name}!".to_sym
      define_method(next_value_method_name) do
        # current_value = @{status}
        #current_status_value = self.instance_variable_get("@#{status_field_name}".to_sym)
        current_status_value = self.send("#{status_field_name}".to_sym)
        # current_index = {STATUS}_VALUES.index(value)
        current_status_index = const_get(values_const_name).send(:index, current_status_value) || 0
        # next_value = {STATUS}_VALUES.at(index) || {STATUS}_VALUES.at(0)
        next_status_value = const_get(values_const_name).send(:at, current_status_index + 1)
        next_status_value ||= const_get(values_const_name).send(:at, 0)
        # @{status} = next_value
        #self.instance_variable_set("@#{status_field_name}".to_sym, next_status_value)
        self.send(set_status_method_name, next_status_value)
      end unless method_defined?(next_value_method_name)
      
      # Define: previous_{status}!
      # Easy status toggling, a.k.a. very simplistic state machine
      previous_value_method_name = "previous_#{status_field_name}!"
      define_method(previous_value_method_name) do
        # current_value = @{status}
        #current_status_value = self.instance_variable_get("@#{status_field_name}".to_sym)
        current_status_value = self.send("#{status_field_name}".to_sym)
        # current_index = {STATUS}_VALUES.index(value)
        current_status_index = const_get(values_const_name).send(:index, current_status_value) || -1
        # previous_value = {STATUS}_VALUES.at(index) || {STATUS}_VALUES.at(0)
        previous_status_value = const_get(values_const_name).send(:at, current_status_index - 1)
        previous_status_value ||= const_get(values_const_name).send(:at, -1)
        # @{status} = previous_value
        #self.instance_variable_set("@#{status_field_name}".to_sym, previous_status_value)
        self.send(set_status_method_name, previous_status_value)
      end unless method_defined?(previous_value_method_name)
      
      # Define: {status}_for_select
      for_select_method_name = "#{status_field_name}_for_select"
      define_method(for_select_method_name) do
        values.uniq.collect { |value| [options[:labels][value.to_sym], value.to_s] }
      end unless method_defined?(for_select_method_name)
      
      # Define the methods for each status value
      values.uniq.each do |value|
        value_method_name = value.to_s.tableize.singularize
        
        # Define: {value}?
        query_value_method_name = "#{value_method_name}?".to_sym
        define_method(query_value_method_name) do
          #self.send(field) == value.to_s
          self.send(has_status_method_name, value.to_s)
        end unless method_defined?(value_method_name)
        
        # Define: {value}!
        set_value_method_name = "#{value_method_name}!".to_sym
        define_method(set_value_method_name) do
          #self.send(field) = value.to_s
          self.send(set_status_method_name, value.to_s)
        end unless method_defined?(set_value_method_name)
      end
      
      # Initialize
      
      # Set default value
      self.send(reset_status_method_name)
    end
    
    # Returns if this model has specified status field initialized
    def has_status_for?(field)
      status_field_name = field.to_s.singularize
      self.respond_to?("has_#{status_field_name}?".to_sym)
    end
    
    private
    
    # Meta programming to add support for "define_method" with optional args.
    def self.define_method_with_args(method_name, &block)
      @@blocks ||= {}
      @@blocks[method_name.to_sym] = lambda(&block)
      eval("
      def #{method_name}(*args)
        @@blocks[:#{method_name}].call(*args)
      end
      ")
    end
    
  end
end
