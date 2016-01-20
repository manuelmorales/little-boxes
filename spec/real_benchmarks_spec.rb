require_relative 'spec_helper'
require 'benchmark'
require 'logger'

RSpec.describe 'Benchmark the speed', benchmark: true do
  def define_class name, &block
    stub_const(name.to_s, Class.new).tap do |c|
      c.class_eval(&block)
    end
  end

  def iterations
    500000
  end

  def test_name
    @__inspect_output.
      gsub(/^"/,'').
      gsub(/" \([^\(]+\)/,'')
  end

  def measure
    b = Benchmark.measure{ iterations.times { yield } }
    @results << {name: test_name, time: b.real}
  end

  before :all do
    @results = []
  end

  after :all do
    File.open 'tmp/real_benchmarks.log', 'w' do |r|
      @results.sort_by{|res| res[:time] }.each do |res|
        r.puts "#{'%0.4f' % res[:time]}s #{res[:name]}"
      end
    end

    puts File.read 'tmp/real_benchmarks.log' if ENV['BENCH_OUT']
  end

  context 'shallow' do
    before do
      define_class :Server do
        include Configurable

        dependency :logger
        dependency :new_logger
        public :new_logger
        public :logger
      end

      configurable_server = Server.new

      define_class :MainBox do
        include Box

        get(:new_logger) { :logger }
        let(:logger) { :logger }
        letc(:server) { Server.new }
        getc(:new_server) { configurable_server }
      end

      define_class :Logger do
      end
    end

    let(:box) { MainBox.new }
    define_method(:logger) { box.logger }
    define_method(:server) { box.server }

    it 'measures getting a memoized dependency within the dependant' do
      server = server()
      measure { server.logger }
    end

    it 'measures getting a dependency within the dependant' do
      server = server()
      measure { server.new_logger }
    end

    it 'measures config time' do
      box = box()
      measure { box.new_server }
    end

    it 'measures first dependency injection time' do
      box = box()
      measure { box.new_server.logger } 
    end
  end

  context 'deep' do
    before do
      define_class :Server do
        include Configurable

        dependency :logger
        dependency :new_logger
        public :new_logger
        public :logger
      end

      configurable_server = Server.new

      define_class :MainBox do
        include Box

        get(:new_logger) { :logger }
        let(:logger) { :logger }

        box(:level) do
          box(:level) do
            box(:level) do
              letc(:server) { Server.new }
              getc(:new_server) { configurable_server }
            end
          end
        end
      end

      define_class :Logger do
      end
    end

    let(:box) { MainBox.new }
    define_method(:logger) { box.logger }
    define_method(:server) { box.level.level.level.server }

    it 'measures config time (deep)' do
      box = box().level.level.level
      measure { box.new_server }
    end

    it 'measures first dependency injection time (deep)' do
      box = box().level.level.level
      measure { box.new_server.logger } 
    end
  end
end
