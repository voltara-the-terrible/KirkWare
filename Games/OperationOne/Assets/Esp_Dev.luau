local module, cache = {}, {};
module.__index = module;

local load_service: (service: string) -> Instance          = function(str) return cloneref(game:GetService(str)) end;
local players:                           Players           = load_service('Players');
local local_player:                      Player            = players.LocalPlayer;
local camera:                            Camera            = cloneref(workspace.CurrentCamera);

local world_to_point = function(pos)
    local point, on = camera:WorldToViewportPoint(pos);
    return Vector2.new(point.X, point.Y), on, point.Z;
end;

module.new = function(model, char)
    if (cache[model]) then return end;

    local self = setmetatable({
        model    = model,
        char     = char,
        children = {},
        connections = {},
        on_screen = false,
        screen_pos = Vector2.new(math.huge, math.huge),
        distance = math.huge
    }, module);

    local children = model:GetChildren();
    for i = 1, #children do
        local v = children[i];
        self.children[v.Name] = v;
    end;
        
    table.insert(self.connections, model.AncestryChanged:Connect(function()
        self:remove();
    end));

    cache[model] = self;

    return self;
end;

module.remove = function(self)
    cache[self.model] = nil;
        
    for i = 1, #self.connections do
        self.connections[i]:Disconnect();
    end;
end;

module.update = function(self, settings)
    local head = self.children.head;
    local point, on = world_to_point(head.Position);
    self.screen_pos = point;
    self.on_screen = on;

    if (not on or not settings.enabled) then return self:hide() end;

    self.distance = (camera.CFrame.Position - head.CFrame.Position).Magnitude;

end;

module.hide = function()
    
end;

return module, cache;
