require_relative '../spec_helper'

RSpec.describe 'Box' do
  subject { my_box_class.new }

  let(:my_box_class) do
    m1 = Module.new do
      include Box

      get(:port) { '80' }
      get(:log_level) { 'INFO' }
    end

    m2 = Module.new  do
      include Box
      get(:log_level_as_symbol) { log_level.to_sym }
      let(:logger) { Logger.new log_level }
      let(:server) { Server.new }

      let(:users) { UsersBox.new }
    end

    Class.new.tap {|c| c.class_eval { include m1; include m2 } }
  end

  let(:users_box) do
    Class.new do
      include Box

      get(:table_name) { 'users' }
      get(:repo) { Repo.new logger }
    end
  end

  before do
    stub_const('Server', Class.new)
    stub_const('UsersBox', users_box)

    Server.class_eval do
      attr_accessor :logger

      def initialize(args)
        args.each { |k,v| send "#{k}=", v }
      end
    end

    stub_const 'Logger', Class.new

    Logger.class_eval do
      attr_accessor :level

      def initialize(level)
        @level = level
      end
    end

    stub_const 'Repo', Class.new
    Repo.class_eval do
      attr_accessor :logger

      def initialize(logger)
        @logger = logger
      end
    end
  end

  it 'can return a value' do
    expect(subject.port).to eq '80'
  end

  it 'can access values from other values in get' do
    expect(subject.log_level_as_symbol).to eq subject.log_level.to_sym
  end

  it 'can access values from other values in let' do
    expect(subject.logger.level).to eq subject.log_level
  end

  it 'doesn\'t share memoized values between instancens of the box' do
    expect(subject.logger).not_to be my_box_class.new.logger
  end

  it 'can memoize values' do
    expect(subject.logger).to be subject.logger
  end

  it 'supports metaboxes' do
    expect(subject.users.table_name).to eq 'users'
  end

  it 'supports getting values from the parent' do
    expect(subject.users.repo.logger).to be_a Logger
  end
end
