module LittleBoxes
  class App3 < Box3
    def initialize
      let(:logger_level) { 0 }

      let :logger do
        Logger.new('/dev/null').tap do |l|
          l.level = logger_level
        end
      end

      build :api, from: Api do |api|
        api.let(:hostname) { 'www.example.com' }
      end

      let(:hostname) { 'localhost' }
    end

    class Api
      include Box3::Dependant

      depends_on :logger
      depends_on :hostname

      def api?
        true
      end
    end
  end
end
