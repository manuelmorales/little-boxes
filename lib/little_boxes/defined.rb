module LittleBoxes
  class Defined
    include DependencyRegistry

    def get
      run
    end
  end
end

