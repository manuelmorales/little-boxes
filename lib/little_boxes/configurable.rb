require 'little_boxes/remarkable_inspect'

module LittleBoxes
  module Configurable
    include RemarkableInspect

    attr_reader :config

    def initialize(options = {})
      config.keys.each do |k|
        config[k] = options[k]
      end
    end

    def configure
      yield config
      self
    end

    def config
      @config ||= self.class::Config.new
    end

    def initialize_copy(source)
      copy_config_from source
    end

    private

    def self.included(klass)
      klass.extend ClassMethods
      klass.const_set :Config, Class.new(ConfigBase)
      klass.const_set :ClassConfig, Class.new(ConfigBase)
    end

    def copy_config_from source
      @config = source.config.dup
    end

    module ClassMethods
      def configure
        yield config
        self
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
