require 'forwarding_dsl'
module LittleBoxes
  class Memoized
    include Registry

    attr_accessor :build_block

    def initialize name: nil, parent: parent, &block
      @build_block = block
      @name = name
      @parent = parent
    end

    def get
      @value ||= ForwardingDsl.run self, &build_block
    end
  end
end

