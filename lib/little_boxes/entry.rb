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
      prev_config = subject.config

      new_config = Hash.new do |h, name|
        h[name] = @box[name]
      end

      new_config.merge! prev_config if prev_config && !prev_config.empty?

      subject.config = new_config

      subject
    end
  end
end
