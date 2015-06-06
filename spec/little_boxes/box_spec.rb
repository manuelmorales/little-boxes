require_relative '../spec_helper'

describe LittleBoxes::Box do
  subject{ subject_class.new }
  let(:subject_class) { LittleBoxes::Box }

  it 'can build instances' do
    expect(subject).to be_a(LittleBoxes::Box)
  end

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
      attr_accessor :logger

      def dependencies
        {logger: nil}
      end
    end

    subject.let(:logger) { double('logger') }
    subject.dependant(:server) { server_class.new }
    expect(subject.server.logger).to be subject.logger
  end

  it 'unknown dependencies raise exception' do
    server_class = Class.new do
      attr_accessor :logger

      def dependencies
        {unknoun_dep: nil}
      end
    end

    subject.dependant(:server) { server_class.new }
    expect{ subject.server }.to raise_error(LittleBoxes::MissingDependency)
  end

  it 'has classes that have class dependencies' do
    server_class = Class.new do
      class << self
        attr_accessor :host

        def dependencies
          {host: nil}
        end
      end
    end

    subject.let(:host) { 'localhost' }
    subject.dependant(:server_class) { server_class }
    expect(subject.server_class.host).to eq 'localhost'
  end

  it 'supports overriding specific attributes' do
    server_class = Class.new do
      attr_accessor :logger

      def dependencies
        {logger: nil}
      end
    end

    subject.let(:logger) { :logger }
    subject.let(:new_logger) { :new_logger }

    subject.custom_dependant(:server) do
      build { server_class.new }
      let(:logger) { :new_logger }
    end

    expect(subject.server.logger).to be :new_logger
  end

  it 'supports suggestions' do
    server_class = Class.new do
      attr_accessor :log

      def dependencies
        {log: {suggestion: ->(a){ a.logger } } }
      end
    end

    subject.let(:logger) { :logger }

    subject.dependant(:server) { server_class.new }

    expect(subject.server.log).to be :logger
  end

  it 'supports sections' do
    subject.section :loggers do
      let(:null) { :null_logger }
      let(:file) { :file_logger }
    end

    expect(subject.loggers.null).to be :null_logger
  end

  it 'supports finding dependencies upwards in the ancestry' do
    server_class = Class.new do
      attr_accessor :logger

      def dependencies
        {logger: nil}
      end
    end

    subject.let(:logger) { :logger }

    subject.section :servers do
      dependant(:one) { server_class.new }
    end

    expect(subject.servers.one.logger).to be :logger
  end

  it 'suggestions within sections' do
    server_class = Class.new do
      attr_accessor :log

      def dependencies
        {log: {suggestion: ->(a){ a.logger } } }
      end
    end

    subject.let(:logger) { :logger }

    subject.section :servers do
      dependant(:apache) { server_class.new }
    end

    expect(subject.servers.apache.log).to be :logger
  end

  it 'supports defining registers at class level' do
    subject_class = Class.new LittleBoxes::Box do
      let(:loglevel) { 0 }
    end

    subject = subject_class.new

    expect(subject.loglevel).to eq 0
  end

  it 'does not share objects with the different instances' do
    subject_class = Class.new LittleBoxes::Box do
      let(:loglevel) { '0' }
    end

    subject_1 = subject_class.new
    subject_2 = subject_class.new

    expect(subject_1.loglevel).not_to be subject_2.loglevel
  end

  it 'has nice inspect' do
    subject.let(:loglevel) { 0 }
    subject.let(:logger) { 0 }
    expect(subject.inspect).to eq "<LittleBoxes::Box box: loglevel logger>"
  end

  it 'has nice class inspect' do
    subject_class = Class.new LittleBoxes::Box do
      let(:loglevel) { 0 }
      let(:logger) { 0 }
    end

    expect(subject_class.inspect).to eq "Box(loglevel logger)"
  end

  it 'supports overriding specific attributes by inheritance' do
    subject_class_1 = Class.new LittleBoxes::Box do
      let(:loglevel) { 0 }
      let(:logger) { :logger }
    end

    subject_class_2 = Class.new subject_class_1 do
      let(:loglevel) { 1 }
    end

    subject_2 = subject_class_2.new

    expect(subject_2.loglevel).to eq 1
    expect(subject_2.logger).to eq :logger
  end

  it 'supports overriding dependants attributes from the outside' do
    server_class = Class.new do
      attr_accessor :logger

      def dependencies
        {logger: nil}
      end
    end

    subject.let(:logger) { :logger }

    subject.dependant(:server) { server_class.new }

    subject.customize(:server) do
      let(:logger) { :new_logger }
    end

    expect(subject.server.logger).to be :new_logger
  end

  it 'has a path' do
    first_class = Class.new LittleBoxes::Box do
      section :second do
        section :third do
        end
      end
    end

    first = first_class.new

    expect(first.second.third.path).to eq [first, first.second, first.second.third]
  end

  it 'names sections' do
    first_class = Class.new LittleBoxes::Box do
      section :second do
        section :third do
        end
      end
    end

    first = first_class.new name: :first

    expect(first.second.third.path.map(&:name)).to eq [:first, :second, :third]
  end

  it 'has a reset' do
    first_class = Class.new LittleBoxes::Box do
      section :second do
        let(:logger) { Object.new }
      end
    end

    first = first_class.new name: :first

    old_logger = first.second.logger
    first.reset
    expect(first.second.logger).not_to be old_logger
  end

  it 'has a root' do
    first_class = Class.new LittleBoxes::Box do
      section :second do
        section :third do
        end
      end
    end

    first = first_class.new

    expect(first.second.third.root).to eq first
  end

  it 'assigns dependencies with lambdas' do
    server_class = Class.new do
      include LittleBoxes::Dependant

      dependency :logger
    end

    subject.dependant(:server) { server_class.new }

    subject.let(:logger) { :old }
    expect(subject.server.logger).to be :old

    subject.let(:logger) { :new }
    expect(subject.server.logger).to be :new
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
      subject.dependant(:dependant_one) { class_one.new }
      subject.dependant(:dependant_two) { class_two.new }

      expect(subject.dependant_one.one).to be :one
      expect(subject.dependant_two.one).to be :one
      expect(subject.dependant_two.two).to be :two
    end
  end

  # it 'has an always executing block'
  # it 'uses logger if defined'
end
