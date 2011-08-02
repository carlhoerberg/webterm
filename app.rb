require 'sinatra'

get '/' do
	haml :index
end

get '/ssh' do
	host = params[:host]
	Net::SSH.start(host, user, :password => password) do |ssh|
		channel = ssh.open_channel do |ch|
			ch.on_data do |c, data|
				$faye.publish("/#{host}/#{user}/#{password}", data)
			end
		end
		channel.wait
	end
end

