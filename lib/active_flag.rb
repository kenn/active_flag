require 'active_flag/definition'
require 'active_flag/railtie'
require 'active_flag/value'
require 'active_flag/version'
require 'active_record'

module ActiveFlag
  extend ActiveSupport::Concern

  module ClassMethods
    def flag(column, keys, options = {})
      class << self
        attr_reader :active_flags
      end
      @active_flags ||= {}
      @active_flags[column] = Definition.new(column, keys, options, self)

      # Getter
      define_method column do
        self.class.active_flags[column].get(self, read_attribute(column))
      end

      # Setter
      define_method "#{column}=" do |arg|
        self.class.active_flags[column].set(self, arg)
      end

      # Reference to definition
      define_singleton_method column.to_s.pluralize do
        active_flags[column]
      end

      # Scopes
      define_singleton_method "where_#{column}" do |*args|
        options = args.extract_options!
        integer = active_flags[column].to_i(args)
        column_name = connection.quote_table_name_for_assignment(table_name, column)
        if options[:op] == :and
          where("#{column_name} & #{integer} = #{integer}")
        else
          where("#{column_name} & #{integer} > 0")
        end
      end
    end
  end
end
