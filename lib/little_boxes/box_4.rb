require 'forwarding_dsl'

module LittleBoxes
  class Box4
    def method_missing name, *args, &block
      if registry[name]
        registry[name].get
      else
        super
      end
    end

    def respond_to_missing? name, *args
      !!registry[name] || super
    end

    def registry
      @registry ||= {}
    end

    def clear
      @registry = {}
    end

    def let name, &block
      registry[name] = Lazy.new self, &block
    end

    def dependant name, &block
      registry[name] = LazyDependant.new self, &block
    end

    def get name
      (registry[name] || missing!(name)).get
    end

    private

    def missing! name
       raise(MissingDependency.new "Could not find #{name}")
    end

    class MissingDependency < RuntimeError; end

    class LazyDependant
      attr_accessor(
        :context,
        :build_block,
      )

      def initialize context, &block
        @context = context
        @build_block = block
      end

      def get
        @value ||= begin
                     ForwardingDsl.run(context, &build_block).tap do |v|
                       v.dependencies.each do |name, options|
                         v.send("#{name}=", context.get(name))
                       end
                     end
                   end
      end
    end

    class Lazy
      def initialize context, &block
        @context = context
        @build_block = block
      end

      def get
        @value ||= ForwardingDsl.run(@context, &@build_block)
      end
    end

    module Dependant
      module ClassMethods
      end

      def self.included klass
        klass.extend ClassMethods
      end
    end
  end
end
