require_relative 'spec_helper'
require 'logger'

RSpec.describe 'sample app' do
  shared_examples_for 'sample app' do
    it 'can be instantiated' do
      expect{ subject_class.new }.not_to raise_error
    end

    it 'has a logger' do
      expect(subject.logger).to be_a Logger
      expect(subject.logger.level).to be 0
    end

    it 'accepts a logger level' do
      subject.logger_level = 1
      expect(subject.logger.level).to eq 1
    end

    it 'has an api' do
      expect(subject.api).to be_api
      expect(subject.api.logger).to be subject.logger
    end

    # it 'supports sections'
    # it 'supports overriding dependency resolution with sub-section'
    # it 'supports overriding specific dependencies'
  end

  describe 'LittleBoxes::Box1 app' do
    subject { subject_instance }
    let(:subject_instance) { subject_class.new }
    let(:subject_class) { LittleBoxes::App1 }

    it_behaves_like 'sample app'
  end

  describe 'LittleBoxes::Box2 app' do
    subject { subject_instance }
    let(:subject_instance) { subject_class.new }
    let(:subject_class) { LittleBoxes::App2 }

    it 'can be instantiated' do
      expect{ subject_class.new }.not_to raise_error
    end

    it 'has a logger' do
      expect(subject.logger).to be_a Logger
      expect(subject.logger.level).to be 0
    end

    it 'accepts a logger level' do
      subject.logger_level = 1
      expect(subject.logger.level).to eq 1
    end

    # it 'has an api' do
    #   expect(subject.api).to be_api
    #   expect(subject.api.logger).to be subject.logger
    # end

    # it 'supports sections'
    # it 'supports overriding dependency resolution with sub-section'
    # it 'supports overriding specific dependencies'
  end

  describe 'LittleBoxes::Box3 app' do
    subject { subject_instance }
    let(:subject_instance) { subject_class.new }
    let(:subject_class) { LittleBoxes::App3 }

    it 'can be instantiated' do
      expect{ subject_class.new }.not_to raise_error
    end

    it 'has a logger' do
      expect(subject.logger).to be_a Logger
      expect(subject.logger.level).to be 0
    end

    it 'accepts a logger level' do
      subject.let(:logger_level) { 1 }
      expect(subject.logger.level).to eq 1
    end

    it 'has an api' do
      expect(subject.api).to be_api
      expect(subject.api.logger).to be subject.logger
    end

    it 'supports overriding specific dependencies' do
      expect(subject.api.hostname).to eq 'www.example.com'
    end

    # it 'has dependencies defined at instance level'
    # it 'supports definitions at class level'
    # it 'supports overriding from the outside'
    # it 'warns if overriding by mistake'
    # it 'has logging'
    # it 'raises meaningful exception if missing register'
    # it 'raises exception if overriding after it has been used'
    # it 'supports sections'
    # it 'supports overriding dependency resolution with sub-section'
  end
end
