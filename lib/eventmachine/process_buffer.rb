BIN = File.expand_path File.join(__FILE__, '../../../bin')

require "bundler/setup"

require 'posix/spawn'
require 'core_ext/process'
require 'eventmachine/pid_poller'
require 'eventmachine/line_processor'
require 'eventmachine/process_buffer/watcher'

module EM
  module ProcessBuffer
    def self.start_process pipe_directory, working_directory, pid_file, command, handler
      buffer_command = %Q{#{BIN}/buffer-process -d #{pipe_directory} -C #{working_directory} -p #{pid_file} "#{command}"}
      buffer_pid, stdin, stdout, stderr = POSIX::Spawn::popen4(buffer_command)
      Process.detach buffer_pid

      wait = EM.add_periodic_timer(0.5) do
        begin
          if Process.waitpid(buffer_pid, Process::WNOHANG)
            stdin.close
            stdout.gets
            wait.cancel

            # watcher.process_exited

          elsif File.exist?(pid_file)
            stdin.close
            stdout.gets
            wait.cancel

            c = Class.new(EM::ProcessBuffer::Watcher) { include handler }
            watcher = c.new pid_file, pipe_directory, working_directory
            
            watcher.attach_to_process
            watcher.process_started
          end
        rescue Errno::ECHILD
          # waiting...
        end
      end
    end

    def self.attach_to_process pid, pipe_directory, working_directory, pid_file, command, handler
      c = Class.new(EM::ProcessBuffer::Watcher) { include handler }
      watcher = c.new pid_file, pipe_directory, working_directory
      watcher.attach_to_process
    end
  end

  def self.buffer_process pid_file, working_directory, command, handler, *args
    pipe_directory = working_directory

    if File.exist?(pid_file)
      pid = File.read(pid_file).strip.to_i

      if Process.alive?(pid)
        puts "found running process pid=#{pid} pid_file=#{pid_file}"
        ProcessBuffer.attach_to_process pid, pipe_directory, working_directory, pid_file, command, handler
      else
        puts "found dead process pid=#{pid} pid_file=#{pid_file}"
        ProcessBuffer.start_process pipe_directory, working_directory, pid_file, command, handler
      end
    else
      ProcessBuffer.start_process pipe_directory, working_directory, pid_file, command, handler
    end
  end
end