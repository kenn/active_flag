module ActiveFlag
  class Definition
    attr_reader :keys, :maps, :column

    def initialize(column, keys, klass)
      @column = column
      @keys = keys.freeze
      @maps = Hash[keys.map.with_index{ |key, i| [key, 2**i] }].freeze
      @klass = klass
    end

    def humans
      @humans ||= {}
      @humans[I18n.locale] ||= begin
        @keys.map { |key| [key, human(key)] }.to_h
      end
    end

    def pairs
      @pairs ||= {}
      @pairs[I18n.locale] ||= humans.invert
    end

    # Set / unset a bit on all records for migration
    # http://stackoverflow.com/a/12928899/157384

    def set_all!(key)
      @klass.update_all("#{@column} = COALESCE(#{@column}, 0) | #{@maps[key]}")
    end

    def unset_all!(key)
      @klass.update_all("#{@column} = COALESCE(#{@column}, 0) & ~#{@maps[key]}")
    end

    def to_i(arg)
      arg = [arg] unless arg.is_a?(Enumerable)
      arg = arg.uniq
      arg.map { |s| s && @maps[s.to_s.to_sym] || 0 }.sum
    end

    def to_value(instance, integer)
      Value.new(to_array(integer)).with(instance, self)
    end

    def to_array(integer)
      @maps.map { |key, mask| (integer & mask > 0) ? key : nil }.compact
    end

  private

    # Human-friendly print on class level
    def human(key, options={})
      return if key.nil? # otherwise, key.to_s.humanize will return ""
      # Mimics ActiveModel::Translation.human_attribute_name
      defaults = @klass.lookup_ancestors.map do |klass|
        :"#{@klass.i18n_scope}.active_flag.#{klass.model_name.i18n_key}.#{@column}.#{key}"
      end
      defaults << :"active_flag.#{@klass.model_name.i18n_key}.#{@column}.#{key}"
      defaults << :"active_flag.#{@column}.#{key}"
      defaults << options.delete(:default) if options[:default]
      defaults << key.to_s.humanize
      I18n.translate defaults.shift, **options.reverse_merge(count: 1, default: defaults)
    end
  end
end
