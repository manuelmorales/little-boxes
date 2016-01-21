module LittleBoxes
  module Strategy
    module_function

    def for(block, memo: false, configure: false, then_block: nil)
      case [memo, configure, !!then_block]
      when [true, true, true]
        memo_configure_then_block_strategy(block, then_block)
      when [true, true, false]
        memo_configure_strategy(block)
      when [true, false, true]
        memo_then_block_strategy(block, then_block)
      when [true, false, false]
        memo_strategy(block)
      when [false, true, true]
        configure_then_block_strategy(block, then_block)
      when [false, true, false]
        configure_strategy(block)
      when [false, false, true]
        then_block_strategy(block, then_block)
      else
        default_strategy(block)
      end
    end

    def memo_configure_strategy(block)
      value = nil
      -> (bx) { value ||= do_configure(block.call(bx), bx) }
    end

    def memo_then_block_strategy(block, then_block)
      value = nil
      -> (bx) { value ||= block.call(bx).tap { |v| then_block.call v, bx } }
    end

    def memo_configure_then_block_strategy(block, then_block)
      value = nil
      -> (bx) do
        value ||= do_configure(block.call(bx), bx)
          .tap{ |v| then_block.call v, bx }
      end
    end

    def memo_strategy(block)
      value = nil
      -> (bx) { value ||= block.call(bx) }
    end

    def configure_strategy(block)
      -> (bx) { do_configure(block.call(bx), bx) }
    end

    def then_block_strategy(block, then_block)
      -> (bx) { block.call(bx).tap { |v| then_block.call v, bx } }
    end

    def configure_then_block_strategy(block, then_block)
      -> (bx) do
        do_configure(block.call(bx), bx).tap{ |v| then_block.call v, bx }
      end
    end

    def default_strategy(block)
      block
    end

    def do_configure(subject, box)
      config = subject.config ||= Hash.new
      config.default_proc = proc do |h, name|
        h[name] = box[name]
      end

      subject
    end
  end
end
