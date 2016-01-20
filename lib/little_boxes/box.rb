module LittleBoxes
  module Box
    module ClassMethods
      def procs
        @procs ||= {}
      end

      def eager
        @eager ||= []
      end

      def inspect
        "#{name}(#{procs.keys.map(&:inspect).join(", ")})"
      end

      private

      def box(name, klass = nil, &block)
        if klass
          box_from_klass(name, klass)
        elsif block_given?
          inline_box(name, &block)
        else
          fail ArgumentError,
            'Either class or block should be passed as argument'
        end
      end

      def box_from_klass(name, klass)
        let(name) { klass.new(parent: self) }
        eager << name
      end

      def inline_box(name, &block)
        let(name) do
          Class.new do
            include ::LittleBoxes::Box

            instance_eval(&block)
          end.new(parent: self)
        end
        eager << name
      end

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

      def eagerc(name, &block)
        let name do
          configure block.call
        end

        eager << name
      end
    end

    def self.included(klass)
      klass.extend ClassMethods
    end

    def [] name
      @memo[name] || (respond_to?(name) && send(name)) || (@parent && @parent[name])
    end

    def inspect
      "#<#{self.class.name} #{procs.keys.map(&:inspect).join(", ")}>"
    end

    private

    def initialize(parent: nil)
      @memo = {}
      @parent = parent
      eager.each { |name| send(name) }
    end

    def procs
      self.class.procs
    end

    def eager
      self.class.eager
    end

    def configure subject
      subject.config = Hash.new do |h, name|
        self[name]
      end

      subject
    end
  end
end
