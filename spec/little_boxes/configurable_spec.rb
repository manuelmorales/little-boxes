require_relative '../spec_helper'

RSpec.describe LittleBoxes::Configurable do
  subject { Server.new }

  before do
    stub_const('Server', Class.new { include LittleBoxes::Configurable })
    Server.class_eval { configurable :port }
  end

  it 'allows passing the config in the initializer' do
    subject = Server.new(port: 80)
    expect(subject.send(:port)).to eq 80
  end

  it 'allows configuring it' do
    subject.configure { |c| c.port = 80 }
    expect(subject.send(:port)).to eq 80
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
    subject.configure { |c| c.port = 80 }
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

  it 'has class config' do
    Server.class_eval { class_configurable :default_port }
    Server.config.default_port = 80
    expect(Server.config.default_port).to eq 80
  end
end
