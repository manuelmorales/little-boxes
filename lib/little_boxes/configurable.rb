module LittleBoxes
  module Configurable
    def self.included(klass)
      klass.include Dependant
      klass.include Initializable
    end
  end
end
