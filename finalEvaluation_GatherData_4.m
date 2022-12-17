function [PlaqueArray1,VglutArray1,VglutArray2,BoutonList2,PlaqueHistograms,SingleStacks]=finalEvaluation_GatherData_4(MouseInfo,SingleStacks,PlaqueListSingle)
keyboard; % try to use the GatherData function in dystrophyDetection
Timer=datenum(now);
pause(1); cprintf('text','GatherData: ');
PlaqueArray1=table;
VglutArray1=table;
VglutArray2=table;
% VglutArray3=table;
BoutonList2=table;
PlaqueHistograms=table;

ColNames2add={'MouseId';'RoiId';'Age';'Time2Treatment';'Res3D'};

SingleStacks(SingleStacks.Res3D==0,:)=[]; % remove all files that no data is available
% among VGLUT1Venus stacks remove those that have been made before
% Wave1=find(Wave1==1 & datenum(SingleStacks.Date,'yyyy.mm.dd HH:MM')<datenum('2017.10.18 00:01','yyyy.mm.dd HH:MM'));

% remove all Vglut1 files that donot contain Step#4
Wave1=find(strfind1(SingleStacks.BoutonDetect,'Do',[],[],1)==1 & strfind1(SingleStacks.BoutonDetect,'Step#4',[],[],1)~=1);
for m=1:size(Wave1,1)
%     keyboard;
    delete(getPathRaw([SingleStacks.Filename{Wave1(m)},'_RatioResults.mat']))
end
SingleStacks(Wave1,:)=[];

% % % Wave1=find(Wave1==1 & datenum(SingleStacks.Date,'yyyy.mm.dd HH:MM')<datenum('2017.10.18 00:01','yyyy.mm.dd HH:MM'));
% % % SingleStacks(Wave1,:)=[];
for iStack=1:size(SingleStacks,1)
    if isempty(SingleStacks.Array1{iStack})
        SingleStacks.StatusRatioResults(iStack,1)=99;
        continue;
    else
        SingleStacks.StatusRatioResults(iStack,1)=10000;
    end
    % determine Time2Treatment
    Mouse=find(MouseInfo.MouseId==SingleStacks.MouseId(iStack));
    Roi=find(MouseInfo.RoiInfo{Mouse}.Roi==SingleStacks.RoiId(iStack));
    RoiInfo=MouseInfo.RoiInfo{Mouse}.Files{Roi};
    Wave1=strfind1(RoiInfo.Filenames,SingleStacks.Filename{iStack});
    Age=RoiInfo.Age(Wave1(1));
    SingleStacks.Age(iStack,1)=Age;
    SingleStacks.Time2Treatment(iStack,1)=Age-MouseInfo.StartTreatmentNum(Mouse);
    
    SingleStacks.Res3D(iStack)=prod(SingleStacks.Res{iStack,1});
    ColValues2add=SingleStacks{iStack,ColNames2add};
    if strcmp(SingleStacks.Filename{iStack}(end),'b')
        Data2add=SingleStacks.Array1{iStack};
        Wave1=array2table(repmat(ColValues2add,[size(Data2add,1),1]),'VariableNames',ColNames2add); Data2add=[Data2add,Wave1];
        PlaqueArray1=[PlaqueArray1;Data2add];
        Data2add=SingleStacks.Histograms{iStack}.DistanceReal2;
%         keyboard; % or if no pixels at distance 50 >=0µm
        if istable(Data2add)==0 || Data2add.Volume(Data2add.Distance==50)==0
            SingleStacks.StatusDistanceReal(iStack,1)=99;
        else
            SingleStacks.StatusDistanceReal(iStack,1)=10000;
            Data2add.Properties.VariableNames{2}='VolumeReal';
            Wave1=array2table(repmat(ColValues2add,[size(Data2add,1),1]),'VariableNames',ColNames2add);
            Data2add=[Data2add,Wave1];
            PlaqueHistograms=[PlaqueHistograms;Data2add];
        end
        
    elseif strcmp(SingleStacks.Filename{iStack}(end),'a')
        
        Wave1=unique(SingleStacks.Array2{iStack,1}.Dystrophies2Radius);
        if sum(ismember([1;2;3;4;5;6;7;8;9],Wave1))
            SingleStacks.StatusDystrophies2Radius(iStack,1)=10000;
        else
            SingleStacks.StatusDystrophies2Radius(iStack,1)=99;
        end
        
        if strfind1(SingleStacks.BoutonList2{iStack,1}.Properties.VariableNames.','AreaXY')
            SingleStacks.StatusAreaXY(iStack,1)=10000;
        else
            SingleStacks.StatusAreaXY(iStack,1)=99;
        end
        
        Data2add=SingleStacks.Array1{iStack};
        Wave1=array2table(repmat(ColValues2add,[size(Data2add,1),1]),'VariableNames',ColNames2add); Data2add=[Data2add,Wave1];
        try
            VglutArray1=[VglutArray1;Data2add];
        catch
            continue;
        end
        
        Data2add=SingleStacks.Array2{iStack};
        Wave1=array2table(repmat(ColValues2add,[size(Data2add,1),1]),'VariableNames',ColNames2add); Data2add=[Data2add,Wave1];
        VglutArray2=[VglutArray2;Data2add];
        
        Data2add=SingleStacks.BoutonList2{iStack};
        VariableNames={'AreaXY';'AreaXYHWI';'DistInMax';'VglutGreenHWI';'DistInOut';'Membership';'Relationship'};
        VariableNames=VariableNames(ismember(VariableNames,Data2add.Properties.VariableNames),:);
        Data2add=Data2add(:,VariableNames);
        Wave1=array2table(repmat(SingleStacks{iStack,{'MouseId';'RoiId';'Time2Treatment';'Age'}},[size(Data2add,1),1]),'VariableNames',{'MouseId';'RoiId';'Time2Treatment';'Age'}); Data2add=[Data2add,Wave1];
        BoutonList2(size(BoutonList2,1)+1:size(BoutonList2,1)+size(Data2add,1),Data2add.Properties.VariableNames)=Data2add;
    end
    cprintf('text',[num2str(iStack),',']);
end
cprintf('text','\n');
% BoutonList2
VariableNames=BoutonList2.Properties.VariableNames.';
VariableNames=strrep(VariableNames,'DistInOut','Distance');
VariableNames=strrep(VariableNames,'Membership','PlId');
BoutonList2.Properties.VariableNames=VariableNames;

BoutonList2.Radius=(BoutonList2.AreaXY/3.1415).^0.5;
BoutonList2.Radius=uint16(BoutonList2.Radius*100);
BoutonList2(:,'AreaXY')=[];
BoutonList2.RadiusHWI=(BoutonList2.AreaXYHWI/3.1415).^0.5;
BoutonList2.RadiusHWI=uint16(BoutonList2.RadiusHWI*100);
BoutonList2(:,'AreaXYHWI')=[];

BoutonList2.DistInMax=uint8(BoutonList2.DistInMax*10);
BoutonList2.VglutGreenHWI=uint16(BoutonList2.VglutGreenHWI);
BoutonList2.Distance=uint8(BoutonList2.Distance);
BoutonList2.PlId=uint8(BoutonList2.PlId);
BoutonList2.Relationship=uint8(BoutonList2.Relationship);
BoutonList2.MouseId=uint16(BoutonList2.MouseId);
BoutonList2.RoiId=uint8(BoutonList2.RoiId);
BoutonList2.Time2Treatment=int16(BoutonList2.Time2Treatment);
BoutonList2.Age=uint16(BoutonList2.Age);

% PlaqueArray1
VariableNames=PlaqueArray1.Properties.VariableNames.';
VariableNames=strrep(VariableNames,'DistInOut','Distance');
VariableNames=strrep(VariableNames,'Membership','PlId');
VariableNames=strrep(VariableNames,'DystrophiesPl','Dystrophies1Pl');
PlaqueArray1.Properties.VariableNames=VariableNames;
PlaqueArray1.VolumeUm3=PlaqueArray1.Volume.*PlaqueArray1.Res3D;

for Var={'MetBlue','MetRed','BRratio','Autofluo1','MetBlueCorr','Dystrophies1','Dystrophies1Pl'}
    PlaqueArray1{:,Var}=PlaqueArray1{:,Var}./PlaqueArray1.Volume;
end
PlaqueArray1.Distance=int16(PlaqueArray1.Distance)-50;

% VglutArray1
VariableNames=VglutArray1.Properties.VariableNames.';
VariableNames=strrep(VariableNames,'DistInOut','Distance');
VariableNames=strrep(VariableNames,'Membership','PlId');
VglutArray1.Properties.VariableNames=VariableNames;

VglutArray1.VolumeUm3=VglutArray1.Volume.*VglutArray1.Res3D;

VglutArray1.RoiId=floor(VglutArray1.RoiId);
VglutArray1=accumarray_9(VglutArray1(:,{'MouseId';'Time2Treatment';'Age';'RoiId';'Distance';'PlId';'Relationship'}),VglutArray1(:,{'Volume';'VglutGreen';'VglutRed';'GRratio';'Dystrophies2';'Dystrophies2Volume';'Dystrophies2Radius';'VolumeUm3'}),@sum,[],'Sparse');

for Var={'VglutGreen','VglutRed','GRratio','Dystrophies2','Dystrophies2Volume','Dystrophies2Radius'}
    VglutArray1{:,Var}=VglutArray1{:,Var}./VglutArray1.Volume;
end
VglutArray1.Distance=int16(VglutArray1.Distance)-50;

% VglutArray2
VariableNames=VglutArray2.Properties.VariableNames.';
VariableNames=strrep(VariableNames,'DistInOut','Distance');
VariableNames=strrep(VariableNames,'Membership','PlId');
VglutArray2.Properties.VariableNames=VariableNames;
VglutArray2.VolumeUm3=VglutArray2.Volume.*VglutArray2.Res3D;

VglutArray2(:,'Res3D')=[];
VglutArray2(:,'Volume')=[];
VglutArray2.RoiId=floor(VglutArray2.RoiId);
VglutArray2=accumarray_9(VglutArray2(:,{'MouseId';'Time2Treatment';'Age';'RoiId';'Distance';'PlId';'Relationship';'Dystrophies2Radius'}),VglutArray2(:,{'VolumeUm3'}),@sum,[],'Sparse');
VglutArray2.Distance=int16(VglutArray2.Distance)-50;

% PlaqueHistograms
PlaqueHistograms.VolumeRealUm3=PlaqueHistograms.VolumeReal.*PlaqueHistograms.Res3D;
PlaqueHistograms(:,{'VolumeReal';'Res3D'})=[];
PlaqueHistograms.Distance=PlaqueHistograms.Distance-50;
% VariableNames=PlaqueHistograms.Properties.VariableNames.';
% PlaqueHistograms.Properties.VariableNames=VariableNames;

SingleStacks(:,'BoutonList2') = [];
disp(['finalEvaluation_GatherData: ',num2str(round((datenum(now)-Timer)*24*60)),'min']);