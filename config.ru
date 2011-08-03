require 'faye'
require './app'

map '/' do
	run Sinatra::Application
end
map '/faye' do
	adapter = Faye::RackAdapter, :mount => '', :timeout => 45

	$faye = adapter.get_client
	run adapter
end
