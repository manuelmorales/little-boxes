module LittleBoxes
  module Initializable
    def initialize(options = {})
      @config = {}

      options.keys.each do |k|
        config[k] = options[k]
      end
    end
  end
end
