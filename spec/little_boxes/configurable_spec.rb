require_relative '../spec_helper'

RSpec.describe 'Configurable' do
  def define_class name, &block
    stub_const(name.to_s, Class.new).tap do |c|
      c.class_eval(&block)
    end
  end

  it 'assigns on initialize' do
    define_class 'UserRepo' do
      include Configurable
      dependency :store
    end

    repo = UserRepo.new store: :the_store

    expect(repo.store).to be :the_store
  end

  it 'respects the original initialize' do
    stub_const('TheDouble', double(:the_double))
    expect(TheDouble).to receive(:do_your_thing)

    define_class 'BaseRepo' do
      def initialize
        TheDouble.do_your_thing
      end
    end

    stub_const('UsersRepo', Class.new(BaseRepo)).class_eval do
      include Configurable
    end

    UsersRepo.new
  end

  it 'respects the original initialize arguments' do
    stub_const('TheDouble', double(:the_double))
    expect(TheDouble).to receive(:do_your_thing).with :some_arg

    define_class 'BaseRepo' do
      def initialize(some_arg)
        TheDouble.do_your_thing some_arg
      end
    end

    stub_const('UsersRepo', Class.new(BaseRepo)).class_eval do
      include Configurable
    end

    UsersRepo.new :some_arg
  end
end
