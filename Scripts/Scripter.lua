local IconsData={}

local IndexIcons={}
local SortFunc=function(a,b) return a.Tier<b.Tier end

local IconDataFolder=game.ReplicatedStorage:FindFirstChild('IconData')
if not IconDataFolder then
   IconDataFolder = Instance.new('Folder')
   IconDataFolder.Name = 'IconData'
   IconDataFolder.Parent = game.ReplicatedStorage
end

local children1=workspace.IconConverter:GetChildren()
for _, part in ipairs(children1) do
   local surfaceGui=part:FindFirstChildOfClass('SurfaceGui')
   if not surfaceGui then continue end
    
   local partName=part.Name
   local partDisplayName=partName
   
   if partName:find('Potion') then
      partDisplayName='Potion'
   elseif partName:find('Money') then
      partDisplayName='Money'
  elseif partName:find('Emoji') then
      partDisplayName='Emoji'
   end
  
   if IndexIcons[partDisplayName]==nil then
      IndexIcons[partDisplayName]=0
   end
   IndexIcons[partDisplayName]+=1
   local index=IndexIcons[partDisplayName
  
   if IconsData[partDisplayName]==nil then
      IconsData[partDisplayName]={}
   end

   local iconChildren=surfaceGui:GetChildren()
   if #iconChildren==1 then
      local imagelabel=iconChildren[1]
      table.insert(IconsData[partDisplayName], {{Id=tostring(index),=partName,Image=imagelabel.Image}})
   else
      local list={}
      for _, imagelabel in ipairs(iconChildren) do
         table.insert(list, {Id=tostring(index),Tier=tonumber(imagelabel.Name) or 1,Image=imagelabel.Image})
      end
      table.sort(list,SortFunc)
      table.insert(IconsData[partDisplayName],list)
  end
  
   part.Parent=game.ReplicatedStorage
end

for displayName, info in ipairs(IconsData) do
   local folder=IconDataFolder:FindFirstChild(displayName)
   if not folder then
      folder = Instance.new('Folder')
      folder.Name = displayName
      folder.Parent = IconDataFolder
   end
   for i,data in ipairs(info) fo
      local second=folder:FindFirstChild(data.Id)
      if not second then
         second = Instance.new('Folder')
         second.Name = data.Id
         second.Parent = folder
      end
  
      local strValue=Instance.new('StringValue')
      strValue.Name=data.Name
      strValue.Value=data.Image
      strValue.Parent=second
   end
end
