# EM Process Buffer

A restartable process watcher that buffers STDIN and STDOUT.

This is designed to watch long running processes. The watching process can be independently restarted without killing the watched process. In the mean time STDOUT is buffered in memory until the watching process is restarted so no output is missed.

Creates named pipes on disk for STDIN and STDOUT.

QUIT will gracefully stop the watching process. TERM will kill the watcher and the buffered process.

## Example

	# In terminal 1 start the process and watcher
	$ ruby examples/simple.rb
	watcher started pid=7652
	process started pid=7815
	[7815] [STDIN 0.0] hello
	[7815] [STDIN 0.99] hello
	
	# In terminal 2 kill the watcher
	$ kill 7652
	
	# back in terminal 1 restart the watcher
	$ ruby examples/simple.rb
	[7869] [STDIN 5.34] hello
	[7869] [STDIN 6.84] hello