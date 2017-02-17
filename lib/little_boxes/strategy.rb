module LittleBoxes
  module Strategy
    module_function

    def for(block, memo: false, configure: false, then_block: nil)
      code = "block.call(bx)"
      code = "do_configure(#{code}, bx)" if configure
      code = "#{code}.tap { |v| then_block.call v, bx }" if then_block

      if memo
        code = "value = nil; ->(bx) { value ||= #{code} }"
      else
        code = "->(bx) { #{code} }"
      end

      eval code
    end

    def do_configure(subject, box)
      config = {box: box}

      config.default_proc = Proc.new do |h, name|
        h[name] = h[:box][name]
      end

      subject.config = config

      subject
    end
  end
end
