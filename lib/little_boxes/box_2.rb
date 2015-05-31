module LittleBoxes
  class Box2
    class << self
      def let name, &block
        define_method "#{name}=" do |value|
          instance_variable_set("@#{name}", value)
        end

        define_method name do
          if value = instance_variable_get("@#{name}")
            value
          else
            instance_variable_set("@#{name}", instance_eval(&block))
          end
        end
      end

      def dependant name
        definition = DependencyDefinition.new
        yield definition
        let name do
          i = instance_eval &(definition.build_block)
          definition.steps.each do |sname, sblock|
            instance_exec i, &sblock
          end
          i
        end
      end
    end

    class DependencyDefinition
      attr_accessor :build_block
      attr_accessor :steps

      def build &block
        @build_block = block
      end

      def step name, &block
        steps[name] = block
      end

      def steps
        @steps ||= {}
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
