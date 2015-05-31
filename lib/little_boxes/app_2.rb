module LittleBoxes
  class App2 < Box2
    class Api
      include Box2::Dependant

      depends_on :logger

      def api?
        true
      end
    end

    dependant :logger do |d|
      d.build { Logger.new('/dev/null') }
      d.step(:level) {|l| l.level = logger_level }
    end

    let :logger_level do
      0
    end
  end
end
