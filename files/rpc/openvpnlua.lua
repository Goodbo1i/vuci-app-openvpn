local M = {}

function M.removeInstance(params)
	local handle = io.popen('find /etc/vuci-upload/openvpn -name "'..params.name..'.*"', 'r')
	local output = assert(handle:read('*a'))
	local files= {}
	
	for line in string.gmatch(output, '[^"%s"]+') do   --PUTS JSON DATA INTO LINES
			table.insert(files, line)
	end

	for i=1,table.getn(files) do 
		os.execute('rm -fr "' ..files[i]..'"')
	end
	return {status="ok", message=params.name.." was deleted!"}
end

function M.deleteFiles(params)
	if params.auth == "tls" then
		 handle = io.popen('find /etc/vuci-upload/openvpn -name "'..params.name..'.secretstatic.*"', 'r')
	else 
		  handle = io.popen('find /etc/vuci-upload/openvpn/ -type f -name "'..params.name..'".auth* && find /etc/vuci-upload/openvpn/ -type f -name "'..params.name..'".key && find /etc/vuci-upload/openvpn/ -type f -name "'..params.name..'".dh', 'r')
	end
	local output = assert(handle:read('*a'))
	local files= {}

	for line in string.gmatch(output, '[^"%s"]+') do   --PUTS JSON DATA INTO LINES
			table.insert(files, line)
	end

	for i=1,table.getn(files) do 
		os.execute('rm -fr "' ..files[i]..'"')
	end
	return {status = "ok", message="Successfully deleted"}
end

return M
