module LittleBoxes
  class Entry
    attr_accessor :name, :memo, :box, :eager, :block, :configure

    def initialize(name:, eager:, memo:, box:, block:, configure:, then_block:)
      self.name = name
      self.memo = memo
      self.box = box
      self.eager = eager
      self.configure = configure

      @block = if memo
                 value = nil

                 if configure
                   if then_block
                     -> (bx) { value ||= do_configure(block.call(bx)).tap{ |v| then_block.call v, bx } }
                   else
                     -> (bx) { value ||= do_configure(block.call(bx)) }
                   end
                 else
                   -> (bx) { value ||= block.call(bx) }
                 end
               else
                 if configure
                   -> (bx) { do_configure(block.call(bx)) }
                 else
                   block
                 end
               end
    end

    def value
      @block.call(@box)
    end

    def do_configure subject
      config = subject.config ||= Hash.new

      config.default_proc = proc do |h, name|
        h[name] = @box[name]
      end

      subject
    end
  end
end
