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

      klass.const_set :Config, Class.new

      klass::Config.class_eval do
        include RemarkableInspect

        def [](key)
          public_send key
        end

        def []=(key, value)
          public_send "#{key}=", value
        end

        def remarkable_methods
          keys
        end

        def keys
          self.class.keys
        end

        class << self
          def keys
            @keys ||= []
          end
        end
      end

      klass.const_set :ClassConfig, Class.new

      klass::ClassConfig.class_eval do
        include RemarkableInspect

        def [](key)
          public_send key
        end

        def []=(key, value)
          public_send "#{key}=", value
        end

        def remarkable_methods
          keys
        end

        def keys
          self.class.keys
        end

        class << self
          def keys
            @keys ||= []
          end
        end
      end
    end

    module ClassMethods
      def configurable(name)
        self::Config.send :attr_accessor, name
        self::Config.keys << name.to_sym

        define_method name do
          config[name]
        end

        private name
      end
      
      def configure
        yield config
      end

      def config
        @config ||= self::ClassConfig.new
      end

      def class_configurable(name)
        self::ClassConfig.send :attr_accessor, name
        self::ClassConfig.keys << name.to_sym

        define_method name do
          config[name]
        end

        private name
      end
    end
  end
end
