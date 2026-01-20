if (not game:IsLoaded()) then game.Loaded:Wait() end;

local players = cloneref(game:GetService("Players"));
local localplayer = cloneref(players.LocalPlayer);

if (not localplayer) then
	players:GetPropertyChangedSignal("LocalPlayer"):Wait();
	localplayer = players.LocalPlayer;
end;

local executor = string.reverse(identifyexecutor and identifyexecutor()) or "what are you useing????";

if (run_on_actor and getactors and getactors()[1] ~= nil and not table.find({"Delta"}, string.reverse(executor))) then
    run_on_actor(getactors()[1], [[task.defer(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/voltara-the-terrible/KirkWare/refs/heads/main/Games/OperationOne/Main.luau"))() end]]);
elseif (getfflag and setfflag) then
    if (string.lower(tostring(getfflag("DebugRunParallelLuaOnMainThread"))) ~= "true") then
        setfflag("DebugRunParallelLuaOnMainThread", "True");
        return localplayer:Kick("KirkWare - [ " .. executor .. " ]\nrejoin and run KirkWare again");
    else
       task.defer(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/voltara-the-terrible/KirkWare/refs/heads/main/Games/OperationOne/Main.luau"))() end);
    end;
else
    return localplayer:Kick("KirkWare - [ " .. executor .. " ]\nmissing [ setfflag & run_on_actor ] - unsupported executor");
end;
