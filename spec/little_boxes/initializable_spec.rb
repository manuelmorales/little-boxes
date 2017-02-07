require_relative '../spec_helper'

RSpec.describe 'Initializable' do
  def define_class name, base = Object, &block
    stub_const(name.to_s, Class.new(base)).tap do |c|
      c.class_eval(&block)
    end
  end

  before :each do
    define_class :User do
      include Initializable
      include Configurable

      dependency :age
    end
  end

  it 'allows configuring attributes in initialize' do
    user = User.new age: 24
    expect(user.age).to be 24
  end

  it 'allows initializing with no args' do
    expect { User.new }.not_to raise_error
  end
end
