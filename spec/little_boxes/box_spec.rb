require_relative '../spec_helper'

describe LittleBoxes::Box do
  subject{ LittleBoxes::Box.new }

  it 'can build instances' do
    expect(subject).to be_a(LittleBoxes::Box)
  end
end
