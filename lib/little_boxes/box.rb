module LittleBoxes
  module Box
    module ClassMethods
      def entries
        @entries ||= {}
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
        let(name) { klass.new(parent: self) }.tap(&:eager!)
      end

      def inline_box(name, &block)
        let(name) do
          Class.new do
            include ::LittleBoxes::Box

            instance_eval(&block)
          end.new(parent: self)
        end.tap(&:eager!)
      end

      def get(name, &block)
        entries[name] = Entry.new(name, &block).tap do |entry|
          define_method name do
            instance_eval(&(entry.proc))
          end
        end
      end

      def let(name, &block)
        entries[name] = Entry.new(name, &block).tap do |entry|
          define_method name do
            @memo[name] ||= instance_eval(&(entry.proc))
          end
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
        end.tap(&:eager!)
      end
    end

    def self.included(klass)
      klass.extend ClassMethods
    end

    def [] name
      @memo[name] ||= (respond_to?(name) && send(name)) || (@parent && @parent[name])
    end

    def inspect
      "#<#{self.class.name} #{procs.keys.map(&:inspect).join(", ")}>"
    end

    private

    def initialize(parent: nil)
      @memo = {}
      @parent = parent
      entries.values.select(&:eager).each { |e| send(e.name) } 
    end

    def entries
      self.class.entries
    end

    def configure subject
      prev_config = subject.config

      new_config = Hash.new do |h, name|
        h[name] = self[name]
      end

      new_config.merge! prev_config if prev_config && !prev_config.empty?

      subject.config = new_config

      subject
    end

    class Entry
      attr_accessor :name, :eager, :proc

      def initialize(name, &block)
        self.name = name
        self.proc = block
      end

      def eager!
        self.eager = true
      end
    end
  end
end
