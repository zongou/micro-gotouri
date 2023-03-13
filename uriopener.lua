 VERSION = "1.0.0"

local micro = import("micro")
local config = import("micro/config")
local shell = import("micro/shell")
local util = import("micro/util")
local os = import("os")

local isAnotherterm = os.Getenv("TERMSH") ~= ""
local isTermux = os.Getenv("TERMUX_VERSION") ~= ""
local isWindows = os.Getenv("OS") == "Windows_NT"
local defaultCmdOption = "default"

function __openuri(uri)
	micro.InfoBar():Message("Goto "..uri)
	local optionValue = config.GetGlobalOption("openuri.cmd")
	if (optionValue == defaultCmdOption) then
		if (isWindows) then
			shell.ExecCommand("explorer.exe", uri)
		elseif (isAnotherterm) then
			shell.ExecCommand("sh","-c","\"$TERMSH\" view --uri \""..uri.."\"")
		elseif (isTermux) then
			shell.ExecCommand("sh","-c","am start -a android.intent.action.VIEW -d \""..uri.."\"")
		end
	else
		local command = string.gsub(optionValue,"{uri}", uri)
		shell.RunCommand(command)
	end
end

function openuri(bp, args)
	if (#args > 0) then
--		 for i = 1, #args do
--			 micro.InfoBar():Message(args[i])
--		 end
		__openuri(args[1])
--	elseif (bp.Cursor:HasSelection()) then
--		__openuri(util.String(bp.Cursor:GetSelection()))
	else
		-- get previous uri delimiter around current cursor and match uri by using FindNext
		local origLoc = {
			X = bp.Cursor.Loc.X,
			Y = bp.Cursor.Loc.Y
		}
		--	Set startLoc, endLoc
		local startLoc
		local endLoc = {X = 0, Y = origLoc.Y + 1}
		
		function isUriDelimiter(runeValue)
			local DelimiterList = ' \t\n\r\'<>"{}|\\^~[]`'
			
			for i=1, string.len(DelimiterList) do
				if runeValue == string.byte(DelimiterList, i) then
					return true
				end
			end
			return false
		end

		for i=origLoc.X,0,-1 do
			local tmpLoc = {X = i, Y = origLoc.Y}
			if (isUriDelimiter(bp.Buf:RuneAt(tmpLoc))) then
				startLoc = tmpLoc
				break
			end
		end

		if (startLoc == nil) then
			startLoc = {X = 0, Y = origLoc.Y}
		end
		
		local uriRegExp = '(ftp(s)?|http(s)?|git|chrome)://[^ 	\'<>"{}|\\\\^~\\[\\]`]+'
		-- the arg down of function FindNext() affects if last char is included
		local uriLocs, err = bp.Buf:FindNext(uriRegExp, startLoc, endLoc, startLoc, true, true)
		bp.Cursor:SetSelectionStart(uriLocs[1])
		bp.Cursor:SetSelectionEnd(uriLocs[2])

		if (bp.Cursor:HasSelection()) then
			local uri = util.String(bp.Cursor:GetSelection())
			 __openuri(uri)
		else
			bp.Cursor:GotoLoc(origLoc)
		end
	end
end

function init()
	config.RegisterGlobalOption("openuri", "cmd", defaultCmdOption)
	
	config.MakeCommand("openuri", openuri, config.NoComplete)
	config.AddRuntimeFile("uriopener", config.RTHelp, "help/uriopener.md")
	
	-- config.TryBindKey("F9", "lua:openuri.openuri", false)
end
