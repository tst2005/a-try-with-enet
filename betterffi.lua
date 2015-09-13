#!/usr/bin/env luajit


-- Testing LuaJIT2 FFI to enet binding

--[[
	About paths

	The path to the compiled lib :
--local libpath = "/usr/lib/x86_64-linux-gnu/libenet.so"     -- dpkg -L libenet-dev | grep 'so$'
--local libpath = "/usr/lib/x86_64-linux-gnu/libenet.so.1.0.3" -- dpkg -L libenet1a | grep so
--local libpath = "libenet" -- without . then search in system path
--local libpath = "enet" -- without . then search in system path, without the "lib" prefix

--local hpath = "/usr/include/enet/enet.h" -- dpkg -L libenet-dev |grep '\.h'
--local hpath = "enet.h"

]]--
local ffi = require 'ffi'

local libpath = "enet" -- the .so
local hpath = "enet.h" -- see generate.sh

local exit = assert(require"os".exit)
local stderr = assert(require"io".stderr)
--local error = assert(error)


-- See https://gcc.gnu.org/onlinedocs/cpp/Line-Control.html#Line-Control
-- after macro expansion there still exists :
-- #line
-- #include <system/path/to/include.h>
local function getheader(f)
	local fd = io.open(f)
	local data
	while true do
		local line = fd:read("*l") -- line does not contains the end-of-line
		if not line then break end
		local token, a = line:match('^#(%S+)%s*(.*)$')
		if not ((token == "line") or (token == "include")) then
			if data then
				data = data .. "\n" .. line
			else
				data = line
			end
		--else
		--	io.stderr:write("token="..token.."\n")
		end
	end
	fd:close()
	return data 
end

local raw_enet = ffi.load(libpath)
ffi.cdef( getheader(hpath) )

local _M = {}
_M.raw_enet = raw_enet

-- try to emul the love2d lua-enet interface ?
--[[
_M.host_create = function(addr-port) -- split <host>:port
	local addr = ffi.new("ENetAddress[1]")
	addr[0].host = raw_enet.ENET_HOST_ANY
	addr[0].port = 12345
	return raw_enet.enet_host_create(addr, 32, 2, 0, 0)
end
]]--


if raw_enet.enet_initialize() ~= 0 then
	error("An error occurred while initializing ENet.\n", 2)
end



--local serv = enet.enet_host_create(addr, 32, 2, 0, 0)
--if tonumber(ffi.cast("int", serv)) == 0 then
--  error("An error occurred while trying to create the host.\n")
--end

if ffi.C and ffi.C.atexit then
	ffi.C.atexit(raw_enet.enet_deinitialize)
elseif newproxy and getmetatable then
	-- Workaround found, see: http://lua-users.org/lists/lua-l/2013-04/msg00495.html
	emul_atexit = newproxy(true) --function() emul_atexit = nil ; collectgarbage() end)
	getmetatable(emul_atexit).__gc = function()
		print("cleanup before exit with raw_enet.enet_deinitialize()")
		raw_enet.enet_deinitialize()
	end

	--emul_atexit = nil
	--collectgarbage();collectgarbage()
else
	print("WARNING: no way found to cleanup on exit")
end

return _M

