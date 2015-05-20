require_relative '../spec_helper'

describe LittleBoxes::MyClass do
  subject{ LittleBoxes::MyClass.new }

  it 'can build instances' do
    expect(subject).to be_a(LittleBoxes::MyClass)
  end
end
