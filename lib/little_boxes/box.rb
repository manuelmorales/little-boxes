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

      def import(klass)
        importable_definitions = klass.entry_definitions
        entry_definitions.merge!(importable_definitions)
        importable_definitions.each_key do |name|
          define_method(name) do
            @entries[name].value
          end
        end
      end

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
        eager(name) { |box| klass.new(parent: box) }
      end

      def inline_box(name, &block)
        eager(name) do |box|
          Class.new do
            include ::LittleBoxes::Box

            define_singleton_method(:name) { "Box[#{name}]" }

            instance_eval(&block)
          end.new(parent: box)
        end
      end

      def get(name, options={}, &block)
        entry_definitions[name] = EntryDefinition.new(name, options, &block)
          .tap do |entry|
          define_method(name) do
            @entries[name].value
          end
        end
      end

      def getc(name, options={}, &block)
        get(name, options.merge(configure: true), &block)
      end

      def let(name, options={}, &block)
        get(name, options.merge(memo: true), &block)
      end

      def letc(name, options={}, &block)
        let(name, options.merge(configure: true), &block)
      end

      def eager(name, options={}, &block)
        let(name, options.merge(eager: true), &block)
      end

      def eagerc(name, options={}, &block)
        eager(name, options.merge(configure: true), &block)
      end
    end

    attr_reader :parent, :entries

    def self.included(klass)
      klass.extend ClassMethods
    end

    def [] name
      entry = @entries[name] ||= (@parent && @parent.entries[name])
      entry ? entry.value : (parent && parent[name])
    end

    def inspect
      "#<#{self.class.name} #{entries.keys.map(&:inspect).join(", ")}>"
    end

    def method_missing(name, *args, &block)
      if respond_to?(name)
        self[name.to_sym]
      else
        super
      end
    end

    def respond_to_missing?(name, include_private = false)
      @parent.respond_to?(name, include_private)
    end

    private

    def initialize(parent: nil)
      @parent = parent
      @entries = entry_definitions.each_with_object({}) do |(k,v), acc|
        acc[k] = v.for(self)
      end
      @entries.values.select(&:eager).each { |e| send(e.name) }
    end

    def entry_definitions
      self.class.entry_definitions
    end
  end
end
