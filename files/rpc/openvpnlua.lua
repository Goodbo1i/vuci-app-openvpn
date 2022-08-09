local uci = require "uci"

local M = {}

function M.get(params)
	local c = uci.cursor()

	return {
		c:get("openvpn", params.section, params.option)
	}
end





function M.toggleSwitch(params)
	
	local c = uci.cursor()
		
	c:set("openvpn", params.name, "enable", params.enable)

	c:commit("openvpn")

	return {status = "ok" }

end

function M.setInterface(params)
	
	local c = uci.cursor()

	c:set("openvpn", params.name, params.type)
	c:set("openvpn", params.name, "keepalive", "10 120")
	c:set("openvpn", params.name, "_name", params.name)
	c:set("openvpn", params.name, "data_ciphers", {"BF-CBC"})
	c:set("openvpn", params.name, "persist_key", 1)
	c:set("openvpn", params.name, "port", 1194)
	c:set("openvpn", params.name, "tun", 1)
	c:set("openvpn", params.name, "verb", 5)
	c:set("openvpn", params.name, "type", params.role)
	c:set("openvpn", params.name, "proto", "udp")
	c:set("openvpn", params.name, "cipher", "BF-CBC")
	c:set("openvpn", params.name, "_auth", "skey")
	c:set("openvpn", params.name, "enable", 0)

	c:set("openvpn", params.name, "local_ip", "")
	c:set("openvpn", params.name, "remote_ip", "")
	c:set("openvpn", params.name, "network_ip", "")
	c:set("openvpn", params.name, "network_mask", "")
	c:set("openvpn", params.name, "secret", "")

	if params.role == "client" then
		c:set("openvpn", params.name, "resolv_retry", "infinite")
		c:set("openvpn", params.name, "nobind", 1)
		c:set("openvpn", params.name, "dev", "tun_c_"..params.name)
		c:set("openvpn", params.name, "status", '/tmp/openvpn-status_'..params.name..'.log')

	end	

	if params.role == "server" then
		c:set("openvpn", params.name, "dev", "tun_s_"..params.name)
	end	
	c:commit("openvpn")

	return {status = "ok" } 	
end

function M.removeInstance(params)
	local c= uci.cursor()

	os.execute('rm -fr "' ..params.secret..'"')
	os.execute('rm -fr "' ..params.ca..'"')
	os.execute('rm -fr "' ..params.key..'"')
	os.execute('rm -fr "' ..params.cert..'"')
	os.execute('rm -fr "' ..params.dh..'"')

	c:delete("openvpn", params.name)
	c:commit("openvpn")

	return {status="ok", message=params.name.." was deleted!"}
end

function M.editInstance(params)

	local c = uci.cursor()

	c:set("openvpn", params.name, "_auth", params.auth)
	c:set("openvpn", params.name, "enable", params.enable)
	c:set("openvpn", params.name, "remote", params.remote)
	c:set("openvpn", params.name, "local_ip", params.local_ip)
	c:set("openvpn", params.name, "server_ip", params.server_ip)
	c:set("openvpn", params.name, "server_netmask", params.server_netmask)
	c:set("openvpn", params.name, "remote_ip", params.remote_ip)
	c:set("openvpn", params.name, "network_ip", params.network_ip)
	c:set("openvpn", params.name, "network_mask", params.network_mask)

	c:set("openvpn", params.name, "ca", params.ca)
	c:set("openvpn", params.name, "key", params.key)
	c:set("openvpn", params.name, "cert", params.cert)
	c:set("openvpn", params.name, "dh", params.dh)
	c:set("openvpn", params.name, "secret", params.secret)

	if params.auth == "tls" then

		c:set("openvpn", params.name, "_tls_auth", params.tls_auth)
	else 

		c:set("openvpn", params.name, "_tls_auth", 0)
	end


	c:commit("openvpn")

	return {status = "ok"}
end

function M.deleteFiles(params)

	if params.auth == "tls" then

		os.execute('rm -fr "' ..params.secret..'"')
	else 
		os.execute('rm -fr "' ..params.ca..'"')
		os.execute('rm -fr "' ..params.key..'"')
		os.execute('rm -fr "' ..params.cert..'"')
		os.execute('rm -fr "' ..params.dh..'"')
	end


	return {status = "ok", message="Successfully deleted"}

end

function M.getOpenVPNData(params)

	local c= uci.cursor()

	local data = {}
	local num = 0

	c:foreach("openvpn", "openvpn", function(i)
		data[num] = i
		num = num + 1
	end)

	return {status = "ok", data=data}
end


return M
