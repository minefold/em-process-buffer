module EM
  module ProcessBuffer

    class Watcher
      attr_reader :pid, :pid_file, :pipe_directory, :working_directory

      def initialize pid_file, pipe_directory, working_directory
        @pid_file = pid_file
        @pipe_directory = pipe_directory
        @working_directory = working_directory
        @pid = File.read(pid_file).strip.to_i
      end

      def post_init
      end

      def receive_stdout line
        puts ">> #{line}"
      end

      def process_exited
        puts "watched process exited"
      end

      def pipe_stdin
        File.join pipe_directory, 'pipe_stdin'
      end

      def pipe_stdout
        File.join pipe_directory, 'pipe_stdout'
      end

      def attach_to_process
        EM.attach(File.open(pipe_stdout, File::NONBLOCK + File::RDONLY), LineProcessor) do |lp|
          lp.on_line = method(:receive_stdout)
        end

        EM::PidPoller.on_exit pid, method(:process_exited)
        
        EM.next_tick { post_init }
      end
      
      def send_stdin line
        File.open(pipe_stdin, 'w+') do |f|
          f.write "#{line}\n"
        end
      end
    end
  end
end