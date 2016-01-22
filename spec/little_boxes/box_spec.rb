require_relative '../spec_helper'

RSpec.describe 'Box' do
  def define_class name, &block
    stub_const(name.to_s, Class.new).tap do |c|
      c.class_eval(&block)
    end
  end

  before do
    define_class :FoldersBox do
      include Box

      letc(:collection) { FoldersCollection.new }
    end

    define_class :MainBox do
      include Box

      let(:logger) { |c| Logger.new level: c.log_level }
      get(:log_level) { 'INFO' }
      letc(:server) { Server.new }
      getc(:users_collection) { UsersCollection.new }
      letc(:users_api) { UsersApi }

      letc(:task) { Task.new }.then do |task, box|
        task.logger = :specific_logger
        task.log_level = box.log_level
      end

      eagerc(:http_client) { HttpClient }
      eager(:api_client) { |b| ApiClient.tap { |ac| ac.logger = b.logger } }
      box(:folders, FoldersBox)
      box(:files) do
        eagerc(:rest_client) { RestClient }
      end
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

    define_class :FoldersCollection do
      include Configurable

      dependency :logger
      public :logger
    end

    define_class :UsersApi do
      include Configurable

      class_dependency :logger
      public_class_method :logger
    end

    define_class :Task do
      include Configurable

      def logger= value
        @config[:logger] = value
      end

      dependency :logger
      public :logger

      def log_level= value
        @config[:log_level] = value
      end

      dependency :log_level
      public :log_level
    end

    define_class :HttpClient do
      include Configurable

      class_dependency :logger
      public_class_method :logger
    end

    define_class :RestClient do
      include Configurable

      class_dependency :logger
      public_class_method :logger
    end

    define_class :ApiClient do
      class << self
        attr_accessor :logger
      end
    end
  end

  let(:box) { MainBox.new }
  define_method(:logger) { box.logger }
  define_method(:server) { box.server }
  define_method(:log_level) { box.log_level }
  define_method(:users_collection) { box.users_collection }
  define_method(:users_api) { box.users_api }
  define_method(:task) { box.task }
  define_method(:http_client) { HttpClient }
  define_method(:rest_client) { RestClient }
  define_method(:api_client) { ApiClient }

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

    it 'respects previously configured dependencies' do
      pending "do this for get, let, getc"
      expect(task.logger).to be :specific_logger
    end

    it 'has access to the box' do
      pending "do this for get, let, getc"
      expect(task.log_level).to eq box.log_level
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

  describe 'http_client (configured eager loading)' do
    it 'loads on box initialization' do
      box
      expect(http_client.logger).to be_a Logger
    end

    it 'doesn\'t eager load the dependencies' do
      expect(box).not_to receive(:logger)
      box
    end
  end

  describe 'api_client (configured eager loading)' do
    it 'loads on box initialization' do
      box
      expect(api_client.logger).to be_a Logger
    end

    it 'doesn\'t eager load the dependencies' do
      expect(box).not_to receive(:logger)
      box
    end
  end

  describe 'nested boxes' do
    describe 'given a box' do
      it 'initializes second level box on first level box initialization' do
        expect(FoldersBox).to receive(:new)
        box
      end

      it 'allows to navigate to element of second level box' do
        expect(box.folders.collection).to be_a FoldersCollection
      end

      it 'configures looking up the tree' do
        expect(box.folders.collection.logger).to be(logger)
      end

      it 'has access to parent' do
        expect(box.folders.parent).to be(box)
      end
    end

    describe 'inline box' do
      it 'eager loads eager loadable stuff on the second level' do
        box
        expect(rest_client.logger).to be logger
      end
    end
  end
end
