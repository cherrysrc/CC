shell.run("delete customAPI/config.lua")
shell.run("wget https://raw.githubusercontent.com/cherrysrc/CC/main/storageSearcher/config.lua customAPI/config.lua")

shell.run("delete get.lua")
shell.run("wget https://raw.githubusercontent.com/cherrysrc/CC/main/storageSearcher/get.lua get.lua")

shell.run("delete insert.lua")
shell.run("wget https://raw.githubusercontent.com/cherrysrc/CC/main/storageSearcher/insert.lua insert.lua")
