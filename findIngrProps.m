function [out]=findIngrProps(chosen,ingredients)

[Lager,ind]=findStrValue(ingredients.Zutaten,chosen,ingredients.Lager);

Einheit=findStrValue(ingredients.Zutaten,chosen,ingredients.Einheit);
[Laden,Einkaufsliste.order]=findStrValue(location2.Produkt,Einkaufsliste.Zutaten,location2.Laden);
Preis=zeros(size(ind,1),1);
for m=1:size(ind,1)
    try
        [col]=findInd((ingredients.Properties.VariableNames.'),Einkaufsliste.Laden{m,1});
        Preis(m,1)=ingredients{ind(m),col};
    end
end
