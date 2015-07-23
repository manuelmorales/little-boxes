require_relative '../spec_helper'
require 'ostruct'

describe LittleBoxes::Section do
  subject{ described_class.new }

  it 'can build instances' do
    expect(subject).to be_a(described_class)
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
  end

  describe '#customize' do
    it 'allows customizing dependencies' do
      subject.let(:loglevel) { 0 }
      subject.let(:logger) { double('logger', loglevel: loglevel) }

      subject.customize(:logger) do |l|
        l.let(:loglevel) { 1 }
      end

      expect(subject.logger.loglevel).to eq 1
    end

    it 'supports overriding let_dependants attributes from the outside' do
      server_class = Class.new do
        include LittleBoxes::Dependant
        dependency :logger
      end

      subject.let(:logger) { :logger }

      subject.let_dependant(:server) { server_class.new }

      subject.customize(:server) do
        let(:logger) { :new_logger }
      end

      expect(subject.server.logger).to be :new_logger
    end
  end

  describe '#let_dependant' do
    it 'has instances that have dependencies' do
      server_class = Class.new do
        include LittleBoxes::Dependant
        dependency :logger
      end

      subject.let(:logger) { double('logger') }
      subject.let_dependant(:server) { server_class.new }
      expect(subject.server.logger).to be subject.logger
    end

    it 'unknown dependencies raise exception' do
      server_class = Class.new do
        include LittleBoxes::Dependant
        dependency :unknown_dep
      end

      subject.let_dependant(:server) { server_class.new }
      expect{ subject.server.unknown_dep }.to raise_error(LittleBoxes::MissingDependency)
    end

    it 'has classes that have class dependencies' do
      server_class = Class.new do
        include LittleBoxes::Dependant
        class_dependency :host
      end

      subject.let(:host) { 'localhost' }
      subject.let_dependant(:server_class) { server_class }
      expect(subject.server_class.host).to eq 'localhost'
    end

    it 'supports suggestions' do
      server_class = Class.new do
        include LittleBoxes::Dependant
        dependency :log, suggestion: ->(d){ d.logger }
      end

      subject.let(:logger) { :logger }

      subject.let_dependant(:server) { server_class.new }

      expect(subject.server.log).to be :logger
    end

    it 'assigns dependencies with lambdas' do
      server_class = Class.new do
        include LittleBoxes::Dependant

        dependency :logger
      end

      subject.let_dependant(:server) { server_class.new }

      subject.let(:logger) { :old }
      expect(subject.server.logger).to be :old

      subject.let(:logger) { :new }
      expect(subject.server.logger).to be :new
    end
  end

  describe '#let_custom_dependant' do
    it 'supports overriding specific attributes' do
      server_class = Class.new do
        include LittleBoxes::Dependant
        dependency :logger
      end

      subject.let(:logger) { :logger }
      subject.let(:new_logger) { :new_logger }

      subject.let_custom_dependant(:server) do
        build { server_class.new }
        let(:logger) { :new_logger }
      end

      expect(subject.server.logger).to be :new_logger
    end
  end

  describe '#section' do
    it 'supports sections' do
      subject.section :loggers do
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

      subject.section :servers do
        let_dependant(:one) { server_class.new }
      end

      expect(subject.servers.one.logger).to be :logger
    end

    it 'suggestions within sections' do
      server_class = Class.new do
        include LittleBoxes::Dependant
        dependency :log, suggestion: ->(a){ a.logger }
      end

      subject.let(:logger) { :logger }

      subject.section :servers do
        let_dependant(:apache) { server_class.new }
      end

      expect(subject.servers.apache.log).to be :logger
    end
  end

  describe '#inspect' do
    it 'has nice inspect' do
      subject.let(:loglevel) { 0 }
      subject.let(:logger) { 0 }
      expect(subject.inspect).to eq "<LittleBoxes::Section box: loglevel logger>"
    end
  end
  
  describe '#path' do
    it 'has a path' do
      subject.section :second do
        section :third do
        end
      end

      expect(subject.second.third.path).to eq [subject, subject.second, subject.second.third]
    end
  end

  describe '#name' do
    it 'names sections' do
      subject.name = :first

      subject.section :second do
        section :third do
        end
      end

      expect(subject.second.third.path.map(&:name)).to eq [:first, :second, :third]
    end
  end

  describe '#reset' do
    it 'has a reset' do
      first = subject

      first.section :second do
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

      first.section :second do
        section(:third) { }
      end

      expect(first.second.third.root).to eq first
    end
  end

  describe 'Dependant' do
    it 'can be inherited' do
      class_one = Class.new do
        include LittleBoxes::Dependant
        dependency :one
      end

      class_two = Class.new class_one do
        include LittleBoxes::Dependant
        dependency :two
      end

      subject.let(:one) { :one }
      subject.let(:two) { :two }
      subject.let_dependant(:dependant_one) { class_one.new }
      subject.let_dependant(:dependant_two) { class_two.new }

      expect(subject.dependant_one.one).to be :one
      expect(subject.dependant_two.one).to be :one
      expect(subject.dependant_two.two).to be :two
    end
  end

  it 'executes block on initialize' do
    subject = described_class.new do
      let(:loglevel) { 0 }
    end

    expect(subject.loglevel).to eq 0
  end
end
