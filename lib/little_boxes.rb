module LittleBoxes
  Dir.glob(File.dirname(__FILE__) + '/little_boxes/*').each{|p| require p }

  class MissingDependency < RuntimeError; end
end
