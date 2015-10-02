require 'little_boxes/remarkable_inspect'

module LittleBoxes
  module Configurable
    include RemarkableInspect

    attr_reader :config

    def initialize(config = nil)
      @config = config
    end

    def configure
      yield config
    end

    def config
      @config ||= self.class::Config.new
    end

    private

    def self.included(klass)
      klass.extend ClassMethods
      klass.const_set :Config, Class.new(ConfigBase)
      klass.const_set :ClassConfig, Class.new(ConfigBase)
    end

    module ClassMethods
      def configure
        yield config
      end

      def config
        @config ||= self::ClassConfig.new
      end

      private

      def class_configurable(name)
        self::ClassConfig.send :attr_accessor, name
        self::ClassConfig.keys << name.to_sym

        define_singleton_method name do
          config[name]
        end

        private_class_method name

        define_method name do
          self.class.config[name]
        end

        private name
      end

      def configurable(name)
        self::Config.send :attr_accessor, name
        self::Config.keys << name.to_sym

        define_method name do
          config[name]
        end

        private name
      end
    end
  end
end
