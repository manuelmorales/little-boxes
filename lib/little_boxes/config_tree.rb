module LittleBoxes
  class ConfigurableTree
    def initialize(name = nil, options = {}, &block)
      @name = name
      @registry = {}
      @parent = options[:parent]
      @block = block
    end

    def get(name, &block)
      registry[name] = self.class.new name, parent: self, &block
    end

    def get_configured(name, &block)
      get(name) do |tree|
        block.call(tree).tap do |obj|
          obj.configure do |cfg|
            cfg.keys.each do |k|
              cfg[k] = tree.public_send k
            end
          end
        end
      end
    end

    def let(name, &block)
      value = nil
      b = ->(c) { value ||= block.call c }
      registry[name] = self.class.new name, parent: self, &b
    end

    def section(name, &block)
      sub_config = self.class.new(name, parent: self)
      yield sub_config if block_given?
      registry[name] = Proc.new { sub_config }
    end

    def method_missing name, *args, &block
      if registry[name]
        registry[name].call
      elsif @parent
        @parent.public_send(name, *args, &block)
      else
        super
      end
    end

    def respond_to_missing? name, *args
      !!registry[name] ||
       parent.respond_to_missing?(name, *args) ||
       super
    end

    def inspect
      "#<#{self.class}:0x#{hex_id} #{name}: #{keys_list}>"
    end

    def call
      @block.call self
    end

    def customize(name = nil)
      if name
        yield registry[name]
      else
        yield self
      end
    end

    private

    attr_reader :registry
    attr_reader :name

    def hex_id
      '%x' % (object_id << 1)
    end

    def keys_list
      registry.keys.join(', ')
    end
  end
end
