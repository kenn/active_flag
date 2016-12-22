module ActiveFlag
  class Value < Set
    def with(instance, definition)
      @instance = instance
      @definition = definition
      @column = definition.column

      @definition.keys.each do |key|
        self.class.class_eval do
          define_method "#{key}?" do
            @instance.send(@column).include?(key)
          end 
        end
      end

      return self
    end

    def raw
      @instance.read_attribute(@column)
    end

    def to_human
      @instance.send(@column).to_a.map{|key| @definition.humans[key] }
    end

    def set(key)
      @instance.send "#{@column}=", add(key)
    end

    def unset(key)
      @instance.send "#{@column}=", delete(key)
    end

    def set!(key, options={})
      set(key)
      @instance.save!(options)
    end

    def unset!(key, options={})
      unset(key)
      @instance.save!(options)
    end
  end
end
