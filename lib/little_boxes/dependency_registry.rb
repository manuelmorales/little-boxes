module LittleBoxes
  module DependencyRegistry
    def self.included base
      base.class_eval do
        include Registry
        attr_accessor :build_block

        def initialize name: nil, parent: parent, &block
          @build_block = block
          @name = name
          @parent = parent
        end
      end
    end
        
    def get
      raise NotImplementedError
    end

    private
    def run
      ForwardingDsl.run self, &build_block
    end
  end
end
