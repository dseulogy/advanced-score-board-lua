local filterEnabled = false
local filterText = {}


local function UpdateBoard()
	SSB_List_Update(SSB_Frame.sortType)
end

function AdvScoreBoard_OnFilterChange()
	local stype = getglobal("SSB_Type"..tostring(SSB_Frame.sortType-3))
	if stype and stype.data then
		filterText.name = AdvScoreFilterName:GetText()
		filterText.guild= AdvScoreFilterGuild:GetText()
		filterEnabled = true
		UpdateBoard()
	end
end

function AdvScoreBoard_OnFilter(ID)
	filterText.name = AdvScoreFilterName:GetText()
	filterText.guild= AdvScoreFilterGuild:GetText()
	filterEnabled = true
	UpdateBoard()
end

local function isMatched(text,substr)
	if not text or not substr or substr == "" or string.find(text:lower(),substr:lower(),1,true) then
		return true
	else
		return false
	end
end

local function findMatched(arg1,index,count)
	for index = index,count do
		local rank,lrank,name,guild,score,note=SSB_GetScoreItemInfo(arg1,index);
		if rank < 0 then
			return false,index
		end
		if isMatched(name,filterText.name) and isMatched(guild, filterText.guild) then
			return true,index
		end
		index = index + 1
	end
	return false,index
end

function SSB_List_Update(arg1)

	local index=SSB_ListScrollBar:GetValue();
	for i=1,SSB_MAX_LISTITEM_NUM do	
		local item=getglobal("SSB_Item"..i);
		item:Hide();
	end
	local count=SSB_GetBoardCount(arg1);
	local realIndex = index+1
	local matched,matchStart = 0,1
	while matchStart < count do
		local found, index = findMatched(arg1, matchStart, count)
		if not found then
			break
		end
		matchStart = index + 1
		matched = matched + 1
	end
	
	for i=1,SSB_MAX_LISTITEM_NUM do	
		if (realIndex<=count) then
			local found, index = findMatched(arg1, realIndex, count)
			if not found then
				break
			end
			local rank,lrank,name,guild,score,note=SSB_GetScoreItemInfo(arg1,index);
			local List=getglobal("SSB_Item"..i);
			SSB_ListItem_SetData(List,rank,lrank,name,guild,score,note);
			List:Show();
			realIndex = index + 1
		end
	end
	if AdvScoreFilterCount then
		AdvScoreFilterCount:SetText(string.format("%d / %d",matched,count))
	end
	
	local rank,lastRank,score,note=SSB_GetScoreMyInfo(arg1);
	--[[
	SSB_MyNoteEditBox:SetText(note);
	SSB_MyNoteEditBox.sortType=note;
	--]]
	if (rank>0) then
		SSB_MyRankFrameNowRank:SetText(rank);
	else
		SSB_MyRankFrameNowRank:SetText("-");
	end
	
	if (lastRank>0) then
		SSB_MyRankFrameLastRank:SetText(lastRank);
	else
		SSB_MyRankFrameLastRank:SetText("-");
	end
	
	if (score>0) then
		SSB_MyRankFrameScore:SetText(score);
	else
		SSB_MyRankFrameScore:SetText("-");
	end	
	-- SSB_MyRankFrameBestScore:SetText(bestScore);
	-- SSB_MyRankFrameBestRank:SetText(bestRank);

	-- SSB_MyNoteEditBox:Enable();

end
