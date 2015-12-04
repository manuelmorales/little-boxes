require_relative '../spec_helper'

RSpec.describe LittleBoxes::Configurable do
  subject { Server.new }

  before do
    stub_const('Server', Class.new { include LittleBoxes::Configurable })
  end

  describe 'instance' do
    before do
      Server.class_eval { configurable :port, memoize: true }
    end

    it 'allows passing the config in the initializer' do
      subject = Server.new(port: 80)
      expect(subject.send(:port)).to eq 80
    end

    it 'allows configuring it' do
      subject.configure { |c| c.port = 80 }
      expect(subject.send(:port)).to eq 80
    end

    it 'allows configuring with lambdas' do
      subject.configure { |c| c.port { 80 } }
      expect(subject.send(:port)).to eq 80
    end

    it 'allows configuring with lambdas memoized' do
      subject.configure { |c| c.port { Object.new } }
      expect(subject.send(:port)).to be subject.send(:port)
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

    describe 'dup and clone' do
      it 'separates the config on dup' do
        other = subject.dup
        expect(subject.config).not_to be other.config
      end

      it 'separates the config on clone' do
        other = subject.clone
        expect(subject.config).not_to be other.config
      end

      it 'copies the config on dup' do
        subject.config[:port] = 99
        other = subject.dup
        expect(other.config.port).to eq 99
      end
    end
  end

  describe 'instance (not memoized)' do
    before do
      Server.class_eval { configurable :port }
    end

    it 'doesn\'t memoize' do
      subject.configure { |c| c.port { Object.new } }
      expect(subject.send(:port)).not_to be subject.send(:port)
    end
  end

  describe 'class' do
    subject do
      Server.class_eval do
        class_configurable :port, memoize: true
      end
    end

    it 'has class config' do
      subject.config.port = 80
      expect(subject.config.port).to eq 80
    end

    it 'exposes class keys as private methods' do
      subject.config.port = 80
      expect(subject.send :port).to eq 80
    end

    it 'exposes keys as private methods' do
      subject.class_eval { class_configurable :port }
      subject.config.port = 80
      expect(subject.send :port).to eq 80
    end

    it 'returns the class after configuring' do
      obj = subject.configure { }
      expect(obj).to be subject
    end

    it 'allows configuring with lambdas' do
      subject.class_eval { class_configurable :port }
      subject.config.port { 80 }
      expect(subject.config.port).to eq 80
    end
  end

  describe 'instance (not memoized)' do
    before do
      Server.class_eval { class_configurable :port }
    end

    it 'doesn\'t memoize' do
      subject.class.configure { |c| c.port { Object.new } }
      expect(subject.send(:port)).not_to be subject.send(:port)
    end
  end
end
