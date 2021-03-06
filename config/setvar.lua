package.path = package.path .. ";/?/init.lua"

-- Script for setting a config var in the shell
local config = require("config")
local args = {...}

varconfig = args[1]
varname = args[2]
varvalue = args[3]

config.load(varconfig)

config.set(varname, varvalue)

config.save()
