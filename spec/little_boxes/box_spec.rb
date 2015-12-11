require_relative '../spec_helper'

RSpec.describe 'Box' do
  def define_class name, &block
    stub_const(name, Class.new).tap do |c|
      c.class_eval(&block)
    end
  end

  before do
    define_class 'UsersCollection' do
      attr_accessor :config

      def logger
        config.logger       
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
        attr_accessor :config

        def logger
          config.logger
        end
      end
    end

    define_class 'Server' do
      attr_accessor :config

      def logger
        config.logger
      end
    end
    
    stub_const('Box', Module.new).tap do |m|
      m.class_eval do
        def self.included(base)
          base.extend(ClassMethods)
          base.class_eval do

          end
        end

        module InstanceMethods
          def initialize(options = {})
            self.parent = options[:parent]
          end
        end

        module ClassMethods
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

          def letc name, &block
            define_method name do
              var_name = "@#{name}"

              if value = instance_variable_get(var_name)
                value
              else
                instance_variable_set var_name, eval_configured(&block)
              end
            end
          end

          def getc name, &block
            define_method name do
              eval_configured(&block)
            end
          end

          def box name, box_class
            box_proc = lambda do
              box_class.new(parent: self)
            end
            let(name, &box_proc)
          end
        end
        
        def eval_configured &block
          instance_eval(&block).tap do |v|
            v.config = self
          end
        end
      end
    end

    define_class 'UsersBox' do
      include Box

      let(:logger) { Logger.new level: 'INFO' }
      letc(:api) { UsersApi }
      getc(:collection) { UsersCollection.new }
    end

    define_class 'MainBox' do
      include Box

      get(:log_level) { 'INFO' }
      let(:logger) { Logger.new level: log_level }
      getc(:server) { Server.new }
      letc(:memoized_server) { Server.new }
      box(:users, UsersBox)
    end
  end

  let(:users_collection) { users_box.collection }
  let(:logger) { box.logger }

  let(:users_api) { users_box.api }

  let(:box) { MainBox.new }
  let(:users_box) { box.users }

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

  describe 'memoized_server' do
    it 'is configured' do
      expect(box.memoized_server.logger).to be box.logger
    end

    it 'is not memoized' do
      expect(box.memoized_server).to be box.memoized_server
    end
  end

  describe 'server' do
    it 'is configured' do
      expect(box.server.logger).to be box.logger
    end

    it 'is not memoized' do
      expect(box.server).not_to be box.server
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
