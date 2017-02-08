require_relative '../spec_helper'
require 'redis'

RSpec.describe 'Use cases' do
  it 'does memoization with #let' do
    define_class :MainBox do
      include LittleBoxes::Box
      let(:redis) { require 'redis'; Redis.new }
    end

    box = MainBox.new

    expect(box.redis).to be_a Redis
    expect(box.redis).to be box.redis
  end

  it 'does automatic configuration with letc' do
    define_class :Publisher do
      include LittleBoxes::Configurable
      dependency :redis
    end

    define_class :MainBox do
      include LittleBoxes::Box
      let(:redis) { require 'redis'; Redis.new }
      letc(:publisher) { Publisher.new }
    end

    box = MainBox.new
    expect(box.publisher.redis).to be box.redis
  end

  it 'supports default values' do
    define_class :Repo do
      include LittleBoxes::Configurable
      dependency(:store) { Hash.new }
    end

    define_class :MainBox do
      include LittleBoxes::Box
      letc(:repo) { Repo.new }
    end

    box = MainBox.new
    expect(box.repo.store).to be_a Hash
  end

  it 'supports default values that use the box' do
    define_class :Repo do
      include LittleBoxes::Configurable
      dependency(:log) { |box| box.logger }
    end

    define_class(:Logger) { }

    define_class :MainBox do
      include LittleBoxes::Box
      let(:logger) { Logger.new }
      letc(:repo) { Repo.new }
    end

    box = MainBox.new
    expect(box.repo.log).to be box.logger
  end
end
