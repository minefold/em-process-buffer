require "bundler/setup"

require 'posix/spawn'
require 'core_ext/process'
require 'eventmachine/pid_poller'
require 'eventmachine/line_processor'
require 'eventmachine/process_buffer/watcher'

module EM
  module ProcessBuffer
    BIN = File.expand_path File.join(__FILE__, '../../../bin')
    
    def self.spawn_detached cmd, environment = {}
      begin
        pid, stdin, stdout, stderr = POSIX::Spawn::popen4(environment, cmd)
        Process.detach pid
        return pid, stdin, stdout, stderr
      rescue Errno::EAGAIN # Resource temporarily unavailable
        retry
      end
    end
    
    def self.start_process pipe_directory, working_directory, pid_file, command, environment, handler, *args, &block
      buffer_command = %Q{#{BIN}/buffer-process -d #{pipe_directory} -C #{working_directory} -p #{pid_file} "#{command}"}
      buffer_pid, stdin, stdout, stderr = spawn_detached buffer_command, environment
      Process.detach buffer_pid

      wait = EM.add_periodic_timer(0.5) do
        begin
          if Process.waitpid(buffer_pid, Process::WNOHANG)
            stdin.close
            stdout.gets
            wait.cancel

            puts "process exited pid=#{buffer_pid}"

          elsif File.exist?(pid_file)
            stdin.close
            stdout.gets
            wait.cancel

            c = Class.new(EM::ProcessBuffer::Watcher) { include handler }
            watcher = c.new pid_file, pipe_directory, working_directory, *args
            
            watcher.process_started
            watcher.attach_to_process
            
            block.call watcher if block_given?
          end
        rescue Errno::ECHILD
          # waiting...
        end
      end
    end

    def self.attach_to_process pid, pipe_directory, working_directory, pid_file, command, handler, *args
      c = Class.new(EM::ProcessBuffer::Watcher) { include handler }
      watcher = c.new pid_file, pipe_directory, working_directory, *args
      watcher.attach_to_process
      watcher.process_reattached

      yield watcher if block_given?
    end
  end

  def self.buffer_process pid_file, working_directory, command, environment, handler, *args, &block
    pipe_directory = working_directory
    
    FileUtils.mkdir_p working_directory

    if File.exist?(pid_file)
      pid = File.read(pid_file).strip.to_i

      if Process.alive?(pid)
        puts "found running process pid=#{pid} pid_file=#{pid_file}"
        ProcessBuffer.attach_to_process pid, pipe_directory, working_directory, pid_file, command, handler, *args, &block
      else
        puts "found dead process pid=#{pid} pid_file=#{pid_file}"
        ProcessBuffer.start_process pipe_directory, working_directory, pid_file, command, environment, handler, *args, &block
      end
    else
      ProcessBuffer.start_process pipe_directory, working_directory, pid_file, command, environment, handler, *args, &block
    end
  end
end