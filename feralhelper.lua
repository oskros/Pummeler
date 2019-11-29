-- Constructs the MCP frame to be scanned for number of charges
function FH_CreatePummelerFrame()
    if pummelerFrame == nil then
        pummelerFrame = CreateFrame("GameTooltip", "pummelerTooltip", nil, "GameTooltipTemplate");
    end;
end;


-- Scans the MCP tooltip for number of charges available
function FH_PummelerChargesText(options)
	pummelerTooltip:SetOwner( WorldFrame, "ANCHOR_NONE" );
	if(options.bag and options.slot) then
		pummelerTooltip:SetBagItem(options.bag, options.slot);
	else
		pummelerTooltip:SetInventoryItem("player", 16);
	end;
	local charges;
	local i = 1;
	while (true) do
		text = getglobal("pummelerTooltipTextLeft"..i):GetText();
		if (not text) then
			break;
		elseif (string.find(text, "Charge")) then
			charges = text;
			pummelerTooltip:Hide();
			return charges;
		end;
		i=i+1;
	end;
	pummelerTooltip:Hide();
	return charges;
end;


-- Converts the output of "FH_PummelerChargesText" to a number
function FH_PummelerChargesNumber(chargesText)
	local charge = 0;
	if (chargesText ~= nil) then
		for i = 0, 3 do
			if (chargesText ~= nil and string.find(chargesText, i)) then
				charge = i; break;
			end;
		end;
	end;
	return charge;
end;


-- Gets the total MCP charges available in both bag and on current weapon
function FH_AvailablePummelerCharges()
    FH_CreatePummelerFrame();
    local bag_charges = 0;
	local equip_charges = 0;
    local pummeler_id = 9449;
    for i = 0, NUM_BAG_SLOTS do
        for z = 1, GetContainerNumSlots(i) do
            if GetContainerItemID(i, z) == pummeler_id then
                bag_charges = bag_charges + FH_PummelerChargesNumber(FH_PummelerChargesText{bag=i, slot=z});
            end;
        end;
    end;
    equip_charges = FH_PummelerChargesNumber(FH_PummelerChargesText{})
    return bag_charges + equip_charges, equip_charges;
end;


-- Finds the first encountered bag position of an item by name
function FH_ItemBagPosition(itemName, threeChargesFlag)
    local itemBag, itemSlot;
	local charges;
    for bag = 0, NUM_BAG_SLOTS do
		for slot = 1, GetContainerNumSlots(bag) do
			local name = GetContainerItemLink(bag,slot)
			if name and string.find(name, itemName) then
				if string.find(name, itemName) then
					charges = FH_PummelerChargesNumber(FH_PummelerChargesText{bag = bag, slot = slot});
					if (threeChargesFlag == true) then
						if (charges == 3) then
							itemBag = bag; itemSlot = slot;
							return itemBag, itemSlot;
						end;
					elseif (charges > 0) then
						itemBag = bag; itemSlot = slot;
						return itemBag, itemSlot;
					end;
				end;
			end;
		end;
	end;
    return itemBag, itemSlot;   
end;


-- Checking if player has buff by SpellID
function FH_PlayerHasBuff(spell_id)
    for i = 1, 40 do
        local _, _, _, _, _, _, _, _, _, spellId = UnitBuff("player", i)
        if spellId == nil then
            return false
        elseif spellId == spell_id then
            return true
        end
    end
    return false
end


-- Gets the spellIcon for the next spell to be used in optimal rotation
function FH_GetNextSpell()
    local next_spell;
    local autoattacking = IsCurrentSpell(6603);
    local cur_energy = UnitPower("player", 3);
    local cur_mana = UnitPower("player", 0);
    local combo_pts = GetComboPoints("player", "target");
    local clearcasting = FH_PlayerHasBuff(16870);
    local _, gcd, _ = GetSpellCooldown(9832); -- shred spellID TODO: TEST THIS FUNCTION!
    --local _, in_cat_form, _, _ = GetShapeshiftFormInfo(3);

    --if (not in_cat_form) then
    --    next_spell = 132115; -- Cat Form
    if (not autoattacking and cur_energy == 100) then
        next_spell = 132242; -- Tigers Fury
    elseif clearcasting then
        next_spell = 136170; -- Clearcasting
    elseif (combo_pts == 5 and cur_energy < 63) then
        next_spell = 132127 -- Ferocious Bite
    elseif (cur_energy < 28 and cur_mana > 612) then
        --next_spell = 132115; -- Cat Form
        if gcd > 0 then
            next_spell = 132116;
        else
            next_spell = 132115; -- Cat Form
        end
    else
        next_spell = 136231; -- Shred
    end;
    return next_spell;
end;


-- Cernie's function. Currently untested
function Pummeler_isBuffTextureActive(texture)
	local i=0;
	local g=GetPlayerBuff;
	local isBuffActive = false;

	while not(g(i) == -1)
	do
		if(strfind(GetPlayerBuffTexture(g(i)), texture)) then isBuffActive = true; end;
		i=i+1
	end;
	return isBuffActive;
end;


-- Cernie's function. Currently untested
function Pummeler_isBuffNameActive(buff)
	local isActive = false;
	local index = -1;
	local i = 1;
	local numBuffs;
	local textleft1;
	while not(UnitBuff("player", i) == -1 or UnitBuff("player", i) == nil)
		do
		pummelerTooltip:SetOwner(WorldFrame, "ANCHOR_NONE");
		pummelerTooltip:SetUnitBuff("player", i);
		textleft1 = getglobal(pummelerTooltip:GetName().."TextLeft1");

		if(textleft1 ~= nil and string.find(string.lower(textleft1:GetText()), string.lower(buff))) then
			isActive = true;
			index = i - 1;
			pummelerTooltip:Hide();
			break;
		end;
		pummelerTooltip:Hide();
		i=i+1;
	end;
	if(index == -1) then
		numBuffs = 0;
	else
		numBuffs = i;
	end;
	return isActive, index, numBuffs;
end;


--Pummeler = {};
--function Pummeler_OnLoad()
--    local this = CreateFrame("FRAME", "DefaultFrame");
--	this:RegisterEvent("PLAYER_ENTERING_WORLD");
--	this:RegisterEvent("ADDON_LOADED");
--	DEFAULT_CHAT_FRAME:AddMessage("Pummeler addon loaded. Type /pummeler for usage.");
--	SlashCmdList["PUMMELER"] = function()
--		local msg = "To use Pummeler addon, create a macro and type /script Pummeler_main();";
--		local msg2 = "To equip a fully charged Manual Crowd Pummeler, create a separate macro and type /script Pummeler_equipFullyCharged();";
--		DEFAULT_CHAT_FRAME:AddMessage(msg);
--		DEFAULT_CHAT_FRAME:AddMessage(msg2);
--	end;
--	SLASH_PUMMELER1 = "/pummeler";
--end;



function get_MCPTooltip(options)
    --SpellId=13494 for the haste buff
	local text;
	if not MCPTooltip then
		CreateFrame("GameTooltip", "MCPTooltip", UIParent, "GameTooltipTemplate");
		MCPTooltip:SetOwner(UIParent, "ANCHOR_NONE");
	end;
	if(options.bag and options.slot) then
		MCPTooltip:SetBagItem(options.bag, options.slot);
	else
		MCPTooltip:SetInventoryItem("player", 16);
	end;
    text = MCPTooltipTextLeft11:GetText();
	MCPTooltip:Hide();
	return text;
end;