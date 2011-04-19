﻿local SharedMedia = LibStub("LibSharedMedia-3.0");
local L = WeakAuras.L
    
local function createOptions(id, data)
    local options = {
        grow = {
            type = "select",
            name = L["Grow"],
            order = 5,
            values = WeakAuras.grow_types
        },
        align = {
            type = "select",
            name = L["Align"],
            order = 10,
            values = WeakAuras.align_types,
            hidden = function() return (data.grow == "LEFT" or data.grow == "RIGHT" or data.grow == "HORIZONTAL") end,
        },
        rotated_align = {
            type = "select",
            name = L["Align"],
            order = 10,
            values = WeakAuras.rotated_align_types,
            hidden = function() return (data.grow == "UP" or data.grow == "DOWN" or data.grow == "VERTICAL") end,
            get = function() return data.align; end,
            set = function(info, v) data.align = v; WeakAuras.Add(data); end
        },
        space = {
            type = "range",
            name = L["Space"],
            order = 15,
            softMin = 0,
            softMax = 100,
            bigStep = 1
        },
        stagger = {
            type = "range",
            name = L["Stagger"],
            order = 20,
            min = -50,
            max = 50,
            step = 0.1,
            bigStep = 1
        },
        animate = {
            type = "toggle",
            width = "double",
            name = L["Animated Expand and Collapse"],
            order = 30
        },
        border = {
            type = "select",
            dialogControl = "LSM30_Border",
            name = L["Border"],
            order = 35,
            values = AceGUIWidgetLSMlists.border
        },
        background = {
            type = "select",
            dialogControl = "LSM30_Background",
            name = L["Background"],
            order = 40,
            values = function()
                local list = {};
                for i,v in pairs(AceGUIWidgetLSMlists.background) do
                    list[i] = v;
                end
                list["None"] = L["None"];
                
                return list;
            end
        },
        borderOffset = {
            type = "range",
            name = L["Border Offset"],
            order = 45,
            softMin = 0,
            softMax = 32,
            bigStep = 1
        },
        backgroundInset = {
            type = "range",
            name = L["Background Inset"],
            order = 47,
            softMin = 0,
            softMax = 32,
            bigStep = 1
        },
        spacer = {
            type = "header",
            name = "",
            order = 50
        }
    };
    options = WeakAuras.AddPositionOptions(options, id, data);
    
    options.width = nil;
    options.height = nil;
    options.selfPoint.disabled = true;
    
    return options;
end

local function createThumbnail(parent, fullCreate)
    local borderframe = CreateFrame("FRAME", nil, parent);
    borderframe:SetWidth(32);
    borderframe:SetHeight(32);
    
    local border = borderframe:CreateTexture(nil, "OVERLAY");
    border:SetAllPoints(borderframe);
    border:SetTexture("Interface\\BUTTONS\\UI-Quickslot2.blp");
    border:SetTexCoord(0.2, 0.8, 0.2, 0.8);
    
    local region = CreateFrame("FRAME", nil, borderframe);
    borderframe.region = region;
    
    region.children = {};
    
    return borderframe;
end

local function modifyThumbnail(parent, borderframe, data, fullModify, size)
    local region = borderframe.region;
    size = size or 24;
    
    local selfPoint;
    if(data.grow == "RIGHT" or data.grow == "HORIZONTAL") then
        selfPoint = "LEFT";
        if(data.align == "LEFT") then
            selfPoint = "TOP"..selfPoint;
        elseif(data.align == "RIGHT") then
            selfPoint = "BOTTOM"..selfPoint;
        end
    elseif(data.grow == "LEFT") then
        selfPoint = "RIGHT";
        if(data.align == "LEFT") then
            selfPoint = "TOP"..selfPoint;
        elseif(data.align == "RIGHT") then
            selfPoint = "BOTTOM"..selfPoint;
        end
    elseif(data.grow == "UP") then
        selfPoint = "BOTTOM";
        if(data.align == "LEFT") then
            selfPoint = selfPoint.."LEFT";
        elseif(data.align == "RIGHT") then
            selfPoint = selfPoint.."RIGHT";
        end
    elseif(data.grow == "DOWN" or data.grow == "VERTICAL") then
        selfPoint = "TOP";
        if(data.align == "LEFT") then
            selfPoint = selfPoint.."LEFT";
        elseif(data.align == "RIGHT") then
            selfPoint = selfPoint.."RIGHT";
        end
    end
    data.selfPoint = selfPoint;
    
    local maxWidth, maxHeight = 0, 0;
    for index, childId in ipairs(data.controlledChildren) do
        local childData = WeakAuras.GetData(childId);
        if(childData) then
            if(data.grow == "LEFT" or data.grow == "RIGHT") then
                maxWidth = maxWidth + childData.width;
                maxWidth = maxWidth + (index > 1 and data.space or 0);
                maxHeight = math.max(maxHeight, childData.height);
            else
                maxHeight = maxHeight + childData.height;
                maxHeight = maxHeight + (index > 1 and data.space or 0);
                maxWidth = math.max(maxWidth, childData.width);
            end
        end
    end
    if(data.grow == "LEFT" or data.grow == "RIGHT" or data.grow == "HORIZONTAL") then
        maxHeight = maxHeight + (math.abs(data.stagger) * (#data.controlledChildren - 1));
    else
        maxWidth = maxWidth + (math.abs(data.stagger) * (#data.controlledChildren - 1));
    end
    
    local scale;
    if(maxHeight > maxWidth) then
        scale = size / maxHeight;
    elseif(maxWidth >= maxHeight) then
        scale = size / maxWidth;
    end
    
    region:SetPoint("CENTER", borderframe, "CENTER");
    region:SetWidth(maxWidth * scale);
    region:SetHeight(maxHeight * scale);
    
    local xOffset, yOffset = 0, 0;
    if(data.grow == "RIGHT" or data.grow == "LEFT" or data.grow == "HORIZONTAL") then
        if(data.align == "LEFT" and data.stagger > 0) then
            yOffset = yOffset - (data.stagger * (#data.controlledChildren - 1));
        elseif(data.align == "RIGHT" and data.stagger < 0) then
            yOffset = yOffset - (data.stagger * (#data.controlledChildren - 1));
        elseif(data.align == "CENTER") then
            if(data.stagger < 0) then
                yOffset = yOffset - (data.stagger * (#data.controlledChildren - 1) / 2);
            else
                yOffset = yOffset - (data.stagger * (#data.controlledChildren - 1) / 2);
            end
        end
    else
        if(data.align == "LEFT" and data.stagger < 0) then
            xOffset = xOffset - (data.stagger * (#data.controlledChildren - 1));
        elseif(data.align == "RIGHT" and data.stagger > 0) then
            xOffset = xOffset - (data.stagger * (#data.controlledChildren - 1));
        elseif(data.align == "CENTER") then
            if(data.stagger < 0) then
                xOffset = xOffset - (data.stagger * (#data.controlledChildren - 1) / 2);
            else
                xOffset = xOffset - (data.stagger * (#data.controlledChildren - 1) / 2);
            end
        end
    end
    
    for index, childId in pairs(data.controlledChildren) do
        local childData = WeakAuras.GetData(childId);
        if(childData) then
            if not(region.children[index]) then
                region.children[index] = CreateFrame("FRAME", nil, region);
                region.children[index].texture = region.children[index]:CreateTexture(nil, "OVERLAY");
                region.children[index].texture:SetAllPoints(region.children[index]);
            end
            local r, g, b;
            if(childData.color) then
                r, g, b = childData.color[1], childData.color[2], childData.color[3];
            elseif(childData.barColor) then
                r, g, b = childData.barColor[1], childData.barColor[2], childData.barColor[3];
            elseif(childData.foregroundColor) then
                r, g, b = childData.foregroundColor[1], childData.foregroundColor[2], childData.foregroundColor[3];
            else
                r, g, b = 0.2, 0.8, 0.2;
            end
            region.children[index].texture:SetTexture(r, g, b);
            
            region.children[index]:ClearAllPoints();
            region.children[index]:SetPoint(selfPoint, region, selfPoint, xOffset * scale, yOffset * scale);
            region.children[index]:SetWidth(childData.width * scale);
            region.children[index]:SetHeight(childData.height * scale);
            if(data.grow == "RIGHT" or data.grow == "HORIZONTAL") then
                xOffset = xOffset + (childData.width + data.space);
                yOffset = yOffset + data.stagger;
            elseif(data.grow == "LEFT") then
                xOffset = xOffset - (childData.width + data.space);
                yOffset = yOffset + data.stagger;
            elseif(data.grow == "UP") then
                yOffset = yOffset + (childData.height + data.space);
                xOffset = xOffset + data.stagger;
            elseif(data.grow == "DOWN" or data.grow == "VERTICAL") then
                yOffset = yOffset - (childData.height + data.space);
                xOffset = xOffset + data.stagger;
            end
        end
    end
    
    local index = #data.controlledChildren + 1;
    if not(region.children[index]) then
        region.children[index] = CreateFrame("FRAME", nil, region);
        region.children[index].texture = region.children[index]:CreateTexture(nil, "OVERLAY");
        region.children[index].texture:SetAllPoints(region.children[index]);
    end
    region.children[index].texture:SetTexture(1, 1, 1);
    region.children[index]:ClearAllPoints();
    if(data.grow == "RIGHT" or data.grow == "LEFT") then
        region.children[index]:SetWidth(size);
        region.children[index]:SetHeight(1);
        if(data.align == "LEFT") then
            region.children[index]:SetPoint("CENTER", region, "TOP");
        elseif(data.align == "RIGHT") then
            region.children[index]:SetPoint("CENTER", region, "BOTTOM");
        else
            region.children[index]:SetPoint("CENTER", region, "CENTER");
        end
    else
        region.children[index]:SetWidth(1);
        region.children[index]:SetHeight(size);
        if(data.align == "LEFT") then
            region.children[index]:SetPoint("CENTER", region, "LEFT");
        elseif(data.align == "RIGHT") then
            region.children[index]:SetPoint("CENTER", region, "RIGHT");
        else
            region.children[index]:SetPoint("CENTER", region, "CENTER");
        end
    end
end

local function createIcon()
    local thumbnail = createThumbnail(UIParent);
    local t1 = thumbnail:CreateTexture(nil, "ARTWORK");
    t1:SetWidth(24);
    t1:SetHeight(6);
    t1:SetTexture(0.8, 0, 0);
    t1:SetPoint("TOP", thumbnail, "TOP", 0, -6);
    local t2 = thumbnail:CreateTexture(nil, "ARTWORK");
    t2:SetWidth(12);
    t2:SetHeight(12);
    t2:SetTexture(0.2, 0.8, 0.2);
    t2:SetPoint("TOP", t1, "BOTTOM", 0, -2);
    local t3 = thumbnail:CreateTexture(nil, "ARTWORK");
    t3:SetWidth(30);
    t3:SetHeight(4);
    t3:SetTexture(0.1, 0.25, 1);
    t3:SetPoint("TOP", t2, "BOTTOM", 0, -2);
    local t4 = thumbnail:CreateTexture(nil, "OVERLAY");
    t4:SetWidth(1);
    t4:SetHeight(36);
    t4:SetTexture(1, 1, 1);
    t4:SetPoint("CENTER", thumbnail, "CENTER");
    
    thumbnail.elapsed = 0;
    thumbnail:SetScript("OnUpdate", function(self, elapsed)
        self.elapsed = self.elapsed + elapsed;
        if(self.elapsed < 0.5) then
            t2:SetPoint("TOP", t1, "BOTTOM", 0, -2 + (28 * self.elapsed));
            t2:SetAlpha(1 - (2 * self.elapsed));
        elseif(self.elapsed < 1.5) then
            --do nothing
        elseif(self.elapsed < 2) then
            t2:SetPoint("TOP", t1, "BOTTOM", 0, -2 + (28 * (2 - self.elapsed)));
            t2:SetAlpha((2 * self.elapsed) - 3);
        elseif(self.elapsed < 3) then
            --do nothing
        else
            self.elapsed = self.elapsed - 3;
        end
    end);
    return thumbnail;
end

WeakAuras.RegisterRegionOptions("dynamicgroup", createOptions, createIcon, L["Dynamic Group"], createThumbnail, modifyThumbnail, L["A group that dynamically controls the positioning of its children"]);