module LittleBoxes
  module Box2
    module ClassMethods
      def get(name, &block)
        registry[name.to_sym] = block
      end

      def let(name, &block)
        memo_block = lambda do
          if value = instance_variable_get("@#{name}_memo")
            value
          else
            instance_variable_set "@#{name}_memo", instance_eval(&block)
          end
        end

        registry[name.to_sym] = memo_block
      end

      def registry
        @registry ||= {}
      end
    end

    def self.included(klass)
      klass.extend ClassMethods
    end

    def initialize
      self.class.registry.each do |name, block|
        define_singleton_method name, &block
      end
    end
  end

  module Box
    module ClassMethods
      def get(name, &block)
        define_method name, &block
      end

      def let(name, &block)
        value = nil

        define_method name do
          value ||= instance_eval(&block)
        end
      end
    end

    def self.included(klass)
      klass.extend ClassMethods
    end
  end
end
