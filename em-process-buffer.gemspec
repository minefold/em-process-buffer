# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'eventmachine/process_buffer/version'

Gem::Specification.new do |gem|
  gem.name          = "em-process-buffer"
  gem.version       = Gem::VERSION
  gem.authors       = ["Dave Newman"]
  gem.email         = ["dave@whatupdave.com"]
  gem.description   = %q{A restartable process watcher that buffers STDIN and STDOUT}
  gem.homepage      = "https://github.com/minefold/em-process-buffer"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = %w(bin lib)
  
  gem.add_dependency "eventmachine", "~>1.0.0.rc.4"
  gem.add_dependency "posix-spawn", "~>0.3.6"
end
