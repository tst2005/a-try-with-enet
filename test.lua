#!/usr/bin/env luajit

local exit = assert(require"os".exit)
local stderr = assert(require"io".stderr)

local ffi = require "ffi"

local enet = require"enet"
local raw_enet = enet.raw_enet

--[[
if enet.enet_initialize() ~= 0 then
  stderr("An error occurred while initializing ENet.\n")
  exit(1)
end
]]--


local addr = ffi.new("ENetAddress[1]")
addr[0].host = raw_enet.ENET_HOST_ANY
addr[0].port = 12345

local peer_count = 32    -- max number of peers, defaults to 64
local channel_count = 2  -- max number of channels, defaults to 1
local in_bandwidth = 0   -- downstream bandwidth in bytes/sec, defaults to 0 (unlimited)
local out_bandwidth = 0  -- upstream bandwidth in bytes/sec, defaults to 0 (unlimited)
local serv = raw_enet.enet_host_create(addr, peer_count, channel_count, in_bandwidth, out_bandwidth)
if tonumber(ffi.cast("int", serv)) == 0 then
  stderr("An error occurred while trying to create the host.\n", 2)
  exit(1)
end



print("exit")
