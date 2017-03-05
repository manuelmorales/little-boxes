require 'pathname'

module LittleBoxes
  def self.root_path
    Pathname.new(__FILE__) + '../..'
  end

  def self.lib_path
    root_path + 'lib'
  end

  Dir.glob(lib_path + 'little_boxes/*').each{|p| require p }

  DependencyNotFound = Class.new(StandardError)
end
