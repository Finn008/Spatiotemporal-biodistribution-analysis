function [PlaqueListSingle,DataArrays]=dystrophyDetection_GatherData_3(MouseInfo,SingleStacks,DataAssignment)

DataArrays=struct;
PlaqueListSingle=table;
% unpack SingleStacks
for Row=1:size(SingleStacks,1)
    
    if strfind1(SingleStacks.Properties.VariableNames.','PlaqueData')==0 || isempty(SingleStacks.PlaqueData{Row,1}) % to accomodate data from control mice without plaques
        PlaqueData=table;PlaqueData.RadiusMaxIntSum=-1;
    else
        PlaqueData=SingleStacks.PlaqueData{Row,1};
    end
    try
        PlaqueData.PlaqueRadius=PlaqueData.RadiusMaxIntSum;
    catch
        continue;
    end
    PlaqueData.PlId=(1:size(PlaqueData,1)).';
    Wave1={'PlId';'PlaqueRadius';'PixCenter';'UmCenter';'DistanceCenter2Border';'BorderTouch';'Percentile';'DistanceDistribution';'InterPlaqueDistance'};
    PlaqueData=PlaqueData(:,ismember(PlaqueData.Properties.VariableNames.',Wave1));
    
    Wave1=SingleStacks(Row,{'MouseId';'Filename'});
    PlaqueData(:,Wave1.Properties.VariableNames)=repmat(Wave1,[size(PlaqueData,1),1]);
    
    PlaqueListSingle(size(PlaqueListSingle,1)+1:size(PlaqueListSingle,1)+size(PlaqueData,1),PlaqueData.Properties.VariableNames)=PlaqueData;
    DistanceRelation=SingleStacks.DistanceRelation{Row,1};
    for iAr=1:size(DistanceRelation,1)
        Data2add=DistanceRelation{iAr,2};
        Wave2=SingleStacks(Row,{'MouseId';'Filename';'Res3D'});
        Data2add(:,Wave2.Properties.VariableNames)=repmat(Wave2,[size(Data2add,1),1]);
        if isfield(DataArrays,DistanceRelation{iAr,1})==0 %         if Row==1
            DataArrays.(DistanceRelation{iAr,1})=Data2add;
        else
            Data=DataArrays.(DistanceRelation{iAr,1});
            Wave2=Data.Properties.VariableNames(ismember(Data.Properties.VariableNames,Data2add.Properties.VariableNames)==0); % find columns that are present in Data but not in Data2add
            if isempty(Wave2)==0; Data2add{:,Wave2}=NaN; end; % add missing columns
            Wave2=Data2add.Properties.VariableNames(ismember(Data2add.Properties.VariableNames,Data.Properties.VariableNames)==0); % find columns that are present in Data2add but not in Data
            if isempty(Wave2)==0; Data{:,Wave2}=NaN; end; % add missing columns
            Data=[Data;Data2add];
            DataArrays.(DistanceRelation{iAr,1})=Data;
        end
    end
end

% BorderTouch: only positive if plaques touch border laterally, or less than 2µm from center to top or bottom
for Pl=1:size(PlaqueListSingle,1)
    if PlaqueListSingle.PlaqueRadius(Pl)==-1; continue; end;
    DistanceCenter2Border=PlaqueListSingle.DistanceCenter2Border{Pl,1};
    if PlaqueListSingle.BorderTouch(Pl,1)==1 && min(min(DistanceCenter2Border(1:2,:)))>PlaqueListSingle.PlaqueRadius(Pl,1)
        PlaqueListSingle.BorderTouch(Pl,1)=0;
    end
    if isempty(DistanceCenter2Border)==0 && min(DistanceCenter2Border(3,:))<2 % empty to jump over datasets that are free of plaques
        PlaqueListSingle.BorderTouch(Pl,1)=1;
    end
end


for iMod=fieldnames(DataArrays).'
    Data=DataArrays.(iMod{1});
    Data(Data.Outside==1,:)=[];
        
    for Col=Data.Properties.VariableNames
        if strfind1({'Distance';'Volume';'DistInOut';'Membership';'Outside';'MouseId';'Filename';'Res3D'},Col,1)
            continue;
        elseif strfind1({'MetBlue';'Bace1';'Iba1';'Lamp1';'APP';'Vglut1';'NAB228';'GFPM';'Ab126468';'Ab22C11';'RBB';'Ab4G8';'Ubiquitin'},Col,1)
            Data{:,Col}=Data{:,Col}./Data.Volume;
        elseif strfind1({'Bace1Corona';'Lamp1Corona';'Microglia';'MicrogliaSoma';'MicrogliaFibers';'APPCorona';'SynucleinFibrils';'UbiquitinDystrophies'},Col,1)
            Data{:,Col}=Data{:,Col}./Data.Volume*100;
        elseif strfind1({'Vglut1DystrophiesRadius';'Vglut1DystrophiesDiameter';'AxonDiameter';'Ab22C11_Diameter'},Col,1)
            continue;
        else
            keyboard;
        end
    end
    Data.VolumeUm3=Data.Volume.*Data.Res3D;
    Data.Distance=int16(Data.DistInOut)-50;
    Data(:,{'Outside';'Volume';'DistInOut';'DistInOut';'Res3D'})=[];
    DataArrays.(iMod{1})=Data;
end

for MouseId=MouseInfo.MouseId.'
    Wave1=find(DataArrays.Standard.MouseId==MouseId);
    [Wave2,Wave3,Wave4]=unique(DataArrays.Standard.Filename(Wave1));
    Wave5=(1:size(Wave2,1)).';
    DataArrays.Standard.RoiId(Wave1,1)=Wave5(Wave4);
end

