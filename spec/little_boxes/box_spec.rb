require_relative '../spec_helper'

describe LittleBoxes::Box do
  subject{ LittleBoxes::Box.new }

  it 'can build instances' do
    expect(subject).to be_a(LittleBoxes::Box)
  end

  it 'registers stuff' do
    subject.register(:sum) { 2 + 2 }
    expect(subject).to respond_to(:sum)
    expect(subject.sum).to eq 4
  end

  it 'memoizes stuff' do
    subject.memoize(:rand) { Random.rand }
    expect(subject.rand).to eq subject.rand
  end

  it 'supports mentioning other elements' do
    subject.memoize(:value_1) { 1 }
    subject.memoize(:value_2) { 2 }
    subject.memoize(:value_3) { subject.value_1 + subject.value_2 }
    expect(subject.value_3).to eq 3
  end
end
