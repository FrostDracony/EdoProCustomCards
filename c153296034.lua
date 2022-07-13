--Frightfur Maker
--Frostdracony

--Variables
local s,id=GetID()
s.listed_series={0xad}
s.material_setcode={0xad}

--Functions
function c153296034.initial_effect(c)
    --Fusion summoning
    c:EnableReviveLimit()
    Fusion.AddProcMixRep(c,true,true,s.mfilter,2,99)
    --Shuffle back into the deck
    local e=Effect.CreateEffect(c)
	e:SetDescription(aux.Stringid(id,2))
	e:SetCategory(CATEGORY_TODECK)
	e:SetProperty(EFFECT_FLAG_DELAY)
	e:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e:SetCode(EVENT_SPSUMMON_SUCCESS)
	e:SetCondition(s.shufflecon)
	e:SetTarget(s.shuffletg)
	e:SetOperation(s.shuffleop)
	c:RegisterEffect(e)
	--Negate activations
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.negcon)
	e1:SetCost(s.negcost)
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1)
	--Sends spells and traps to the grave
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e2:SetTarget(s.gytg)
	e2:SetOperation(s.gyop)
	c:RegisterEffect(e2)
end


---------------------------------[[[[[[Third Effect]]]]]]---------------------------------
--//Sending spells and trap cards to the graveyard

function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,LOCATION_SZONE,LOCATION_SZONE,e:GetHandler())
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,#g,0,0)
end

function s.gyop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,LOCATION_SZONE,LOCATION_SZONE,e:GetHandler())
	Duel.SendtoGrave(g,REASON_EFFECT)

	if e:GetHandler():GetMaterialCount()>=5 and #g>0 then 
		local g2=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,0,LOCATION_ONFIELD,1,#g,nil)
		if #g2>0 then
			Duel.SendtoGrave(g2,REASON_EFFECT)
		end
	end
end

---------------------------------[[[[[[Second Effect]]]]]]---------------------------------
--//Negating cards

--Cost Filters
function s.negFrightfurfilter(c)
	return c:IsSetCard(0xad) and c:IsAbleToRemoveAsCost()
end

function s.negHandfilter(c)
	return (c:IsSetCard(0xa9) or c:IsSetCard(0xc3) or c:IsCode(70245411)) and c:IsAbleToRemoveAsCost()
end

--Cost
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil) end

	--local edFright=Duel.GetMatchingGroup(s.negFrightfurfilter,tp,LOCATION_EXTRA,0,nil,POS_FACEDOWN)
	--local handCards=Duel.GetMatchingGroup(s.negHandfilter,tp,LOCATION_HAND,0,nil)

	local edFright=Duel.SelectMatchingCard(tp,s.negFrightfurfilter,tp,LOCATION_EXTRA,0,1,1, false, c)
	local handCards=Duel.SelectMatchingCard(tp,s.negHandfilter,tp,LOCATION_HAND,0,1,1, false, c)

	local mergedGroup=edFright:Merge(handCards)

	Duel.Remove(mergedGroup,POS_FACEUP,REASON_COST)
end

--Condition
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c==nil then return true end

	local tp=e:GetHandlerPlayer()
	local edFright=Duel.GetMatchingGroup(s.negFrightfurfilter,tp,LOCATION_EXTRA,0,c,POS_FACEDOWN)
	local handCards=Duel.GetMatchingGroup(s.negHandfilter,tp,LOCATION_HAND,0,c,POS_FACEDOWN)

	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev) and edFright:GetCount()>0 and handCards:GetCount()>0 
end

--Target
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end

--Operation
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
		if e:GetHandler():GetMaterialCount()>=3 then 
			Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
		end
	end
end


---------------------------------[[[[[[First Effect]]]]]]---------------------------------
--//Shuffling back cards

--Filter to check the fusion materials
function s.mfilter(c,fc,sumtype,tp)
    return c:IsSetCard(0xad,fc,sumtype,tp) and c:IsType(TYPE_FUSION,fc,sumtype,tp)
end

--Condition for the effect to happen
function s.shufflecon(e,tp,eg,ep,ev,re,r,rp)
	Debug.Message("Condition is happening")
	return (e:GetHandler():GetSummonType()&SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION
end

--Filter for a specific set of archetype(s)
function s.archetypefilter(c,fc,sumtype,tp)
	return (c:IsSetCard(0xad) or c:IsSetCard(0xa9) or c:IsSetCard(0xc3) or c:IsCode(70245411)) and c:IsAbleToDeck()
end

--Function for target
function s.shuffletg(e,tp,eg,ep,ev,re,r,rp,chk)
	Debug.Message("Target is happening")
	if chk==0 then return true end

	local g=Duel.GetMatchingGroup(s.archetypefilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_GRAVE+LOCATION_REMOVED,nil)
	
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
end

--Function for operation
function s.shuffleop(e,tp,eg,ep,ev,re,r,rp)
	Debug.Message("Shuffle is happening")
	local g=Duel.GetMatchingGroup(s.archetypefilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_GRAVE+LOCATION_REMOVED,nil)
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
