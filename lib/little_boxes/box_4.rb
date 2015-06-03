require 'forwarding_dsl'

module LittleBoxes
  class Box4
    attr_accessor :fallback

    def initialize fallback = {}
      @fallback = fallback
    end

    def method_missing name, *args, &block
      if self[name]
        self[name].get
      else
        super
      end
    end

    def respond_to_missing? name, *args
      !!self[name] || super
    end

    def registry
      @registry ||= {}
    end

    def [] name
      registry[name] || fallback[name]
    end

    def []= name, value
      registry[name]= value
    end

    def clear
      @registry = {}
    end

    def let name, &block
      self[name] = Lazy.new self, &block
    end

    def dependant name, &block
      self[name] = LazyDependant.new self, &block
    end

    def custom_dependant name, &block
      self[name] = LazyDependant.new self
      ForwardingDsl.run self[name], &block
    end

    def get name
      (self[name] || missing!(name)).get
    end

    def section name, &block
      self[name] = LazyDependant.new self
      self[name].build { this.class.new this }
      ForwardingDsl.run self[name].get, &block
    end

    def dependencies
      {}
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
                         v.send("#{name}=", resolve(name, options))
                       end
                     end
                   end
      end

      def resolve name, options = nil
        options ||= {}

        if v = registry[name]
          v.get
        elsif v = context[name]
          v.get
        elsif v = options[:suggestion]
          v.call context
        else
          raise(MissingDependency.new "Could not find #{name}")
        end
      end

      def registry
        @registry ||= {}
      end

      def let name, &block
        registry[name] = Lazy.new self, &block
      end

      def build &block
        @build_block = block
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
