module EM
  module PidPoller
    def self.on_exit pid, *a, &b
      cb = EM::Callback *a, &b
      poller = EM.add_periodic_timer(1) do
        state = process_alive?(pid)
        unless state
          poller.cancel
          cb.call
        end
      end
      cb
    end

    def self.process_alive? pid
      Process.kill(0, pid)
      true
    rescue Errno::ESRCH
      false
    end
  end
end