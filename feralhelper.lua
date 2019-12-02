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
function FH_GetNextSpellIcon()
    local next_spell;
    local autoattacking = IsCurrentSpell(6603);
    local cur_energy = UnitPower("player", 3);
    local cur_mana = UnitPower("player", 0);
    local combo_pts = GetComboPoints("player", "target");
    local clearcasting = FH_PlayerHasBuff(16870);

	if clearcasting then
        next_spell = 136170; -- Clearcasting
    elseif (not autoattacking and cur_energy == 100) then
        next_spell = 132242; -- Tigers Fury
    elseif (combo_pts == 5 and cur_energy < 63) then
        next_spell = 132127 -- Ferocious Bite
    elseif (cur_energy < 28 and cur_mana > 612) then
		next_spell = 132115; -- Cat Form
    else
        next_spell = 136231; -- Shred
    end;
    return next_spell;
end;


-- Simplified function to extract the number of charges from a manual crowd pummeler
function FH_getMCPcharges(options)
    --SpellId=13494 for the haste buff
	local text, charges;
	if not MCPTooltip then
		CreateFrame("GameTooltip", "MCPTooltip", nil, "GameTooltipTemplate");
	end;
	MCPTooltip:SetOwner(WorldFrame, "ANCHOR_NONE");
	if(options.bag and options.slot) then
		MCPTooltip:SetBagItem(options.bag, options.slot);
	else
		MCPTooltip:SetInventoryItem("player", 16);
	end;
    text = MCPTooltipTextLeft11:GetText();
	MCPTooltip:Hide();
	charges, _ = strsplit(" ", text, 2)
	return charges;
end;