require 'set'

module ActiveFlag
  class Value < Set
    def with(instance, definition)
      @instance = instance
      @definition = definition
      @column = definition.column
      return self
    end

    def raw
      @instance.read_attribute(@column).to_i
    end

    def to_human
      to_a.map{|key| @definition.humans[key] }
    end

    def to_s
      to_a.to_s
    end

    def set(key)
      @instance.send "#{@column}=", add(key)
    end

    def unset(key)
      @instance.send "#{@column}=", delete(key)
    end

    def set!(key, options={})
      set(key)
      @instance.save!(**options)
    end

    def unset!(key, options={})
      unset(key)
      @instance.save!(**options)
    end

    def set?(key)
      include?(key)
    end

    def unset?(key)
      !set?(key)
    end

    def method_missing(symbol, *args, &block)
      if key = symbol.to_s.chomp!('?') and @definition.keys.include?(key.to_sym)
        set?(key.to_sym)
      else
        super
      end
    end
  end
end
