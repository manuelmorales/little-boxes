module LittleBoxes
  module Box
    module ClassMethods
      def entry_definitions
        @entry_definitions ||= {}
      end

      def inspect
        "#{name}(#{entry_definitions.keys.map(&:inspect).join(", ")})"
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
        let(name, eager: true) { |box| klass.new(parent: box) }
      end

      def inline_box(name, &block)
        let(name, eager: true) do |box|
          Class.new do
            include ::LittleBoxes::Box

            instance_eval(&block)
          end.new(parent: box)
        end
      end

      def get(name, options={}, &block)
        entry_definitions[name] = EntryDefinition.new(name, options, &block).tap do |entry|
          define_method name do
            @entries[name].value
          end
        end
      end

      def let(name, options={}, &block)
        get(name, options.merge(memo: true), &block)
      end

      def getc(name, &block)
        get(name, configure: true, &block)
      end

      def letc(name, &block)
        let(name, configure: true, &block)
      end

      def eagerc(name, &block)
        let(name, eager: true, configure: true, &block)
      end
    end

    def self.included(klass)
      klass.extend ClassMethods
    end

    def [] name
      @entries[name] &&
        @entries[name].value ||
        @parent[name]
    end

    def inspect
      "#<#{self.class.name} #{entries.keys.map(&:inspect).join(", ")}>"
    end

    private

    def initialize(parent: nil)
      @memo = {}
      @parent = parent
      @entries = entry_definitions.each_with_object({}) { |(k,v), acc| acc[k] = v.for(self) }
      @entries.values.select(&:eager).each { |e| send(e.name) } 
    end

    def entry_definitions
      self.class.entry_definitions
    end


    class EntryDefinition
      attr_accessor :name, :eager, :memo, :block, :configure

      def initialize(name, eager: false, memo: false, configure: false, then_block: nil, &block)
        self.name = name
        self.memo = memo
        self.eager = eager
        self.configure = configure
        self.block = block
      end

      def eager!
        self.eager = true
      end

      def for(box)
        Entry.new(name: name, box: box, block: block, memo: memo, configure: configure, eager: eager, then_block: @then_block)
      end

      def then(&block)
        @then_block = block
      end
    end

    class Entry
      attr_accessor :name, :memo, :box, :eager, :block, :configure

      def initialize(name:, eager:, memo:, box:, block:, configure:, then_block:)
        self.name = name
        self.memo = memo
        self.box = box
        self.eager = eager
        self.configure = configure

        @block = if memo
                   value = nil

                   if configure
                     if then_block
                       -> (bx) { value ||= do_configure(block.call(bx)).tap{ |v| then_block.call v } }
                     else
                       -> (bx) { value ||= do_configure(block.call(bx)) }
                     end
                   else
                     -> (bx) { value ||= block.call(bx) }
                   end
                 else
                   if configure
                     -> (bx) { do_configure(block.call(bx)) }
                   else
                     block
                   end
                 end
      end

      def value
        @block.call(@box)
      end

      def do_configure subject
        prev_config = subject.config

        new_config = Hash.new do |h, name|
          h[name] = @box[name]
        end

        new_config.merge! prev_config if prev_config && !prev_config.empty?

        subject.config = new_config

        subject
      end

    end
  end
end
