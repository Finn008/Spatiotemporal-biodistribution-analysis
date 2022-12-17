function [PlaqueData]=finalEvaluationSub6(PlaqueData)
% Sub1: quadrants
% Sub2: lateral
% Sub3: above
% Sub4: below
% Sub5: blood
PoolSubRegions={[1;2],[2],[3],[4],[1;2;3;4],[5]};
PlaqueNumber=size(PlaqueData,1);
Wave1=repmat({table},[2,size(PoolSubRegions,2)]);
PlaqueData2=table(repmat({Wave1},[PlaqueNumber,1]),'VariableNames',{'Vector'});

for Pl=1:PlaqueNumber
    for Type=1:2
%         if size(PlaqueData,2)==1 % no a-data available
%             continue;
%         end
        if Type==1
            SubRegionNumber=5;
        else
            SubRegionNumber=6;
        end
        if isempty(PlaqueData.Vector{Pl}{Type,1})
            continue;
        end
        for Sub=1:SubRegionNumber
            Wave1=PlaqueData.Vector{Pl}(Type,PoolSubRegions{Sub}).';
            Wave1=fuseTable_5(Wave1);
            for Mod=Wave1.Properties.VariableNames
                Ind=zeros(0,1);
                for m=1:size(Wave1,1)
                    Ind(m,1)=isempty(Wave1{m,Mod}{1});
                end
                Ind=find(Ind==0);
                Original=Wave1{Ind(1),Mod}{1};
                Wave2=Original{:,:};
                for m=2:size(Ind,1)
                    Wave2=Wave2+Wave1{Ind(m,1),Mod}{1}{:,:};
                end
                Original{:,:}=Wave2;
                PlaqueData2.Vector{Pl}{Type,Sub}{1,Mod}={Original};
                clear Wave2;
            end
            PlaqueData2.Vector{Pl}{Type,Sub}{1,'Distance'}=PlaqueData.Vector{1}{1,1}{1,'Distance'};
        end
    end
end
PlaqueData=PlaqueData2;