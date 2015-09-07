module LittleBoxes
  class Obtained
    include DependantRegistry

    def get
      run
    end

    def get
      ForwardingDsl.run(self, &build_block)
    end
  end
end
