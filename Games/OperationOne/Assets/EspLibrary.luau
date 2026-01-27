local players = game:GetService("Players");
local local_player = players.LocalPlayer;
local camera = workspace.CurrentCamera;
local dirs = { Vector3.new(-1, -1, -1), Vector3.new(1, -1, -1), Vector3.new(-1, 1, -1), Vector3.new(1, 1, -1), Vector3.new(-1, -1, 1), Vector3.new(1, -1, 1), Vector3.new(-1, 1, 1), Vector3.new(1, 1, 1) };

local world_to_screen = function(pos)
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

        for i = 1, #self.drawings do
            self.drawings[i]:Destroy();
        end;
    end;
    
    function player_esp:Update(settings)
        local head = self.children.head;
        local _, on = world_to_screen(head.Position);
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
        local cf, size = self.model:GetBoundingBox();
        local sx, sy, sz = size.X * 0.5, size.Y * 0.5, size.Z * 0.5;
        
        local top, bottom, left, right = math.huge, -math.huge, math.huge, -math.huge;
        local yay = false;
        
        for i = 1, 8 do
            local d = dirs[i];
            local point, on = world_to_screen(cf * Vector3.new(d.X * sx, d.Y * sy, d.Z * sz));
            if (on) then
                yay = true;
                if (point.Y < top) then top = point.Y end;
                if (point.Y > bottom) then bottom = point.Y end;
                if (point.X < left) then left = point.X end;
                if (point.X > right) then right = point.X end;
            end;
        end;
    
        if (not yay or left >= right or top >= bottom) then return nil end;
    
        return top, bottom, left, right;
    end;

end;

return player_esp;
