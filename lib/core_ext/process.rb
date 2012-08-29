module Process
  def self.alive?(pid)
    begin
      Process.kill(0, pid)
      true
    rescue Errno::ESRCH
      false
    end
  end
end