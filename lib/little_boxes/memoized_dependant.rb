module LittleBoxes
  class MemoizedDependant
    include Registry

    attr_accessor :build_block

    def initialize name: nil, parent: parent, &block
      @build_block = block
      @name = name
      @parent = parent
    end

    def get
      @value ||= begin
                   ForwardingDsl.run(parent, &build_block).tap do |subject|
                     subject.dependencies.each do |name, options|
                       subject.send("#{name}"){ get_dependency(name, options) }
                     end
                   end
                 end
    end

    def build &block
      @build_block = block
    end

    def get_dependency name, options = nil
      options ||= {}

      if d = self[name]; d.get
      elsif s = options[:suggestion]; s.call parent
      else raise(MissingDependency.new "Could not find #{name}")
      end
    end
  end
end
