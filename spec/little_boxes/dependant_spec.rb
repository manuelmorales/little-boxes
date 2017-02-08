require_relative '../spec_helper'

RSpec.describe 'Dependant' do
  describe 'dependency' do
    it 'provides getter and setter' do
      define_class :Server do
        include Dependant
        dependency :logger
      end

      server = Server.new
      server.logger = :the_logger

      expect(server.logger).to be :the_logger
    end

    it 'allows configuring by #configure' do
      define_class :Server do
        include Dependant
        dependency :logger
      end

      server = Server.new

      server.configure do |c|
        c[:logger] = :the_logger
      end

      expect(server.logger).to be :the_logger
    end

    it 'accepts default values' do
      define_class :Server do
        include Dependant
        dependency(:logger) { :the_logger }
      end

      server = Server.new

      expect(server.logger).to be :the_logger
    end

    it 'passes the box to the default lambda' do
      define_class :Server do
        include Dependant
        dependency(:logger) { |box| box }
      end

      server = Server.new

      server.configure do |c|
       c[:box] = :the_box
      end

      expect(server.logger).to be :the_box
    end
  end

  describe 'class_dependency' do
    it 'provides getter and setter' do
      define_class :Server do
        include Dependant
        class_dependency :logger
      end

      Server.logger = :the_logger

      expect(Server.logger).to be :the_logger
    end

    it 'allows configuring by #configure' do
      define_class :Server do
        include Dependant
        class_dependency :logger
      end

      Server.configure do |c|
        c[:logger] = :the_logger
      end

      expect(Server.logger).to be :the_logger
    end

    it 'accepts default values' do
      define_class :Server do
        include Dependant
        class_dependency(:logger) { :the_logger }
      end

      expect(Server.logger).to be :the_logger
    end

    it 'passes the box to the default lambda' do
      define_class :Server do
        include Dependant
        class_dependency(:logger) { |box| box }
      end

      Server.configure do |c|
       c[:box] = :the_box
      end

      expect(Server.logger).to be :the_box
    end
  end

  it 'respects original initializer' do
    define_class :ServerBase do
      attr_accessor :given_args
      attr_accessor :changed_on_yield

      def initialize(*args)
        @given_args = args

        yield self
      end
    end

    define_class :Server, ServerBase do
      include Dependant
    end

    server = Server.new(:some_args) do |s|
      s.changed_on_yield = true
    end

    expect(server.given_args).to eq [:some_args]
    expect(server.changed_on_yield).to be true
  end
end
