module LittleBoxes
  class Box
    def register name, &block
      registry[name] = block
    end

    def memoize name, &block
      registry[name] = Memoizer.new(&block)
    end

    private

    def registry
      @registry ||= {}
    end

    def method_missing name, *args, &block
      if b = registry[name]
        b.call
      else
        super
      end
    end

    def respond_to_missing? name, *args
      !!(registry[name] || super)
    end

    class Memoizer
      def initialize &block
        @block = block
      end

      def call
        @value ||= @block.call
      end
    end
  end
end
