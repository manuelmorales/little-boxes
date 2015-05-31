module LittleBoxes
  class Box1
    class << self
      def has_one name, &block
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

      def has_one_dependant name, klass, &block
        define_method "#{name}=" do |value|
          instance_variable_set("@#{name}", value)
        end

        define_method name do
          if value = instance_variable_get("@#{name}")
            value
          else
            value = klass.new
            klass.dependencies.each do |dname, doptions|
              value.send "#{dname}=", send(dname)
            end
            instance_variable_set("@#{name}", value)
          end
        end
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
