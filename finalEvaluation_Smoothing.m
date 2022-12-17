function [TimeDistTable]=finalEvaluation_Smoothing(TimeDistTable,MouseInfo)


%% Smooth5VolWeight: Dystrophies, AutofluoSurface, Bouton1Number
% Wave1=strfind1(TimeDistTable.Mod,{'Dystrophies1';'Dystrophies2';'Autofluo1';'Boutons1Number'});
% Data2Process=TimeDistTable(Wave1,:);
% Data2Process=TimeDistTable(strcmp(TimeDistTable.Calc,'Raw'),:);

for m=1:size(TimeDistTable)
    if strcmp(TimeDistTable.Calc{m},'Raw')~=1
        continue;
    end
    Mouse=TimeDistTable.Mouse(m);
    Roi=TimeDistTable.Roi(m);
    Sub=TimeDistTable.SubPool(m);
    Mod=TimeDistTable.Mod{m};
    Pl=TimeDistTable.Pl(m);
    Calc=table;
    if strfind1({'Dystrophies1';'Dystrophies2';'Autofluo1';'Boutons1Number'},Mod)
        Calc.Version(size(Calc,1)+1,1)={'Smooth5VolWeight'};
        Wave1=struct;
        if strfind1({'Boutons1Number'},Mod,1)
            Wave1.Window=5;
            Wave1.Force=4;
        else % strfind1({'Dystrophies1';'Dystrophies2';'Autofluo1'},Mod,1)
            Wave1.Window=3;
            Wave1.Force=1;
        end
        Calc.Spec(size(Calc,1),1)={Wave1};
    end
    
    if strfind1({'Plaque';'VglutGreen'},Mod)
        Calc.Version(size(Calc,1)+1,1)={'NormTp'};
    end
    
    for iCalc=1:size(Calc,1)
        Data=TimeDistTable.Data{m};
        if strfind1({'Dystrophies1';'Autofluo1';'Plaque'},Mod)
            Volume='Volume1';
        elseif strfind1({'Dystrophies2';'Boutons1Number';'VglutGreen'},Mod)
            Volume='Volume2';
        else
            keyboard;
        end
        Volume=findTDTind(TimeDistTable,Mouse,Roi,Sub,Volume,Pl,'Raw');
        Volume=TimeDistTable.Data{Volume};
        NonNanTp=find(Volume{1,:}==0).';
        
        if strcmp(Calc{iCalc,1},'NormTp')
            for Time=NonNanTp.'
                [Wave2]=Data{:,Time}/max(Data{:,Time})*100;
                Data{:,Time}=Wave2;
            end
        end
        
        if strcmp(Calc{iCalc,1},'Smooth5VolWeight')
            Wave1=Calc.Spec{iCalc};
            for Time=NonNanTp.'
                [Wave2]=weightedMovingAverage(Data{:,Time},Wave1.Window,Volume{:,Time},5,Wave1.Force);
                Data{:,Time}=Wave2;
            end
        end
        Ind=findTDTind(TimeDistTable,Mouse,Roi,Sub,Mod,Pl,Calc.Version{iCalc});
        TimeDistTable(Ind,{'Mouse';'Roi';'Sub';'Mod';'Pl';'Calc';'Data'})={Mouse,Roi,Sub,{Mod},Pl,Calc.Version(iCalc),{Data}};
    end
    
    
end

keyboard; % Plaque: NormTp


