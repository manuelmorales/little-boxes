module LittleBoxes
  module Registry
    def let name, &block
      self[name] = Box.new parent: self, &block
    end

    def dependant name, &block
      self[name] = Box.new parent: self, dependencies_block: ->(s){s.dependencies}, &block
    end

    def custom_dependant name, &block
      self[name] = Box.new parent: self, dependencies_block: ->(s){s.dependencies}, &block
      customize name, &block
    end

    def customize name, &block
      ForwardingDsl.run self[name], &block
    end

    def registry
      @registry ||= {}
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
  end
end
