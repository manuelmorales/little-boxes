module LittleBoxes
  class App4 < Box4

    class Api
      include Box4::Dependant

      def api?
        true
      end
    end
  end
end
