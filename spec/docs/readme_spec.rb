require_relative '../spec_helper'

RSpec.describe 'README.md examples', :docs do
  before { stub_const 'MyApp', Module.new }

  describe 'Minimal example' do
    it 'has a basic example' do
      module MyApp
        class MainBox
          include LittleBoxes::Box

          let(:port) { 80 }
          letc(:server) { Server.new }
        end

        class Server
          include LittleBoxes::Configurable

          dependency :port
        end
      end

      box = MyApp::MainBox.new
      # => #<MyBox :server, :logger, :log_path>

      box.server.port
      # => 80

      expect(box.server.port).to eq 80
    end
  end
end
