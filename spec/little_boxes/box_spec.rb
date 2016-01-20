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
      getc(:users_collection) { UsersCollection.new }
      letc(:users_api) { UsersApi }
      eagerc(:http_client) { HttpClient }
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

    define_class :UsersCollection do
      include Configurable

      dependency :logger
      public :logger
    end

    define_class :UsersApi do
      include Configurable

      class_dependency :logger
      public_class_method :logger
    end
  
    define_class :HttpClient do
      include Configurable
      
      class_dependency :logger
      public_class_method :logger
    end
  end
  
  let(:box) { MainBox.new }
  define_method(:logger) { box.logger }
  define_method(:server) { box.server }
  define_method(:log_level) { box.log_level }
  define_method(:users_collection) { box.users_collection }
  define_method(:users_api) { box.users_api }
  define_method(:http_client) { HttpClient }

  describe 'box' do
    it 'memoizes' do
      expect(logger).to be logger
    end

    it 'doesn\'t share between instances' do
      expect(logger).not_to be MainBox.new.logger
    end
  end

  describe 'logger' do
    it 'is a new instance every time (get)' do
      expect(log_level).to eq 'INFO'
      expect(log_level).not_to be log_level
    end

    it 'has the log_level (relying on other deps)' do
      expect(logger.level).to eq log_level
    end

    it 'has memoized log_level (let memoizes)' do
      expect(logger.level).to be logger.level
    end
  end

  describe 'server (letc)' do
    it 'is configured' do
      expect(server.logger).to be logger
    end

    it 'is memoized' do
      expect(server).to be server
    end
  end

  describe 'users_collection (getc)' do
    it 'doesn\'t memoize' do
      expect(users_collection).not_to be users_collection
    end

    it 'has a logger' do
      expect(users_collection.logger).to be_a Logger
    end

    it 'is main box\'s logger' do
      expect(users_collection.logger).to be logger
    end

    it 'memoizes the logger' do
      expect(users_collection.logger).to be users_collection.logger
    end
  end

  describe 'users_api (class configurable)' do
    it 'has a logger' do
      expect(users_api.logger).to be_a Logger
    end

    it 'is main box\'s logger' do
      expect(users_api.logger).to be logger
    end
  end

  describe 'http_client (eager loading)' do
    it 'loads on box initialization' do
      box
      expect(http_client.logger).to be_a Logger
    end

    it 'doesn\'t eager load the dependencies' do
      expect(box).not_to receive(:logger)
      box
    end
  end
end
