require 'forwarding_dsl'

module LittleBoxes
  class Box5
    attr_accessor :build_block
    attr_accessor :context
    attr_accessor :dependencies_block
    attr_accessor :registry
    attr_accessor :name

    def initialize context: nil, dependencies_block: Proc.new{ {} }, &block
      self.context = context
      self.dependencies_block = dependencies_block 
      self.build_block = block

      self.registry = {}

      self.class.registry.each do |name, value|
        registry[name] = value.dup
      end
    end

    def inspect
      "<#{name} box: #{registry.keys.join(" ")}>"
    end

    def self.inspect
      "#{name || 'Box'}(#{registry.keys.join(" ")})"
    end

    def self.inherited klass
      self.registry.each do |name, value|
        klass.registry[name] = value.dup
      end
    end

    def name
      @name || self.class.name
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

    def get
      @value ||= ForwardingDsl.run(context, &build_block).tap do |subject|
        dependencies_block.call(subject).each do |name, options|
          subject.send("#{name}=", resolve(name, options))
        end
      end
    end

    def resolve name, options = nil
      options ||= {}

      if d = self[name]
        d.get
      elsif s = options[:suggestion]
        s.call context
      else
        raise(MissingDependency.new "Could not find #{name}")
      end
    end

    module RegisteringMethods
      def let name, &block
        self[name] = Box5.new context: self, &block
      end

      def dependant name, &block
        self[name] = Box5.new context: self, dependencies_block: ->(s){s.dependencies}, &block
      end

      def custom_dependant name, &block
        self[name] = Box5.new context: self, dependencies_block: ->(s){s.dependencies}, &block
        ForwardingDsl.run self[name], &block
      end

      def section name, &block
        s = Box5.new context: self
        s.build { s }
        self[name] = s
        ForwardingDsl.run s, &block
      end

      def registry
        @registry ||= {}
      end

      def [] name
        registry[name] || (context && context[name])
      end

      def []= name, value
        registry[name]= value
      end

      def clear
        @registry = {}
      end
    end

    include RegisteringMethods
    extend RegisteringMethods

    def build &block
      self.build_block = block
    end

    private

    class MissingDependency < RuntimeError; end

    module Dependant
      module ClassMethods
      end

      def self.included klass
        klass.extend ClassMethods
      end
    end
  end
end
