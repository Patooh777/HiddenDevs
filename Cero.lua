local QuestItems = workspace.Map.QuestItems
local QuestRmt = game:GetService("ReplicatedStorage").Assets.Remotes.QuestRemote

local QuestSystem = {}
QuestSystem.Reward = 100
QuestSystem.Needed = 3

QuestSystem.AddQuest = function(plr, Value)
	--This function is called when the player talks with a quest NPC (on the client)
	--then it goes to the server that will require the the correct module(mission) that NPC gives
	
	local QuestName = Instance.new("StringValue") -- Creates a stringValue with the current quest name inside the "CurrentQuests" Folder
	QuestName.Name = script.Name -- Holds the questName
	QuestName.Parent = plr.CurrentQuests

	local Goal = Instance.new("NumberValue") -- Creates a NumberValue with the goal the player needs to complete the quest, goes inside the "CurrentQuests" Folder
	Goal.Name = "Goal"
	Goal.Value = QuestSystem.Needed --how much the player needs to complete the quest
	Goal.Parent = QuestName

	local Progress = Instance.new("NumberValue") --  Creates a NumberValue with the players progress , goes inside the "CurrentQuests" Folder
	Progress.Name = "Progress"
	Progress.Value = Value or 0 -- Current progress
	Progress.Parent = QuestName

	QuestSystem.HandleQuest(plr, QuestName) -- After creating the quest, we call the handle for it
end

QuestSystem.CancelQuest = function(plr)
	--if the player wants to cancell the quest
	local QuestsFolder = plr.CurrentQuests

	QuestRmt:FireClient(plr, {Type = "UiControllerCancell"}) --Fire it to the client, so the QuestUI will be closed
	QuestsFolder:ClearAllChildren() -- Remove the player current quest
end

QuestSystem.CompleteQuest = function(plr, QuestName)
	--==To do:  Add Yen, Xp Rewards ==--
	QuestRmt:FireClient(plr, {Type = "QuestCompleted"}) --Fire it to the client, so the QuestUI will be closed and the quest completed
	print("QUEST COMPLETED!")
	local QuestsFolder = plr.CurrentQuests
	task.wait(3)
	QuestsFolder:ClearAllChildren() -- Remove the player current quest
end

QuestSystem.HandleQuest = function(plr, QuestName) -- The quest funcion, how the quest works, what the player needs to do etc...
	for _,Bananas in pairs(QuestItems:GetChildren()) do --Loops through all the bannas inside the Folder
		if Bananas.Name == "Banana" then --Check if the value found is equal "bananas"
			Bananas.ClickBanana.MouseClick:Connect(function(plr) -- if its a banana, we will start monitorating the mouseclick event that is inside of it
				if plr.CurrentQuests:FindFirstChild(script.Name) then --cheks if the player have the quest, otherwise the script will not continue
					QuestName.Progress.Value += 1 --adds +1 in te progress

					if QuestName.Progress.Value == QuestSystem.Needed then -- checks if the progress is equal to the needed to complete the quest
						QuestSystem.CompleteQuest(plr, QuestName) --calls the complete function
					end
				end
			end)
		end
	end
end

return QuestSystem
