if World.isClient then
	require "script_client.main"
end

if not World.isClient then
	require "script_server.main"
end
