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
      def dependency name
        private

        define_method name do
          @config[name]
        end
      end

      def class_dependency name
        private

        define_singleton_method name do
          @config[name]
        end

        define_method name do
          self.class.config[name]
        end
      end
    end
  end
end
