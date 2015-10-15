require_relative '../spec_helper'

RSpec.describe LittleBoxes::ConfigTree do
  let(:plain_server_class) do
    Class.new do
      attr_accessor :port

      def initialize(args = {})
        @port = args[:port]
      end
    end
  end

  let(:configurable_server_class) do
    Class.new do
      include LittleBoxes::Configurable
      configurable :port
      public :port
    end
  end

  shared_examples_for 'ConfigTree definition' do
    it 'defines a method' do
      subject.public_send(method_name, :server) { Server.new }
      expect(subject.server).to be_a Server
    end

    it 'supports mentioning others' do
      subject.get(:port) { 80 }
      subject.public_send(method_name, :server) { |c| Server.new port: c.port }

      expect(subject.server.port).to eq 80
    end
  end

  shared_examples_for 'ConfigTree memoization' do
    it 'memoizes the response' do
      subject.public_send(method_name, :server) { Server.new }
      expect(subject.server).to be subject.server
    end
  end

  shared_examples_for 'ConfigTree eager loading' do
    it 'eager load' do
      target = double(:target, port: 80)

      expect(target).to receive(:port)

      subject.get(:port) { target.port }

      subject.public_send(method_name.to_s, :server) do |c|
        Server.new port: c.port
      end
    end
  end

  shared_examples_for 'ConfigTree NO memoization' do
    it 'builds a new instance each time' do
      subject.public_send(method_name, :server) { Server.new }
      expect(subject.server).not_to be subject.server
    end
  end

  shared_examples_for 'ConfigTree configuration' do
    it 'configures the object' do
      subject.get(:port) { 80 }
      subject.public_send(method_name, :server) { Server.new }

      expect(subject.server.port).to eq 80
    end

    it 'supports overriding options' do
      subject.get(:port) { 80 }
      subject.public_send(method_name, :server) { |c| Server.new port: 81 }

      expect(subject.server.port).to eq 81
    end

    it 'doesn\'t resolve the dependency at injection time' do
      target = double(:target, port: 1)

      expect(target).not_to receive(:port)

      subject.get(:port) { target.port }
      subject.public_send(method_name, :server) { |c| Server.new }
      subject.server
    end
  end


  shared_examples_for 'ConfigTree customization' do
    it 'allows overriding values defined with' do
      subject.get(:port) { 80 }
      subject.public_send(method_name, :server) { |c| Server.new port: c.port }
      subject.customize(:server) { |c| c.get(:port) { 443 } }

      expect(subject.server.port).to eq 443
      expect(subject.port).to eq 80
    end

    it 'allows customizing inline' do
      subject.get(:port) { 80 }

      subject.public_send(method_name, :server) do |c|
        Server.new port: c.port 
      end.customize do |c|
        c.get(:port) { 443 }
      end

      expect(subject.server.port).to eq 443
      expect(subject.port).to eq 80
    end
  end

  describe '#get' do
    let(:method_name) { :get }
    before { stub_const('Server', plain_server_class) }

    it_behaves_like 'ConfigTree definition'
    it_behaves_like 'ConfigTree NO memoization'
    it_behaves_like 'ConfigTree customization'
  end

  describe '#get_configured' do
    let(:method_name) { :get_configured }
    before { stub_const('Server', configurable_server_class) }

    it_behaves_like 'ConfigTree definition'
    it_behaves_like 'ConfigTree configuration'
    it_behaves_like 'ConfigTree NO memoization'
    it_behaves_like 'ConfigTree customization'
  end

  describe '#let' do
    let(:method_name) { :let }
    before { stub_const('Server', plain_server_class) }

    it_behaves_like 'ConfigTree definition'
    it_behaves_like 'ConfigTree memoization'
    it_behaves_like 'ConfigTree customization'
  end

  describe '#let!' do
    let(:method_name) { :let! }
    before { stub_const('Server', plain_server_class) }

    it_behaves_like 'ConfigTree definition'
    it_behaves_like 'ConfigTree memoization'
    it_behaves_like 'ConfigTree eager loading'
  end

  describe '#let_configured' do
    let(:method_name) { :let_configured }
    before { stub_const('Server', configurable_server_class) }

    it_behaves_like 'ConfigTree definition'
    it_behaves_like 'ConfigTree memoization'
    it_behaves_like 'ConfigTree configuration'
    it_behaves_like 'ConfigTree customization'
  end

  describe '#let_configured!' do
    let(:method_name) { :let_configured! }
    before { stub_const('Server', configurable_server_class) }

    it_behaves_like 'ConfigTree definition'
    it_behaves_like 'ConfigTree memoization'
    it_behaves_like 'ConfigTree configuration'
    it_behaves_like 'ConfigTree eager loading'
  end

  describe 'inspect' do
    it 'is pretty' do
      subject = described_class.new :app
      subject.get(:logger) { }
      subject.get(:port) { }

      expect(subject.inspect).to match(/app.*logger/)
    end
  end

  describe 'section' do
    before { stub_const('Server', plain_server_class) }

    it 'creates another config' do
      subject.section(:servers) do |c|
        c.get(:main) { Server.new }
      end

      expect(subject.servers.main).to be_a Server
    end

    it 'forwards undefined messages' do
      subject.get(:logger) { :a_logger }
      subject.section(:servers)
      expect(subject.servers.logger).to be :a_logger
    end
  end
end
