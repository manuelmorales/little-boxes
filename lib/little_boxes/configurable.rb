module LittleBoxes
  module Configurable
    attr_reader :config

    def initialize(config = nil)
      @config = config
    end

    def configure
      yield config
    end

    def inspect
      hex_id = '%x' % (object_id << 1)
      remarkable_methods = methods(false) + self.class.instance_methods(false)
      "#<#{self.class}:0x#{hex_id} #{remarkable_methods.join(", ")}>"
    end

    def config
      @config ||= self.class::Config.new
    end

    private

    def self.included(klass)
      klass.extend ClassMethods
      klass.const_set :Config, Class.new
      klass::Config.class_eval do
        def inspect
          hex_id = '%x' % (object_id << 1)
          remarkable_methods = methods false
          remarkable_methods += self.class.instance_methods false
          remarkable_methods -= [:inspect]

          remarkable_methods = remarkable_methods.sort.map(&:to_s).tap do |mm|
            # Substittues [my_method, my_method=] by [my_method/=]
            mm.grep(/\=$/).each do |setter|
              getter = setter.gsub /\=$/, ''
              if mm.include? getter
                mm.delete setter
                mm[mm.find_index(getter)] = setter.gsub /\=$/, '/='
              end
            end
          end
          "#<#{self.class}:0x#{hex_id} #{remarkable_methods.join(", ")}>"
        end
      end
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
