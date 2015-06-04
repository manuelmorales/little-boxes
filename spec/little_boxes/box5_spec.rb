require_relative '../spec_helper'

describe LittleBoxes::Box5 do
  subject{ subject_class.new }
  let(:subject_class) { LittleBoxes::Box5 }

  it 'can build instances' do
    expect(subject).to be_a(LittleBoxes::Box5)
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
    expect{ subject.server }.to raise_error(LittleBoxes::Box5::MissingDependency)
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
    subject_class = Class.new LittleBoxes::Box5 do
      let(:loglevel) { 0 }
    end

    subject = subject_class.new

    expect(subject.loglevel).to eq 0
  end

  it 'does not share objects with the different instances' do
    subject_class = Class.new LittleBoxes::Box5 do
      let(:loglevel) { '0' }
    end

    subject_1 = subject_class.new
    subject_2 = subject_class.new

    expect(subject_1.loglevel).not_to be subject_2.loglevel
  end

  it 'has nice inspect' do
    subject.let(:loglevel) { 0 }
    subject.let(:logger) { 0 }
    expect(subject.inspect).to eq "<LittleBoxes::Box5 box: loglevel logger>"
  end

  it 'has nice class inspect' do
    subject_class = Class.new LittleBoxes::Box5 do
      let(:loglevel) { 0 }
      let(:logger) { 0 }
    end

    expect(subject_class.inspect).to eq "Box(loglevel logger)"
  end

  it 'supports overriding specific attributes by inheritance' do
    subject_class_1 = Class.new LittleBoxes::Box5 do
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

  # it 'supports overriding dependants in sections from the outside'
  # it 'supports overriding dependants attributes from the outside'
  # it 'warns if overriding by mistake'
  # it 'has logging'
  # it 'raises exception if overriding after it has been used'
end
