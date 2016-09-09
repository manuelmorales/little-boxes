module LittleBoxes
  module Configurable
    attr_accessor :config

    def initialize(options = {})
      @config = {}

      options.keys.each do |k|
        config[k] = options[k]
      end
    end

    def configure(&block)
      yield @config
      self
    end

    private

    def self.included(klass)
      klass.extend ClassMethods

      klass.class_eval do
        class << self
          attr_accessor :config
          instance_variable_set :@config, {}
        end
      end
    end

    module ClassMethods
      def dependency name, &default_block
        default_block ||= Proc.new do
          fail(DependencyNotFound, "Dependency #{name} not found")
        end

        private

        define_method name do
          @config[name] ||= default_block.call(@config[:box])
        end
      end

      def class_dependency name, &default_block
        default_block ||= Proc.new do
          fail(DependencyNotFound, "Dependency #{name} not found")
        end

        private

        define_singleton_method name do
          @config[name] ||= default_block.call(@config[:box])
        end

        define_method name do
          self.class.config[name] ||= default_block.call(@config[:box])
        end
      end

      def configure(&block)
        yield @config
        self
      end
    end
  end
end
