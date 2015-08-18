require_relative '../spec_helper'

describe LittleBoxes::Dependant do
  let(:box) { LittleBoxes::Box.new }

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

      box.let(:one) { :one }
      box.let(:two) { :two }
      box.let_dependant(:dependant_one) { class_one.new }
      box.let_dependant(:dependant_two) { class_two.new }

      expect(box.dependant_one.one).to be :one
      expect(box.dependant_two.one).to be :one
      expect(box.dependant_two.two).to be :two
    end
  end
end
