local GENERIC_OBJECT_CLEANUP_FUNCS={"Destroy","Disconnect","destroy","disconnect"}

local Utility={}

function Utility.CallSafely(func,...)
	if func then
		local success,result=pcall(func,...)
		if not success then
			warn("function failed with error: ",result)
			return false
		else
			return result
		end
	end
end

-- Loads and executes a function hosted on a remote URL. Cancels the request if the requested URL takes too long to respond.
-- Errors with the function are caught and logged to the output
function Utility.LoadWithTimeout(url,timeout)
	assert(type(url)=="string","Expected string,got " .. type(url))
	timeout=timeout or 5
	local done,success,result=false,false,nil
	local requestThread=task.spawn(function()
		local fetchSuccess,fetchResult=pcall(game.HttpGet,game,url) -- game:HttpGet(url)
		-- If the request fails the content can be empty,even if fetchSuccess is true
		if not fetchSuccess or #fetchResult==0 then
			if #fetchResult==0 then
				fetchResult="Empty response" -- Set the error message
			end
			done,success,result=true,false,fetchResult
			return
		end
		local content=fetchResult -- Fetched content
		local executeSuccess,executResult=pcall(function()
			return loadstring(content)()
		end)
		done,success,result=true,executeSuccess,executResult
		done=true
	end)
	local timeoutThread=task.delay(timeout,function()
		if not done then
			done=true
			warn("Request for " .. url .. " timed out after " .. tostring(timeout) .. " seconds")
			task.cancel(requestThread)
			result="Request timed out"
		end
	end)
	-- Wait for completion or timeout
	while not done do
		task.wait()
	end
	-- Cancel timeout thread if still running when request completes
	if coroutine.status(timeoutThread)~="dead" then
		task.cancel(timeoutThread)
	end
	if not success then
		warn("Failed to process " .. tostring(url) .. ": " .. tostring(result))
	end
	return success and result or nil
end


function Utility.Cleanup(object)
	local objectType=typeof(object)
	if objectType=='function' then
		pcall(function() object() end)
	elseif objectType=='RBXScriptConnection' then
		object:Disconnect()
	elseif objectType=='Instance' then
		if object and object.Parent then object:Destroy() end
	elseif objectType=='thread' then
		local wasCancelled:boolean?=nil
		if coroutine.running()~=object then
			wasCancelled=pcall(function()
				task.cancel(object)
			end)
		end
		if not wasCancelled then
			local toClean=object
			task.defer(function()
				task.cancel(toClean)
			end)
		end
	elseif objectType=='table' then
		for i,k in ipairs(GENERIC_OBJECT_CLEANUP_FUNCS) do
			local func=object[k]
			if typeof(func)=='function' then
				pcall(func)
				break
			end
		end
	else
		warn('[Utility]: Unable to cleanup unknown object:',objectType)
	end
	return nil
end

function Utility.Missing(s,v,f)
	if typeof(v)==s then return v end return f
end

return Utility
