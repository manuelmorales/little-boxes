require_relative '../spec_helper'

describe LittleBoxes::Box4 do
  subject{ LittleBoxes::Box4.new }

  it 'can build instances' do
    expect(subject).to be_a(LittleBoxes::Box4)
  end

  it 'has freely defined registers with just a lambda' do
    subject.let(:loglevel) { 0 }
    expect(subject.loglevel).to eq 0
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
    expect{ subject.server }.to raise_error(LittleBoxes::Box4::MissingDependency)
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

  # it 'supports mentioning other registers'
  # it 'supports overriding specific attributes'
  # it 'supports overriding specific attributes by inheritance'
  # it 'supports defining registers at class level'
  # it 'has dependencies defined at instance level'
  # it 'supports definitions at class level'
  # it 'supports overriding from the outside'
  # it 'warns if overriding by mistake'
  # it 'has logging'
  # it 'raises meaningful exception if missing register'
  # it 'raises exception if overriding after it has been used'
  # it 'supports sections'
  # it 'supports overriding dependency resolution with sub-section'
  # it 'supports overriding attributes in sub-section'
end
