module LittleBoxes
  require 'little_boxes/registry'
  require 'little_boxes/dependant_registry'
  Dir.glob(File.dirname(__FILE__) + '/little_boxes/*').each{|p| require p }

  class MissingDependency < RuntimeError; end
end
