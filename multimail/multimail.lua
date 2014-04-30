

-- ---------creating the table to save all the mailing lists in



--MM_MAX_ROWS_TO_DISPLAY = 30
--MM_MAX_ENTRIES = 125  -- unlimited witha scroll bar, yey
MM_HEIGHT_OF_BUTTON = 18
MM_COLUMNS_TO_DISPLAY = 3
MM_MAX_SIZE_OF_NAMES = 120
MM_MAX_LISTS = 500





--MMdebug = true

MMprintstack = -1
function MMprint(message)
   if(MMdebug) then
      local stack, filler
      if not message then
	  	 DEFAULT_CHAT_FRAME:AddMessage("No Message to print.")
		 return false 
      end
      MMprintstack=MMprintstack+1
      local filler=""
      for stack=1,MMprintstack do
	  	 filler=filler.."--"
      end   
      if (type(message) == "table") then
	  	-- DEFAULT_CHAT_FRAME:AddMessage("its a table.  length="..MM_tcount(message))
	 	local i
	 	for k,v in pairs(message) do

	    	DEFAULT_CHAT_FRAME:AddMessage(filler.."(key)   "..k)
	    	MMprint(v)
	 	end
      elseif (type(message) == "userdata") then
      
      else
	  	  if(MMprintstack>0) then
	    	 DEFAULT_CHAT_FRAME:AddMessage(filler.."(value) "..message)
	 	 else
	    	 DEFAULT_CHAT_FRAME:AddMessage(filler..message)
	 	 end
	end
      MMprintstack=MMprintstack-1
   end
end

		
function MMnamelist_Initialise(self,level)
   local level = level or 1
   if (level == 1) then
      local info = UIDropDownMenu_CreateInfo();
      local key, value
      for i = 1,2 do
            info.text = "info text"..i
    	    info.value = i
    	    info.hasArrow = false
    	    info.notCheckable = false
    	    info.owner = self:GetParent()
    	    info.func =  MMnamelistItem_OnClick
--[[   
		    if(i == MMsortmethodnum) then
    	        info.checked = true
    	    else
                info.checked = false
    	    end
			]]
			
    	    UIDropDownMenu_AddButton(info,level)
			
      end
	  
    end
end

function MMnamelistItem_OnClick(self)
   --if they clicked it again, change desc/asc
	MMprint("*CLeeek! "..self.value)
   
end
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++end


-- ONLOAD, duh
function MM_onload() 

    DEFAULT_CHAT_FRAME:AddMessage("MM Loaded.")
	
	-- create our slash commands
	SLASH_MM1 = "/MM";
	SLASH_MM2 = "/mm";
	-- create our slash commands
	
	SLASH_MM3 = "/MM";
	SLASH_MM4 = "/multimail";
	SlashCmdList["MM"] = MMmain;
	

    --create the invisible parent frame that recieves all the events.  im trying a no XML aproach
    MMframe = CreateFrame("frame",MMframe,UIParent)
    MMframe:SetScript("OnEvent",MM_onevent)
    MMframe:SetScript("OnUpdate",MM_onupdate)
    


	-- Register for events
	MMframe:RegisterEvent("MAIL_SHOW");
	MMframe:RegisterEvent("MAIL_INBOX_UPDATE");
	MMframe:RegisterEvent("MAIL_CLOSED");
	MMframe:RegisterEvent("MAIL_SEND_INFO_UPDATE");
	MMframe:RegisterEvent("MAIL_SEND_SUCCESS");
	MMframe:RegisterEvent("MAIL_FAILED");
	MMframe:RegisterEvent("CLOSE_INBOX_ITEM");
	MMframe:RegisterEvent("VARIABLES_LOADED");

	--initialize our variables
	MMsendqueue = {}
	MMsendqueue.subject = ""
	MMsendqueue.body = ""
	MMsendqueue.names = {}
	MMsendqueue.elapsed = 0
	
	MMcansendnext = true
	MMalllists = {}
	MMcurrentlistnum = 1
	
	-- get arena names

			-- no team info is available till MMframe is called.  Its a server function so the info might not be available right away, which is why i call it at the start
	--	ArenaTeamRoster(3)  --function removed in 5.3
	
	--get guild names
	GuildRoster()


	
	
	-- The Button that appears in the MailBox window
	MMopenMM = CreateFrame("Button",nil,MailFrame,"UIPanelButtonTemplate")
		MMopenMM:SetHeight(30)
		MMopenMM:SetWidth(44)
		MMopenMM:SetText("MM")
		MMopenMM:SetPoint("TOPRIGHT",12,-12)
		MMopenMM:SetScript("OnClick",function()
		      MailFrameTab2:Click()
		      MMcustom:Hide()

			MMmain()
		end)


	-- --------------the main frame
	MMlist = CreateFrame("Frame","MMlist",UIParent)
		MMlist:Hide()
		--[[
		MMlist:SetWidth(MM_MAX_SIZE_OF_NAMES * MM_COLUMNS_TO_DISPLAY)
		--MMlist:SetHeight((MM_MAX_ROWS_TO_DISPLAY * MM_HEIGHT_OF_BUTTON) + 90)
		MMlist:SetHeight(MailFrame:GetHeight())
		-- Dont ask me why, it just looked good here
		MMlist:SetPoint("left",MailFrame,"right",-36,18)
		]]
		MMlist:SetPoint("topleft",MMopenMM,"topright")
		MMlist:SetHeight(MailFrame:GetHeight())
		MMlist:SetWidth(MailFrame:GetWidth())
		
		MMlist:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
									edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border",
									tile = false,
									tilesize = 16,
									edgesize = 16,
									insets = { left = 10, right = 10, top = 10, bottom = 10 }})
		MMlist:SetBackdropColor(0,0,0,1)

		------------------------invisible header frame for non-buttons
	MMheaderframe = CreateFrame("Frame",nil,MMlist)
	--MMheaderframe:SetWidth(MMlist:GetWidth())
	MMheaderframe:SetHeight(70)
	MMheaderframe:SetPoint("Topleft")
	MMheaderframe:SetPoint("Topright")
	
			-- ------------- add edit box to change lists
			MMlistnumbereditbox = CreateFrame("EditBox",nil,MMheaderframe,"InputBoxTemplate")
				MMlistnumbereditbox:SetHeight(45)
				MMlistnumbereditbox:SetWidth(32)
				MMlistnumbereditbox:SetText(MMcurrentlistnum)
				MMlistnumbereditbox:SetPoint("topright",-40,0)
				MMlistnumbereditbox:SetMaxLetters(2)
				MMlistnumbereditbox:SetNumeric(true)
				MMlistnumbereditbox:SetScript("OnEscapePressed",function()
					MMlist:Hide()
				end)
				MMlistnumbereditbox:SetScript("OnTabPressed",function()
					MMnewnameeditbox:SetFocus()
				end)
				-- ------------------ change our mailing list displayed
				MMlistnumbereditbox:SetScript("OnCursorChanged",function()
					if  (MMlistnumbereditbox:GetNumber()) then
						if (MMlistnumbereditbox:GetNumber() > MM_MAX_LISTS) then
							MMlistnumbereditbox:SetText(MM_MAX_LISTS)
						end
					
						MMcurrentlistnum = MMlistnumbereditbox:GetNumber()
		
						MMlistupdate()
					end
				end)
				
				MMlistnumbereditbox:SetScript("OnMouseUp",function()
				   MMlistnumbereditbox:HighlightText()
				end)
				
				
				--[[
				
				
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++				
				--testing using dropdown instead of Edit Box
				
				MMnamelist = CreateFrame("Frame", "MMnamelist", MMlist, "UIDropDownMenuTemplate");
				UIDropDownMenu_SetWidth(MMnamelist,150,18)
				MMnamelist:SetPoint("Top",MMlist,"bottom",0,0)
				--invisible button for text
				MMnamelistbutton = CreateFrame("Button",nil,MMnamelist)
				MMnamelistbutton:SetText("Choose list:")
				MMnamelistbutton:SetNormalFontObject(GameFontNormal)
				MMnamelistbutton:SetPoint("topleft",40,0)
				MMnamelistbutton:SetWidth(80)
				MMnamelistbutton:SetHeight(32)
				--MMnamelistbutton:Disable()
				UIDropDownMenu_Initialize(MMnamelist,MMnamelist_Initialise);
				--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

				]]
				
				
					-- ---------------------- create the 'lookin at list number ' caption
			MMcaption = CreateFrame("Button",nil,MMheaderframe)
				MMcaption:SetHeight(32)
				MMcaption:SetWidth(100)
				MMcaption:SetText("Displaying list #")
				MMcaption:SetPoint("right",MMlistnumbereditbox,"left")
				MMcaption:SetNormalFontObject(GameFontNormal)
				

			
	-- --------------'Add name' button
		MMnewnamebutton = CreateFrame("Button",nil,MMheaderframe,"UIPanelButtonTemplate")
			MMnewnamebutton:SetHeight(32)
			MMnewnamebutton:SetWidth(100)
			MMnewnamebutton:SetText("Add a Name")
			MMnewnamebutton:SetPoint("TOPLEFT",10,-32)
			MMnewnamebutton:SetScript("OnClick",function()
				local MMnewname = MMnewnameeditbox:GetText()
				if MMnewname ~= "" then
					if not (MMalllists[MMcurrentlistnum]) then
						MMalllists[MMcurrentlistnum] = {}
					end
					table.insert(MMalllists[MMcurrentlistnum],MMnewname)
					MMnewnameeditbox:SetText("")
					MMlistupdate()
				end
			end)
			
	-- --------------Add Edit box for names
		MMnewnameeditbox = CreateFrame("EditBox",nil,MMheaderframe)
			MMnewnameeditbox:SetFocus()
			MMnewnameeditbox:SetFontObject(ChatFontNormal)
			MMnewnameeditbox:SetBackdropColor(0,0,0,0)
			MMnewnameeditbox:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
									edgeFile="",
									tile = false,
									tilesize = 1,
									edgesize = 1,
									insets = { left = 0, right = 0, top = 0, bottom = 0 }})
	


			MMnewnameeditbox:SetHeight(26)
			MMnewnameeditbox:SetWidth(MMnewnamebutton:GetWidth())
			MMnewnameeditbox:SetText("Add a Name")
			MMnewnameeditbox:SetPoint("LEFT",MMnewnamebutton,"RIGHT")
			MMnewnameeditbox:SetFrameLevel(3)
			MMnewnameeditbox:SetScript("OnEscapePressed",function()
				MMlist:Hide()
			end)
			MMnewnameeditbox:SetScript("OnTabPressed",function()
					MMlistnumbereditbox:SetFocus()
				end)
			MMnewnameeditbox:SetScript("OnEnterPressed",function()
				MMnewnamebutton:Click()
				MMnewnameeditbox:SetText("")
			end)
			MMnewnameeditbox:SetScript("OnEnter",function()
				if MMnewnameeditbox:GetText() == "Add a Name" then
					MMnewnameeditbox:SetText("")
				end
			end)
			
			
-- --------------Add 'send' button
		MMsendbutton = CreateFrame("Button",nil,MMlist,"UIPanelButtonTemplate")
			MMsendbutton:SetHeight(32)
			MMsendbutton:SetWidth(100)
			MMsendbutton:SetText("Multi Mail!")
			MMsendbutton:SetPoint("BOTTOM")
			MMsendbutton:SetScript("OnEnter", function(self)
                    mmShowTooltip(self,"Send Your Message to Everyone")
                end)
			MMsendbutton:SetScript("OnLeave", mmHideTooltip)
		
-- ------------------heres the actual queuing loop			
			MMsendbutton:SetScript("OnClick",function()
				MMprint("MM button clicked - calling mmsendmail")
				MMsendmail()
				
			end)
		
	
		MMcreatelistbuttons()
	
			
			local align = "RIGHT"
			--local align = "LEFT"
			

	-- -------------------------------the 5v5, 3v3 and 2v2 buttons
		MM5v5button = CreateFrame("Button",nil,MMlist,"UIPanelButtonTemplate")
			MM5v5button:SetHeight(32)
			MM5v5button:SetWidth(40)
			MM5v5button:SetText("5v5")
			MM5v5button:SetFrameStrata("HIGH")
			--MM5v5button:SetPoint("TOP"..align,MM5v5button:GetWidth(),-16)
			MM5v5button:SetPoint("topleft",MMopenMM,"Bottomleft",0,-32)
			MM5v5button:SetPoint("topright",MMopenMM,"Bottomright",0,-32)
			align = "RIGHT"
			MM5v5button:SetScript("OnClick",function()
				MMgetarenanames(5)
			end)
			
			-- -------------------------------the 3v3 
		MM3v3button = CreateFrame("Button",nil,MMlist,"UIPanelButtonTemplate")
			MM3v3button:SetHeight(32)
			MM3v3button:SetWidth(40)
			MM3v3button:SetText("3v3")
			MM3v3button:SetPoint("TOP",MM5v5button,"BOTTOM",0,0)
			MM3v3button:SetFrameStrata("HIGH")
			MM3v3button:SetScript("OnClick",function()
				MMgetarenanames(3)
			end)
			-- -------------------------------the 2v2
		MM2v2button = CreateFrame("Button",nil,MMlist,"UIPanelButtonTemplate")
			MM2v2button:SetHeight(32)
			MM2v2button:SetWidth(40)
			MM2v2button:SetText("2v2")
			MM2v2button:SetPoint("TOP",MM3v3button,"BOTTOM",0,0)
			MM2v2button:SetFrameStrata("HIGH")
			MM2v2button:SetScript("OnClick",function()
				MMgetarenanames(2)
			end)
			
			-- ---------------------------the friends button
					MMfriendsbutton = CreateFrame("Button",nil,MMlist,"UIPanelButtonTemplate")
			MMfriendsbutton:SetHeight(32)
			MMfriendsbutton:SetWidth(50)
			MMfriendsbutton:SetText("Friends")
			MMfriendsbutton:SetPoint("TOP"..align,MM2v2button,"BOTTOM"..align,0,-32)
			MMfriendsbutton:SetFrameStrata("HIGH")
			MMfriendsbutton:SetScript("OnClick",function()	
				local numFriends = GetNumFriends();
				if not (MMalllists[MMcurrentlistnum]) then
					MMalllists[MMcurrentlistnum] = {}
				end
				for i=1, 50 do
					name, level, class, area, connected, status = GetFriendInfo(i)
					table.insert(MMalllists[MMcurrentlistnum],name)
				end
				MMlistupdate()
			end)
			
			-- --------------------------- the guild button
			MMguildbutton = CreateFrame("Button",nil,MMlist,"UIPanelButtonTemplate")
			MMguildbutton:SetHeight(32)
			MMguildbutton:SetWidth(40)
			MMguildbutton:SetText("Guild")
			MMguildbutton:SetPoint("TOP"..align,MMfriendsbutton,"BOTTOM"..align,0,-16)
			MMguildbutton:SetFrameStrata("HIGH")
			MMguildbutton:SetScript("OnClick",function()
				local numGuildMembers = GetNumGuildMembers(true );  --true for offline
				local name
				if (numGuildMembers == 0) then
					DEFAULT_CHAT_FRAME:AddMessage("No members found.  If you are in a guild, try again in a few moments, or open your guild pane.")
					return
				else
					DEFAULT_CHAT_FRAME:AddMessage(numGuildMembers.." members added.")
				end
				--local guildName, guildRankName, guildRankIndex = GetGuildInfo("player");
		
				if not (MMalllists[MMcurrentlistnum]) then
					MMalllists[MMcurrentlistnum] = {}
				end
				for i=1, numGuildMembers do
					--name, rank, rankIndex, level, class, zone, note, officernote, online = GetGuildRosterInfo(i);
					name,_,_,_,_,_,_,_,_ = GetGuildRosterInfo(i);
					table.insert(MMalllists[MMcurrentlistnum],name)
				end
				MMlistupdate()
			end)
			
						-- --------------------------- the custom list button
			MMcustombutton = CreateFrame("Button",nil,MMlist,"UIPanelButtonTemplate")
			MMcustombutton:SetHeight(32)
			MMcustombutton:SetWidth(60)
			MMcustombutton:SetText("Custom")
			MMcustombutton:SetPoint("TOP"..align,MMguildbutton,"BOTTOM"..align,0,-16)
			MMcustombutton:SetFrameStrata("HIGH")
			MMcustombutton:SetScript("OnClick",function()
			     MMcustom:Show()
			     MMlist:Hide()
			end)
			
			
			-- --------------------------- the clear button
		MMclearbutton = CreateFrame("Button",nil,MMlist,"UIPanelButtonTemplate")
			MMclearbutton:SetHeight(32)
			MMclearbutton:SetWidth(40)
			MMclearbutton:SetText("Clear")
			MMclearbutton:SetPoint("TOP"..align,MMcustombutton,"BOTTOM"..align,0,-32)
			MMclearbutton:SetFrameStrata("HIGH")
			MMclearbutton:SetScript("OnClick",function()
				MMalllists[MMcurrentlistnum] = {}
				MMlistupdate()
			end)


            MMcreatecustomframe()

			MMcreatescrollbar()

 -- message("loading MM!"); 
end 

function MMcreatelistbuttons()

	-- -----------all the buttons to display names
	local previousrow, topofrow, MMnamebutton
	local rtcf
	rtcf = MMrowsthatcanfit()
	for i=1, rtcf * MM_COLUMNS_TO_DISPLAY do
		
		-- MMnamebutton = CreateFrame("Button",nil,MMlist,"FriendsFrameIgnoreButtonTemplate")
		MMnamebutton = CreateFrame("Button","MMnamebutton"..i,MMlist)
		
		--if your text is above size 16 font, dang
		MMnamebutton:SetHeight(16)
		
		MMnamebutton:SetWidth(MMlist:GetWidth() / MM_COLUMNS_TO_DISPLAY)		
		MMnamebutton:SetNormalFontObject(GameFontNormal)

		-- if its the top of a row
		if (i % rtcf == 1) then
			if(topofrow == nil) then
				--its the first button
				MMnamebutton:SetPoint("TOPLEFT",MMheaderframe,"BottomLeft")
				topofrow = MMnamebutton			
			else
				MMnamebutton:SetPoint("left",topofrow,"right")
			end
			topofrow = MMnamebutton
		else
			if previousrow == nil then
				message("Error line 190.  Stupid Programmer.")
			else
				MMnamebutton:SetPoint("TOP",previousrow,"BOTTOM")
			end
		end
		
	-- ----------------------here is where we delete stuff
		MMnamebutton:SetScript("OnClick",function()
			local currentlist = MMalllists[MMcurrentlistnum]
			local scrollbar = getglobal(MMlist:GetName().."scrollbarScrollBar")
			local offset = scrollbar:GetValue() * MM_COLUMNS_TO_DISPLAY
			
			if (currentlist[i+offset]) then
				table.remove(currentlist, i+offset)
			end
			
			MMlistupdate()

		end)
	
		previousrow = MMnamebutton
	end

end

function MMmain(input)
	MMprint ("someone did a /mm")
	if(input == "test") then
		
		MailFrame:Show()
		MMlist:Show()
	
	elseif(input == "debug") then
		if not MMdebug then 
			MMdebug = true 
		else
			MMdebug = not MMdebug
		end;
		print(MMdebug)
	else
		MMlist:Show()
		
	end

end

function MMsendmail()
	if(not SendMailSubjectEditBox:IsVisible()) then		
		DEFAULT_CHAT_FRAME:AddMessage("The 'Send Mail' screen must be visible")
		return
	end		
	if(SendMailSubjectEditBox:GetText() == "" and SendMailBodyEditBox:GetText()== "") then
		DEFAULT_CHAT_FRAME:AddMessage("Naga, Please.  Thrall doesn't like spam.  Write something!  Now!")
		return
	end		

   local playerName = string.lower(UnitName("player"));

	MMsendbutton:Disable()
	
	MMsendqueue.subject = SendMailSubjectEditBox:GetText()
	MMsendqueue.body = SendMailBodyEditBox:GetText()		
	local MMcurrentlist = MMalllists[MMcurrentlistnum]
	MMprint("PRE filter")
	MMprint(MMcurrentlist)
	MMcurrentlist = MMremoveduplicates(MMcurrentlist)
	MMprint("POST filter")
	MMprint(MMcurrentlist)
	
	for i=1,table.maxn(MMcurrentlist) do
		
		-- do not allow adding ones self
		MMprint("playername = ")
		MMprint(playerName)
		
		if (string.lower(MMcurrentlist[i]) ~= playerName) then   
			-- put the names in the queue
		   table.insert(MMsendqueue.names, MMcurrentlist[i])
		end
	end
	MMlistupdate()
		
	-- one cannot actually send anything from this loop
	-- when one mail is sent, Blizzard locks the sending mail engine
	-- until a MAIL_SENT or MAIL_FAILED event is recieved
	-- therefore, one must create a queue,
	-- and put the actual sending event in the OnUpdate() handler
	-- thus making sure the server is free before sending the next mail
	--SendMail(SendMailNameEditBox:GetText(), SendMailSubjectEditBox:GetText(), SendMailBodyEditBox:GetText());
	
end
-- ----------------------get the names for the matching size arena team and fill the list
function MMgetarenanames(MMteamtype)
	for MMteamid = 1, 3 do
		-- no team info is available till this is called.  Its a server function so the info might not be available right away  :(
		ArenaTeamRoster(MMteamid)
		local teamName, teamSize, _, _, _, _, _, _, _,_  = GetArenaTeam(MMteamid);
		if(teamSize == MMteamtype) then
			local numMembers = GetNumArenaTeamMembers(MMteamid);
			if (numMembers == 0) then
				DEFAULT_CHAT_FRAME:AddMessage("It takes a bit to get this info from the server.  Give it a few seconds.")
				return
			end		
			for MMarenanames=1,numMembers do
				local name, _, _, _, _, _, _, _, _ = GetArenaTeamRosterInfo(MMteamid, MMarenanames);
				if(name) then
					if not (MMalllists[MMcurrentlistnum]) then
						MMalllists[MMcurrentlistnum] = {}
					end
					table.insert(MMalllists[MMcurrentlistnum],name)
				end
			end
		end
	end
	MMlistupdate()

end



function MM_onevent(self, event)
	MMprint("|c0055ffffevent =")
	MMprint(event)
	if ( event == "MAIL_SEND_SUCCESS" ) then
		MMcansendnext = true;
	elseif ( event == "MAIL_FAILED" ) then
		MMcansendnext = true;
	elseif ( event == "MAIL_CLOSED" ) then
		MMcansendnext = nil;
		MMlist:Hide()
	elseif ( event == "MAIL_SHOW" ) then
		MMcansendnext = true;
	elseif ( event == "VARIABLES_LOADED") then
	   MMcreateguildranks()

	end
end






function MM_onupdate(self,elapsed)


-- this is called every frame update by the server
-- check if mail is unlocked and mailBox is open
	if ( (not MMcansendnext) and SendMailSubjectEditBox:IsVisible()) then
		return;
	end
	MMsendqueue.elapsed = MMsendqueue.elapsed + elapsed;
	-- also check that at least half a second has passed, just in case
	if ( MMsendqueue.elapsed > 0.5 ) then
--	DEFAULT_CHAT_FRAME:AddMessage("Update called")
	
		MMsendqueue.elapsed = 0;
		
			-- send ONE item
			MMprocessqueue();
		
	end
end


function MMprocessqueue()

-- check if theres anything in the queue

	if(MMsendqueue.names[1]) then
		DEFAULT_CHAT_FRAME:AddMessage("Attempting to send to "..MMsendqueue.names[1])
		-- send it.  Just one mail can be sent right now
		
		if(MMsendqueue.subject == "") then
			MMsendqueue.subject = "MM mail"
		end
		
		SendMail( MMsendqueue.names[1],MMsendqueue.subject, MMsendqueue.body)
		-- Pause OnUpdate processing
		MMcansendnext = nil;
		-- and erase it from the queue
		table.remove(MMsendqueue.names,1)
	else 
		-- if theres nothing in the queue, enable sending
		MMsendbutton:Enable()
	end
	
end

-- borrowed from WowWiki
function MM_GetWords(str)
-- Original --      _,pos,word=string.find(str, "^ *([^%s]+) *", pos+1); --
   local ret = {};
   local pos=0;
   while(true) do
     local word;
     _,pos,word=string.find(str, "^[%s%p]*([^%s%p]+)[%s%p]*", pos+1);
     if(not word) then
       return ret;
     end
     table.insert(ret, word);
   end
 end





function MMlistupdate(parentframe)
	MMprint("|c0055ddddUpdate")
	
	if not (parentframe) then parentframe = MMlist end;
	

	if not (MMalllists[MMcurrentlistnum]) then
		MMalllists[MMcurrentlistnum] = {}
	end
	local MMcurrentlist = MMalllists[MMcurrentlistnum]

	local scrollbar = getglobal(parentframe:GetName().."scrollbarScrollBar")
	--set scroll bar limits
	local rtcf = MMrowsthatcanfit(parentframe)
	scrollbar:SetMinMaxValues(0,math.max(0,(math.ceil((#MMcurrentlist-(rtcf * MM_COLUMNS_TO_DISPLAY)) / MM_COLUMNS_TO_DISPLAY))))
	--get the scroll bar value
	--offset = scrollbar:GetValue()
	
	
	-- make our temporary variables
	local offset = scrollbar:GetValue() * MM_COLUMNS_TO_DISPLAY
	
	MMprint("offset value = "..offset)
	
	local MMcurrentrow,i	
	MMlistnumbereditbox:SetText(MMcurrentlistnum)
	local MMcurrentlist = MMalllists[MMcurrentlistnum]
		
	i=1
	-- Loop through all the buttons
	repeat
	   MMcurrentrow = getglobal("MMnamebutton"..i)
	   -- if there are buttons
	   if (MMcurrentrow) then
	      -- if theres stuff to fill them with
	      if (MMcurrentlist) then
			 if (MMcurrentlist[i+offset]) then
				-- print the value, and enable highlights
				MMcurrentrow:SetText(MMcurrentlist[i+offset])
				MMcurrentrow:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestLogTitleHighlight")		
			 else
				MMcurrentrow:SetText("")
				MMcurrentrow:SetHighlightTexture(nil)				
			 end
		  else
			 MMcurrentrow:SetText("")
			 MMcurrentrow:SetHighlightTexture(nil)				
		  end
	   end
	   
	   i = i + 1
	   -- go till we run out of rows
	until (not (MMcurrentrow))
	
end

function mmShowTooltip(frame,notes)
   if(frame) then
      if frame:GetRight() >= (GetScreenWidth() / 2) then
		GameTooltip:SetOwner(frame, "ANCHOR_LEFT")
      else
		GameTooltip:SetOwner(frame, "ANCHOR_RIGHT")
      end
      if(notes) then
		 GameTooltip:SetText(notes, 0, 1, 1, 1, 1)
		 GameTooltip:Show()
      end
   end
end

function mmHideTooltip()
   GameTooltip:Hide()
end

function MMremoveduplicates(MMlist)

	local newlist = {}
	local MMexists = false

	for i = 1,#MMlist do
		MMexists = false
		if not (newlist[1]) then
			MMprint("Newlist is empty.")
		end
		
		for j = 1,#newlist do
			MMprint("Does MMlist["..i.."] ("..MMlist[i].." = newlist["..j.."] ("..newlist[j].." ? ")	
			if (MMlist[i] == newlist[j]) then --it exists in the new list already
				MMexists  = true
				break
			end
		end
		if(MMexists == false) then
			MMprint("Inserting: "..MMlist[i])
			tinsert(newlist,MMlist[i])
		else
			MMprint("NOT Inserting: "..MMlist[i])
		end
	end

	return newlist
end

function MMcreatescrollbar(parentframe,buttonname,rows,columns)

   --make the scroll bar for the frame
   if not parentframe then parentframe = MMlist end;
   if not columns then columns = MM_COLUMNS_TO_DISPLAY end;
   
	local scrollbarframe = CreateFrame("ScrollFrame",parentframe:GetName().."scrollbar",parentframe,"UIPanelScrollFrameTemplate")
	
	scrollbarframe:SetAllPoints()
   
   local scrollupbutton = getglobal(scrollbarframe:GetName().."ScrollBarScrollUpButton" );
   scrollupbutton:Enable()
   scrollupbutton:SetScript("OnClick",function()
        local scrollbar = getglobal(scrollbarframe:GetName().."ScrollBar")
        scrollbar:SetValue(scrollbar:GetValue() - 1)
   end)
   scrollupbutton:SetScript("OnMouseDown",function()
					      end)  
   scrollupbutton:SetScript("OnMouseUp",function()
					    end)  


   local scrolldownbutton = getglobal(scrollbarframe:GetName().."ScrollBarScrollDownButton" );
   scrolldownbutton:Enable()
   scrolldownbutton:SetScript("OnClick",function()
		local scrollbar = getglobal(scrollbarframe:GetName().."ScrollBar")
        scrollbar:SetValue(scrollbar:GetValue() + 1)
   end)
   scrolldownbutton:SetScript("OnMouseDown",function()
						end)  
   scrolldownbutton:SetScript("OnMouseUp",function()
					      end)  
   scrollbarframe:SetScript("OnVerticalScroll",function()
	--call your update function here
       MMlistupdate(parentframe)
   end)

   scrollbarframe:SetScript("OnMouseWheel",function(self,arg1)
		-- i think arg1 is up or down?
		
		if (not arg1) then
			return
		end
		local scrollbar = getglobal(self:GetName().."ScrollBar")
		local rows = MMrowsthatcanfit(parentframe,buttonname)
		local offset = scrollbar:GetValue()
		scrollbar:SetValue(offset - (arg1*((rows/columns)/2))) --have it scroll half the list each scroll
   end)
   
   local scrollbar = getglobal(scrollbarframe:GetName().."ScrollBar")
   scrollbar:SetScript("OnShow",function()
        MMprint("Onshow")
	end)  		
   scrollbar:SetValueStep(1)
   MMcreatescrollbartemplate(scrollbarframe)

end



function MMcreatescrollbartemplate(ourscrollbar)

   -------------------------------------------------------------------------------
   --- this is my attempt to go the extra step and give our scrollbar some texture
   -------------------------------------------------------------------------------
   MMtexturetop = ourscrollbar:CreateTexture()
   --   MMtexturetop:SetHeight(MM_BUTTON_HEIGHT)
   MMtexturetop:SetWidth(31)
   MMtexturetop:SetPoint("topright",29,2)
   MMtexturetop:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-ScrollBar")
   MMtexturetop:SetTexCoord(0,.484375,0,1) --this cuts the texture, taking only the bottomleft part of it, which just happens to fit the top of a scroll bar --thanks to possessions mod for the exact numbers

   MMtexturebottom = ourscrollbar:CreateTexture()
   MMtexturebottom:SetWidth(30)
   MMtexturebottom:SetHeight(106)
   MMtexturebottom:SetPoint("bottomright",29,-2)
   MMtexturebottom:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-ScrollBar")
   MMtexturebottom:SetTexCoord(.515625,1,0,.4140625) --this cuts the texture, taking only the bottomright part of it, which just happens to fit the bottom of a scroll bar
   
   MMtexturemiddle = ourscrollbar:CreateTexture()
   MMtexturemiddle:SetWidth(30)
   --MMtexturemiddle:SetHeight(ourscrollbar:GetHeight())
   MMtexturemiddle:SetPoint("bottomright",29,0)
   MMtexturemiddle:SetPoint("topright",29,0)
   
   MMtexturemiddle:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-ScrollBar")
   MMtexturemiddle:SetTexCoord(0,.5,.2,.2) --this cuts the texture, taking only the left

   MMtexture = ourscrollbar:CreateTexture()
   MMtexture:SetHeight(25)
   --   MMtexture:SetWidth(30)
   MMtexture:SetAllPoints()
   MMtexture:SetPoint("right",29,45)
   MMtexture:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-ScrollBar")
   MMtexture:SetTexCoord(0,.4,.8,.8) --this cuts the texture, taking only the left middle part of it
   MMtexture:Hide()
end
--=======================================================================
function MMrowsthatcanfit(parentframe)
	local rows = math.floor((MMlist:GetHeight() - MMheaderframe:GetHeight()) / MM_HEIGHT_OF_BUTTON)
	--MMprint("Rowsthatcanfit = "..tostring(rows))
	return rows
end

MM_onload() 