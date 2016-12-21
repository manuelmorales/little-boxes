require 'rubygems'
require 'rspec'
require 'pry'

$LOAD_PATH.unshift File.expand_path('lib')
require 'little_boxes'

$LOAD_PATH.unshift File.expand_path('spec/support')

module LittleBoxes
  module SpecHelper
    def self.configure_rspec
      RSpec.configure do |c|
        c.color = true
        c.tty = true
        c.formatter = :documentation # :documentation, :progress, :html, :textmate
        c.filter_run_excluding benchmark: !benchmark_enabled?, docs: !docs?
        c.include SpecHelper
      end
    end

    def self.benchmark_enabled?
      ENV['BENCH'] == "true"
    end

    def self.docs?
      ENV['DOCS'] == "true"
    end
  end
end

LittleBoxes::SpecHelper.configure_rspec
include LittleBoxes
