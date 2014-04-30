local function PrettyCurrency(copper)
	local text = "";
	
	local gold = floor( copper / COPPER_PER_GOLD );
	if gold > 0 then
		text = ("%s%d|cffffd700g|r"):format(text, gold);
	end
	
	local silver = floor( ( copper % COPPER_PER_GOLD ) / COPPER_PER_SILVER );
	if silver > 0 then
		text = ("%s%d|cffc7c7cfs|r"):format(text, silver);
	end
	
	local copper = floor( copper % COPPER_PER_SILVER );
	if copper > 0 or text == "" then
		text = ("%s%d|cffeda55fc|r"):format(text, copper);
	end
	
	return text;
end

-- StartAuction overwriting

local originalStartAuction = StartAuction;
function StartAuction(bid, buyout, duration, stackSize, numStacks)
	if (not IMA_AuctionFrameMassAuction:IsVisible()) then
		originalStartAuction(bid,buyout,duration,stackSize,numStacks)
		return
	end
	
	if (IMAauctionconfirmvisible) then
		--we are still waiting on confirmation for some other auction
			IMAprint("IMAauctionconfirmvisible found - exiting")
		return
	end
	local name, texture, count, quality, canUse, price = GetAuctionSellItemInfo();
	local itemLink = select(2, GetItemInfo(GetAuctionSellItemInfo())); -- GetAuctionSellItemInfo first result is an itemName, but GetItemInfo allows itemNames as long as the item is in your current inventory
	IMAprint("|c00aaffaaREPLACEMENT Start Auction "..itemLink)
	stackSize = stackSize or 1
	numStacks = numStacks or 1
	StaticPopupDialogs["StartAuctionPostConfirm"] = {
		text = ("Post %d auctions of %dx%s at %s bid and %s buyout?"):format(numStacks, count, itemLink or "", PrettyCurrency(bid or 0), PrettyCurrency(buyout or 0)),
		button1 = YES,
		button2 = NO,
		OnAccept = function(self)
			self.accepted = true;
			
			self:Hide();
		end,
		OnCancel = function(self,arg1,arg2)
			self.accepted = nil;
			IMAprint("|c00aaaa00 ONCAnCeL reached! 1 ="..tostring(arg1).."2 ="..tostring(arg2).."  self="..tostring(self))
			--IMAprint(self)
			if(arg1 == "timeout") then  --doesn't seem to work.  hrm.
				print("Accept box timed out.  Going to next.")
			end
			IMAskipitem()
		end,
		OnHide = function(self)
			if self.accepted then
				IMAwaitingfornewauctionevent = true
				IMAwaitingfornewauctioneventtimeout = time()
				originalStartAuction(bid, buyout, duration, count, numStacks);
			end
			IMAauctionconfirmvisible=false
		end,
		OnShow = function(self)
			IMAauctionconfirmvisible=true
		end,
		timeout = 30,
		whileDead = 1,
		hideOnEscape = 1,
		enterClicksFirstButton=true,
		exclusive=true,
	};
	StaticPopup_Show("StartAuctionPostConfirm");
end

