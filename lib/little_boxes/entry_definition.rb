module LittleBoxes
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
      Entry.new(
        name: name, box: box, block: block, memo: memo,
        configure: configure, eager: eager, then_block: @then_block
      )
    end

    def then(&block)
      @then_block = block
    end
  end
end
