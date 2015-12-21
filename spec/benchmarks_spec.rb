require_relative 'spec_helper'
require 'benchmark'
require'logger'

RSpec.describe 'Benchmark the speed', benchmark: true do
  def define_class name, &block
    stub_const(name, Class.new).tap do |c|
      c.class_eval(&block)
    end
  end

  def iterations
    100000
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
    File.open 'tmp/benchmarks.log', 'w' do |r|
      @results.sort_by{|res| res[:time] }.each do |res|
        r.puts "#{'%0.4f' % res[:time]}s #{res[:name]}"
      end
    end

    puts File.read 'tmp/benchmarks.log' if ENV['BENCH_OUT']
  end

  it '.config -> @config -> .port -> @port' do
    define_class 'Server' do
      def port
        config.port
      end

      def config
        @config ||= Configuration.new
      end
    end

    define_class 'Configuration' do
      def port
        @port ||= 80
      end
    end

    server = Server.new

    measure { server.port }
  end

  it '.config -> @config -> [:port]' do
    define_class 'Server' do
      def port
        config[:port]
      end

      def config
        @config ||= {port: 80}
      end
    end

    server = Server.new

    measure { server.port }
  end

  it '.port_proc -> @port_proc -> .call' do
    define_class 'Server' do
      def port
        port_proc.call
      end

      def port_proc
        @port_proc ||= lambda { 90 }
      end
    end

    server = Server.new

    measure { server.port }
  end

  it '.port -> @port' do
    define_class 'Server' do
      def port
        the_port
      end

      def the_port
        @port ||= 80
      end
    end

    server = Server.new

    measure { server.port }
  end

  it '@port' do
    define_class 'Server' do
      def initialize
        @port = 80
      end

      def port
        @port
      end
    end

    server = Server.new

    measure { server.port }
  end

  it 'Port' do
    define_class 'Server' do
      Port = 80

      def port
        Port
      end
    end

    server = Server.new

    measure { server.port }
  end

  it '@config[:port]' do
    define_class 'Server' do
      def port
        @config[:port]
      end

      def initialize
        @config = begin
                      Hash.new.tap do |h|
                        h.default_proc = lambda do |hash, key|
                          h[:port] = 80
                        end
                      end
                    end
      end
    end

    server = Server.new

    measure { server.port }
  end
end
