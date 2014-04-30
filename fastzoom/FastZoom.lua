

--Fastzoomdebug = true

local printstack = -1
function Fastzoomprint(message)
   if(Fastzoomdebug) then
      local stack, filler
      if not message then
	  	 DEFAULT_CHAT_FRAME:AddMessage("No Message to print.")
		 return false 
      end
      printstack=printstack+1
      local filler=""
      for stack=1,printstack do
	  	 filler=filler.."--"
      end   
      if (type(message) == "table") then
	  	-- DEFAULT_CHAT_FRAME:AddMessage("its a table.  length="..SL_tcount(message))
	 	local i
	 	for k,v in pairs(message) do

	    	DEFAULT_CHAT_FRAME:AddMessage(filler.."(key)   "..k)
	    	Fastzoomprint(v)
	 	end
      elseif (type(message) == "userdata") then
      
      else
	  	  if(printstack>0) then
	    	 DEFAULT_CHAT_FRAME:AddMessage(filler.."(value) "..message)
	 	 else
	    	 DEFAULT_CHAT_FRAME:AddMessage(filler..message)
	 	 end
	end
      printstack=printstack-1
   end
end



function Fastzoominitialize()


   Fastzoomprint("|c00aaffffvariables loaded.  Initializing.")

   local playerName = UnitName("player");
   local serverName = GetCVar("realmName");
   if (playerName == nil or playerName == UNKNOWNOBJECT or playerName == UNKNOWNBEING) then
      return;
   end

   
   if (FASTZOOMSPEED) then                     --old version
   
   else
        Fastzoomprint("Setting Defaults!")
      --set defaults here
        FASTZOOMSPEED = 5
        SetBinding("CTRL-MOUSEWHEELUP","FastZoomIn")
        SetBinding("CTRL-MOUSEWHEELDOWN","FastZoomOut")
        SaveBindings(2)
   end
   
   SetCVar( "cameraDistanceMaxFactor", 50);
   
end



-- ONLOAD, duh
function Fastzoom_OnLoad()

   -- Register for events
   --  self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
   Fastzoomframe = CreateFrame("Frame")
   Fastzoomframe:RegisterEvent("VARIABLES_LOADED")
   Fastzoomframe:RegisterEvent("UPDATE_BINDINGS")
   
   
   Fastzoomframe:SetScript("OnEvent",Fastzoom_OnEvent)

   print("FastZoom Loaded.  Type '/Fastzoom X' to change speed")

   -- create our Fastzoomash commands
   SLASH_Fastzoom1 = "/Fastzoom";
   SLASH_Fastzoom2 = "/fastzoom";
   SLASH_Fastzoom3 = "/FZ";
   SLASH_Fastzoom4 = "/fz";
   
   SlashCmdList["Fastzoom"] = Fastzoommain;


   

  	BINDING_HEADER_FastZoom = "Fast Zoom"
	BINDING_NAME_FastZoomIn = "Fast Zoom In"
	BINDING_NAME_FastZoomOut = "Fast Zoom Out"

	


   Fastzoomprint("|c00449955 end onload ")

   
end 
---------------------------------------------------------------------------

function FastZoomIn()
   CameraZoomIn(FASTZOOMSPEED)
end

function FastZoomOut()
   CameraZoomOut(FASTZOOMSPEED)
end



function Fastzoommain(input)

   Fastzoomprint("someone did a /Fastzoom")
   
   local binding = GetBindingKey("FastZoomIn")
   if(binding) then
        Fastzoomprint("getkeybinding = "..binding        )
    end
   if not (tonumber(input)) then 
        DEFAULT_CHAT_FRAME:AddMessage("type /Fastzoom 'Number from 1-50'")
   else
        DEFAULT_CHAT_FRAME:AddMessage("Zoom speed set to "..tonumber(input))
        FASTZOOMSPEED = tonumber(input)
   end
   
   

end



------------>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
----------<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
function Fastzoom_OnEvent(self,event)
    Fastzoomprint("|c00aaffaa  event Triggered!  ")
    Fastzoomprint(event)
    self:UnregisterEvent(event)
   --local timestaFastzoom, event, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags = CombatLogGetCurrentEntry()  --for documentation purposes
   --if (event == "VARIABLES_LOADED") then
   if (event == "UPDATE_BINDINGS") then

      Fastzoominitialize()

   end
end



Fastzoom_OnLoad()