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

    def from(other)
      keys.each do |k|
        public_send k do
          other.public_send k
        end
      end
    end

    private

    def procs
      self.class.procs
    end

    def get name
      instance_variable_get("@#{name}")
    end

    def set name, value
      instance_variable_set("@#{name}", value)
    end

    def get_from_proc name
      procs[name] && procs[name].call
    end

    class << self
      def attr name
        def_attr name

        define_method name do |&block|
          if block
            procs[name] ||= block
          else
            get(name) || get_from_proc(name)
          end
        end
      end

      def mem_attr name
        def_attr name

        define_method name do |&block|
          if block
            procs[name] ||= block
          else
            get(name) || set(name, get_from_proc(name))
          end
        end
      end

      def def_attr name
        name = name.to_sym
        attr_writer name
        keys << name
      end

      def keys
        @keys ||= []
      end

      def procs
        @procs ||= {}
      end
    end
  end
end
