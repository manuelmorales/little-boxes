module LittleBoxes
  class App1 < Box1
    class Api
      include Box1::Dependant

      depends_on :logger

      def api?
        true
      end
    end

    has_one :logger do
      Logger.new('/dev/null').tap do |l|
        l.level = logger_level
      end
    end

    has_one :logger_level do
      0
    end

    has_one_dependant :api, Api
  end
end
