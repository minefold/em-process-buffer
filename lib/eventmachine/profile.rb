module EM
  def self.profile
    started_at = Time.now
    iterations = 0
    iteration_started_at = Time.now

    EM.add_periodic_timer(1) do
      iterations += 1
      total_delta = ((Time.now - started_at) - iterations)
      iteration_delta = (Time.now - iteration_started_at) - 1
      iteration_started_at = Time.now

      puts "iteration: #{iteration_delta.round(4)} total:#{total_delta.round(4)}"
    end    
  end
end