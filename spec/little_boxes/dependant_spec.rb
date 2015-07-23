require_relative '../spec_helper'

describe LittleBoxes::Dependant do
  let(:section) { LittleBoxes::Section.new }

  describe 'Dependant' do
    it 'can be inherited' do
      class_one = Class.new do
        include LittleBoxes::Dependant
        dependency :one
      end

      class_two = Class.new class_one do
        include LittleBoxes::Dependant
        dependency :two
      end

      section.let(:one) { :one }
      section.let(:two) { :two }
      section.let_dependant(:dependant_one) { class_one.new }
      section.let_dependant(:dependant_two) { class_two.new }

      expect(section.dependant_one.one).to be :one
      expect(section.dependant_two.one).to be :one
      expect(section.dependant_two.two).to be :two
    end
  end
end
