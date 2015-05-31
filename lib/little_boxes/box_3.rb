module LittleBoxes
  class Box3
    def method_missing name, *args, &block
      if registry[name]
        registry[name].get
      else
        super
      end
    end

    def registry
      @registry ||= {}
    end

    def let name, &block
      registry[name] = MemoizedDependencyDefinition.new &block
    end

    def build name, opts
      klass = opts[:from]
      overrides = dup
      overrides.clear
      yield overrides
      registry[name] = DependantDefinition.new klass, self, overrides
    end

    def clear
      @registry = {}
    end

    class DependantDefinition
      def initialize klass, box, overrides
        @box = box
        @overrides = overrides
        @klass = klass
      end

      def get
        @klass.new.tap do |i|
          @klass.dependencies.each do |name, dependency|
            i.public_send "#{name}=", (@overrides.registry[name] || @box.registry[name]).get
          end
        end
      end
    end

    class MemoizedDependencyDefinition
      def initialize &block
        @build_block = block
      end

      def get
        @value ||= @build_block.call
      end
    end

    module Dependant
      module ClassMethods
        def dependencies
          @dependencies ||= {}
        end

        def depends_on name
          attr_accessor name
          dependencies[name] = nil
        end
      end

      def self.included klass
        klass.extend ClassMethods
      end
    end
  end
end
