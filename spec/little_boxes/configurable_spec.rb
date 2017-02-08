require_relative '../spec_helper'

RSpec.describe 'Configurable' do
  it 'provides the Dependant functionality' do
    define_class :Server do
      include Configurable
      dependency :instance_dependency
      class_dependency :class_dependency
    end

    Server.class_dependency = :class_dep
    expect(Server.class_dependency).to be :class_dep

    server = Server.new
    server.instance_dependency = :instance_dep
    expect(server.instance_dependency).to be :instance_dep
  end

  it 'provides the Initializable functionality' do
    define_class :Server do
      include Configurable
      dependency :instance_dependency
    end

    server = Server.new instance_dependency: :instance_dep
    expect(server.instance_dependency).to be :instance_dep
  end
end
