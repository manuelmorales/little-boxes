module LittleBoxes
  class DefinedDependant
    include DependantRegistry

    def get
      run
    end
  end
end
