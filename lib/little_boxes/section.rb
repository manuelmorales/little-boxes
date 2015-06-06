module LittleBoxes
  class Section
    include Registry

    def get
      self
    end

    def customize name, &block
      ForwardingDsl.run self[name], &block
    end

    def let_dependant name, &block
      self[name] = MemoizedDependant.new name: name, parent: self, &block
    end

    def let_custom_dependant name, &block
      self[name] = MemoizedDependant.new(name: name, parent: self).tap do |d|
        ForwardingDsl.run d, &block
      end
    end

    def section name, &block
      s = self.class.new parent: self, name: name
      self[name] = s
      ForwardingDsl.run s, &block
    end
  end
end
