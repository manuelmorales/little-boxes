require 'forwarding_dsl'

module LittleBoxes
  class Box5
    attr_accessor :build_block
    attr_accessor :context
    attr_accessor :dependencies_block

    def initialize context: nil, dependencies_block: Proc.new{ {} }, &block
      self.context = context
      self.dependencies_block = dependencies_block 
      self.build_block = block
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
      registry[name]
    end

    def []= name, value
      registry[name]= value
    end

    def clear
      @registry = {}
    end

    def get
      @value ||= ForwardingDsl.run(context, &build_block).tap do |subject|
        dependencies_block.call(subject).each do |name, options|
          subject.send("#{name}=", resolve(name, options))
        end
      end
    end

    def find name
      self[name] || (context && context.find(name))
    end

    def resolve name, options = nil
      options ||= {}

      if d = find(name)
        d.get
      elsif s = options[:suggestion]
        s.call context
      else
        raise(MissingDependency.new "Could not find #{name}")
      end
    end

    def let name, &block
      self[name] = self.class.new context: self, &block
    end

    def dependant name, &block
      self[name] = self.class.new context: self, dependencies_block: ->(s){s.dependencies}, &block
    end

    def custom_dependant name, &block
      self[name] = self.class.new context: self, dependencies_block: ->(s){s.dependencies}, &block
      ForwardingDsl.run self[name], &block
    end

    def section name, &block
      s = self.class.new context: self
      s.build { s }
      self[name] = s
      ForwardingDsl.run s, &block
    end

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
