local players = game:GetService("Players");
local coregui = game:GetService("CoreGui");
local local_player = players.LocalPlayer;
local camera = workspace.CurrentCamera;
local dirs = { Vector3.new(-1, -1, -1), Vector3.new(1, -1, -1), Vector3.new(-1, 1, -1), Vector3.new(1, 1, -1), Vector3.new(-1, -1, 1), Vector3.new(1, -1, 1), Vector3.new(-1, 1, 1), Vector3.new(1, 1, 1) };

local world_to_point = function(pos)
    local point, on = camera:WorldToViewportPoint(pos);
    return Vector2.new(point.X, point.Y), on, point.Z;
end;

local create_drawing = function(type, props)
    local a = Drawing.new(type);
    for i, v in next, (props) do
        a[i] = v;
    end;
    return a;
end;

local player_esp = {cache = {}} do
    player_esp.__index = player_esp;
    
    player_esp.new = function(model, char)
        if (player_esp.cache[model]) then return end;
                
        local self = setmetatable({
            ["model"] = model,
            ["connections"] = {},
            ["drawings"] = {},
            ["children"] = {},
            ["adornments"] = {},
            ["distance"] = math.huge,
            ["on_screen"] = false,
            ["screen_pos"] = Vector2.new(math.huge, math.huge)
        }, player_esp);
        
        local children = model:GetChildren();
        for i = 1, #children do
            local v = children[i];
            self.children[v.Name] = v;
        end;
        
        table.insert(self.connections, model.AncestryChanged:Connect(function()
            self:Remove();
        end));
        
        self.drawings["box"] = create_drawing("Square", {Visible = false, Thickness = 1, Color = Color3.fromRGB(255, 255, 255), Filled = false, ZIndex = 1});
        self.drawings["box_outline"] = create_drawing("Square", {Visible = false, Thickness = 3, Color = Color3.fromRGB(0, 0, 0), Filled = false, ZIndex = 0});
        
        self.cache[model] = self;
        return self;
    end;
    
    function player_esp:Remove()
        self.cache[self.model] = nil;
        
        for i = 1, #self.connections do
            self.connections[i]:Disconnect();
        end;

        for i, v in self.drawings do
            v:Destroy();
        end;
        
        for i = 1, #self.adornments do
            self.adornments[i]:Destroy();
        end;
    end;
    
    function player_esp:Update(settings)
        local head = self.children.head;
        local point, on = world_to_point(head.Position);
        self.screen_pos = point;
        self.on_screen = on;
        if (not on or not settings.enabled) then return self:Hidedrawings() end;
        
        local top, bottom, left, right = self:GetBoundingBox();
        if (not top) then return self:Hidedrawings() end;
        local distance = math.floor((camera.CFrame.Position - head.Position).Magnitude);
        
        self.distance = distance;
        self:RenderBox(top, bottom, left, right, settings);
    end;
    
    function player_esp:RenderBox(top, bottom, left, right, settings)
        local drawings = self.drawings;
        if (not settings.box) then
            drawings.box_outline.Visible = false;
            drawings.box.Visible = false;
            return;
        end;
        
        drawings.box.Color = settings.box_color;
        drawings.box.Visible = true;
        drawings.box.Position = Vector2.new(left - 2, top - 2);
        drawings.box.Size = Vector2.new((right - left) + 2 * 2, (bottom - top) + 2 * 2);

        drawings.box_outline.Visible = true;
        drawings.box_outline.Position = Vector2.new(left - 3, top - 3);
        drawings.box_outline.Size = Vector2.new((right - left) + 3 * 2, (bottom - top) + 3 * 2);
    end;
    
    function player_esp:Hidedrawings()
        for i, v in self.drawings do
            v.Visible = false;
        end;
        
        for i = 1, #self.adornments do
            self.adornments[i].Visible = false;
        end;
    end;
    
    function player_esp:GetBoundingBox()
        local top, bottom, left, right = math.huge, -math.huge, math.huge, -math.huge;
        local yay = false;

        for _, part in pairs(self.children) do
            if (typeof(part) == "Instance" and part.ClassName == "Part") then
                local size = part.Size * 0.5;
                for i = 1, #dirs do
                    dir = dirs[i];
                    local point, on = world_to_point(part.CFrame * Vector3.new(dir.X * size.X, dir.Y * size.Y, dir.Z * size.Z));
                    if (on) then
                        yay = true;
                        top = math.min(top, point.Y);
                        bottom = math.max(bottom, point.Y);
                        left = math.min(left, point.X);
                        right = math.max(right, point.X);
                    end;
                end;
            end;
        end;

        if (not yay or left >= right or top >= bottom) then return nil end;
        return top, bottom, left, right;
    end;

end;

return player_esp;
