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
      def initialize args
        args.each { |k,v| send "#{k}=", v }
      end

      def level
        config[:level]
      end

      def level= value
        config[:level] = value
      end

      def config
        @config ||= {}
      end
    end

    define_class 'UsersApi' do
      class << self
        attr_accessor :logger
      end
    end

    define_class 'Server' do
      def initialize config
        @config = config
      end

      def logger
        @config.logger
      end
    end

    define_class 'MainBox' do
      class << self
        def get name, &block
          define_method name, &block
        end

        def let name, &block
          define_method name do
            var_name = "@#{name}"

            if value = instance_variable_get(var_name)
              value
            else
              instance_variable_set var_name, instance_eval(&block)
            end
          end
        end
      end

      get(:log_level) { 'INFO' }
      let(:logger) { Logger.new level: log_level }
      let(:server) { Server.new self }
    end
  end

  let(:users_collection) { UsersCollection.new logger: logger }
  let(:logger) { box.logger }

  let(:users_api) do
    UsersApi.tap do |api|
      api.logger = logger
    end
  end

  let(:box) { MainBox.new }

  def log_level
    box.log_level
  end

  describe 'box' do
    it 'memoizes' do
      expect(box.logger).to be box.logger
    end

    it 'doesn\'t share between instances' do
      expect(box.logger).not_to be MainBox.new.logger
    end
  end

  describe 'server' do
    it 'is configured' do
      expect(box.server.logger).to be box.logger
    end
  end

  describe 'logger' do
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
