﻿local SharedMedia = LibStub("LibSharedMedia-3.0");
  
local default = {
  controlledChildren = {},
  anchorPoint = "CENTER",
  xOffset = 0,
  yOffset = 0
};

local function create(parent)
  local region = CreateFrame("FRAME", nil, parent);
  region:SetMovable(true);
  region:SetWidth(0.01);
  region:SetHeight(0.01);
  
  local texture = region:CreateTexture(nil, "BACKGROUND");
  texture:SetAllPoints(region);
  texture:SetTexture(0, 1, 0, 0.3);
  
  return region;
end

local function getRect(data)
  local blx, bly, trx, try;
  blx, bly = data.xOffset, data.yOffset;
  if(data.selfPoint:find("LEFT")) then
    trx = blx + data.width;
  elseif(data.selfPoint:find("RIGHT")) then
    trx = blx;
    blx = blx - data.width;
  else
    blx = blx - (data.width/2);
    trx = blx + data.width;
  end
  if(data.selfPoint:find("BOTTOM")) then
    try = bly + data.height;
  elseif(data.selfPoint:find("TOP")) then
    try = bly;
    bly = bly - data.height;
  else
    bly = bly - (data.height/2);
    try = bly + data.height;
  end
  
  return blx, bly, trx, try;
end

local function modify(parent, region, data)
  data.selfPoint = "BOTTOMLEFT";
  local leftest, rightest, lowest, highest = 0, 0, 0, 0;
  for index, childId in ipairs(data.controlledChildren) do
    local childData = WeakAuras.GetData(childId);
    if(childData) then
      local blx, bly, trx, try = getRect(childData);
      leftest = math.min(leftest, blx);
      rightest = math.max(rightest, trx);
      lowest = math.min(lowest, bly);
      highest = math.max(highest, try);
    end
  end
  region.blx = leftest;
  region.bly = lowest;
  region.trx = rightest;
  region.try = highest;
  
  region:ClearAllPoints();
  region:SetPoint(data.selfPoint, parent, data.anchorPoint, data.xOffset, data.yOffset);
  
  function region:PositionChildren()
  end
  
  function region:ControlChildren()
  end
end

WeakAuras.RegisterRegionType("group", create, modify, default);