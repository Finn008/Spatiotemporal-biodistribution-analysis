function [PlaqueListSingle]=dystrophyDetection_GatherData_1(MouseInfo,SingleStacks,DataAssignment)


PlaqueListSingle=table;
% unpack SingleStacks
for Row=1:size(SingleStacks,1)
    try
        DistRelation=SingleStacks.RatioResults{Row,1}.DistRelation.Data(:,1);
    catch
        continue;
    end
    
    PlaqueData=SingleStacks.PlaqueData{Row,1};
    if isempty(PlaqueData)
        PlaqueData=table;PlaqueData.Radius=0;PlaqueData.BorderTouch=0;PlaqueData.DistanceCenter2TopBottom=999;PlaqueData.UmCenter(1,1)={[0;0;0]};
        DistRelation{1}.Distance=0;
    end
    
    
    % format adjustment from old storage format (Plaque data was stored in Column 'Data' as a subtable
    PlaqueData.DistRelation(:,1)=DistRelation;
    if strfind1(PlaqueData.Properties.VariableNames.','Radius')==0
        for Pl=1:size(PlaqueData,1)
            PlaqueData(Pl,PlaqueData.Data{Pl}.Properties.VariableNames)=PlaqueData.Data{Pl}(1,PlaqueData.Data{Pl}.Properties.VariableNames);
        end
        PlaqueData(:,'Data')=[];
    end
    
    if size(PlaqueData.DistanceCenter2TopBottom,2)==1
        PlaqueData.DistanceCenter2TopBottom(:,2)=PlaqueData.DistanceCenter2TopBottom(:,1);
    end
    PlaqueData.SliceThickness(:,1)=SingleStacks.SliceThickness(Row);
%     PlaqueData.Um(:,1)=SingleStacks.SliceThickness(Row);
    PlaqueData.Zum(:,1)=SingleStacks.Um{Row}(3);
%     keyboard;
    
    
    for Pl=1:size(PlaqueData,1)
        Ind=size(PlaqueListSingle,1)+1;
        PlaqueListSingle(Ind,SingleStacks.Properties.VariableNames)=SingleStacks(Row,SingleStacks.Properties.VariableNames);
        PlaqueListSingle.Pl(Ind,1)=Pl;
        PlaqueListSingle(Ind,PlaqueData.Properties.VariableNames)=PlaqueData(Pl,PlaqueData.Properties.VariableNames);
    end
    
end
PlaqueListSingle.Properties.VariableNames{strfind1(PlaqueListSingle.Properties.VariableNames.','Radius',1)}='RadiusFit1';
try; PlaqueListSingle.Age(PlaqueListSingle.Age>999)=999; catch; PlaqueListSingle.Age(:,1)=999; end;
try; PlaqueListSingle.Time2Treatment(PlaqueListSingle.Time2Treatment>999)=999; catch; PlaqueListSingle.Time2Treatment(:,1)=999; end;
PlaqueListSingle.BorderTouch(PlaqueListSingle.BorderTouch==1&min(PlaqueListSingle.DistanceCenter2TopBottom,[],2)>2)=0;
PlaqueListSingle=PlaqueListSingle(:,{'MouseId';'TreatmentType';'Roi';'Pl';'Res';'Age';'Time2Treatment';'UmCenter';'DystrophyDetection';'Filename';'DistanceCenter2TopBottom';'BorderTouch';'RadiusFit1';'SliceThickness';'Zum';'DistRelation'});


for Pl=1:size(PlaqueListSingle,1)
    DistRelation=PlaqueListSingle.DistRelation{Pl,1};
    Distance=DistRelation.Distance;
    Wave1=DistRelation.Volume;
    Volume=nan(256,1);
    Volume(Distance+50,1)=Wave1;
    Res3D=prod(PlaqueListSingle.Res{Pl,1});
    Modifications=DistRelation.Properties.VariableNames.';
    RawData2Add=table;
    for ModN=1:size(Modifications,1)
        Data=nan(256,1);
        Mod=Modifications{ModN};
        Wave1=DistRelation{:,Mod};
        Data(Distance+50,1)=Wave1;
        if strfind1({'Distance'},Mod,1)
            continue;
        elseif strfind1({'Volume'},Mod,1)
            Data=Data*Res3D;
            RawData2Add(1,Mod)={Data.'};
        elseif strfind1({'MetBlue';'Bace1';'Iba1';'Lamp1'},Mod,1)
            Data=Data./Volume;
            Data=Data/nanmean(Data(60:80));
            RawData2Add(1,Mod)={Data.'};
        elseif strfind1({'Bace1Corona';'Lamp1Corona';'Microglia';'MicrogliaSoma';'MicrogliaFibers'},Mod,1)
            Data=Data./Volume;
            RawData2Add(1,Mod)={Data.'};
        else
            keyboard;
        end
        
    end
%     PlaqueData=PlaqueData(:,{'MouseId','RoiId','Pl','Time','Radius','RadiusFit1','BorderTouch','UmCenter','Age','Growth','TreatmentType','Time2Treatment','Mouse','Filenames'});
    PlaqueListSingle(Pl,RawData2Add.Properties.VariableNames)=RawData2Add(1,RawData2Add.Properties.VariableNames);
end



% VariableNames=PlaqueListSingle.Properties.VariableNames;






