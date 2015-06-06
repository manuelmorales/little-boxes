require 'forwarding_dsl'
require 'mini_object'

module LittleBoxes
  class Box
    include Registry
    extend Registry

    attr_accessor :build_block
    attr_accessor :parent
    attr_accessor :dependencies_block
    attr_accessor :registry
    attr_accessor :name

    def initialize parent: nil, dependencies_block: Proc.new{ {} }, name: nil, &block
      self.parent = parent
      self.dependencies_block = dependencies_block 
      self.build_block = block
      self.name = name
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
        self[name].get self
      else
        super
      end
    end

    def respond_to_missing? name, *args
      !!self[name] || super
    end

    def get parent
      @value ||= begin
                   _logger.debug "Building #{name}"

                   ForwardingDsl.run(parent, &build_block).tap do |subject|
                     dependencies_block.call(subject).each do |name, options|
                       options ||= {}
                       assign_as = options.fetch(:assign_as) { :equal }

                       case assign_as
                       when :equal then subject.send("#{name}=", resolve(name, options))
                       when :block then subject.send("#{name}"){ resolve(name, options) }
                       else
                         raise "Unexpected assign_as #{assign_as}. Use :equal or :block"
                       end
                     end
                   end
                 end
    end

    def resolve name, options = nil
      options ||= {}

      if d = self[name]
        d.get self
      elsif s = options[:suggestion]
        s.call parent
      else
        raise(MissingDependency.new "Could not find #{name}")
      end
    end

    def section name, &block
      s = Box.new parent: self
      s.build { s }
      self[name] = s
      ForwardingDsl.run s, &block
    end

    def self.section name, &block
      s = Class.new self
      ForwardingDsl.run s, &block
      self[name] = Box.new { s.new name: name, parent: this }
    end

    def path
      if parent
        parent.path + [self]
      else
        [self]
      end
    end

    def root
      path.first
    end

    def build &block
      self.build_block = block
    end

    def reset
      @value = nil

      registry.each do |name, register|
        register.reset
      end
    end

    private

    def _logger
      @_logger ||= NullLogger.new
    end
  end
end
