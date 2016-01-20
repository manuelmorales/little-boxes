module LittleBoxes
  module Box
    module ClassMethods
      def get(name, &block)
        procs[name] = block

        define_method name do
          instance_eval(&procs[name])
        end
      end

      def let(name, &block)
        procs[name] = block

        define_method name do
          @memo[name] ||= instance_eval(&procs[name])
        end
      end

      def getc(name, &block)
        get name do
          configure block.call
        end
      end

      def letc(name, &block)
        let name do
          configure block.call
        end
      end

      def procs
        @procs ||= {}
      end

      def inspect
        "#{name}(#{procs.keys.map(&:inspect).join(", ")})"
      end
    end

    def self.included(klass)
      klass.extend ClassMethods
    end

    def [] name
      @memo[name] || send(name)
    end

    def inspect
      "#<#{self.class.name} #{procs.keys.map(&:inspect).join(", ")}>"
    end

    private

    def initialize
      @memo = {}
    end

    def procs
      self.class.procs
    end

    def configure subject
      subject.config = Hash.new do |h, name|
        self[name]
      end

      subject
    end
  end
end
