local players = game:GetService("Players");
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
    
    player_esp.new = function(model)
        if (player_esp.cache[model] or model.head.Transparency > 0.8 or model.Name == "LocalViewmodel") then return end;
        
        local self = setmetatable({
            ["model"] = model,
            ["connections"] = {},
            ["drawings"] = {},
            ["children"] = {},
            ["distance"] = math.huge
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
        self.drawings["box_outline"] = create_drawing("Square", {Visible = false, Thickness = 2, Color = Color3.fromRGB(0, 0, 0), Filled = false, ZIndex = 0});

    
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
    end;
    
    function player_esp:Update(settings)
        local head = self.children.head;
        local _, on = world_to_point(head.Position);
        if (not on) then return self:HideDrawings() end;
        
        local top, bottom, left, right = self:GetBoundingBox();
        if (not top) then return self:HideDrawings() end;
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
        
        local pos = Vector2.new(left - 2, top - 2);
        local size = Vector2.new((right - left) + 2 * 2, (bottom - top) + 2 * 2);

        drawings.box.Visible = true;
        drawings.box.Position = pos;
        drawings.box.Size = size;

        drawings.box_outline.Visible = true;
        drawings.box_outline.Position = pos;
        drawings.box_outline.Size = size;
    end;
    
    function player_esp:HideDrawings()
        for i, v in self.drawings do
            v.Visible = false;
        end;
    end;
    
    function player_esp:GetBoundingBox()
        local top, bottom, left, right = math.huge, -math.huge, math.huge, -math.huge;
        local yay = false;

        for _, part in next, (self.Bodyparts) do
            if (typeof(part) == "Basepart") then
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
