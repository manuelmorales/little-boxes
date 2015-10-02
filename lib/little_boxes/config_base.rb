require 'little_boxes/remarkable_inspect'

module LittleBoxes
  class ConfigBase
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
