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
      klass.const_set :Config, Class.new { include RemarkableInspect }
    end

    module ClassMethods
      def configurable(name)
        self::Config.send :attr_accessor, name

        define_method name do
          config.public_send(name)
        end

        private name
      end
    end
  end
end
