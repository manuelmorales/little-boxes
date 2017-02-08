module LittleBoxes
  module SpecHelper
    module ClassSupport
      def define_class name, base = Object, &block
        stub_const(name.to_s, Class.new(base)).tap do |c|
          c.class_eval(&block)
        end
      end
    end
  end
end
