module LittleBoxes
  class MemoizedDependant
    include DependantRegistry

    def initialize(*args)
      @mutex = Mutex.new
      super
    end

    def get
      @value ||= @mutex.synchronize { run }
    end
  end
end
