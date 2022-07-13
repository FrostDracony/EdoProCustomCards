--Frightfur Guardian
--Frostdracony

--Variables
local s,id=GetID()
s.listed_series={0xad}
s.material_setcode={0xad}

--Functions
function c501967301.initial_effect(c)
    --Fusion summoning
    c:EnableReviveLimit()
	Fusion.AddProcMix(c,
	true,
	true,
	aux.FilterBoolFunctionEx(Card.IsSetCard,0xad),
	aux.FilterBoolFunctionEx(Card.IsSetCard,0xa9),
	aux.FilterBoolFunctionEx(Card.IsSetCard,0xc3))
	--Cannot be targeted by opponent's card effects
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e0:SetRange(LOCATION_MZONE)
	e0:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e0:SetTargetRange(LOCATION_MZONE,0)
	e0:SetTarget(aux.TargetBoolFunction(s.targetBoolFilter))
	e0:SetValue(aux.tgoval)
	c:RegisterEffect(e0)
	--Cannot be destroyed by opponent's card effects
	local e1=e0:Clone()
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetValue(s.indval)
	c:RegisterEffect(e1)
	--Special summon from the Graveyard
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
    --Fusion summon 1 fusion monster
	local params = {nil, Card.IsAbleToRemove,s.fextra,Fusion.BanishMaterial}
    local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.fscon)
	e3:SetTarget(Fusion.SummonEffTG(table.unpack(params)))
	e3:SetOperation(Fusion.SummonEffOP(table.unpack(params)))
	c:RegisterEffect(e3)
end

--Filters for fusion summon of this card
function s.fextra(e,tp,mg)
	if not Duel.IsPlayerAffectedByEffect(tp,69832741) then
		return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToRemove),tp,LOCATION_GRAVE,0,nil)
	end
	return nil
end


--Other Filters
function s.indval(e,re,tp)
	return tp~=e:GetHandlerPlayer()
end

function s.targetBoolFilter(c)
	return c:IsSetCard(0xad) and not c:IsCode(id)
end

---------------------------------[[[[[[Second Effect]]]]]]---------------------------------
--//Special Summon a monster from the Graveyard
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		if tc:IsSetCard(0xad) then
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end

---------------------------------[[[[[[Third Effect]]]]]]---------------------------------
--//Fusion Summon a monster

--Filters
function s.sfilter(c,tp)
	return (c:IsSummonType(SUMMON_TYPE_NORMAL) or c:IsSummonType(SUMMON_TYPE_FLIP) or c:IsSummonType(SUMMON_TYPE_SPECIAL) or c:IsSummonType(SUMMON_TYPE_GEMINI)) and not c:IsCode(id)
end

--Condition
function s.fscon(e,tp,eg,ep,ev,re,r,rp)
	return eg and eg:IsExists(s.sfilter,1,nil,tp)
end