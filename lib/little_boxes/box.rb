module LittleBoxes
  class Box
    include Registry

    def get
      self
    end

    def customize name, &block
      ForwardingDsl.run self[name], &block
    end

    def box name, &block
      s = self.class.new parent: self, name: name
      self[name] = s
      ForwardingDsl.run s, &block
    end
  end
end
