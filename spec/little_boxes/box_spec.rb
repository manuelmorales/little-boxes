require_relative '../spec_helper'

RSpec.describe 'Box' do
  def define_class name, &block
    stub_const(name, Class.new).tap do |c|
      c.class_eval(&block)
    end
  end

  before do
    define_class 'UsersCollection' do
      attr_accessor :logger

      def initialize args
        args.each { |k,v| send "#{k}=", v }
      end
    end

    define_class 'Logger' do
      attr_accessor :level

      def initialize args
        args.each { |k,v| send "#{k}=", v }
      end
    end

    define_class 'UsersApi' do
      class << self
        attr_accessor :logger
      end
    end
  end

  let(:users_collection) { UsersCollection.new logger: logger }
  let(:logger) { Logger.new level: log_level }

  let(:users_api) do
    UsersApi.tap do |api|
      api.logger = logger
    end
  end

  def log_level
    'INFO'
  end

  describe 'log_level' do
    it 'is a new instance every time' do
      expect(log_level).to eq 'INFO'
      expect(log_level).not_to be log_level
    end

    it 'has the log_level' do
      expect(logger.level).to eq log_level
    end

    it 'has memoized log_level' do
      expect(logger.level).to be logger.level
    end
  end

  describe 'users_collection' do
    it 'exists' do
      expect(users_collection).to be_a UsersCollection
    end

    it 'has a logger' do
      expect(users_collection.logger).to be_a Logger
    end

    it 'memoizes the logger' do
      expect(users_collection.logger).to be users_collection.logger
    end
  end

  describe 'users_api' do
    it 'exists' do
      expect(users_api).to be UsersApi
    end

    it 'has a logger' do
      expect(users_api.logger).to be_a Logger
    end
  end
end
