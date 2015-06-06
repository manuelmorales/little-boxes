require 'logger'

module LittleBoxes
  class NullLogger < Logger
    def initialize; end
    def add(*args); end
  end
end
