module LittleBoxes
  module Dependant
    attr_accessor :config

    def initialize(*args)
      @config = {}
      super
    end

    def configure(&block)
      yield @config
      self
    end

    private

    def self.included(klass)
      klass.extend ClassMethods
    end

    module ClassMethods
      def self.extended(base)
        base.class_eval do
          class << self
            attr_accessor :config
            instance_variable_set :@config, {}
          end
        end
      end

      def dependency name, &default_block
        default_block ||= Proc.new do
          fail(DependencyNotFound, "Dependency #{name} not found")
        end

        define_method name do
          @config[name] ||= default_block.call(@config[:box])
        end

        define_method "#{name}=" do |value|
          @config[name] = value
        end
      end

      def class_dependency name, &default_block
        default_block ||= Proc.new do
          fail(DependencyNotFound, "Dependency #{name} not found")
        end

        @config ||= {}

        define_singleton_method name do
          @config[name] ||= default_block.call(@config[:box])
        end

        define_singleton_method "#{name}=" do |value|
          @config[name] = value
        end

        define_method name do
          self.class.config[name] ||= default_block.call(self.class.config[:box])
        end
      end

      def configure(&block)
        yield @config
        self
      end
    end
  end
end
