require 'eventmachine'
require 'net/ssh'
class OutMock
	def publish(channel, msg)
		puts "#{channel}: #{msg}"
	end
	def subscribe(channel, &blk)
		blk.call({cmd: 'ls'})

	end
end
$faye = OutMock.new
host = 'localhost'
user = 'carl'

EM.run {
	Net::SSH.start(host, user, :password => password) do |ssh|
	puts 'in ssh'
	channel = ssh.open_channel do |ch|
		shell = session.shell.open( :pty => true )

		loop do
			break unless shell.open?
			
			if IO.select([$stdin],nil,nil,0.01)
				data = $stdin.sysread(1)
				shell.send_data data
			end

			$stdout.print shell.stdout while shell.stdout?
			$stdout.flush
		end
		ch.request_pty do |c, success|
		end
		puts 'in open channel'
		ch.on_data do |c, data|
			$faye.publish("/from/#{host}/#{user}/#{password}", data)
		end
		$faye.subscribe "/to/#{host}/#{user}/#{password}" do |msg|
			ch.exec msg[:cmd]
		end
	end
	puts 'before wait'
	channel.wait
	puts 'after wait'
	end
}
