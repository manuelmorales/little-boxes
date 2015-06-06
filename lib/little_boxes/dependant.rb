require 'mini_object'

module LittleBoxes
  module Dependant
    module ClassMethods
      def dependency name, opts = {}
        instance_dependencies[name] = opts
        attr_injectable name
      end

      def class_dependency name, opts = {}
        class_dependencies[name] = opts
        cattr_injectable name
      end

      def instance_dependencies
        @instance_dependencies ||= {}
      end

      def class_dependencies
        @class_dependencies ||= {}
      end

      def dependencies
        class_dependencies
      end

      def inherited klass
        klass.class_dependencies.merge! class_dependencies
        klass.instance_dependencies.merge! instance_dependencies
        super
      end
    end

    def self.included klass
      klass.extend ClassMethods
      klass.include MiniObject::Injectable
    end

    def dependencies
      self.class.instance_dependencies
    end
  end
end
