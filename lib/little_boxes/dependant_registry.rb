module LittleBoxes
  module DependantRegistry
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

    private
    def run
      ForwardingDsl.run(parent, &build_block).tap do |subject|
        subject.dependencies.each do |name, options|
          subject.send("#{name}"){ get_dependency(name, options) }
        end
      end
    end
  end
end
