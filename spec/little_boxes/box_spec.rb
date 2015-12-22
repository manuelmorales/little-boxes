require_relative '../spec_helper'

RSpec.describe 'Box' do
  def define_class name, &block
    stub_const(name.to_s, Class.new).tap do |c|
      c.class_eval(&block)
    end
  end

  before do
    define_class :MainBox do
      include Box

      let(:logger) { Logger.new level: log_level }
      get(:log_level) { 'INFO' }
      letc(:server) { Server.new }
    end

    define_class :Server do
      include Configurable

      dependency :logger
      public :logger
    end

    define_class :Logger do
      attr_accessor :level

      def initialize(attrs)
        @level = attrs[:level]
      end
    end
  end

  let(:box) { MainBox.new }
  define_method(:logger) { box.logger }
  define_method(:log_level) { box.log_level }

  describe 'box' do
    it 'memoizes' do
      expect(box.logger).to be box.logger
    end

    it 'doesn\'t share between instances' do
      expect(box.logger).not_to be MainBox.new.logger
    end
  end

  describe 'logger' do
    it 'is a new instance every time' do
      expect(log_level).to eq 'INFO'
      expect(log_level).not_to be log_level
    end

    it 'has the log_level' do
      binding.pry
      expect(logger.level).to eq log_level
    end

    it 'has memoized log_level' do
      expect(logger.level).to be logger.level
    end
  end

  describe 'server' do
    it 'is configured' do
      expect(box.server.logger).to be box.logger
    end

    it 'is not memoized' do
      expect(box.server).to be box.server
    end
  end

  # describe 'server' do
  #   it 'is configured' do
  #     expect(box.server.logger).to be box.logger
  #   end

  #   it 'is not memoized' do
  #     expect(box.server).not_to be box.server
  #   end
  # end


  # describe 'users_collection' do
  #   it 'exists' do
  #     expect(users_collection).to be_a UsersCollection
  #   end

  #   it 'has a logger' do
  #     expect(users_collection.logger).to be_a Logger
  #   end

  #   it 'is main box\'s logger' do
  #     expect(users_collection.logger).to be box.logger
  #   end

  #   it 'memoizes the logger' do
  #     expect(users_collection.logger).to be users_collection.logger
  #   end
  # end

  # describe 'users_api' do
  #   it 'exists' do
  #     expect(users_api).to be UsersApi
  #   end

  #   it 'has a logger' do
  #     expect(users_api.logger).to be_a Logger
  #   end

  #   it 'is main box\'s logger' do
  #     expect(users_api.logger).to be box.logger
  #   end
  # end
end
