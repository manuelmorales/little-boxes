module LittleBoxes
  class Entry
    attr_accessor :name, :memo, :box, :eager, :block, :configure, :then_block

    def initialize(name:, eager:, memo:, box:, block:, configure:, then_block:)
      self.name = name
      self.memo = memo
      self.box = box
      self.eager = eager
      self.configure = configure
      self.then_block = then_block

      @block = Strategy.for(
        block, memo: @memo, configure: @configure, then_block: @then_block
      )
    end

    def value
      @block.call(@box)
    end
  end
end
