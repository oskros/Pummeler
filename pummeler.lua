Pummeler = {};
function Pummeler_OnLoad()
    local this = CreateFrame("FRAME", "DefaultFrame");
	this:RegisterEvent("PLAYER_ENTERING_WORLD");
	this:RegisterEvent("ADDON_LOADED");
	DEFAULT_CHAT_FRAME:AddMessage("Pummeler addon loaded. Type /pummeler for usage.");
	SlashCmdList["PUMMELER"] = function()
		local msg = "To use Pummeler addon, create a macro and type /script Pummeler_main();";
		local msg2 = "To equip a fully charged Manual Crowd Pummeler, create a separate macro and type /script Pummeler_equipFullyCharged();";
		DEFAULT_CHAT_FRAME:AddMessage(msg);
		DEFAULT_CHAT_FRAME:AddMessage(msg2);
	end;
	SLASH_PUMMELER1 = "/pummeler";
end;


Pummeler_Start_HasteBuff_Time = 0;
function Pummeler_main()
	createPummelerFrame();
	local haste, hasteIndex, numBuffs = Pummeler_isBuffNameActive("Haste");
	local slotId = GetInventorySlotInfo("MAINHANDSLOT");
	local itemLink = GetInventoryItemLink("player", slotId);
	local pummelerWeapon = "Manual Crowd Pummeler";
	local weaponTimer, weaponCd = GetInventoryItemCooldown("player", 16);
	local gameTime = GetTime();
	local timeLeft = 0;
	local chargesText = nil;
	local charge = 0;
	local buffTimeLeft = -1;
	local timeBetweenUses = 3;
	local bagPummeler, slotPummeler = nil;
	local attackSpeed = UnitAttackSpeed("player");
	local catForm = 3;
	local bearForm = 1;
	
	--get user's current form
	local currentForm = 0;
	for i = 1, GetNumShapeshiftForms(), 1
		do
			_,_,active = GetShapeshiftFormInfo(i);
			if(active ~= nil) then currentForm = i; end;
	end;
	
	chargesText = Pummeler_getChargesText{};
	charge = Pummeler_getChargeNumber(chargesText);
	if(Pummeler_Start_HasteBuff_Time ~= 0) then
		buffTimeLeft = 30 - math.floor(gameTime - Pummeler_Start_HasteBuff_Time);
	end;

	if(buffTimeLeft > 0 and (haste == true or (currentForm == bearForm and attackSpeed <= 1.7) or (currentForm == catForm and attackSpeed <= 0.7))) then
		--buffTimeLeft = 30 - math.floor(gameTime - Pummeler_Start_HasteBuff_Time);
		DEFAULT_CHAT_FRAME:AddMessage("Pummeler: "..itemLink.." Is active for "..buffTimeLeft.." more seconds!");
	elseif(buffTimeLeft < 0 and ((haste == false and numBuffs < 32) or (currentForm == bearForm and attackSpeed > 1.7) or (currentForm == catForm and attackSpeed > 0.7))) then	
		--if(numBuffs < 32 or (currentForm == bearForm and attackSpeed > 1.7) or (currentForm == catForm and attackSpeed > 0.7)) then
			if(weaponCd ~= 0) then
				timeLeft = weaponCd - math.floor(gameTime - weaponTimer);
				DEFAULT_CHAT_FRAME:AddMessage("Pummeler: "..itemLink.." on cooldown, "..timeLeft.." seconds left!");
			elseif(itemLink ~= nil and string.find(itemLink, pummelerWeapon) and charge > 0 and weaponCd == 0) then
				buffTimeLeft = math.floor(gameTime - Pummeler_Start_HasteBuff_Time);
				if(buffTimeLeft >= timeBetweenUses) then
					charge = charge - 1;
					UseInventoryItem(16);
					Pummeler_Start_HasteBuff_Time = gameTime;
					DEFAULT_CHAT_FRAME:AddMessage("Pummeler: Using "..itemLink..": "..charge.." charges left!");
				end;
			else
				bagPummeler, slotPummeler = Pummeler_isPummelerInBag("Manual Crowd Pummeler", false);
				if(bagPummeler ~= nil and slotPummeler ~= nil) then
					UseContainerItem(bagPummeler, slotPummeler, 1);
					DEFAULT_CHAT_FRAME:AddMessage("Pummeler: Equipping a "..pummelerWeapon..".");
				end;
			end;
		--end;
	 --elseif(haste == false and numBuffs >= 32) then
		 --DEFAULT_CHAT_FRAME:AddMessage("Pummeler: Cannot use "..itemLink.. " due to buff limit!");
	end;
end;

function Pummeler_availableCharges()
    createPummelerFrame();
    local bag_charges = 0;
	local equip_charges = 0;
    local pummeler_id = 9449;
    for i = 0, NUM_BAG_SLOTS do
        for z = 1, GetContainerNumSlots(i) do
            if GetContainerItemID(i, z) == pummeler_id then
                bag_charges = bag_charges + Pummeler_getChargeNumber(Pummeler_getChargesText{bag=i, slot=z});
            end;
        end;
    end;
    equip_charges = Pummeler_getChargeNumber(Pummeler_getChargesText{})
    return bag_charges + equip_charges, equip_charges;
end;


--function get_MCPTooltip()
    --SpellId=13494 for the haste buff
    --if not MCPTooltip then
        --CreateFrame("GameTooltip", "MCPTooltip", UIParent, "GameTooltipTemplate");
        --MCPTooltip:SetOwner(UIParent, "ANCHOR_NONE");
        --MCPTooltip:SetInventoryItem("player", 16, nil, nil);
    --end;
    --return MCPTooltipTextLeft11:GetText();
--end;


function Pummeler_getChargesText(options)
	pummelerTooltip:SetOwner( WorldFrame, "ANCHOR_NONE" );
	if(options.bag and options.slot) then 
		pummelerTooltip:SetBagItem(options.bag, options.slot);
	else
		pummelerTooltip:SetInventoryItem("player", 16);
	end;
	local charges = nil;
	local i = 1;
	while (true)
		do
			text = getglobal("pummelerTooltipTextLeft"..i):GetText();
			if(not text) then break;
			elseif(string.find(text, "Charge")) then
				charges = text;
				pummelerTooltip:Hide();
				return charges;
			end;
			i=i+1;
	end;
	pummelerTooltip:Hide();
	return charges;
end;

function Pummeler_getChargeNumber(chargesText)
	local charge = 0;
	if(chargesText ~= nil) then
		for i = 0, 3, 1
			do
				if(chargesText ~= nil and string.find(chargesText, i)) then 
					charge = i; break;
				end;
		end;
	end;
	return charge;
end;

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

function createPummelerFrame()
    if pummelerFrame == nil then
        pummelerFrame = CreateFrame("GameTooltip", "pummelerTooltip", nil, "GameTooltipTemplate");
    end;
end;

function Pummeler_isBuffNameActive(buff)
	local isActive = false;
	local index = -1;
	local i = 1;
	local numBuffs = nil;
	local g=UnitBuff;
	local textleft1 = nil;
	while not(g("player", i) == -1 or g("player", i) == nil)
		do
		pummelerTooltip:SetOwner( WorldFrame, "ANCHOR_NONE" );
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

function Pummeler_isPummelerInBag(itemName, threeChargesFlag)
    local itemBag, itemSlot = nil;
	local charges = nil;
    for bag = 0, 4, 1
        do 
            for slot = 1, GetContainerNumSlots(bag), 1
                do local name = GetContainerItemLink(bag,slot)
                if name and string.find(name, itemName) then
                    if string.find(name, itemName) then 
						charges = Pummeler_getChargeNumber(Pummeler_getChargesText{bag = bag, slot = slot});
						if(threeChargesFlag == true) then
							if(charges == 3) then
								itemBag = bag; itemSlot = slot; 
								return itemBag, itemSlot; 
							end;
						elseif(charges > 0) then
							itemBag = bag; itemSlot = slot; 
							return itemBag, itemSlot; 
						end;
					end;
                end;
            end;
        end;
    return itemBag, itemSlot;   
end;

-- Separate macro function to equip a fully charged Pummeler.
function Pummeler_equipFullyCharged()
	createPummelerFrame();
	local haste, hasteIndex, numBuffs = Pummeler_isBuffNameActive("Haste");
	local bagPummeler, slotPummeler = nil;
	local pummelerWeapon = "Manual Crowd Pummeler";
	local chargesText = nil;
	local charge = 0;
	local slotId = GetInventorySlotInfo("MAINHANDSLOT");
	local itemLink = GetInventoryItemLink("player", slotId);
	local buffTimeLeft = nil;
	local gameTime = GetTime();
	
	chargesText = Pummeler_getChargesText{};
	charge = Pummeler_getChargeNumber(chargesText);
	
	if(haste == true) then 
		buffTimeLeft = 30 - math.floor(gameTime - Pummeler_Start_HasteBuff_Time);
		DEFAULT_CHAT_FRAME:AddMessage("Pummeler: "..itemLink.." Is active for "..buffTimeLeft.." more seconds!");
	else
		if(charge == 3) then
			DEFAULT_CHAT_FRAME:AddMessage("Pummeler: You already have a fully charged "..pummelerWeapon.." equipped.");
		else
			bagPummeler, slotPummeler = Pummeler_isPummelerInBag("Manual Crowd Pummeler", true);
			if(bagPummeler ~= nil and slotPummeler ~= nil) then
				UseContainerItem(bagPummeler, slotPummeler, 1);
				DEFAULT_CHAT_FRAME:AddMessage("Pummeler: Equipping a fully charged "..pummelerWeapon..".");
			else
				DEFAULT_CHAT_FRAME:AddMessage("Pummeler: No fully charged "..pummelerWeapon.." found.");
			end;
		end;
	end;
end;


function PlayerHasBuff(spell_id)
    for i = 1, 40 do
        local name, icon, count, debuffType, duration, expirationTime, source, isStealable,
  nameplateShowPersonal, spellId = UnitBuff("player", i)
        if spellId == nil then
            return false
        elseif spellId == spell_id then
            return true
        end
    end
    return false
end


function GetNextSpell()
    local next_spell;
    local autoattacking = IsCurrentSpell(6603);
    local cur_energy = UnitPower("player", 3);
    local cur_mana = UnitPower("player", 0);
    local combo_pts = GetComboPoints("player", "target");
    local clearcasting = PlayerHasBuff(16870);
    local gcd = GetSpellCooldown(9832); -- shred spellID
    local _, in_cat_form, _, _ = GetShapeshiftFormInfo(3);

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
