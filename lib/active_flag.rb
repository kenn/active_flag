require 'active_flag/definition'
require 'active_flag/railtie'
require 'active_flag/value'
require 'active_flag/version'
require 'active_record'

module ActiveFlag
  extend ActiveSupport::Concern

  module ClassMethods
    def flag(column, keys)
      unless respond_to?(:active_flags)
        class_attribute :active_flags
        self.active_flags = {}
      end

      raise "active_flags on :#{column} already defined!" if active_flags[column]

      self.active_flags[column] = Definition.new(column, keys, self)

      # Getter
      define_method column do
        self.class.active_flags[column].to_value(self, read_attribute(column).to_i)
      end

      # Setter
      define_method "#{column}=" do |arg|
        write_attribute column, self.class.active_flags[column].to_i(arg)
      end

      # Reference to definition
      define_singleton_method column.to_s.pluralize do
        active_flags[column]
      end

      # Scopes
      define_singleton_method "where_#{column}" do |*args|
        integer, column_name = send("_where_#{column}", *args)
        where("#{column_name} & #{integer} > 0")
      end

      define_singleton_method "where_all_#{column}" do |*args|
        integer, column_name = send("_where_#{column}", *args)
        where("#{column_name} & #{integer} = #{integer}")
      end

      define_singleton_method "where_not_#{column}" do |*args|
        integer, column_name = send("_where_#{column}", *args)
        where("#{column_name} & #{integer} = 0")
      end

      define_singleton_method "where_not_all_#{column}" do |*args|
        integer, column_name = send("_where_#{column}", *args)
        where("#{column_name} & #{integer} < #{integer}")
      end

      # utility method to extract parameters
      define_singleton_method "_where_#{column}" do |*args|
        return [
          active_flags[column].to_i(args),
          "#{connection.quote_table_name(table_name)}.#{connection.quote_column_name(column)}"
        ]
      end

      define_singleton_method "set_all!" do |key|
        af_definition = active_flags.values.first
        af_definition.set_all!(key, scope: self)
      end

      define_singleton_method "unset_all!" do |key|
        af_definition = active_flags.values.first
        af_definition.unset_all!(key, scope: self)
      end
    end
  end
end
