local QuestItems = workspace.Map.QuestItems
local QuestRmt = game:GetService("ReplicatedStorage").Assets.Remotes.QuestRemote

local QuestSystem = {}
QuestSystem.Reward = 100
QuestSystem.Needed = 3

QuestSystem.AddQuest = function(plr, Value)
	local QuestName = Instance.new("StringValue")
	QuestName.Name = script.Name
	QuestName.Parent = plr.CurrentQuests

	local Goal = Instance.new("NumberValue")
	Goal.Name = "Goal"
	Goal.Value = QuestSystem.Needed
	Goal.Parent = QuestName

	local Progress = Instance.new("NumberValue")
	Progress.Name = "Progress"
	Progress.Value = Value or 0
	Progress.Parent = QuestName

	QuestSystem.HandleQuest(plr, QuestName)
end

QuestSystem.CancelQuest = function(plr)
	local QuestsFolder = plr.CurrentQuests

	QuestRmt:FireClient(plr, {Type = "UiControllerCancell"})
	QuestsFolder:ClearAllChildren()
end

QuestSystem.CompleteQuest = function(plr, QuestName)
	--== Add Yen, Xp Rewards ==--
	QuestRmt:FireClient(plr, {Type = "QuestCompleted"})
	print("QUEST COMPLETED!")
	local QuestsFolder = plr.CurrentQuests
	
	wait(3)
	QuestsFolder:ClearAllChildren()
end

QuestSystem.HandleQuest = function(plr, QuestName)
	for _,Bananas in pairs(QuestItems:GetChildren()) do
		if Bananas.Name == "Banana" then
			Bananas.ClickBanana.MouseClick:Connect(function(plr)
				if plr.CurrentQuests:FindFirstChild(script.Name) then
					Bananas:Destroy()
					QuestName.Progress.Value += 1

					if QuestName.Progress.Value == QuestSystem.Needed then
						QuestSystem.CompleteQuest(plr, QuestName)
					end
				end
			end)
		end
	end
end

return QuestSystem
