-- Store Service
-- Crazyman32
-- December 1, 2015

-- Updated: December 31, 2016

--[[
	
	Server:
		
		StoreService:HasPurchased(player, productId)
		
		StoreService.PromptPurchaseFinished(player, receiptInfo)
	
	
	Client:
		
		StoreService:HasPurchased(productId)
		StoreService:GetNumberPurchased(productId)
	
		StoreService.PromptPurchaseFinished(receiptInfo)
	
--]]



local StoreService = {
	Client = {
		Events = {
			"PromptPurchaseFinished";
		};
	};
	Events = {
		"PromptPurchaseFinished";
	};
}

local services
local marketplaceService = game:GetService("MarketplaceService")

local dataStoreScope = "PlayerReceipts"


function IncrementPurchase(player, productId)
	productId = tostring(productId)
	local productPurchases = services.DataService:Get(player, "ProductPurchases")
	if (not productPurchases) then
		productPurchases = {}
		services.DataService:Set(player, "ProductPurchases", productPurchases)
	end
	local n = productPurchases[productId]
	productPurchases[productId] = (n and (n + 1) or 1)
	services.DataService:Save(player, "ProductPurchases")
end


function ProcessReceipt(receiptInfo)
	
	--[[
		ReceiptInfo:
			PlayerId               [Number]
			PlaceIdWherePurchased  [Number]
			PurchaseId             [String]
			ProductId              [Number]
			CurrencyType           [CurrencyType Enum]
			CurrencySpent          [Number]
	--]]
	
	local player = game.Players:GetPlayerByUserId(receiptInfo.PlayerId)
	
	local dataStoreName = tostring(receiptInfo.PlayerId)
	local key = tostring(receiptInfo.PurchaseId)
	
	-- Check if unique purchase was already completed:
	local alreadyPurchased = services.DataService:GetCustom(dataStoreName, dataStoreScope, key)
	
	if (not alreadyPurchased) then
		-- Mark as purchased:
		services.DataService:SetCustom(dataStoreName, dataStoreScope, key, true)
		services.DataService:SaveCustom(dataStoreName, dataStoreScope, key)
	end
	
	if (player) then
		IncrementPurchase(player, receiptInfo.ProductId)
		StoreService.PromptPurchaseFinished:Fire(player, receiptInfo)
		StoreService.Client.Events.PromptPurchaseFinished:FireClient(player, receiptInfo)
	end
	
	return Enum.ProductPurchaseDecision.PurchaseGranted
	
end


function StoreService:HasPurchased(player, productId)
	local productPurchases = services.DataService:Get(player, "ProductPurchases")
	return (productPurchases and productPurchases[tostring(productId)] ~= nil)
end


-- Get the number of productId's purchased:
function StoreService.Client:GetNumberPurchased(player, productId)
	local n = 0
	local productPurchases = services.DataService:Get(player, "ProductPurchases")
	if (productPurchases) then
		n = (productPurchases[tostring(productId)] or 0)
	end
	return n
end


-- Whether or not the productId has been purchased before:
function StoreService.Client:HasPurchased(player, productId)
	return StoreService:HasPurchased(player, productId)
end


function StoreService:Start()
	marketplaceService.ProcessReceipt = ProcessReceipt
end


function StoreService:Init(otherServices)
	services = otherServices
end


return StoreService