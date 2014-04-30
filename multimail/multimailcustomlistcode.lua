--just trying to organize my code.  the custom mail stuff got messy

--[[  list all labels/boxes
mmguildlabel
mmguildcb
mmfriendslabel
mmfriendscb
mmguildtitlelabel
mmguildranklabel
mmguildranklable..i
mmguildrankcb..i
mmclasseslabel
mmclasslabel..i
mmclasscb..i
mmraceslabel
mmracelabel..i
mmracecb..i
mmlevellabel
mmminlevellabel
mmminleveleditbox
mmmaxlevellable
mmmaxleveleditbox
]]



function MMcreatecustomframe()
     

	-- --------------the main custom frame
	MMcustom = CreateFrame("Frame",nil,UIParent)
	MMcustom:SetScript("OnShow",function()
					      mmcustomlistupdate()
					   end)
		MMcustom:Hide()
		MMcustom:SetWidth(400)
		MMcustom:SetHeight(MMlist:GetHeight())
		-- Dont ask me why, it just looked good here
		MMcustom:SetPoint("left",MailFrame,"right",0,0)
		MMcustom:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
									edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border",
									tile = false,
									tilesize = 16,
									edgesize = 16,
									insets = { left = 10, right = 10, top = 10, bottom = 10 }})
		MMcustom:SetBackdropColor(0,0,0,1)

	--[[ alright.  how do we want to organize this?
		2 checkboxes for friends and Guild.
		if neither is checked, nothing else is active.
		
		labels:
		guild enables titles.  up to 10?
		class.  9 of those.
		race.  10 of those.  No, five.  Only those of your faction.
		level.  Min - max box
		and one big ol 'add names' button
	  ]]--

	  ----------------- 'guild' label
	  mmguildlabel = CreateFrame("Button", nil, MMcustom)
	  mmguildlabel:SetWidth(40)
	  mmguildlabel:SetHeight(40)
	  mmguildlabel:SetNormalFontObject(GameFontNormal)
	  mmguildlabel:SetPoint("TopLeft",50,-10)
	  mmguildlabel:SetText("Guild")
	  mmguildlabel:SetScript("OnClick", function()
				 local ourcb = getglobal("mmguildcb")
				 ourcb:Click()
			      end)

--	  mmguildlabel:Hide()


	  ------------- guild checkbox

	mmguildcb = CreateFrame("CheckButton",nil,MMcustom)
	mmguildcb:SetWidth(40)
	mmguildcb:SetHeight(mmguildcb:GetWidth())
	mmguildcb:SetPoint("Left",mmguildlabel,"right")
	mmguildcb:SetDisabledTexture("Interface\\Buttons\\UI-CheckBox-Check-Disabled") 
	mmguildcb:SetHighlightTexture("Interface\\Buttons\\UI-CheckBox-Highlight") 
	mmguildcb:SetNormalTexture("Interface\\Buttons\\UI-CheckBox-Up")
	mmguildcb:SetPushedTexture("Interface\\Buttons\\UI-CheckBox-Down")	
	mmguildcb:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")	
	mmguildcb:SetNormalFontObject(GameFontNormal)
	mmguildcb:SetScript("OnClick",function()
					 mmcustomlistupdate()
				      end)
	mmguildcb:SetChecked()
--	mmguildcb:Hide()
		

	  ----------------- 'friend' label
	  mmfriendslabel = CreateFrame("Button", nil, MMcustom)
	  mmfriendslabel:SetWidth(40)
	  mmfriendslabel:SetHeight(40)
	  mmfriendslabel:SetNormalFontObject(GameFontNormal)
	  mmfriendslabel:SetPoint("Left",mmguildcb,"right",50,0)
	  mmfriendslabel:SetText("Friends")
	  mmfriendslabel:SetScript("OnClick",function()
		mmfriendscb:Click()
	     end)
--	  mmfriendslabel:Hide()  --omg.  offline friends won't work.  sigh.

	  ----------------- 'title' label
	  mmtitlelabel = CreateFrame("Button", nil, MMcustom)
	  mmtitlelabel:SetWidth(40)
	  mmtitlelabel:SetHeight(40)
	  mmtitlelabel:SetNormalFontObject(GameFontNormal)
	  mmtitlelabel:SetPoint("Top",0,10)
	  mmtitlelabel:SetText("Custom Mailing")


	  ------------------ friend checkbox
	mmfriendscb = CreateFrame("CheckButton",nil,MMcustom)
	mmfriendscb:SetWidth(40)
	mmfriendscb:SetHeight(mmfriendscb:GetWidth())
	mmfriendscb:SetPoint("Left",mmfriendslabel,"right")
	mmfriendscb:SetDisabledTexture("Interface\\Buttons\\UI-CheckBox-Check-Disabled") 
	mmfriendscb:SetHighlightTexture("Interface\\Buttons\\UI-CheckBox-Highlight") 
	mmfriendscb:SetNormalTexture("Interface\\Buttons\\UI-CheckBox-Up")
	mmfriendscb:SetPushedTexture("Interface\\Buttons\\UI-CheckBox-Down")	
	mmfriendscb:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")	
	mmfriendscb:SetNormalFontObject(GameFontNormal)
	mmfriendscb:SetScript("OnClick",function()
					 mmcustomlistupdate()
				      end)
--	mmfriendscb:Hide()

	  ----------------- 'Guild Title' label
	  mmguildtitlelabel = CreateFrame("Button", nil, MMcustom)
	  mmguildtitlelabel:SetWidth(120)
	  mmguildtitlelabel:SetHeight(40)
	  mmguildtitlelabel:SetNormalFontObject(GameFontNormal)
	  mmguildtitlelabel:SetPoint("TopLeft",0,-50)
	  mmguildtitlelabel:SetText("Guild Titles:")


	  ----------------- all the guild title lables, and checkboxes
--[[   --this has to happen after variables are loaded or it wont find any guild ranks
	  local mmnumranks = GuildControlGetNumRanks()
	  DEFAULT_CHAT_FRAME:AddMessage("Guild ranks number: "..tonumber(mmnumranks))
	  local mmpreviouslabel
	  for i=1, mmnumranks do

	     -------------- the label
	     	  mmguildranklabel = CreateFrame("Button", "mmguildranklabel"..i, MMcustom)
		  mmguildranklabel:SetWidth(60)
		  mmguildranklabel:SetHeight(20)
		  mmguildranklabel:SetNormalFontObject(GameFontNormal)
		  if i==1 then
		     mmguildranklabel:SetPoint("Top",mmguildtitlelabel,"Bottom")
		  else
		     mmguildranklabel:SetPoint("Top",mmpreviouslabel,"Bottom")
		  end
		  mmguildranklabel:SetText(GuildControlGetRankName(i))
		  mmguildranklabel:SetScript("OnClick",function()
			local ourcb = getglobal("mmguildrankcb"..i)
			 ourcb:Click()
	       end)
--		  DEFAULT_CHAT_FRAME:AddMessage("ranks number: "..i.."  = "..GuildControlGetRankName(i))
		  
		  ---------------- the checkbox
		  mmguildrankcb = CreateFrame("CheckButton","mmguildrankcb"..i,MMcustom)
		  mmguildrankcb:SetWidth(30)
		  mmguildrankcb:SetHeight(mmguildrankcb:GetWidth())
		  mmguildrankcb:SetPoint("Left",mmguildranklabel,"right")
		  mmguildrankcb:SetDisabledTexture("Interface\\Buttons\\UI-CheckBox-Check-Disabled") 
		  mmguildrankcb:SetHighlightTexture("Interface\\Buttons\\UI-CheckBox-Highlight") 
		  mmguildrankcb:SetNormalTexture("Interface\\Buttons\\UI-CheckBox-Up")
		  mmguildrankcb:SetPushedTexture("Interface\\Buttons\\UI-CheckBox-Down")	
		  mmguildrankcb:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")	
		  mmguildrankcb:SetNormalFontObject(GameFontNormal)

		  mmpreviouslabel = mmguildranklabel
	     
	  end

    ]]
	  ----------------- classes label
	  mmclasseslabel = CreateFrame("Button", nil, MMcustom)
	  mmclasseslabel:SetWidth(120)
	  mmclasseslabel:SetHeight(40)
	  mmclasseslabel:SetNormalFontObject(GameFontNormal)
	  mmclasseslabel:SetPoint("Left",mmguildtitlelabel,"right",10,0)
	  mmclasseslabel:SetText("Classes:")


	  ----------------- classes and checkboxes.  9 each.
	  local mmpreviouslabel, classes
	  classes = {"Rogue","Warrior","Hunter","Mage","Warlock","Shaman","Druid","Priest","Paladin"}
	  for i=1, 9 do

	     -------------- the label
	     	  mmclasslabel = CreateFrame("Button", "mmclasslabel"..i, MMcustom)
		  mmclasslabel:SetWidth(60)
		  mmclasslabel:SetHeight(20)
		  mmclasslabel:SetNormalFontObject(GameFontNormal)
		  if i==1 then
		     mmclasslabel:SetPoint("Top",mmclasseslabel,"Bottom")
		  else
		     mmclasslabel:SetPoint("Top",mmpreviouslabel,"Bottom")
		  end
		  mmclasslabel:SetText(classes[i])
		  mmclasslabel:SetScript("OnClick",function()
			local ourcb = getglobal("mmclasscb"..i)
			 ourcb:Click()
	       end)
--		  DEFAULT_CHAT_FRAME:AddMessage("ranks number: "..i.."  = "..GuildControlGetRankName(i))
		  
		  ---------------- the checkbox
		  mmclasscb = CreateFrame("CheckButton","mmclasscb"..i,MMcustom)
		  mmclasscb:SetWidth(30)
		  mmclasscb:SetHeight(mmclasscb:GetWidth())
		  mmclasscb:SetPoint("Left",mmclasslabel,"right")
		  mmclasscb:SetDisabledTexture("Interface\\Buttons\\UI-CheckBox-Check-Disabled") 
		  mmclasscb:SetHighlightTexture("Interface\\Buttons\\UI-CheckBox-Highlight") 
		  mmclasscb:SetNormalTexture("Interface\\Buttons\\UI-CheckBox-Up")
		  mmclasscb:SetPushedTexture("Interface\\Buttons\\UI-CheckBox-Down")	
		  mmclasscb:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")	
		  mmclasscb:SetNormalFontObject(GameFontNormal)

		  mmpreviouslabel = mmclasslabel
	     
	  end
	  ----------------- race label
	  mmraceslabel = CreateFrame("Button", nil, MMcustom)
	  mmraceslabel:SetWidth(120)
	  mmraceslabel:SetHeight(40)
	  mmraceslabel:SetNormalFontObject(GameFontNormal)
	  mmraceslabel:SetPoint("Left",mmclasseslabel,"right",10,0)
	  mmraceslabel:SetText("Races:")


	  ----------------- races and checkboxes.  5 each.
	  local mmpreviouslabel, races
	  races = {"Human","Dwarf","Night Elf","Gnome","Draenei","Orc","Troll","Tauren","Undead","Blood Elf"}
	  for i=1, 10 do

	     -------------- the label
	     	  mmracelabel = CreateFrame("Button", "mmracelabel"..i, MMcustom)
		  mmracelabel:SetWidth(60)
		  mmracelabel:SetHeight(20)
		  mmracelabel:SetNormalFontObject(GameFontNormal)
		  if i==1 then
		     mmracelabel:SetPoint("Top",mmraceslabel,"Bottom")
		  else
		     mmracelabel:SetPoint("Top",mmpreviouslabel,"Bottom")
		  end
		  mmracelabel:SetText(races[i])
		  mmracelabel:SetScript("OnClick",function()
			local ourcb = getglobal("mmracecb"..i)
			 ourcb:Click()
		      end)
--		  DEFAULT_CHAT_FRAME:AddMessage("ranks number: "..i.."  = "..GuildControlGetRankName(i))
		  
		  ---------------- the checkbox
		  mmracecb = CreateFrame("CheckButton","mmracecb"..i,MMcustom)
		  mmracecb:SetWidth(30)
		  mmracecb:SetHeight(mmracecb:GetWidth())
		  mmracecb:SetPoint("Left",mmracelabel,"right")
		  mmracecb:SetDisabledTexture("Interface\\Buttons\\UI-CheckBox-Check-Disabled") 
		  mmracecb:SetHighlightTexture("Interface\\Buttons\\UI-CheckBox-Highlight") 
		  mmracecb:SetNormalTexture("Interface\\Buttons\\UI-CheckBox-Up")
		  mmracecb:SetPushedTexture("Interface\\Buttons\\UI-CheckBox-Down")	
		  mmracecb:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")	
		  mmracecb:SetNormalFontObject(GameFontNormal)

		  if UnitFactionGroup("player") == "Alliance" then
		     if i>5 then
			mmracecb:Hide()
			mmracelabel:Hide()
		     end
		  else
		     if i<=5 then
			mmracecb:Hide()
			mmracelabel:Hide()
		     end

		  end



		  mmpreviouslabel = mmracelabel
	     end
	  ---------------- level label
	  mmlevellabel = CreateFrame("Button", nil, MMcustom)
	  mmlevellabel:SetWidth(20)
	  mmlevellabel:SetHeight(20)
	  mmlevellabel:SetNormalFontObject(GameFontNormal)
	  mmlevellabel:SetPoint("bottom",0,90)
	  mmlevellabel:SetText("Level:")


	  ---------------- minimum label
	  mmminlevellabel = CreateFrame("Button", nil, MMcustom)
	  mmminlevellabel:SetWidth(20)
	  mmminlevellabel:SetHeight(20)
	  mmminlevellabel:SetNormalFontObject(GameFontNormal)
	  mmminlevellabel:SetPoint("topright",mmlevellabel,"bottomleft",0,0)
	  mmminlevellabel:SetText("Min:")



	  ---------------- minimum editbox
	  mmminleveleditbox = CreateFrame("EditBox",nil,MMcustom,"InputBoxTemplate")
	  mmminleveleditbox:SetFocus()
	  mmminleveleditbox:SetHeight(32)
	  mmminleveleditbox:SetWidth(30)
	  mmminleveleditbox:SetFontObject(ChatFontNormal)
	  mmminleveleditbox:SetBackdropColor(0,0,0,0)
	  mmminleveleditbox:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
									edgeFile="",
									tile = false,
									tilesize = 1,
									edgesize = 1,
									insets = { left = 0, right = 0, top = 0, bottom = 0 }})
	

--	  mmminleveleditbox:SetText("Add a Name")
	  mmminleveleditbox:SetPoint("top",mmminlevellabel,"bottom")
	  mmminleveleditbox:SetFrameLevel(3)
	  mmminleveleditbox:SetScript("OnEscapePressed",function()
		 MMcustom:Hide()
	      end)
	  mmminleveleditbox:SetScript("OnTabPressed",function()
		     mmmaxleveleditbox:SetFocus()
	   end)
	  mmminleveleditbox:SetScript("OnEnterPressed",function()
	--	mmminlevelbutton:Click()
         --	mmminleveleditbox:SetText("")
                       end)
	  mmminleveleditbox:SetScript("OnEnter",function()
           --	if mmminleveleditbox:GetText() == "Add a Name" then
        --	    mmminleveleditbox:SetText("")
	--	 end
	      end)
	  --------------- max
	  mmmaxlevellabel = CreateFrame("Button", nil, MMcustom)
	  mmmaxlevellabel:SetWidth(20)
	  mmmaxlevellabel:SetHeight(20)
	  mmmaxlevellabel:SetNormalFontObject(GameFontNormal)
	  mmmaxlevellabel:SetPoint("TopLeft",mmlevellabel,"Bottomright",0,0)
	  mmmaxlevellabel:SetText("Max:")



	  --------------- max editbox
  mmmaxleveleditbox = CreateFrame("EditBox",nil,MMcustom,"InputBoxTemplate")
	  mmmaxleveleditbox:SetFocus()
	  mmmaxleveleditbox:SetHeight(32)
	  mmmaxleveleditbox:SetWidth(30)
	  mmmaxleveleditbox:SetFontObject(ChatFontNormal)
	  mmmaxleveleditbox:SetBackdropColor(0,0,0,0)
	  mmmaxleveleditbox:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
									edgeFile="",
									tile = false,
									tilesize = 1,
									edgesize = 1,
									insets = { left = 0, right = 0, top = 0, bottom = 0 }})
	


--	  mmmaxleveleditbox:SetText("Add a Name")
	  mmmaxleveleditbox:SetPoint("top",mmmaxlevellabel,"bottom")
	  mmmaxleveleditbox:SetFrameLevel(3)
	  mmmaxleveleditbox:SetScript("OnEscapePressed",function()
		 MMcustom:Hide()
	      end)
	  mmmaxleveleditbox:SetScript("OnTabPressed",function()
		     mmminleveleditbox:SetFocus()
	   end)
	  mmmaxleveleditbox:SetScript("OnEnterPressed",function()
	--	mmmaxlevelbutton:Click()
         --	mmmaxleveleditbox:SetText("")
                       end)
	  mmmaxleveleditbox:SetScript("OnEnter",function()
           --	if mmmaxleveleditbox:GetText() == "Add a Name" then
        --	    mmmaxleveleditbox:SetText("")
	--	 end
	      end)
		  
		  
	  --------------------------------------------------------------------------------------
	  -------------- last online stuff -----------------------------------
	  
	  MMlastonlineframe = CreateFrame("Frame","MMlastonlineframe",MMcustom)
	  MMlastonlineframe:SetAllPoints()
	  
	    ---------------- lastonline label
	  MMlastonlinelabel = CreateFrame("Button", nil, MMlastonlineframe)
	  MMlastonlinelabel:SetWidth(20)
	  MMlastonlinelabel:SetHeight(40)
	  MMlastonlinelabel:SetNormalFontObject(GameFontNormal)
	  MMlastonlinelabel:SetPoint("top",MMlevellabel,"bottom",0,-100)
	  MMlastonlinelabel:SetText("Days since\nlast online:")
		MMlastonlinelabel:EnableMouse(false)

	  ---------------- minimum label
	  MMminlastonlinelabel = CreateFrame("Button", nil, MMlastonlineframe)
	  MMminlastonlinelabel:SetWidth(30)
	  MMminlastonlinelabel:SetHeight(20)
	  MMminlastonlinelabel:SetNormalFontObject(GameFontNormal)
	  MMminlastonlinelabel:SetPoint("topright",MMlastonlinelabel,"bottomleft",5,0)
	  MMminlastonlinelabel:SetText("From:")
	MMminlastonlinelabel:EnableMouse(false)


	  ---------------- minimum editbox
	  MMminlastonlineeditbox = CreateFrame("EditBox",nil,MMlastonlineframe)
	  MMminlastonlineeditbox:SetHeight(32)
	  MMminlastonlineeditbox:SetWidth(30)
	  MMminlastonlineeditbox:SetFontObject(ChatFontNormal)
	  MMminlastonlineeditbox:SetPoint("top",MMminlastonlinelabel,"bottom")
	  MMminlastonlineeditbox:SetNumeric(true)
	MMminlastonlineeditbox:SetMaxLetters(2)
	  
	  MMminlastonlineeditbox:SetScript("OnEscapePressed",function(self,event)
		self:ClearFocus()
		 MMcustom:Hide()
	end)
	  MMminlastonlineeditbox:SetScript("OnTabPressed",function()
		     MMmaxlastonlineeditbox:SetFocus()
	   end)
	  MMminlastonlineeditbox:SetScript("OnEnterPressed",function()
	                   end)
	  MMminlastonlineeditbox:SetScript("OnEnter",function()

	      end)
		  		local t1,t2,t3
		t1 = MMminlastonlineeditbox:CreateTexture()
		t1:SetTexture("Interface\\Common\\Common-Input-Border")
		t1:SetPoint("left",-5,0)
		t1:SetHeight(20)
		t1:SetWidth(8)
		t1:SetTexCoord(0,.0625,0,.625)
		
		t2 = MMminlastonlineeditbox:CreateTexture()
		t2:SetTexture("Interface\\Common\\Common-Input-Border")
		t2:SetPoint("right")
		t2:SetHeight(20)
		t2:SetWidth(8)
		t2:SetTexCoord(0.9375,1.0,0,0.625)
		
		t3 = MMminlastonlineeditbox:CreateTexture()
		t3:SetTexture("Interface\\Common\\Common-Input-Border")
		t3:SetPoint("left",t1,"right")
		t3:SetPoint("right",t2,"left")
		t3:SetHeight(20)
		t3:SetWidth(10)
		t3:SetTexCoord(0.0625,0.9375,0,0.625)


	  --------------- max label
	  MMmaxlastonlinelabel = CreateFrame("Button", nil, MMlastonlineframe)
	  MMmaxlastonlinelabel:SetWidth(20)
	  MMmaxlastonlinelabel:SetHeight(20)
	  MMmaxlastonlinelabel:SetNormalFontObject(GameFontNormal)
	  MMmaxlastonlinelabel:SetPoint("Left",MMminlastonlinelabel,"right",20,0)
	  MMmaxlastonlinelabel:SetText("To:")
	MMmaxlastonlinelabel:EnableMouse(false)


	  --------------- max editbox	
  MMmaxlastonlineeditbox = CreateFrame("EditBox",nil,MMlastonlineframe)
	
	  MMmaxlastonlineeditbox:SetHeight(26)
	  MMmaxlastonlineeditbox:SetWidth(30)
	  MMmaxlastonlineeditbox:SetFontObject(ChatFontNormal)
	  MMmaxlastonlineeditbox:SetPoint("left",MMminlastonlineeditbox,"right",20,0)
	MMmaxlastonlineeditbox:SetNumeric(true)
	MMmaxlastonlineeditbox:SetMaxLetters(2)
	  MMmaxlastonlineeditbox:SetScript("OnEscapePressed",function(self)
		 MMcustom:Hide()
		 self:ClearFocus()
		end)
	  MMmaxlastonlineeditbox:SetScript("OnTabPressed",function()
		     MMminleveleditbox:SetFocus()
	   end)
	  MMmaxlastonlineeditbox:SetScript("OnEnterPressed",function()

                       end)
	  MMmaxlastonlineeditbox:SetScript("OnEnter",function()
 	      end)
		  		local t1,t2,t3
		t1 = MMmaxlastonlineeditbox:CreateTexture()
		t1:SetTexture("Interface\\Common\\Common-Input-Border")
		t1:SetPoint("left",-5,0)
		t1:SetHeight(20)
		t1:SetWidth(8)
		t1:SetTexCoord(0,.0625,0,.625)
		
		t2 = MMmaxlastonlineeditbox:CreateTexture()
		t2:SetTexture("Interface\\Common\\Common-Input-Border")
		t2:SetPoint("right")
		t2:SetHeight(20)
		t2:SetWidth(8)
		t2:SetTexCoord(0.9375,1.0,0,0.625)
		
		t3 = MMmaxlastonlineeditbox:CreateTexture()
		t3:SetTexture("Interface\\Common\\Common-Input-Border")
		t3:SetPoint("left",t1,"right")
		t3:SetPoint("right",t2,"left")
		t3:SetHeight(20)
		t3:SetWidth(10)
		t3:SetTexCoord(0.0625,0.9375,0,0.625)

		  
		  
	  
	  --------------- a big ol 'add custom names' button
	mmaddcustombutton = CreateFrame("Button",nil,MMcustom,"UIPanelButtonTemplate")
			mmaddcustombutton:SetHeight(32)
			mmaddcustombutton:SetWidth(180)
			mmaddcustombutton:SetText("Add Custom Names")
			mmaddcustombutton:SetPoint("bottom")
			mmaddcustombutton:SetScript("OnClick",function()

				 mmaddcustomnames()
				 MMcustom:Hide()
				 MMlist:Show()
				 MMlistupdate()
			end)
		
			mmaddcustombutton:SetScript("OnEnter",function()
				local notes = mmcreatecustomlisttooltip()
				mmShowTooltip(mmaddcustombutton,notes)
				end)
			mmaddcustombutton:SetScript("OnLeave",function() mmHideTooltip() end)




end


function MMcreateguildranks()

	  ----------------- all the guild title lables, and checkboxes
   --this has to happen after variables are loaded or it wont find any guild ranks
	  local mmnumranks = GuildControlGetNumRanks()
--	  DEFAULT_CHAT_FRAME:AddMessage("Guild ranks number: "..tonumber(mmnumranks))
	  local mmpreviouslabel
	  for i=1, mmnumranks do

	     -------------- the label
	     mmguildranklabel = CreateFrame("Button", "mmguildranklabel"..i, MMcustom)
		  mmguildranklabel:SetWidth(60)
		  mmguildranklabel:SetHeight(20)
		  mmguildranklabel:SetNormalFontObject(GameFontNormal)
		  if i==1 then
		     mmguildranklabel:SetPoint("Top",mmguildtitlelabel,"Bottom")
		  else
		     mmguildranklabel:SetPoint("Top",mmpreviouslabel,"Bottom")
		  end
		  mmguildranklabel:SetText(GuildControlGetRankName(i))
		  mmguildranklabel:SetScript("OnClick",function()
			local ourcb = getglobal("mmguildrankcb"..i)
			 ourcb:Click()
	       end)
--		  DEFAULT_CHAT_FRAME:AddMessage("ranks number: "..i.."  = "..GuildControlGetRankName(i))
		  
		  ---------------- the checkbox
		  mmguildrankcb = CreateFrame("CheckButton","mmguildrankcb"..i,MMcustom)
		  mmguildrankcb:SetWidth(30)
		  mmguildrankcb:SetHeight(mmguildrankcb:GetWidth())
		  mmguildrankcb:SetPoint("Left",mmguildranklabel,"right")
		  mmguildrankcb:SetDisabledTexture("Interface\\Buttons\\UI-CheckBox-Check-Disabled") 
		  mmguildrankcb:SetHighlightTexture("Interface\\Buttons\\UI-CheckBox-Highlight") 
		  mmguildrankcb:SetNormalTexture("Interface\\Buttons\\UI-CheckBox-Up")
		  mmguildrankcb:SetPushedTexture("Interface\\Buttons\\UI-CheckBox-Down")	
		  mmguildrankcb:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")	
		  mmguildrankcb:SetNormalFontObject(GameFontNormal)

		  mmpreviouslabel = mmguildranklabel
	     
	  end

end


function mmcustomlistupdate()

local ourlable,ourcb

   if MMcustom:IsVisible() then
      -- something has to be checked at the top
      
      if mmguildcb:GetChecked() then
	 mmguildtitlelabel:SetNormalFontObject("GameFontNormal")
--	 DEFAULT_CHAT_FRAME:AddMessage("Num of ranks = "..GuildControlGetNumRanks())
	 for i=1,GuildControlGetNumRanks() do
	 
	    ourlabel = getglobal("mmguildranklabel"..i)
	    ourcb = getglobal("mmguildrankcb"..i)
	    if(ourlabel) then
	     --  DEFAULT_CHAT_FRAME:AddMessage("we must get here")
	       ourlabel:SetText(GuildControlGetRankName(i))

	       ourlabel:SetNormalFontObject("GameFontNormal")
	       ourlabel:Enable()
	       ourcb:Enable()
	    else
	       	  --     DEFAULT_CHAT_FRAME:AddMessage("label not found")
		       MMcreateguildranks()
	    end
	 end
      else
	 mmguildtitlelabel:SetNormalFontObject("GameFontDarkGraySmall")
	 for i=1,GuildControlGetNumRanks() do
	    ourlabel = getglobal("mmguildranklabel"..i)
	    ourcb = getglobal("mmguildrankcb"..i)
	    if(ourlabel)then
	       ourlabel:SetNormalFontObject("GameFontDarkGraySmall")
	       ourlabel:Disable()
	       ourcb:Disable()
	    end
	 end
      end

      if mmguildcb:GetChecked() or mmfriendscb:GetChecked() then


	 mmclasseslabel:SetNormalFontObject("GameFontNormal")
	 mmraceslabel:SetNormalFontObject("GameFontNormal")
	 mmraceslabel:Enable()
	 mmlevellabel:SetNormalFontObject("GameFontNormal")
	 mmminlevellabel:SetNormalFontObject("GameFontNormal")
	 mmmaxlevellabel:SetNormalFontObject("GameFontNormal")
	 mmminleveleditbox:Show()
	 mmmaxleveleditbox:Show()

	 for i=1,9 do
	    ourlabel = getglobal("mmclasslabel"..i)
	    ourcb = getglobal("mmclasscb"..i)
	    ourlabel:SetNormalFontObject("GameFontNormal")
	    ourlabel:Enable()
	    ourcb:Enable()
	 end
	 
	 for i=1,10 do
	    ourlabel = getglobal("mmracelabel"..i)
	    ourcb = getglobal("mmracecb"..i)
	    ourlabel:SetNormalFontObject("GameFontNormal")
	    ourlabel:Enable()
	    ourcb:Enable()
	 end
	 
	 
      else  --if its not checked, disable everything
	 
	 mmclasseslabel:SetNormalFontObject("GameFontDarkGraySmall")
	 mmraceslabel:SetNormalFontObject("GameFontDarkGraySmall")
	 mmraceslabel:Disable()
	 mmlevellabel:SetNormalFontObject("GameFontDarkGraySmall")
	 mmminlevellabel:SetNormalFontObject("GameFontDarkGraySmall")
	 mmmaxlevellabel:SetNormalFontObject("GameFontDarkGraySmall")
	 mmminleveleditbox:Hide()
	 mmmaxleveleditbox:Hide()

	 for i=1,9 do
	    ourlabel = getglobal("mmclasslabel"..i)
	    ourcb = getglobal("mmclasscb"..i)
	    ourlabel:SetNormalFontObject("GameFontDarkGraySmall")
	    ourlabel:Disable()
	    ourcb:Disable()
	 end
	 
	 for i=1,10 do
	    ourlabel = getglobal("mmracelabel"..i)
	    ourcb = getglobal("mmracecb"..i)
	    ourlabel:SetNormalFontObject("GameFontDarkGraySmall")
	    ourlabel:Disable()
	    ourcb:Disable()
	 end
      end
   end
end


function mmaddcustomnames()
   
--[[   DEFAULT_CHAT_FRAME:AddMessage("guild checks: "..mmguildcb:GetChecked().."  pass:"..tonumber(isrankchecked()))
   if isrankchecked() then

   end
   if isclasschecked() then
      DEFAULT_CHAT_FRAME:AddMessage("class is checked")
   else
      DEFAULT_CHAT_FRAME:AddMessage("class is not checked")
   end
]]

if isrankchecked() or isclasschecked() or isracechecked() or islevelchecked() then
          --  DEFAULT_CHAT_FRAME:AddMessage("something, class? is checked")

      local numFriends = GetNumFriends();
      local name, level, class, area, connected, status,i,race,raceengrank
      local i, passrankcheck,passclasscheck,passracecheck,passlevelcheck
      local minlevel, maxlevel

      if not (MMalllists[MMcurrentlistnum]) then
	 MMalllists[MMcurrentlistnum] = {}
      end

--[[      
      if(mmfriendscb:GetChecked())then
	 DEFAULT_CHAT_FRAME:AddMessage("friends is  checked")
      else
	 DEFAULT_CHAT_FRAME:AddMessage("friends is not checked")
      end
]]    
  
      minlevel = mmminleveleditbox:GetNumber()
      maxlevel = mmmaxleveleditbox:GetNumber()
      if maxlevel == 0 then maxlevel = 100 end

      -- do all friend processing
      if(mmfriendscb:GetChecked())then
	 for i=1, numFriends do
	    
	    passrankcheck = true
	    passclasscheck = false
	    passracecheck = false
	    passlevelcheck = false
	    
	    name, level, class, area, connected, status = GetFriendInfo(i)
	    race,raceeng= UnitRace(name)
	    if race then
	--	  DEFAULT_CHAT_FRAME:AddMessage(race.." of race ")
	    end
	    if raceeng then
	--	  DEFAULT_CHAT_FRAME:AddMessage(raceeng.." of race eng")
	    end
	    
--[[  doing rank checking for friends is stupid
	    _, rank, _ = GetGuildInfo(name);
	    -- if a rank is checked, do rank checking
	    if isrankchecked() then
	       -- if that specific rank is checked
	       if isrankchecked(rank) then
		  --it passses.  for now.
		  passrankcheck = true
	       else
		  passrankcheck = false
	       end
	    else
	       -- if we are not checking rankes, then we pass the rank check automatically
	       passrankcheck = true
	    end
      ]]    
	    
	    -- if a class is checked, do class checking
	    if isclasschecked() then
	       -- if that specific class is checked
	       if isclasschecked(class) then
		  --it passses.  for now.
		  passclasscheck = true
	       else
		  passclasscheck = false
	       end
	    else
	       -- if we are not checking classes, then we pass the class check automatically
	       passclasscheck = true
	    end
	    
	    -- if a race is checked, do race checking
	    if isracechecked() then
	       
	       -- if that specific race is checked
	       if isracechecked(race) then
		  --it passses.  for now.
	--	  DEFAULT_CHAT_FRAME:AddMessage(name.." of race "..status..connected"  passes race check.")
		  passracecheck = true
	       else
		  passracecheck = false
	       end
	    else
	       -- if we are not checking racees, then we pass the race check automatically
	       passracecheck = true
	    end
	    
	    --check level
	    if (level >= minlevel) and (level <= maxlevel) then
	       passlevelcheck = true
	    end

	    -- if it passed everything
	    if passrankcheck and passclasscheck and passracecheck and passlevelcheck then
	       --add it to the list
	       table.insert(MMalllists[MMcurrentlistnum],name)
	    end
	 end  --next friend
      end 


      if(mmguildcb:GetChecked())then
--	 DEFAULT_CHAT_FRAME:AddMessage("guild is  checked")
      else
--	 DEFAULT_CHAT_FRAME:AddMessage("guild is not checked")
      end
      
      -- do all guild procession
      if(mmguildcb:GetChecked())then
	 
	 local numGuildMembers = GetNumGuildMembers(true);  --true for offline
	 
--	 DEFAULT_CHAT_FRAME:AddMessage("guildmembers: "..numGuildMembers.. "  Rank 1 = "..GuildControlGetRankName(1))
	 if (numGuildMembers == 0) then
	    DEFAULT_CHAT_FRAME:AddMessage("Requesting info from the server.  Opening your guild pane speeds this up.")
	    return
	 end
	 for i=1, numGuildMembers do
	    
	    passrankcheck = false
	    passclasscheck = false
	    passracecheck = false
	    passlevelcheck = false
		passlastonlinecheck = false
		
	    
	    --name, rank, rankIndex, level, class, zone, note, officernote, online = GetGuildRosterInfo(i)
	    name,rank,_,level,class,_,_,_,_ = GetGuildRosterInfo(i)
	    race = UnitRace(name)

	    if not race then
--	       message("no race found?! for "..name)
	    end
	    
	    -- if a rank is checked, do rank checking
	    if isrankchecked() then
	       -- if that specific rank is checked
	       if isrankchecked(rank) then
		  --it passses.  for now.
		  passrankcheck = true
	       else
		  passrankcheck = false
	       end
	    else
	       -- if we are not checking rankes, then we pass the rank check automatically
	       passrankcheck = true
	    end
	    
	    
	    -- if a class is checked, do class checking
	    if isclasschecked() then
	       -- if that specific class is checked
	       if isclasschecked(class) then
		  --it passses.  for now.
		  passclasscheck = true
	       else
		  passclasscheck = false
	       end
	    else
	       -- if we are not checking classes, then we pass the class check automatically
	       passclasscheck = true
	    end
	    
	    -- if a race is checked, do race checking
	    if isracechecked() then

--	       DEFAULT_CHAT_FRAME:AddMessage("race is checked")
	       -- if that specific race is checked
	       if isracechecked(race) then
		  --it passses.  for now.
		  passracecheck = true
		--  DEFAULT_CHAT_FRAME:AddMessage(name.."passed race check "..race)
	       else
		--  DEFAULT_CHAT_FRAME:AddMessage(name.."failed race check"..race)
		  passracecheck = false
	       end
	    else
	       -- if we are not checking racees, then we pass the race check automatically
	       passracecheck = true
	    end
	    
	    --check level
	  
	    if (level >= minlevel) and (level <= maxlevel) then
	       passlevelcheck = true
	    end
		--check last online
		if (MMminlastonlineeditbox) then
			yearsOffline, monthsOffline, daysOffline, hoursOffline = GetGuildRosterLastOnline(i);
			lastonlinemin = MMminlastonlineeditbox:GetNumber()
			if not (daysOffline and daysOffline > 0) then
				daysOffline = 0
			end
			if( lastonlinemin <= 0) then
				lastonlinemin = 9999
			end
			lastonlinemax = MMmaxlastonlineeditbox:GetNumber()  -- uuuuuhhhhhh..... why would I have code from peeka's tea party in multimail???? this has to be mistake
		
			--MMprint(tostring(daysOffline).." days offline for "..name.."  max="..lastonlinemax.."  min="..lastonlinemin)
			if (daysOffline >= lastonlinemax and daysOffline <= lastonlinemin) then
			   passlastonlinecheck = true
			end
		else
			passlastonlinecheck = true
		end
		

	    -- if it passed everything
	    if passrankcheck and passclasscheck and passracecheck and passlevelcheck and passlastonlinecheck then
	       --add it to the list
	   --    DEFAULT_CHAT_FRAME:AddMessage("adding: "..name)
	       table.insert(MMalllists[MMcurrentlistnum],name)
	    end
	 end  --next guildy
      end
      
      MMlistupdate()
   end
   --mmcustomlistupdate()
end





function mmcreatecustomlisttooltip()
   --[[
   
   mmguildcb
   mmfriendscb
   
   mmguildrankcb..i
   mmclasscb..i
   mmracecb..i
   mmminleveleditbox
   mmmaxleveleditbox
   ]]

   mmcustomlistupdate()

   local tooltip,ourcb,ourlabel 

   --if nothing is checked, then we add nothing
   if isracechecked() or isclasschecked() or isrankchecked() or islevelchecked() then
      
      tooltip = "Adding "
      
      if isrankchecked() then
	 tooltip = tooltip.."Guidies that are rank: "
	 for i=1,GuildControlGetNumRanks() do
	    if ourcb then
	       ourcb = getglobal("mmguildrankcb"..i)
	       if(ourcb:GetChecked()) then
		  ourlabel = getglobal("mmguildranklabel"..i)
		  tooltip = tooltip..ourlabel:GetText()..", "
	       end
	    end
	 end

	 tooltip = tooltip.."and "
      end

      
      if mmguildcb:GetChecked() then
	 tooltip=tooltip.."guildies, "
      end
      if mmfriendscb:GetChecked() then
	 tooltip=tooltip.."online friends "
      end
      
      if isclasschecked() then
	 tooltip=tooltip.."of class: "
	 for i=1,9 do

	    ourcb = getglobal("mmclasscb"..i)
	    if ourcb then
	       if(ourcb:GetChecked()) then
		  ourlabel = getglobal("mmclasslabel"..i)
		  tooltip = tooltip..ourlabel:GetText()..", "
	       end
	    end
	 end
      else
	 tooltip=tooltip.." of any class,"
      end
      tooltip=tooltip.." And are: "
      
      if isracechecked() then
	 for i=1,10 do
	    ourcb = getglobal("mmracecb"..i)
	    if ourcb then
	       if(ourcb:GetChecked()) then
		  ourlabel = getglobal("mmracelabel"..i)
		  tooltip = tooltip..ourlabel:GetText()..", "
	       end
	    end
	 end
      else
	 tooltip=tooltip.." of any race."
      end
      tooltip=tooltip.."  Note:  Race cannot be determined if they are not online."
   else
      tooltip="nothing added"
   end
   
   return tooltip
end




function isrankchecked(rank)
   local ourcb, ourlabel
   --are any ranks checked?
   if mmguildcb:GetChecked() then
      for i=1,GuildControlGetNumRanks() do
	 ourcb = getglobal("mmguildrankcb"..i)
	 if(ourcb) then
	    if(ourcb:GetChecked()) then
	       --if a specific rank was specified
	       if (rank) then
		  ourlabel = getglobal("mmguildranklabel"..i)
		  -- if it matched, return true.   if not, keep searching
		  if rank == ourlabel:GetText() then
		     return true
		  end
	       else
		  return true
	       end
	    end
	 end
      end
   end
   return false
end

function isclasschecked(class)
   local ourcb, ourlabel
   --are any classes checked?
   for i=1,9 do
      ourcb = getglobal("mmclasscb"..i)
      if ourcb then
	 if(ourcb:GetChecked()) then
	    --if a specific class was specified
	    if (class) then
	       ourlabel = getglobal("mmclasslabel"..i)
	       -- if it matched, return true.   if not, keep searching
	       if class == ourlabel:GetText() then
		  return true
	       end
	    else
	       return true
	    end
	 end
      end
   end
   return false
end

function isracechecked(race)
   local ourcb, ourlabel
   
   --are any races checked?
   for i=1,10 do
      ourcb = getglobal("mmracecb"..i)
      if ourcb then
	 if(ourcb:GetChecked()) then
	    --if a specific race was specified
	    if (race) then
	       ourlabel = getglobal("mmracelabel"..i)
	       -- if it matched, return true.   if not, keep searching
	       if race == ourlabel:GetText() then
		  return true
	       end
	    else
	       return true
	    end
	 end
      end
   end
   return false
end

function islevelchecked()

   if mmminleveleditbox:GetNumber() > 0 or mmmaxleveleditbox:GetNumber() < 100 then
      return true
   else
      return false
   end
end



function MMislastonlinechecked()
	if MMminlastonlineeditbox:GetNumber() > 0 or MMmaxlastonlineeditbox:GetNumber() > 0 then
      return true
   else
      return false
   end

end