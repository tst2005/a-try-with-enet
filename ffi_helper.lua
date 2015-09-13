
-- original file found at https://github.com/arch-jslin/mysandbox/blob/master/lua/ffi_helper.lua

local ffi = require 'ffi'
return {
  NULL = ffi.cast("void*", ffi.new("int",0)),
  ZERO = ffi.new("int", 0)
}

