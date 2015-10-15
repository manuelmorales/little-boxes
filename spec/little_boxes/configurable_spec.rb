require_relative '../spec_helper'

RSpec.describe LittleBoxes::Configurable do
  subject { Server.new }

  before do
    stub_const('Server', Class.new { include LittleBoxes::Configurable })
    Server.class_eval { configurable :port }
  end

  describe 'instance' do
    it 'allows passing the config in the initializer' do
      subject = Server.new(port: 80)
      expect(subject.send(:port)).to eq 80
    end

    it 'allows configuring it' do
      subject.configure { |c| c.port = 80 }
      expect(subject.send(:port)).to eq 80
    end

    it 'returns the object after configuring' do
      obj = subject.configure { |c| c.port = 80 }
      expect(obj).to be subject
    end

    it 'fails if the wrong config name is used' do
      expect{ subject.configure { |c| c.whatever = :anything } }
      .to raise_error(NoMethodError)
    end

    it 'has a nice inspect' do
      Server.class_eval do
        def start; end
        def stop; end
      end

      expect(subject.inspect).to match %r{#<Server:0x[0-f]+ start, stop>}
    end

    it 'allows iterating through the dependencies' do
      expect(subject.config.keys).to eq [:port]
    end

    it 'allows setting keys as a hash' do
      subject.config[:port] = 80
      expect(subject.config[:port]).to eq 80
    end

    it 'has a nice config inspect' do
      expect(subject.config.inspect)
      .to match %r{#<Server::Config:0x[0-f]+ port>}
    end

    it 'clears the config on dup' do
      other = subject.dup
      expect(subject.config).not_to be other.config
    end

    it 'clears the config on clone' do
      other = subject.clone
      expect(subject.config).not_to be other.config
    end
  end

  describe 'class' do
    it 'has class config' do
      Server.class_eval { class_configurable :default_port }
      Server.config.default_port = 80
      expect(Server.config.default_port).to eq 80
    end

    it 'exposes class keys as private methods' do
      Server.class_eval { class_configurable :default_port }
      Server.config.default_port = 80
      expect(Server.send :default_port).to eq 80
    end

    it 'exposes keys as private methods' do
      Server.class_eval { configurable :port }
      subject.config.port = 80
      expect(subject.send :port).to eq 80
    end

    it 'returns the class after configuring' do
      obj = Server.configure { }
      expect(obj).to be Server
    end
  end
end
