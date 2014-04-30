-- Zirco (Oct 20, 2008) quick bug fixes to get it working with patch 3.0.2
-- dax added auctioneer code (nov 2008)
IMA_Settings = {};

local IMA_NUMITEMBUTTONS = 18;
local IMA_Playername = nil;
local WAITINGFORUPDATE = 1
local QUERY = 2
IMAdeclinecount = 1

--I am rewriting all the 'queue' code to not use a global frame

IMAsellingqueue = {}
IMAcursor = {}

IMAprintstack = -1
local messagestring = ""
function IMAprint(message)
   if(IMAdebug) then
		if(IMAprintstack == -1) then
			messagestring=""
		end
      local stack, filler
      if not message then
	  	 DEFAULT_CHAT_FRAME:AddMessage(messagestring..tostring(message))
		 return false 
      end
      IMAprintstack=IMAprintstack+1
      
	  filler=string.rep(". . ",IMAprintstack)
      
      if (type(message) == "table") then
	  	-- DEFAULT_CHAT_FRAME:AddMessage("its a table.  length="..IMA_tcount(message))
	 	
		DEFAULT_CHAT_FRAME:AddMessage(messagestring.."{table} --> ")
		
	 	for k,v in pairs(message) do
			messagestring = filler.."["..k.."] = "
	    	IMAprint(v)
	 	end
      elseif (type(message) == "userdata") then

      elseif (type(message) == "function") then
        DEFAULT_CHAT_FRAME:AddMessage(messagestring.." A Function()")
      elseif (type(message) == "boolean") then
            DEFAULT_CHAT_FRAME:AddMessage(messagestring..tostring(message))
      else
	  	 	DEFAULT_CHAT_FRAME:AddMessage(messagestring..tostring(message))
      end
      IMAprintstack=IMAprintstack-1
   end
end



function IMA_ContainerFrameItemButton_OnClick(self)
	if ( not IMA_AuctionFrameMassAuction:IsVisible() ) then
		return;
	end
	
	if ( IMA_HoldAlt:GetChecked() and CursorHasItem() ) then

		-- put item back down and pass through if item already in
		local bag, slot = self:GetParent():GetID(), self:GetID()
		if ( IMA_GetItemFrame(bag, slot) ) then
			PickupContainerItem(bag, slot);
			return;
		end

		local i;
		for i = 1, IMA_NUMITEMBUTTONS, 1 do
			if ( not _G["IMA_Item"..i.."ItemButton"].slot ) then
				IMA_ItemButton_OnClick(self,_G["IMA_Item"..i.."ItemButton"]);
				IMA_UpdateItemButtons();
				return;
			end
		end	
	
	end
end



function IMA_ContainerFrameItemButton_OnModifiedClick(self)
	IMAprint("|c00343377 container Button MODIFIED clicked.  Cursorhasitem? = "..tostring(CursorHasItem()))
	-- pass through if auction window not open
	if ( not AuctionFrame:IsVisible() or IsControlKeyDown() or IsShiftKeyDown() ) then
		return;
	end
	if ( not button ) then 
		button = self;
	end

	-- pass through if slot already in
	local bag, slot = self:GetParent():GetID(), self:GetID()
	if ( IMA_GetItemFrame(bag, slot) ) then
		return;
	end

	if ( not CursorHasItem() ) then
		IMA_ClearAuctionSellItem();
		IMAcursor.bag = bag;
		IMAcursor.slot = slot;
	end

    if ( IsAltKeyDown() and IMA_AuctionFrameMassAuction:IsVisible() and not CursorHasItem() ) then 
		IMA_ClearAuctionSellItem();
		local i;
		for i = 1, IMA_NUMITEMBUTTONS, 1 do
			if ( not _G["IMA_Item"..i.."ItemButton"].slot ) then
				PickupContainerItem(bag, slot);
				IMA_ItemButton_OnClick(self,_G["IMA_Item"..i.."ItemButton"]);
				IMA_UpdateItemButtons();
				return;
			end
		end
	elseif ( IsAltKeyDown() and not CursorHasItem() ) then
		IMA_ClearAuctionSellItem();
		PickupContainerItem(bag, slot);
		ClickAuctionSellItemButton(AuctionSellItemButton)  -- ClickAuctionSellItemButton(Frame, left or right click, boolean (held down));
		return;
	end

	PickupContainerItem(bag, slot);
	IMAprint("modified click shown called")
	IMA_UpdateItemButtons();
end



--Controls the IMA auction frame tab
function IMA_AuctionFrameTab_OnClick(self, index)
--	IMAprint("Self and Index and auctionframetab:getid()")
--	IMAprint(self)
--	IMAprint(index)  --index appears to be what mousebutton clicked??
--	IMAprint(IMA_AuctionFrameTab:GetID())
	
		index = self:GetID();
	
	if(not self) then
		IMAprint("|c00ff0000 ERROR!  NO SELF TAB!")
	end
	if(not index) then
		IMAprint("|c00ff0000 ERROR!  NO TAB index!")
	end
	

	if (index and index == IMA_AuctionFrameTab:GetID() ) then
	
		IMAprint("Tab click |c0000ee00successfully |rdetected")
	
		-- MassAuction tab
		AuctionFrameTopLeft:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Bid-TopLeft");
		AuctionFrameTop:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Bid-Top");
		AuctionFrameTopRight:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Bid-TopRight");
		AuctionFrameBotLeft:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Bid-BotLeft");
		AuctionFrameBot:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Bid-Bot");
		AuctionFrameBotRight:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Bid-BotRight");

		-- this is to fix a bug where the AuctionsFrame can't handle having auctions added without it showing first
		if (AuctionFrameAuctions.page == nil) then
			AuctionFrameAuctions.page = 0;
		end

		IMA_AuctionFrameMassAuction:Show();	
	else
		IMA_AuctionFrameMassAuction:Hide();
	end
end



function IMA_ContainerFrame_Update(frame)
	if ( not IMA_AuctionFrameMassAuction:IsVisible() ) then
		return;
	end

	local i;
	for i = 1, IMA_NUMITEMBUTTONS, 1 do
		local button = _G["IMA_Item"..i.."ItemButton"];
		if ( button.slot and button.bag ) then
			if ( button.bag == frame:GetID() ) then
				SetItemButtonDesaturated(_G[frame:GetName() .. "Item" .. (frame.size-button.slot)+1], 1, 0.5, 0.5, 0.5);
			end
		end
	end
end



function IMA_AuctionFrameMassAuction_OnLoad(self)
	--Hook for Auction Frame Tab
	  -- create our slash commands
	  --dax
   SLASH_IMA1 = "/IMA";
   SLASH_IMA2 = "/ima";
   SlashCmdList["IMA"] = IMAmain; 
   
   
    CreateFrame("GameTooltip", "MyT");
	MyT:SetOwner( WorldFrame,"ANCHOR_NONE");
	MyT:AddFontStrings(MyT:CreateFontString("$parentTextLeft1", nil, "GameTooltipText"),MyT:CreateFontString("$parentTextRight1", nil, "GameTooltipText"))
	  
	IMA_HoldAlt:SetChecked(true)
	IMAorigupdate = AuctionFrameBrowse:GetScript("OnUpdate")
	AuctionFrameBrowse:SetScript("OnUpdate",IMAAuctionFrameBrowse_OnUpdate)
	IMAqueryelapsed = 0
	IMAelapsed = 0
	--enddax
   
	
	hooksecurefunc("AuctionFrameTab_OnClick",IMA_AuctionFrameTab_OnClick)
	hooksecurefunc("ContainerFrame_Update",IMA_ContainerFrame_Update)

	--Hook for ALT-LeftClick auction posting
	hooksecurefunc("ContainerFrameItemButton_OnModifiedClick", IMA_ContainerFrameItemButton_OnModifiedClick)

	--Hook for one click auction posting
	hooksecurefunc("ContainerFrameItemButton_OnClick", IMA_ContainerFrameItemButton_OnClick)

	
	hooksecurefunc("ClearCursor", function(bag, slot)
		IMAcursor = {}
	end);
	
	--Hook for manipulating items
	hooksecurefunc("PickupContainerItem", function(bag, slot)
		if ( CursorHasItem() ) then
			IMAcursor.bag = bag;
			IMAcursor.slot = slot;
		else
			IMAcursor.bag = nil;
			IMAcursor.slot = nil;
		end
		--IMAprint("onload called")
		IMA_UpdateItemButtons();
	end);
	
	for i = 1, IMA_NUMITEMBUTTONS, 1 do
		IMA_AuctionsRadioButton_OnClick(i,3);
	end

	self:RegisterEvent("UNIT_NAME_UPDATE");
	self:RegisterEvent("AUCTION_HOUSE_CLOSED");
	--self:RegisterEvent("NEW_AUCTION_UPDATE");
	self:RegisterEvent("AUCTION_ITEM_LIST_UPDATE")
	self:RegisterEvent("AUCTION_OWNED_LIST_UPDATE")
	self:SetScript("OnEvent",IMA_OnEvent)
	

	IMA_AddTabbing(self);
end


function IMAAuctionFrameBrowse_OnUpdate(self,elapsed,...)  --this is used to query the AH for bag items
	if (IMAorigupdate) then
		IMAorigupdate(self,elapsed,...)
	end
	
   --this is the Blizzard Update, called every computer clock cycle ~millisecond  --but ONLY if the MASSAUCTION frame is visible!  gaaaah
     -- IMAprint("calling |c00ff33ff IMA update "..tostring(elapsed).."    arg1= "..tostring(arg1))
   
	if (AuctionFrameBrowse:IsVisible()) then
		
		  --------------------------------------------------
		  ----this is needed because sometimes a query completes, and the results are sent back - but the ah will not accept a query right away. there is no event that fires when a query is possible, so i just have to spam requests

		if IMAstatus and elapsed then
		--   	IMAprint("Sendingquery  status = "..IMAstatus)
			IMAqueryelapsed=IMAqueryelapsed+elapsed
			if (IMAqueryelapsed > .1) then     --a tenth of a second?
				IMAqueryelapsed=0
				if( IMAstatus==QUERY) then
				   --IMA.status=WAITINGFORUPDATE
				   
				   IMAsendquery(self)
				
				elseif (IMAstatus==WAITINGFORPROMPT) then
					--do nothing

				end
			end --end if elapsed > .5
		end  --end if sl.status
	end
end



function IMAmain(input)


	if (input == "test") then
		 IMAdebug = true
		
         bag = 0
         slot =1
		 
		 MyT:SetBagItem(bag,slot)
		 IMAprint(MyTTextLeft1:GetText())
		 
		 itemLink = GetContainerItemLink(bag,slot)
		 texture, count, locked, quality, readable = GetContainerItemInfo(bag, slot);
		 if not count then count = 1 end;
		 
		if(AuctionLite) then
			if(AuctionLite.GetAuctionPrice ) then
				if( AuctionLite:GetAuctionPrice(itemLink)) then
					buyout =  AuctionLite:GetAuctionPrice(itemLink) * count
					IMAprint("auctionlite Buyout, count = .."..buyout.." , "..count)
				else
					IMAprint("Auctionlite:getauctionprice(itemlink) not found?")
				end
			else
				IMAprint("Auctionlite.getauctionprice not found?")
			end
		else
			IMAprint("Auctionlite not found?")
		end
	elseif (input == "debug") then
	
		if not IMAdebug then
			IMAdebug = true
		else
			IMAdebug = not IMAdebug
		end
		DEFAULT_CHAT_FRAME:AddMessage("Debug set to: "..tostring(IMAdebug))
			 
	end

end

function IMA_AuctionFrameMassAuction_OnShow(self)
	IMAprint("|c0000ff44 onshow called")
	IMA_UpdateItemButtons();

	for i = 1, IMA_NUMITEMBUTTONS, 1 do
		IMA_AuctionsRadioButton_OnClick(i,IMA_Settings["duration"..i])
	end
end



function IMA_SetItemAsAuction(itemindex)

--[[  --not neccessary.  when we actually sell something we take care of this.  now it just creates glitches
	IMA_ClearAuctionSellItem();

	-- first see if something is in that slot
	button = _G["IMA_Item"..itemindex.."ItemButton"];
	if ( button.bag == nil or button.slot == nil) then return end

	-- if we have something on cursor already, remember it
	oldbag = IMAcursor.bag;
	olditem = IMAcursor.slot;

	-- if we are already holding what we want
	if (button.bag == oldbag and button.slot == olditem) then
		ClickAuctionSellItemButton(AuctionSellItemButton);  --
		return;
	end
		
	-- put down what we had
	if ( oldbag ~= nil and olditem ~= nil) then
		PickupContainerItem(oldbag,olditem);
	end
	
	-- pick up the new thing and put it in
	PickupContainerItem(button.bag,button.slot);
	ClickAuctionSellItemButton(AuctionSellItemButton)  -- ClickAuctionSellItemButton(Frame, left or right click, boolean (held down));
	PickupContainerItem(button.bag,button.slot);
	
	-- pick up what we had
	if ( oldbag ~= nil and olditem ~= nil) then
		PickupContainerItem(oldbag,olditem);
	end
	
	]]
end



function IMA_FindAuctionItem(self)
	for bag = 0,4,1 do
		slots = GetContainerNumSlots(bag)
		if (slots ~= nil and slots > 0) then
			for slot = 1, slots, 1 do
				local texture, itemCount, locked, quality, readable = GetContainerItemInfo(bag,slot);
				local lockedstr = locked;
				if ( locked == nil ) then
					lockedstr = "nil";
				end
				if ( itemCount ~= nil and itemCount > 0 and locked ~= nil ) then
					return bag,slot;
				end
			end
		end
	end
	return nil;
end



-- this function assumes that itemindex is the current active auction item
function IMA_SetInitialPrices(button)
	local scheme = UIDropDownMenu_GetSelectedValue(IMA_PriceSchemeDropDown);
    local name, texture, count, quality, canUse, price = GetAuctionSellItemInfo();
	local start = max(100, floor(price * 1.5));
	local buyout = 0;
	--IMAprint("scheme")
	--IMAprint(scheme)
    if (scheme) then
    	scheme = string.gsub(scheme," ","_");
    	pricefunc = _G["IMA_"..scheme.."_GetPriceAndBuyout"];
    	if (pricefunc ~= nil) then
    		local start2 = nil;
    		local buyout2 = nil;
    		start2, buyout2 = pricefunc(button.bag,button.slot,button.count,button.texture,button.name,button.price,start)
    		if (start2 ~= nil) then
    			start = start2;
    		end
    		if (buyout2 ~= nil) then
    			buyout = buyout2;
    		end
    	end
    end
    local startframe = _G[button:GetParent():GetName().."StartPrice"]
	local buyoutframe = _G[button:GetParent():GetName().."BuyoutPrice"]
    MoneyInputFrame_SetCopper(startframe, start);
    MoneyInputFrame_SetCopper(buyoutframe, buyout);
end





--For changing individual auction durations
--direction 1 is forwards, 0 is backwards
--<OnClick>IMA_AuctionsRadioButton_OnClick(self:GetParent():GetID(),self:GetID())</OnClick>
function IMA_ChangeAuctionDuration(itemindex, direction)
	if direction == nil then
		direction = 1;
	end

	if _G["IMA_Item"..itemindex.."LongAuction"]:GetChecked() then
		local duration = 3;
	elseif _G["IMA_Item"..itemindex.."MediumAuction"]:GetChecked() then
		local duration = 2;
	elseif _G["IMA_Item"..itemindex.."ShortAuction"]:GetChecked() then
		local duration = 1;
	else
	--DEFAULT_CHAT_FRAME:AddMessage("Radio Button Error - " .. IMA_ERROR, 1, 0, 0);
	return;
	end

	if direction == 1 then
		if duration == 1 then local newduration = 2;
		elseif duration == 2 then local newduration = 3;
		else local newduration = 1;
		end
	end

	if direction == 0 then
		if duration == 1 then local newduration = 3;
		elseif duration == 2 then local newduration = 1;
		else local newduration = 2;
		end
	end

	IMA_AuctionsRadioButton_OnClick(itemindex, newduration);
end



function IMA_AuctionsRadioButton_OnClick(itemindex,index)
	if index == nil then
		index = 3;
	end

	_G["IMA_Item"..itemindex.."ShortAuction"]:SetChecked(nil)
	_G["IMA_Item"..itemindex.."MediumAuction"]:SetChecked(nil)
	_G["IMA_Item"..itemindex.."LongAuction"]:SetChecked(nil)
	if ( index == 1 ) then
		_G["IMA_Item"..itemindex.."ShortAuction"]:SetChecked(1)
		_G["IMA_Item"..itemindex].duration = 1;
	elseif ( index ==2 ) then
		_G["IMA_Item"..itemindex.."MediumAuction"]:SetChecked(1)
		_G["IMA_Item"..itemindex].duration = 2;
	else
		_G["IMA_Item"..itemindex.."LongAuction"]:SetChecked(1)
		_G["IMA_Item"..itemindex].duration = 3;
	end

	IMA_Settings["duration"..itemindex] = index;

	-- maybe sure this is the current item before we update
	IMA_SetItemAsAuction(itemindex);  --seems to break the item textures
	IMA_UpdateDeposit(itemindex);
	IMA_ClearAuctionSellItem();
	ClearCursor();
	IMA_UpdateItemButtons()
end



function IMA_UpdateDeposit(itemindex, amount)
	if ( amount == nil ) then
		runtime = _G["IMA_Item"..itemindex].duration
		amount = CalculateAuctionDeposit(runtime);
	end
	if ( amount == nil ) then
		amount = 0;
	end
	
	MoneyFrame_Update("IMA_Item"..itemindex.."DepositCharge",amount)
end



-- this function assumes you don't have something on the cursor already
function IMA_ClearAuctionSellItem()
--[[  --this is the reason for the odd graphical bug.  its not needed since when we actually sell something we check this

	ClearCursor()
	IMAcursor = {}
	if ( GetAuctionSellItemInfo() ~= nil ) then
		ClickAuctionSellItemButton(AuctionSellItemButton)  -- ClickAuctionSellItemButton(Frame, left or right click, boolean (held down));
		local bag, slot = IMA_FindAuctionItem(self);
		PickupContainerItem(bag, slot);
	end
	
	]]
	
end
function IMA_ItemButton_OnEnter(self)
	--IMAprint("Entering button "..self:GetName())
	--IMAprint(self)
	IMA_UpdateItemButtons()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	if ( self.slot and self.bag ) then
		GameTooltip:SetBagItem(self.bag,self.slot)
	else
		GameTooltip:SetText(IMA_MOUSEOVER_TEXT, 1.0, 1.0, 1.0);
	end
end


-- Handles the dragging of items
function IMA_ItemButton_OnClick(self,button)
	if ( not button ) then 
		button = self;
	end
	
	if ( CursorHasItem()) then
		local bag = IMAcursor.bag;
		local slot = IMAcursor.slot;
		if ( not bag or not slot ) then	return; end
		--dax006
--		IMAprint("Calling validation for "..GetContainerItemLink(bag,slot))
		if not (IMA_Validate(bag,slot)) then
		   IMAprint(GetContainerItemLink(bag,slot).."|c00ee3300 not validated - clearing")
		   ClearCursor()
		   return
		end
--		IMAprint("|c00eeff77  validation passed!|r for "..GetContainerItemLink(bag,slot))
		
		--dax end
		-- Clear cursor if item already in IMA pane
		if ( IMA_GetItemFrame(bag, slot) ) then
			ClearCursor();
			return;
		end

--		IMAprint("Self, Button = ")
--		IMAprint(self:GetName())
--		IMAprint(button:GetName())
		AuctionFrameAuctions.duration = 1  --just to fix errors?!
		-- put it in auction slot while we're holding it
		ClickAuctionSellItemButton(AuctionSellItemButton)  -- ClickAuctionSellItemButton(Frame, left or right click, boolean (held down));

		-- If there was already an auction in the auction window we'll now be holding it instead
		if (CursorHasItem()) then ClearCursor(); end


		if ( button.bag and button.slot ) then
			-- There's already an item there
			PickupContainerItem(button.bag, button.slot);
			IMAcursor.bag = button.bag;
			IMAcursor.slot = button.slot;
		else
			IMAcursor.bag = nil;
			IMAcursor.slot = nil;
		end

		local texture, count = GetContainerItemInfo(bag, slot);

		_G[button:GetName() .. "IconTexture"]:Show();
		_G[button:GetName() .. "IconTexture"]:SetTexture(texture);

		if ( count > 1 ) then
			_G[button:GetName() .. "Count"]:SetText(count);
			_G[button:GetName() .. "Count"]:Show();
		else
			_G[button:GetName() .. "Count"]:Hide();
		end

		local name, texture, count, quality, canUse, price = GetAuctionSellItemInfo();
		button.bag = bag;
		button.slot = slot;
		button.texture = texture;
		button.count = count;
		button.name = name;
		button.price = price;

		-- set our item count based on the first item
		if (button:GetParent():GetID() == 1) then
			local checkprice = MoneyInputFrame_GetCopper(IMA_AllSamePriceFrameStartPrice);
			local checkbuyout = MoneyInputFrame_GetCopper(IMA_AllSamePriceFrameBuyoutPrice);
			if (checkprice == 0) and (checkbuyout == 0) then
				IMA_AllSamePriceFrameStackSize:SetText(count);
			end
		end
							   
		IMA_UpdateDeposit(button:GetParent():GetID());
		IMA_SetInitialPrices(button);
		
	elseif ( button.slot and button.bag ) then

		IMA_ClearAuctionSellItem(button);
	
		PickupContainerItem(button.bag, button.slot);
		
		_G[button:GetName() .. "IconTexture"]:Hide();
		_G[button:GetName() .. "IconTexture"]:SetTexture(nil);
		_G[button:GetName() .. "Count"]:Hide();

	--	IMAcursor.bag = button.bag;  --should be taken care of automatically in the hook handler
--		IMAcursor.slot = button.slot;

		button.slot = nil;
		button.bag = nil;
		button.count = nil;
		button.texture = nil;
		button.name = nil;
		button.price = nil;
	end
	IMA_UpdateItemButtons();  --meh, just update them all to fix the occassional graphic glitch

	-- TODO: Display the total deposit
	
	for i = 1, NUM_CONTAINER_FRAMES, 1 do
		if ( _G["ContainerFrame" .. i]:IsVisible() ) then
			ContainerFrame_Update(_G["ContainerFrame" .. i]);
		end
	end

end




function IMA_UpdateItemButtons(frame)


	local i;
	local num = 0;
	local totalDeposit = 0;
	for i = 1, IMA_NUMITEMBUTTONS, 1 do
		local button = _G["IMA_Item"..i.."ItemButton"];
		if ((not frame) or (frame and button == frame )) then
			local texture, count;
			if ( button.slot and button.bag ) then
				texture, count = GetContainerItemInfo(button.bag, button.slot);
			end
			if ( not texture ) then
				_G[button:GetName() .. "IconTexture"]:Hide();
				_G[button:GetName() .. "Count"]:Hide();
				button.slot = nil; 
				button.bag = nil; 
				button.count = nil; 
				button.texture = nil;
				button.name = nil;
				button.price = nil;
				IMA_UpdateDeposit(button:GetParent():GetID(),0);
				MoneyInputFrame_SetCopper(_G[button:GetParent():GetName().."StartPrice"], 0);
				MoneyInputFrame_SetCopper(_G[button:GetParent():GetName().."BuyoutPrice"], 0);
			else
				num = num + 1
				local deposit = _G[button:GetParent():GetName().."DepositCharge"].staticMoney;
				if ( deposit ~= nil ) then
					totalDeposit = totalDeposit + deposit;
				end
				button.count = count;
				button.texture = texture;
				_G[button:GetName() .. "IconTexture"]:Show();
				_G[button:GetName() .. "IconTexture"]:SetTexture(texture);
				if ( count > 1 ) then
					_G[button:GetName() .. "Count"]:Show();
					_G[button:GetName() .. "Count"]:SetText(count);
				else
					_G[button:GetName() .. "Count"]:Hide();
				end
			end
		end
	end
	num = tonumber(num)
	IMA_AuctionFrameMassAuction.num = num;
	IMA_AuctionFrameMassAuction.totalDeposit = totalDeposit;
	if ( num > 0 ) then
		IMA_AuctionsClearButton:Enable();
		IMA_AuctionsSubmitButton:Enable();
	else
		IMA_AuctionsClearButton:Disable();
		IMA_AuctionsSubmitButton:Disable();
	end
	
	
	--now make sure cursor and whatnot match up
	if (IMAcursor.bag and IMAcursor.slot) then
		if(CursorHasItem()) then
			--assume they match and we're all good
		else
			IMAcursor.bag = nil
			IMAcursor.slot = nil
		end
	else
		ClearCursor()
	end
	
	
	
end



function IMA_GetItemFrame(bag, slot)
	local i;
	for i = 1, IMA_NUMITEMBUTTONS, 1 do
		local button = _G["IMA_Item"..i.."ItemButton"];
		if ( button.slot == slot and button.bag == bag ) then
			return button;
		end
	end
	return nil;
end



function IMA_ClearItems(self)
	local i;
	for i = 1, IMA_NUMITEMBUTTONS, 1 do
		local item = _G["IMA_Item"..i];
		local button = _G[item:GetName().."ItemButton"];
		MoneyInputFrame_SetCopper(_G[item:GetName().."StartPrice"], 0);
		MoneyInputFrame_SetCopper(_G[item:GetName().."BuyoutPrice"], 0);
		IMA_UpdateDeposit(i,0);
		button.slot = nil;
		button.count = nil;
		button.bag = nil;
		button.texture = nil;
		button.name = nil;
		button.price = nil;
	end
	IMA_UpdateItemButtons();
	IMA_ClearAuctionSellItem();
	IMAsellingqueue = {}
	IMAwaitingfornewauctionevent = false
end



function IMA_ClearItem(bag,slot)
	local i;
	for i = 1, IMA_NUMITEMBUTTONS, 1 do
		local item = _G["IMA_Item"..i];
		local button = _G[item:GetName().."ItemButton"];
		if (button.bag == bag and button.slot == slot) then
			MoneyInputFrame_SetCopper(_G[item:GetName().."StartPrice"], 0);
			MoneyInputFrame_SetCopper(_G[item:GetName().."BuyoutPrice"], 0);
			IMA_UpdateDeposit(i,0);
			button.slot = nil;
			button.count = nil;
			button.bag = nil;
			button.texture = nil;
			button.name = nil;
			button.price = nil;
			return;
		end
	end
	IMAprint("|c00343377 clearitemcalled")
	IMA_UpdateItemButtons();
end



function IMA_OnEvent(self,event,arg1)
	IMAprint("EVENT |c00aa3333"..tostring(event).."  arg1="..tostring(arg1))

	if (( event == "UNIT_NAME_UPDATE" ) and (arg1 == "player")) then
		local playername = UnitName("player");
		IMA_Playername = playername;
	elseif ( event == "AUCTION_HOUSE_CLOSED" ) then
		IMA_ClearItems(self);
		IMAsellingqueue={};
		IMA_AcceptSendFrame:Hide();
		IMAstatus = nil
		IMAwaitingfornewauctionevent = false
		IMAauctionconfirmvisible = false --hopefully....?  im not sure how to remove popup boxes
		
	elseif(event == "AUCTION_ITEM_LIST_UPDATE") then
		--IMAprint("IMAstatus = "..tostring(IMAstatus))
		if(IMAstatus and IMAstatus == WAITINGFORUPDATE) then
			IMAstatus = QUERY
		end
	elseif(event == "NEW_AUCTION_UPDATE") then  --THis happens when the 'to sell' button in the auction tab changes, meaning we add or remove something - doesn't mean it is being listed in the ah
		--IMAprint("IMAstatus = "..tostring(IMAstatus))
	elseif(event == "AUCTION_OWNED_LIST_UPDATE") then  --happens when we posted an item for sale  :)
		IMAwaitingfornewauctionevent = false
	end
end



function IMA_AcceptSendFrame_OnShow(self)
	_G[self:GetName().."Info"]:Show();
	_G[self:GetName().."InfoString"]:Show();
	_G[self:GetName().."MoneyFrame"]:Show();
	_G[self:GetName().."InfoItems"]:SetText(IMA_AuctionFrameMassAuction.num .. " " .. IMA_ITEMS);
	_G[self:GetName().."SubmitButton"]:Enable();
	IMAprint("Acceptsend frame shown called")
	IMA_UpdateItemButtons();
	MoneyFrame_Update(self:GetName() .. "MoneyFrame", IMA_AuctionFrameMassAuction.totalDeposit);
end



function IMA_AcceptSendFrameSubmitButton_OnClick(self)
	IMAprint("IMA_AcceptSendFrameSubmitButton_OnClick(self) called")

	IMAsellingqueue = IMA_FillItemTable();
	_G[self:GetParent():GetName().."Info"]:Hide();
	_G[self:GetParent():GetName().."InfoString"]:Hide();
	_G[self:GetParent():GetName().."MoneyFrame"]:Hide();
	self:Disable();
end



function IMA_AcceptSendFrameCancelButton_OnClick(self)
	self:GetParent():Hide();
	IMAsellingqueue = {};
end



function IMA_FillItemTable()  --self is always the globalframe
	IMAprint("|c0034ff77 fillItemTable() called")
	local arr = { };
	for i = 1, IMA_NUMITEMBUTTONS, 1 do
		local item = _G["IMA_Item"..i];
		local button = _G[item:GetName().."ItemButton"];
		local price = MoneyInputFrame_GetCopper(_G[item:GetName().."StartPrice"]);
		local buyout = MoneyInputFrame_GetCopper(_G[item:GetName().."BuyoutPrice"]);
		
		if ( button.slot and button.bag ) then
			tinsert(arr, { ["slot"] = button.slot, ["bag"] = button.bag, ["price"] = price,
						   ["buyout"] = buyout, ["duration"] = item.duration });
		end
	end
	IMAprint(arr)
	return arr;
end



function IMA_ProcessQueue(self,elapsed)  -- hmm.. whats this do?  And why is it attached to the global frame?  holy memory leak, batman.

	if (not elapsed) or (not IMA_AuctionFrameMassAuction) or (not IMA_AuctionFrameMassAuction:IsVisible()) then
		return
	else
		IMAelapsed=IMAelapsed+elapsed
	--	IMAprint(IMAelapsed)
		if (IMAelapsed < .1) then     --a tenth of a second?
			return
		end
	end
	IMAelapsed=0
	if (IMAsellingqueue[IMAdeclinecount]) then -- something exists to be processed/sold
		IMA_AcceptSendFrame:Hide();
		if(IMAwaitingfornewauctionevent) then  --because it takes a while for the item you posted to actually dissapear from your bags, meaning this code thinks it still needs to be sold
		--	IMAprint("Waiting for newauction Event. returning")
			if(difftime(IMAwaitingfornewauctioneventtimeout,time()) > 30) then  --30 second timeout?
				print("Auction house new auction event timed out.  Going to next item to sell.")
				IMAskipitem()
			end
			return
		end
	
		if ( IMAsellingqueue[IMAdeclinecount].bag ~= nil and IMAsellingqueue[IMAdeclinecount].slot ~= nil ) then  
			--keep repeating until that item dissapears from our bags
			if (not GetContainerItemInfo(IMAsellingqueue[IMAdeclinecount].bag, IMAsellingqueue[IMAdeclinecount].slot)) then  --get that items info
				--yey.  it was sold.
				IMAprint("|c00dd00ff.  bag queue[1] sold.  Removing it.  Reloop.")
				--IMA_ClearItem(IMAsellingqueue[IMAdeclinecount].bag,IMAsellingqueue[IMAdeclinecount].slot);  --find the button with this item in it and clear it - not very efficient, imo
				table.remove(IMAsellingqueue,1)
				
				IMA_UpdateItemButtons()
				IMAelapsed = 1 --so we instantly go on to the next item to sell instead of waiting another .1 seconds :)
				
				--some sort of timeout feature is needed here.  if an item doesn't dissapear from the bags after, oh, a minute, abort everything.
			else
			--	IMAprint("attempting to sell..")
--				IMAprint({GetContainerItemInfo(IMAsellingqueue[IMAdeclinecount].bag, IMAsellingqueue[IMAdeclinecount].slot)})
				IMA_StartAuction(IMAsellingqueue[IMAdeclinecount]);  
				IMA_AcceptSendFrameInfoItems:SetText(#IMAsellingqueue.." items left to sell...")

			
			end
		else
			IMAprint("|c00ff0033Error.  bag queue[1] is empty.")
		end
	else
		IMAsellingqueue = {}
		IMAdeclinecount = 1  --reset it
		--IMAprint("nothing in queue to sell")
	--	IMA_AcceptSendFrame:Hide();
	end
end

function IMAskipitem()
	IMAdeclinecount = IMAdeclinecount + 1
	IMAwaitingfornewauctionevent = false

end

function IMA_StartAuction(iteminfo)
	
	local auctionpending = false
	--check that we aren't currently trying to sell this item
	local name, texture, count, quality, canUse, price = GetAuctionSellItemInfo()
	--check if pending auction exists already
	if(name) then
		--check if that pending auction matches what we're now trying to sell. 
		local auctionbag,auctionslot = IMA_FindAuctionItem()
		if(auctionbag==iteminfo.bag and auctionslot==iteminfo.slot) then
			auctionpending = true
		else
			--if it doesnt, clear the pendingauction - or just replace it and clear cursor
		end
	else
		--carry on
	end

	IMAprint("|c0000ffaaStarting Auction ")

	if(not auctionpending)then  --skip this
		-- Get item from bag, put in cursor
		if ( CursorHasItem()) then
			if(IMAcursor.bag and IMAcursor.slot) then
				if (iteminfo.bag==IMAcursor.bag and iteminfo.slot==IMAcursor.slot) then
				--do nothing since cursor already contains what we want to sell
				else
					ClearCursor()  --should never be reached
					PickupContainerItem(iteminfo.bag, iteminfo.slot);
				end
			else
				ClearCursor()  --should never be reached
				PickupContainerItem(iteminfo.bag, iteminfo.slot);
			end
		else
			PickupContainerItem(iteminfo.bag, iteminfo.slot);
		end
		
		--click on auction box - item should go to there
		AuctionFrameAuctions.duration = iteminfo.duration;  --with 4.0 this has to be set ahead of time
		ClickAuctionSellItemButton(AuctionSellItemButton)  -- ClickAuctionSellItemButton(Frame, left or right click, boolean (held down));
		ClearCursor() --just in case we replaced something
		IMAcursor.bag = nil
		IMAcursor.slot = nil
		
		local name, texture, count, quality, canUse, price = GetAuctionSellItemInfo();
		if ( not name ) then 	
		--check that it actually DID go there
	
			IMAprint("Item did not make it to the auctionqueue")
			IMAprint({GetContainerItemInfo(IMAsellingqueue[IMAdeclinecount].bag, IMAsellingqueue[IMAdeclinecount].slot)})
			return
		end
		
	end

	--it made it - carry on

	-- these 3 lines help with compatability
	MoneyInputFrame_SetCopper(StartPrice, iteminfo.price);
	MoneyInputFrame_SetCopper(BuyoutPrice, iteminfo.buyout);
	AuctionFrameAuctions.duration = iteminfo.duration;
	StartAuction(iteminfo.price, iteminfo.buyout, iteminfo.duration,count,1);

		


	return;
end



-- SET PRICES DROPDOWN CODE
function IMA_PriceSchemeDropDown_OnShow(self)
	IMA_PriceSchemeDropDown_OnLoad(self);
	
	-- set default if none
	if IMA_Settings.DropDown == nil then
		IMA_Settings.DropDown = "Default";
	end
	
	_G["IMA_" .. IMA_Settings.DropDown .. "_function"](self);
end



function IMA_PriceSchemeDropDown_OnLoad(self)
	UIDropDownMenu_Initialize(self, IMA_PriceSchemeDropDown_Initialize);
end



function IMA_ClearTopFrame(self)
	if IMA_MultiplierFrame then
		IMA_MultiplierFrame:Hide();
		IMA_AllSamePriceFrame:Hide();
		IMA_EasyAuctionFrame:Hide();
		MoneyInputFrame_SetPreviousFocus(IMA_Item1StartPrice, IMA_Item18BuyoutPriceCopper);
		MoneyInputFrame_SetNextFocus(IMA_Item18BuyoutPrice, IMA_Item1StartPriceGold);
	end
end



function IMA_Default_function(self)
	UIDropDownMenu_SetSelectedValue(IMA_PriceSchemeDropDown, "Default");
	IMA_ClearTopFrame(self);
	IMA_Settings.DropDown = "Default";
end
	


function IMA_Multiplier_function(self)
	UIDropDownMenu_SetSelectedValue(IMA_PriceSchemeDropDown, "Multiplier");
	IMA_ClearTopFrame(self);
	IMA_MultiplierFrame:Show();
	IMA_Settings.DropDown = "Multiplier";
end


	
function IMA_AllSamePrice_function(self)
	UIDropDownMenu_SetSelectedValue(IMA_PriceSchemeDropDown, "AllSamePrice");
	IMA_ClearTopFrame(self);
	IMA_AllSamePriceFrame:Show();
	MoneyInputFrame_SetPreviousFocus(IMA_Item1StartPrice, IMA_AllSamePriceFrameStackSize);
	MoneyInputFrame_SetNextFocus(IMA_Item18BuyoutPrice, IMA_AllSamePriceFrameStartPriceGold);
	--IMA_AllSamePriceFrameStartPriceGold:SetFocus();
	IMA_Settings.DropDown = "AllSamePrice";
end



function IMA_EasyAuction_function(self)
	UIDropDownMenu_SetSelectedValue(IMA_PriceSchemeDropDown, "EasyAuction");
	IMA_ClearTopFrame(self);
	IMA_EasyAuctionFrame:Show();
	IMA_Settings.DropDown = "EasyAuction";
end

-- dax006 code
function IMA_Auctioneer_function(self)
	if(AucAdvanced) then
    	UIDropDownMenu_SetSelectedValue(IMA_PriceSchemeDropDown, "Auctioneer");
    	IMA_ClearTopFrame(self);
    	IMA_Settings.DropDown = "Auctioneer";
    else
       DEFAULT_CHAT_FRAME:AddMessage("Auctioneer module not found.")
       if(IMA_Settings.DropDown == "Auctioneer") then
          IMA_Settings.DropDown = "Default";
       end
    end
end


function IMA_Auc_undercut_function(self)

IMAprint("Auc Undercut Clicked!")
	if(AucAdvanced) then
    	UIDropDownMenu_SetSelectedValue(IMA_PriceSchemeDropDown, "Auc_undercut");
    	IMA_ClearTopFrame(self);
    	IMA_Settings.DropDown = "Auc_undercut";
    else
       DEFAULT_CHAT_FRAME:AddMessage("Auctioneer module not found.")
       if(IMA_Settings.DropDown == "Auc_undercut") then
          IMA_Settings.DropDown = "Default";
       end
    end
end
function IMA_AuctionLite_function(self)
	if(AuctionLite) then
    	UIDropDownMenu_SetSelectedValue(IMA_PriceSchemeDropDown, "AuctionLite");
    	IMA_ClearTopFrame(self);
    	IMA_Settings.DropDown = "AuctionLite";
    else
       DEFAULT_CHAT_FRAME:AddMessage("AuctionLite not found.")
       if(IMA_Settings.DropDown == "AuctionLite") then
          IMA_Settings.DropDown = "Default";
       end
    end
end

function IMA_Validate(bag,slot)
	local text,repair,cooldown
	
		
	cooldown,repair = MyT:SetBagItem(bag,slot)
	if ((repair and repair > 0) or cooldown) then
			local itemLink = GetContainerItemLink(bag,slot)
			if (not IMAdebug) then  --only for the noobs :)
				print("You cannot auction "..itemLink..", for it is on cooldown or needs repair")
			end
			return false
	end
	
	--IMAprint("Number of lines in tooltip? |c000000ff"..MyT:NumLines())
	
	
	for i=1,MyT:NumLines() do
		MyTtext = _G["MyTTextLeft"..i]
		
		if (MyTtext) then
			text = MyTtext:GetText()
		else
			IMAPrint("|C00ff00ERror: |r MyTTextLeft"..i.."  not found")
		end
		
		-- or string.find(text,"right click to open")
		
		if(text) then
	--		IMAprint("|c00eeaaff  text = "..text) 
			text = string.lower(text)
			if (string.find(text,"soulbound") or string.find(text,"conjured") or string.find(text,"quest item") or string.find(text,"right click to open")) then
				local itemLink = GetContainerItemLink(bag,slot)
				if (not IMAdebug) then  --only for the noobs :)
					print("You cannot auction "..itemLink..", due to it being "..text)
				end
				return false
			end
		else
			IMAprint("row "..i.." text not found, returning ?")
			return true
		end
	end
	return true
end


function IMA_PriceSchemeDropDown_Initialize(self)

	local info = {};
	info.text = IMA_DEFAULT;
	info.value = "Default";
	info.func = IMA_Default_function;
	UIDropDownMenu_AddButton(info);

	info = {};
	info.text = IMA_VALUE_MULTIPLIER;
	info.value = "Multiplier";
	info.func = IMA_Multiplier_function;
	UIDropDownMenu_AddButton(info);

	info = {};
	info.text = IMA_ALL_SAME_PRICE;
	info.value = "AllSamePrice";
	info.func = IMA_AllSamePrice_function;
	UIDropDownMenu_AddButton(info);

	info = {};
	info.text = IMA_EASY_AUCTION;
	info.value = "EasyAuction";
	info.func = IMA_EasyAuction_function;
	UIDropDownMenu_AddButton(info);
	
	if(AucAdvanced) then
		info = {};
		info.text = IMA_AUCTIONEER_AUCTION;
		info.value = "Auctioneer";
		info.func = IMA_Auctioneer_function;
		UIDropDownMenu_AddButton(info);
		
		info = {};
		info.text = IMA_AUCTIONEERUNDERCUT_AUCTION;
		info.value = "Auc_undercut";
		info.func = IMA_Auc_undercut_function;
		UIDropDownMenu_AddButton(info);
	end
	
	if(AuctionLite) then
		info = {};
		info.text = IMA_AUCTIONLITE_AUCTION;
		info.value = "AuctionLite";
		info.func = IMA_AuctionLite_function;
		UIDropDownMenu_AddButton(info);
	end
	
end


--end dax006
function IMA_SetAllPricesButton_OnClick(self)
	local scheme = UIDropDownMenu_GetSelectedValue(IMA_PriceSchemeDropDown);
	scheme = string.gsub(scheme," ","_");

	pricefunc = _G["IMA_"..scheme.."_GetPriceAndBuyout"];
	if (pricefunc == nil) then
		return;
	end
	
	IMA_ClearAuctionSellItem();
	for i = 1, IMA_NUMITEMBUTTONS, 1 do
		local item = _G["IMA_Item"..i];
		local button = _G[item:GetName().."ItemButton"];
		
		if (button.bag ~= nil and button.slot ~= nil) then
			if (true and true) then -- put checkbox code here
				price, buyout = pricefunc(button.bag,button.slot,button.count,button.texture,button.name,button.price, MoneyInputFrame_GetCopper(_G[item:GetName().."StartPrice"]))
				if (price ~= nil) then
					MoneyInputFrame_SetCopper(_G[item:GetName().."StartPrice"],price);
				end
				if (buyout ~= nil) then	
					MoneyInputFrame_SetCopper(_G[item:GetName().."BuyoutPrice"],buyout);
				end
			end
		end
	end
end



function IMA_Default_GetPriceAndBuyout(bag, slot, count, texture, name, price, currentstart)
	start = MoneyInputFrame_GetCopper(StartPrice);
	buyout = MoneyInputFrame_GetCopper(BuyoutPrice);
	return start, buyout;
end

--auctioneer data added by Dax006
function IMA_Auctioneer_GetPriceAndBuyout(bag, slot, count, texture, name, price, currentstart)	
	start = MoneyInputFrame_GetCopper(StartPrice);   --default is *3 market value i believe
	buyout = MoneyInputFrame_GetCopper(BuyoutPrice);
    itemLink = GetContainerItemLink(bag,slot)
    texture, count, locked, quality, readable = GetContainerItemInfo(bag, slot);
	if not count then count = 1 end;
	if(AucAdvanced) then
		if( AucAdvanced.API.GetMarketValue(itemLink)) then
			buyout = AucAdvanced.API.GetMarketValue(itemLink) * count
		end
    end
	if(buyout) then
		start = buyout * 0.8
	end
	return start, buyout;
end


function IMA_Auc_undercut_GetPriceAndBuyout(bag, slot, count, texture, name, price, currentstart)	

    local itemLink = GetContainerItemLink(bag,slot)  
	local texture, count, locked, quality, readable = GetContainerItemInfo(bag, slot);
	
    

	local buy, bid
	local reason = ""

	-- We need this out here because it fetches the items from the image
	IMAprint(" AucAdvanced.Modules.Util.SimpleAuction.Private.GetItems(itemLink) ")
	local imgseen, image, matchBid, matchBuy, lowBid, lowBuy, aSeen, aveBuy = AucAdvanced.Modules.Util.SimpleAuction.Private.GetItems(itemLink) 
	
		--Check for undercut first
			if lowBuy then
				buy = lowBuy
				if lowBid and lowBid > 0 and lowBid <= lowBuy then
					bid = lowBid
				else
					bid = lowBuy * 0.8
				end
				reason = "Undercutting market by "
			end
			

		--if no buy price yet, look for marketprice
		if not buy then
			local market, seen = AucAdvanced.API.GetMarketValue(itemLink)
			if market and (market > 0) then
				buy = market
				bid = market * 0.8
				reason = "Using market value"
			end
		end
		--look for average of current competition
		if not buy and aveBuy and aveBuy > 0 then
			buy = aveBuy
			bid = buy * 0.8
			reason = "Using current market data"
		end
		--Vendor markup
		if not buy and GetSellValue then
			local vendor = GetSellValue(itemLink)
			if vendor and vendor > 0 then
				buy = vendor * 3
				bid = buy * 0.8
				reason = "Marking up vendor"
			end
		end
	
	if not buy then
		buy = 0
	end
	if not bid then
		bid = buy * 0.8
	end
	--multiply by stacksize
	bid = bid * count
	buy = buy * count
	--We give up
	if bid == 0 then
		bid = 1
		buy = 0
		reason = "Unable to calculate price" 
	end
	
	bid, buy = ceil(tonumber(bid) or 1), ceil(tonumber(buy) or 0)
	IMAprint("Bid, buy, reason"..bid.."  "..buy.."  "..reason)

			
        return bid - 1,buy - 1  --one copper.  im so evil.
end

function IMA_AuctionLite_GetPriceAndBuyout(bag, slot, count, texture, name, price, currentstart)	
	start = MoneyInputFrame_GetCopper(StartPrice);   --default is *3 market value i believe
	buyout = MoneyInputFrame_GetCopper(BuyoutPrice);
    itemLink = GetContainerItemLink(bag,slot)
    texture, count, locked, quality, readable = GetContainerItemInfo(bag, slot);
	if not count then count = 1 end;
	if(AuctionLite) then
		if(AuctionLite:GetAuctionValue(itemLink)) then
			buyout =  AuctionLite:GetAuctionValue(itemLink) * count
		end
    end
	if(buyout and buyout > 0) then
		start = math.floor(buyout * 0.75)
	end
	return start, buyout;
end

    -- end dax006 code


function IMA_Multiplier_GetPriceAndBuyout(bag, slot, count, texture, name, price, currentstart)
	local retprice = nil;
	local retbuyout = nil;
	
	if (IMA_MultiplierFramePriceCheckButton:GetChecked()) then
		pricepercent = IMA_MultiplierFramePriceMultiplier:GetText() + 0;
		if (pricepercent >= 1 and pricepercent <= 9999) then
			retprice = max(1,floor(price * pricepercent ));
			currentstart = retprice + 0;
		end
	end

	if (IMA_MultiplierFrameBuyoutCheckButton:GetChecked()) then
		buyoutpercent = IMA_MultiplierFrameBuyoutMultiplier:GetText() + 0;
		if (buyoutpercent >= 1 and buyoutpercent <= 9999) then
			retbuyout = floor(currentstart * buyoutpercent );
		end
	end
	
	return retprice, retbuyout;
end



function IMA_AllSamePrice_GetPriceAndBuyout(bag, slot, count, texture, name, price, currentstart)
	local price = MoneyInputFrame_GetCopper(IMA_AllSamePriceFrameStartPrice);
	local buyout = MoneyInputFrame_GetCopper(IMA_AllSamePriceFrameBuyoutPrice);
	local basecount = IMA_AllSamePriceFrameStackSize:GetNumber() + 0;

	if (basecount > 0 and count ~= basecount) then
		price = ceil(price / basecount * count);
		buyout = ceil(buyout / basecount * count);
	end

	return price, buyout;
end



function IMA_EasyAuction_GetPriceAndBuyout(bag, slot, count, texture, name, price, currentstart)
	local start = nil;
	local buyout = nil;
	
	if (EasyAuction_Prices ~= nil and EasyAuction_PersonalPrices ~= nil) then
		local lastauction = nil;
		if (IMA_Playername ~= nil and EasyAuction_PersonalPrices[IMA_Playername] ~= nil
				and EasyAuction_PersonalPrices[IMA_Playername][name] ~= nil) then
			lastauction = EasyAuction_PersonalPrices[IMA_Playername][name];
		else
			if (EasyAuction_Prices[name] ~= nil) then
				lastauction = EasyAuction_Prices[name];
			end
		end
		if (lastauction ~= nil) then
			start = lastauction.bid * count;
			buyout = lastauction.buyout * count;
		end
	end	

	return start, buyout;
end



function IMA_SetDurationForAll(chosenDuration)
	local i;
	local index;
	local num = 0;
	for i = 1, IMA_NUMITEMBUTTONS, 1 do
		_G["IMA_Item"..i.."ShortAuction"]:SetChecked(nil)
		_G["IMA_Item"..i.."MediumAuction"]:SetChecked(nil)
		_G["IMA_Item"..i.."LongAuction"]:SetChecked(nil)

		if ( chosenDuration == 12 ) then
			_G["IMA_Item"..i.."ShortAuction"]: SetChecked(1)
			_G["IMA_Item"..i].duration = 1;  --changed in patch 3.3.3 from minutes to index (1, 2 or 3)
			index = 1;
		elseif ( chosenDuration == 24 ) then
			_G["IMA_Item"..i.."MediumAuction"]:SetChecked(1)
			_G["IMA_Item"..i].duration = 2;
			index = 2;
		else
			_G["IMA_Item"..i.."LongAuction"]:SetChecked(1)
			_G["IMA_Item"..i].duration = 3;
			index = 3;
		end
		
		IMA_Settings["duration"..i] = index;
		
		-- maybe sure this is the current item before we update
		IMA_SetItemAsAuction(i);
		IMA_UpdateDeposit(i);
	end
	IMA_ClearAuctionSellItem();
	ClearCursor();
	IMA_UpdateItemButtons()
end



function IMA_InitAuctionFrameTab(tab)
	local index =1;
	-- Find the first unused tab.
	while (_G["AuctionFrameTab" .. index]) do
		index = index + 1;
	end

	-- Make it an alias for our tab
	setglobal("AuctionFrameTab" .. index, tab)

	-- Set up tabbing data
	tab:SetID(index);
	PanelTemplates_SetNumTabs(AuctionFrame, index);

	-- Set geometry
	tab:SetPoint("TOPLEFT", _G["AuctionFrameTab"..(index-1)], "TOPRIGHT", -8, 0);
end

--[[
function IMA_AuctionFrameTab_OnClick()
	IMAprint("CLICK tabed")
end
]]

function IMA_AddTabbing(self)
-- Adds Tabbing in the All Same Price entry boxes.
	MoneyInputFrame_SetPreviousFocus(IMA_AllSamePriceFrameStartPrice, IMA_Item18BuyoutPriceCopper);
	MoneyInputFrame_SetNextFocus(IMA_AllSamePriceFrameStartPrice, IMA_AllSamePriceFrameBuyoutPriceGold);

	MoneyInputFrame_SetPreviousFocus(IMA_AllSamePriceFrameBuyoutPrice, IMA_AllSamePriceFrameStartPriceCopper);
	MoneyInputFrame_SetNextFocus(IMA_AllSamePriceFrameBuyoutPrice, IMA_AllSamePriceFrameStackSize);

	MoneyInputFrame_SetPreviousFocus(IMA_AllSamePriceFrameStackSize, IMA_AllSamePriceFrameBuyoutPriceCopper);
	MoneyInputFrame_SetNextFocus(IMA_AllSamePriceFrameStackSize, IMA_Item1StartPriceGold);


-- Adds Tabbing in the 18 (or however many) auction slots.
	local iprev, i, inext;
	for i = 1, IMA_NUMITEMBUTTONS, 1 do
		if i == 1 then
			iprev = IMA_NUMITEMBUTTONS;
			inext = i + 1;
		elseif i == IMA_NUMITEMBUTTONS then
			iprev = i - 1;
			inext = IMA_NUMITEMBUTTONS;
		else
			iprev = i - 1;
			inext = i + 1;
		end
		MoneyInputFrame_SetPreviousFocus(_G["IMA_Item" .. i .. "StartPrice"], _G["IMA_Item" .. iprev .. "BuyoutPriceCopper"]);
		MoneyInputFrame_SetNextFocus(_G["IMA_Item" .. i .. "StartPrice"], _G["IMA_Item" .. i .. "BuyoutPriceGold"]);
		MoneyInputFrame_SetPreviousFocus(_G["IMA_Item" .. i .. "BuyoutPrice"], _G["IMA_Item" .. i .. "StartPriceCopper"]);
		MoneyInputFrame_SetNextFocus(_G["IMA_Item" .. i .. "BuyoutPrice"], _G["IMA_Item" .. inext .. "StartPriceGold"]);
	end

end




function IMAshowtooltip(frame,notes)
   if(frame) then
      if frame:GetRight() >= (GetScreenWidth() / 2) then
	 GameTooltip:SetOwner(frame, "ANCHOR_LEFT")
      else
	 GameTooltip:SetOwner(frame, "ANCHOR_RIGHT")
      end
      if(notes) then
	 GameTooltip:SetText(notes, 1, 1, 1, 1, 1)
	 GameTooltip:Show()
      end
   end
end

function IMAhidetooltip(self)
   GameTooltip:Hide()
end

function IMA_AddAllButton_OnClick(self)

	IMAprint("|c0000aada Add All Button Clicked.")
	local texture, itemCount, locked, quality, readable
	ClearCursor()
    if (IMA_AuctionFrameMassAuction:IsVisible()) then 
		local i,bag,numberofslots,slot,IMAitem,IMAitemnum,IMAitembox;
		local freeitemfound = false
		IMAitem = 1
		for bag = 0,4 do  --loop through each item in each bag
			numberofslots = GetContainerNumSlots(bag);
			if (numberofslots > 0) then
				for slot=1,numberofslots do
					if(not IMA_GetItemFrame(bag, slot)) then --its already up for sale in another box - trying to pick it up would fail and leave a blank item
						texture, itemCount, locked, quality, readable = GetContainerItemInfo(bag,slot);
						if(not locked) then  --not sure why some items are locked and not others
							ClearCursor()  --lol adding this got rid of ALL my bugs
							PickupContainerItem(bag, slot);
							if(CursorHasItem()) then  --pick it up one at a time
								if (IMA_Validate(bag,slot)) then
									IMAprint("|c000044dd Validation passed for Bag "..tostring(bag)..", slot "..tostring(slot)..", item: "..GetContainerItemLink(bag,slot)..", Locked ="..tostring(locked))
								
									--find first open bag
									freeitemfound = false
									while(not freeitemfound) do
										if(IMAitem > IMA_NUMITEMBUTTONS) then
											ClearCursor()
											IMA_UpdateItemButtons();
											IMAprint(IMAitemnum.."|c00ff44dd  No Room.")
											return  --all IMA boxes have items
										end
										IMAitemnum = "IMA_Item"..IMAitem.."ItemButton"
										IMAitembox = _G[IMAitemnum]
										if (not IMAitembox.slot ) then
											IMAprint(IMAitemnum.."|c000044dd  was available")
											freeitemfound = true
											--put it in bag
											IMA_ItemButton_OnClick(IMAitembox);
										end
										IMAitem = IMAitem+1
									end
								end
							end
						else
							IMAprint("|c00ff44dd LOCKED");
							IMAprint({GetContainerItemInfo(bag,slot)});
						end
					end
				end
			end
		end
	end
	ClearCursor()
	IMA_UpdateItemButtons();
	
end




function IMA_QueryAllButton_OnClick(self)
	--IMAdebug = true
	IMAprint("query all button clicked.")
	IMAscanahforbagitems(self)
end
function IMAscanahforbagitems(self)  --this is when they click the button
	IMAbagitemlist = IMAcreatebagitemlist(self)
	IMAprint(IMAbagitemlist)
	IMAbagitemlistnum = 1 --a 'reset' of sorts
	IMAsendquery(self)
end

function IMAremoveduplicates(IMAlist)

	local newlist = {}
	local IMAexists = false

	for i = 1,#IMAlist do
		IMAexists = false
		
		for j = 1,#newlist do
		if (IMAlist[i] == newlist[j]) then --it exists in the new list already
				IMAexists  = true
				break
			end
		end
		if(IMAexists == false) then
			tinsert(newlist,IMAlist[i])
		end
	end

	return newlist
end

function IMAcreatebagitemlist(self)
	
	local i,bag,numberofslots,slot,texture,itemCount,locked,quality,readable, link
	local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemCount, itemEquipLoc, itemTexture
	local canQuery,canQueryAll
	local testtable = {}

	for bag = 0,4 do  --loop through each item in each bag
		numberofslots = GetContainerNumSlots(bag);
		if (numberofslots > 0) then
			for slot=1,numberofslots do
				link = GetContainerItemLink(bag,slot)
				if(link) then
					itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemCount, itemEquipLoc, itemTexture = GetItemInfo(link) 
					testtable[#testtable+1] = itemName
				end
		
			end
		end
	end
	testtable = IMAremoveduplicates(testtable)
	return testtable
end

function IMAsendquery(self)

	IMAprint("Attempting to send query for name of: "..tostring(IMAbagitemlist[IMAbagitemlistnum]))

	if AuctionFrameBrowse then  --some mods change the default AH frame name
		AuctionFrameTab1:Click()
		if AuctionFrameBrowse:IsVisible() then  
			canQuery,canQueryAll = CanSendAuctionQuery()  --check if we can send a query
			if canQuery then
				if(IMAbagitemlist[IMAbagitemlistnum]) then
					local name = IMAbagitemlist[IMAbagitemlistnum]
					IMAbagitemlistnum = IMAbagitemlistnum + 1
					IMAstatus=WAITINGFORUPDATE
					BrowseName:SetText(name)
					AuctionFrameBrowse_Search()	
					return true
				else
					IMAstatus = nil
					IMA_AuctionFrameTab:Click()
				end
			else
				IMAprint("CAN NOT query")
			end
		end
	end
end