require_relative '../spec_helper'
require 'ostruct'

describe LittleBoxes::Box do
  subject{ described_class.new }

  describe '#customize' do
    it 'allows customizing dependencies' do
      subject.let(:loglevel) { 0 }
      subject.let(:logger) { double('logger', loglevel: loglevel) }

      subject.customize(:logger) do |l|
        l.let(:loglevel) { 1 }
      end

      expect(subject.logger.loglevel).to eq 1
    end

    it 'supports overriding lets attributes from the outside' do
      server_class = Class.new do
        include LittleBoxes::Dependant
        dependency :logger
      end

      subject.let(:logger) { :logger }

      subject.let(:server) { server_class.new }

      subject.customize(:server) do
        let(:logger) { :new_logger }
      end

      expect(subject.server.logger).to be :new_logger
    end
  end

  describe '#let' do
    it 'has freely defined registers with just a lambda' do
      subject.let(:loglevel) { 0 }
      expect(subject.loglevel).to eq 0
    end

    it 'memoizes the result' do
      n = 0
      subject.let(:loglevel) { n = n + 1 }

      expect(subject.loglevel).to eq 1
      expect(subject.loglevel).to eq 1
    end

    it 'allows referencing other dependencies within such lambda' do
      subject.let(:loglevel) { 0 }
      subject.let(:logger) { double('logger', loglevel: loglevel) }
      expect(subject.logger.loglevel).to eq 0
    end

    it 'has instances that have dependencies' do
      server_class = Class.new do
        include LittleBoxes::Dependant
        dependency :logger
      end

      subject.let(:logger) { double('logger') }
      subject.let(:server) { server_class.new }
      expect(subject.server.logger).to be subject.logger
    end

    it 'unknown dependencies raise exception' do
      server_class = Class.new do
        include LittleBoxes::Dependant
        dependency :unknown_dep
      end

      subject.let(:server) { server_class.new }
      expect{ subject.server.unknown_dep }.to raise_error(LittleBoxes::MissingDependency)
    end

    it 'has classes that have class dependencies' do
      server_class = Class.new do
        include LittleBoxes::Dependant
        class_dependency :host
      end

      subject.let(:host) { 'localhost' }
      subject.let(:server_class) { server_class }
      expect(subject.server_class.host).to eq 'localhost'
    end

    it 'supports defaults' do
      server_class = Class.new do
        include LittleBoxes::Dependant
        dependency :log, default: ->(d){ d.logger }
      end

      subject.let(:logger) { :logger }

      subject.let(:server) { server_class.new }

      expect(subject.server.log).to be :logger
    end

    it 'assigns dependencies with lambdas' do
      server_class = Class.new do
        include LittleBoxes::Dependant

        dependency :logger
      end

      subject.let(:server) { server_class.new }

      subject.let(:logger) { :old }
      expect(subject.server.logger).to be :old

      subject.let(:logger) { :new }
      expect(subject.server.logger).to be :new
    end

    it 'supports overriding specific attributes' do
      server_class = Class.new do
        include LittleBoxes::Dependant
        dependency :logger
      end

      subject.let(:logger) { :logger }
      subject.let(:new_logger) { :new_logger }

      subject.let(:server) do
        build { server_class.new }
        let(:logger) { new_logger }
      end

      expect(subject.server.logger).to be :new_logger
    end
  end

  describe '#obtain' do
    it 'does not memoize the result' do
      n = 0
      subject.obtain(:loglevel) { n = n + 1 }

      expect(subject.loglevel).to eq 1
      expect(subject.loglevel).to eq 2
    end

    it 'doesn not inject anything' do
      server_class = Class.new do
        include LittleBoxes::Dependant
        dependency :logger
      end

      subject.let(:logger) { double('logger') }
      subject.obtain(:server) { server_class.new.tap { |s| s.logger = :old_logger } }
      expect(subject.server.logger).to be :old_logger
    end
  end

  describe '#define' do
    it 'does not memoize the result' do
      n = 0
      subject.define(:loglevel) { n = n + 1 }

      expect(subject.loglevel).to eq 1
      expect(subject.loglevel).to eq 2
    end

    it 'has instances that have dependencies' do
      server_class = Class.new do
        include LittleBoxes::Dependant
        dependency :logger
      end

      subject.let(:logger) { double('logger') }
      subject.define(:server) { server_class.new }
      expect(subject.server.logger).to be subject.logger
    end

    it 'unknown dependencies raise exception' do
      server_class = Class.new do
        include LittleBoxes::Dependant
        dependency :unknown_dep
      end

      subject.define(:server) { server_class.new }
      expect{ subject.server.unknown_dep }.to raise_error(LittleBoxes::MissingDependency)
    end

    it 'has classes that have class dependencies' do
      server_class = Class.new do
        include LittleBoxes::Dependant
        class_dependency :host
      end

      subject.let(:host) { 'localhost' }
      subject.define(:server_class) { server_class }
      expect(subject.server_class.host).to eq 'localhost'
    end

    it 'supports defaults' do
      server_class = Class.new do
        include LittleBoxes::Dependant
        dependency :log, default: ->(d){ d.logger }
      end

      subject.let(:logger) { :logger }

      subject.define(:server) { server_class.new }

      expect(subject.server.log).to be :logger
    end

    it 'assigns dependencies with lambdas' do
      server_class = Class.new do
        include LittleBoxes::Dependant

        dependency :logger
      end

      subject.define(:server) { server_class.new }

      subject.let(:logger) { :old }
      expect(subject.server.logger).to be :old

      subject.let(:logger) { :new }
      expect(subject.server.logger).to be :new
    end
  end

  describe '#box' do
    it 'supports boxes' do
      subject.box :loggers do
        let(:null) { :null_logger }
        let(:file) { :file_logger }
      end

      expect(subject.loggers.null).to be :null_logger
    end

    it 'supports finding dependencies upwards in the ancestry' do
      server_class = Class.new do
        include LittleBoxes::Dependant
        dependency :logger
      end

      subject.let(:logger) { :logger }

      subject.box :servers do
        let(:one) { server_class.new }
      end

      expect(subject.servers.one.logger).to be :logger
    end

    it 'defaults within boxes' do
      server_class = Class.new do
        include LittleBoxes::Dependant
        dependency :log, default: ->(a){ a.logger }
      end

      subject.let(:logger) { :logger }

      subject.box :servers do
        let(:apache) { server_class.new }
      end

      expect(subject.servers.apache.log).to be :logger
    end
  end

  describe '#inspect' do
    it 'has nice inspect' do
      subject.let(:loglevel) { 0 }
      subject.let(:logger) { 0 }
      expect(subject.inspect).to eq "<LittleBoxes::Box box: loglevel logger>"
    end
  end
  
  describe '#path' do
    it 'has a path' do
      subject.box :second do
        box :third do
        end
      end

      expect(subject.second.third.path).to eq [subject, subject.second, subject.second.third]
    end
  end

  describe '#name' do
    it 'names boxes' do
      subject.name = :first

      subject.box :second do
        box :third do
        end
      end

      expect(subject.second.third.path.map(&:name)).to eq [:first, :second, :third]
    end
  end

  describe '#reset' do
    it 'has a reset' do
      first = subject

      first.box :second do
        let(:logger) { Object.new }
      end

      old_logger = first.second.logger

      first.reset
      expect(first.second.logger).not_to be old_logger
    end
  end

  describe '#root' do
    it 'has a root' do
      first = subject

      first.box :second do
        box(:third) { }
      end

      expect(first.second.third.root).to eq first
    end
  end

  describe '.new' do
    it 'executes block on initialize' do
      subject = described_class.new do
        let(:loglevel) { 0 }
      end

      expect(subject.loglevel).to eq 0
    end

    it 'can build instances' do
      expect(subject).to be_a(described_class)
    end
  end
end
