module LittleBoxes
  class MemoizedDependant
    include DependantRegistry

    def get
      @value ||= run
    end
  end
end