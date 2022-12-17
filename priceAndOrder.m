function [purchaseList]=priceAndOrder(purchaseList,location)
dbstop if error;
itemNumber=size(purchaseList,1);

% replace emptyshop (ingredients with unkown shop) with unknown
purchaseList.shop(cellfun(@isempty, purchaseList.shop))={'unknown'};

allShops=unique(purchaseList.shop);
for m=1:itemNumber
    try
        [col]=findInd((purchaseList.Properties.VariableNames.'),purchaseList.shop{m});
        purchaseList.price(m,1)=purchaseList.(col)(m);
    end
    
    try
        purchaseList.order(m)=findInd(purchaseList.shop{m},allShops)*10000;
        purchaseList.order(m)=purchaseList.order(m)+find(strcmp(location.item,purchaseList.item{m})==1 & strcmp(location.shop,purchaseList.shop{m})==1);
    end
end
