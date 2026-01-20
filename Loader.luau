if (not game:IsLoaded()) then game.Loaded:Wait() end;

local players = cloneref(game:GetService("Players"));
local localplayer = cloneref(players.LocalPlayer);

if (not localplayer) then
	players:GetPropertyChangedSignal("LocalPlayer"):Wait();
	localplayer = players.LocalPlayer;
end;

local messagebox = (messagebox or messageboxasync);
local executor = (identifyexecutor and identifyexecutor()) or "what are you useing????";

if (typeof(messagebox) ~= "function") then
      return localplayer:Kick("KirkWear - [" .. executor .. "]\nmissing messagebox");
end;

if (run_on_actor and getactors and getactors()[1] ~= nil) then
    run_on_actor(getactors()[1], [[task.spawn(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/voltara-the-terrible/KirkWare/refs/heads/main/Games/OperationOne/Main.luau"))() end]]);
elseif (getfflag and setfflag) then
    if (getfflag("DebugRunParallelLuaOnMainThread") ~= "True") then
        setfflag("DebugRunParallelLuaOnMainThread", "True");
        return localplayer:Kick("KirkWear - [" .. executor .. "]\nrejoin and run KirkWear again");
    else
       task.spawn(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/voltara-the-terrible/KirkWare/refs/heads/main/Games/OperationOne/Main.luau"))() end);
    end;
else
    return messagebox("missing [ setfflag & run_on_actor ] - unsupported executor", "KirkWear - [" .. executor .. "]", 48);
end;
