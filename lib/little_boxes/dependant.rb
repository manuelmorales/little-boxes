require 'mini_object'

module LittleBoxes
  module Dependant
    module ClassMethods
      def dependency name
        dependencies[name] = {assign_as: :block}
        attr_injectable name
      end

      def dependencies
        @dependencies ||= {}
      end

      def inherited klass
        klass.dependencies.merge! dependencies
        super
      end
    end

    def self.included klass
      klass.extend ClassMethods
      klass.include MiniObject::Injectable
    end

    def dependencies
      self.class.dependencies
    end
  end
end
