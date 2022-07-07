require 'set'

module ActiveFlag
  class Value < Set
    def initialize(values, instance, definition)
      super(values)
      @instance = instance
      @definition = definition
      @column = definition.column

      @definition.keys.each do |key|
        define_singleton_method( [key, '?'].join ) { set?( key.to_sym ) }
      end
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
  end
end
