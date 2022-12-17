function [PlaqueData]=finalEvaluationSub5(PlaqueData,FileTypes)

PlaqueNumber=size(PlaqueData,1);
% TypeNumber=2;%size(PlaqueData.Vector,2);

for Type=1:2
    if Type==1
        SubRegionNumber=5;
    else
        SubRegionNumber=6;
    end
    
    for Pl=1:PlaqueNumber
        for Sub=1:SubRegionNumber
            Data=PlaqueData.Vector{Pl}{Type,Sub};
            try; Data('Smooth',:)=[]; end;
            Co=struct;
            Modifications=Data.Properties.VariableNames.';
            for Mod=Modifications.'
                PlaqueData.Vector{Pl}{Type,Sub}{'Smooth',Mod}={table};
                CalcTypes=cell(0,0);
                ModData=Data(:,Mod);
                NonNanTp=nansum(ModData{'Original',1}{1}{:,:},1);
                NonNanTp=find(NonNanTp~=0).';
                
                % smooth with a weighted average of 5µm
                if strfind1({'Boutons1Number';'Autofluo';'Plaque';'AutofluoSurface';'AutofluoSurface2';'Dystrophies2Surf';'Dystrophies1Surf';'Dystrophies2D'},Mod,1)
                    if strfind1({'Boutons1Number'},Mod,1)
                        Window=5;
                        Force=4;
                    elseif strfind1({'Plaque';'Autofluo';'AutofluoSurface';'AutofluoSurface2';'Dystrophies2Surf';'Dystrophies1Surf';'Dystrophies2D'},Mod,1)
                        Window=3;
                        Force=1;
                    end
                    Smooth5VolWeight=ModData;
                    for Calc={'Original','Density','NormTotal','NormTp','Vol'} % Data.Properties.RowNames.'
                        if strfind1({'Dystrophies2D'},Mod,1)
                            Volume=PlaqueData.Vector{Pl}{Type,Sub}{'Specific',Mod}{1}.Volume{:,:};
                        else
                            Volume=PlaqueData.Vector{Pl}{Type,Sub}.Volume{'Original'}{:,:};
                        end
                        if isempty(Smooth5VolWeight{Calc,1}{1})==0
                            
                            Wave1=Smooth5VolWeight{Calc,1}{1}{:,:};
                            for Time=NonNanTp.'
                                [Wave1(:,Time)]=weightedMovingAverage(Wave1(:,Time),5,Volume(:,Time),Window,Force);
                            end
                            Smooth5VolWeight{Calc,1}{1}{:,:}=Wave1;
                        end
                    end
                    CalcTypes=[CalcTypes;{'Smooth5VolWeight'}];
                end
                
                
                for Calc=CalcTypes.'
                    Wave1=eval(Calc{1});
                    RowNames=Wave1.Properties.RowNames;
                    PlaqueData.Vector{Pl}{Type,Sub}{'Smooth',Mod}{1}(RowNames,Calc{1})=Wave1;
                end
            end
        end
    end
end