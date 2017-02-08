require_relative '../spec_helper'

RSpec.describe 'Configurable' do
  it 'assigns on initialize' do
    define_class 'UserRepo' do
      include Configurable
      dependency :store
    end

    repo = UserRepo.new store: :the_store

    expect(repo.store).to be :the_store
  end
end
