local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NpcFolder = workspace.Entites.Npc
local ModulesPath = ReplicatedStorage.Assets.Modules
local QuestRmt = ReplicatedStorage.Assets.Remotes.QuestRemote

local Server = {}
Server.IsFramework = true
Server.Loaded = false

Server.Init = function()
	
	for _, Npc in pairs(NpcFolder:GetChildren()) do
		local QuestName = Npc.QuestSystem.QuestInfo.QuestToGive.Value
		
		local ProxmityPrompt = Instance.new("ProximityPrompt")
		ProxmityPrompt.ObjectText = Npc.Name
		ProxmityPrompt.ActionText = "Talk to " .. Npc.Name
		ProxmityPrompt.HoldDuration = 0
		ProxmityPrompt.Parent = Npc
		
		ProxmityPrompt.Triggered:Connect(function(plr)
			if not plr.CurrentQuests:FindFirstChild(QuestName) then
				QuestRmt:FireClient(plr, {
					Type = "UiController", 
					Npc = Npc, 
					QuestDescription = QuestName, 
					QuestTimer = Npc.QuestSystem.QuestInfo.QuestTime.Value})
			end
		end)
	end
	
	QuestRmt.OnServerEvent:Connect(function(plr, args)
		local QuestModule = require(ModulesPath.Quests[args.QuestName])
		if args.Type == "CreateQuest" then
			QuestModule.AddQuest(plr)
		elseif args.Type == "CancelQuest" then
			QuestModule.CancelQuest(plr)
		end
	end)
	
end

return Server
