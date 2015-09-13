require_relative '../spec_helper'

RSpec.describe LittleBoxes::Config do
  before do
    server_class = Class.new do
      attr_accessor :port

      def initialize(args = {})
        @port = args[:port]
      end
    end

    stub_const('Server', server_class)
  end

  describe '#get' do
    it 'defines a method' do
      subject.get(:server) { Server.new }
      expect(subject.server).to be_a Server
    end

    it 'builds a new instance each time' do
      subject.get(:server) { Server.new }
      expect(subject.server).not_to be subject.server
    end

    it 'supports mentioning others' do
      subject.get(:port) { 80 }
      subject.get(:server) { |c| Server.new port: c.port }

      expect(subject.server.port).to eq 80
    end
  end

  describe '#let' do
    it 'defines a method' do
      subject.let(:server) { Server.new }
      expect(subject.server).to be_a Server
    end

    it 'memoizes the response' do
      subject.let(:server) { Server.new }
      expect(subject.server).to be subject.server
    end

    it 'supports mentioning others' do
      subject.let(:port) { 80 }
      subject.let(:server) { |c| Server.new port: c.port }

      expect(subject.server.port).to eq 80
    end
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

  describe 'custom' do
    it 'allows overriding values defined with get' do
      subject.get(:port) { 80 }
      subject.get(:server) { |c| Server.new port: c.port }
      subject.customize(:server) { |c| c.get(:port) { 443 } }

      expect(subject.server.port).to eq 443
      expect(subject.port).to eq 80
    end

    it 'allows overriding values defined with let' do
      subject.let(:port) { 80 }
      subject.let(:server) { |c| Server.new port: c.port }
      subject.customize(:server) { |c| c.let(:port) { 443 } }

      expect(subject.server.port).to eq 443
      expect(subject.port).to eq 80
    end

    it 'allows customizing inline' do
      subject.get(:port) { 80 }
      subject.get(:server) { |c| Server.new port: c.port }.customize do |c|
        c.get(:port) { 443 }
      end

      expect(subject.server.port).to eq 443
      expect(subject.port).to eq 80
    end
  end
end
