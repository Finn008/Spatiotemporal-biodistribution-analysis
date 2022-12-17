function [PlaqueData]=finalEvaluationSub7(PlaqueData)

MaxDistance=50+51;

for Pl=1:size(PlaqueData,1)
    Timepoints=size(PlaqueData.Vector{1}{1}{1,1}{1},2);
%     Container=table;
    
    % calculate BoutonNumber decline
    Bouton1Number=PlaqueData.Vector{Pl}{2,2}{'Smooth','Boutons1Number'}{1}.Smooth5VolWeight{'Density'};
    
    clear BoutonBorder;
    Smooth=table([1;10;1],{[];[];[]},'VariableNames',{'Power';'Robust'});
    for Time=1:Timepoints
        [Wave1,Out]=ableitung_2(Bouton1Number{51:100,Time},[],Smooth);
        Wave2=find(Wave1(:,2)<0.1);
% %        NormDensity=max(Bouton1Number{1:100,Time});
% %        Wave1=find(Bouton1Number{:,Time}>NormDensity*0.8);

       BoutonBorder(Time,1)=Wave2(1);
    end
    PlaqueData.Single{Pl,1}.BoutonBorder=BoutonBorder;
    
    % calculate Dystrophy Extension
    Volume=PlaqueData.Vector{Pl}{1,2}{'Original','Volume'}{1};
    Dystrophies=PlaqueData.Vector{Pl}{1,2}{'Density','Dystrophies1Surf'}{1};
    clear DystrophyExt;
    for Time=1:Timepoints
        Table=table;
        Table.Volume=Volume{:,Time};
        Table.DystPerc=Dystrophies{:,Time};
        Table.DystVol=Table.Volume.*Table.DystPerc/100;
        for m=1:size(Table,1)
            Table.CumVol(m,1)=nansum(Table.Volume(1:m,1));
        end
        DystVol=nansum(Table.DystVol);
        if DystVol==0
            DystrophyExt(Time,1)=NaN;
        else
            Wave1=find(Table.CumVol<DystVol);
            Wave1=Wave1(end);
            DystrophyExt(Time,1)=Wave1+(DystVol-Table.CumVol(Wave1))/(Table.CumVol(Wave1+1)-Table.CumVol(Wave1))-50;
        end
    end
    PlaqueData.Single{Pl,1}.DystrophyExt=DystrophyExt;
end
