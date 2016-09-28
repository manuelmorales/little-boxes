module LittleBoxes
  class MemoizedDependant
    include DependantRegistry

    def get
      @value ||= mutex.synchronize { run }
    end

    private

    def mutex
      @mutex ||= Mutex.new
    end
  end
end
