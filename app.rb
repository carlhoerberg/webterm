require 'sinatra'

configure do
	$faye.subscribe 'connect' do |msg|
		host = msg.host
		user = msg.user
		password = msg.password
	end

end
get '/' do
	haml :index
end

get '/ssh' do
	host = params[:host]
end

