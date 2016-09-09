module LittleBoxes
  class Entry
    attr_accessor :name, :memo, :box, :eager, :block, :configure, :then_block, :mutex

    def initialize(name:, eager:, memo:, box:, block:, configure:, then_block:)
      self.name = name
      self.memo = memo
      self.box = box
      self.eager = eager
      self.configure = configure
      self.then_block = then_block
      self.block = block
      self.mutex = Mutex.new if @memo
    end

    def value
      if @memo
        @mutex.synchronize { @block.call(@box) }
      else
        @block.call(@box)
      end
    end

    def block= block
      @block = Strategy.for(
        block, memo: @memo, configure: @configure, then_block: @then_block
      )
    end
  end
end
