require 'spec_helper'

RSpec.describe "[Integration] Thread safety" do
  let(:configurable) { Struct.new(:config) }
  let(:dependency_block) do
    ->(box) do
      sleep 0.1
      configurable.new
    end
  end
  let(:box) { box_class.new }

  describe 'LittleBoxes::Box#let' do
    let(:box_class) do
      _dependency_block = dependency_block

      Class.new do
        include LittleBoxes::Box
        let :dependency, &_dependency_block
      end
    end

    it 'is thread safe' do
      expect(dependency_block).to receive(:call).once.and_call_original
      20.times.map { Thread.new { box.dependency } }.each(&:join)
    end
  end

  describe 'LittleBoxes::Box#letc' do
    let(:box_class) do
      _dependency_block = dependency_block

      Class.new do
        include LittleBoxes::Box
        letc :dependency, &_dependency_block
      end
    end

    it 'is thread safe' do
      expect(dependency_block).to receive(:call).once.and_call_original
      20.times.map { Thread.new { box.dependency } }.each(&:join)
    end
  end

  describe 'LittleBoxes::Box#get' do
    let(:box_class) do
      _dependency_block = dependency_block

      Class.new do
        include LittleBoxes::Box
        get :dependency, &_dependency_block
      end
    end

    it 'does not use a mutex' do
      expect_any_instance_of(Mutex).to_not receive(:synchronize)
      20.times.map { Thread.new { box.dependency } }.each(&:join)
    end
  end

  describe 'LittleBoxes::Box#getc' do
    let(:box_class) do
      _dependency_block = dependency_block

      Class.new do
        include LittleBoxes::Box
        getc :dependency, &_dependency_block
      end
    end

    it 'does not use a mutex' do
      expect_any_instance_of(Mutex).to_not receive(:synchronize)
      20.times.map { Thread.new { box.dependency } }.each(&:join)
    end
  end
end
