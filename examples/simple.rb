$:.unshift File.join(__FILE__, '../../lib')

require 'eventmachine'
require 'eventmachine/process_buffer'
require 'eventmachine/profile'

module Watcher
  def post_init
    started_at = Time.now
    EM.add_periodic_timer(1) do
      send_stdin 'hello'
    end
  end

  def process_started
    puts "process started pid=#{pid}"
  end

  def process_exited
    puts "process exited pid=#{pid}"
  end

  def receive_stdout line
    puts "[#{pid}] #{line}"
  end
end

`mkdir -p tmp/simple`

EM.run do
  puts "watcher started pid=#{Process.pid}"
  EM.buffer_process 'tmp/simple.pid', 'tmp/simple', File.join(File.expand_path(File.dirname(__FILE__)), 'in-out'), Watcher
end
