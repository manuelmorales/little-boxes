module LittleBoxes
  module Configurable
    attr_accessor :config

    def initialize(options = {})
      @config = {}

      config.keys.each do |k|
        config[k] = options[k]
      end
    end

    private

    def self.included(klass)
      klass.extend ClassMethods
    end

    module ClassMethods
      def dependency name
        private

        define_method name do
          @config[name]
        end
      end
    end
  end
end
