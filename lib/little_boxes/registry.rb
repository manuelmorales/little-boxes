module LittleBoxes
  module Registry
    attr_accessor :parent
    attr_accessor :name

    def initialize parent: nil, name: self.class, &block
      @parent = parent
      @name = name
      ForwardingDsl.run self, &block
    end

    def registry
      @registry ||= {}
    end

    def method_missing name, *args, &block
      if self[name]
        self[name].get
      else
        super
      end
    end

    def respond_to_missing? name, *args
      !!self[name] || super
    end

    def [] name
      registry[name] || (parent && parent[name])
    end

    def []= name, value
      registry[name]= value
    end

    def clear
      @registry = {}
    end

    def let name, &block
      self[name] = Memoized.new name: name, parent: self, &block
    end

    def inspect
      "<#{name} box: #{registry.keys.join(" ")}>"
    end

    alias to_s inspect

    def name
      @name || self.class.name
    end

    def path
      if parent
        parent.path + [self]
      else
        [self]
      end
    end

    def root
      path.first
    end

    def reset
      @value = nil

      registry.each do |name, register|
        register.reset
      end
    end
  end
end
