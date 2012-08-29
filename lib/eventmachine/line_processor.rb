module EM
  class LineProcessor < EM::P::LineAndTextProtocol
    attr_accessor :on_line

    def receive_line(line)
      if on_line
        on_line.call line
      end
    end
  end
end