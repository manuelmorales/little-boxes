module LittleBoxes
  class MemoizedDependant
    include DependantRegistry

    def initialize(*args)
      @mutex = Mutext.new
      super
    end

    def get
      @value ||= @mutex.synchronize { run }
    end
  end
end
