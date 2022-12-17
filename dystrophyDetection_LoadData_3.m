function [MouseInfo,SingleStacks]=dystrophyDetection_LoadData_3(DataSelection)
% UmCenter, PixCenter, DistanceCenter2TopBottom, BorderTouch, PlaqueRadius
global W;

SingleStacks=table;
SingleStacks.Filename=W.G.T.F{W.Task}.Filename;
try; SingleStacks.MouseId=W.G.T.F{W.Task}.MouseId; catch; SingleStacks.MouseId(:,1)=NaN; end;
try; SingleStacks.RoiId=W.G.T.F{W.Task}.Roi; catch; SingleStacks.RoiId(:,1)=NaN; end;
SingleStacks.DystrophyDetection=W.G.T.F{W.Task}.DystrophyDetection;

%% select data to be analysed
DataSelection.DystrophyDetection{1}={DataSelection.DystrophyDetection;{'Step#1'}};
if strfind1(DataSelection.Properties.VariableNames.','DystrophyDetection')
    for m=1:size(DataSelection.DystrophyDetection{1},1)
        [~,Wave1(:,m)]=strfind1(SingleStacks.DystrophyDetection,DataSelection.DystrophyDetection{1}{m});
    end
    SingleStacks=SingleStacks(sum(Wave1,2)==size(Wave1,2),:);
end
if size(unique(SingleStacks.Filename),1)<size(SingleStacks,1) % some filenames are dublettes
    keyboard;
end

for File=1:size(SingleStacks,1)
    FilenameTotal=SingleStacks.Filename{File,1}; FilenameTotal=regexprep(FilenameTotal,{'.lsm';'.czi'},'.ims');
    Fileinfo=getFileinfo_2(FilenameTotal);
    Path=[FilenameTotal,'_Results.mat'];
    [Path,Report]=getPathRaw(Path);
    if Report==0; continue; end;
    load(Path);
    try; SingleStacks.Date(File,1)={datestr(TotalResults.TimeStamp.ExtractResults,'yyyy.mm.dd HH:MM')}; end;
    try; SingleStacks.Res3D(File,1)=prod(TotalResults.Res); end;
    SingleStacks.Um(File,1)=Fileinfo.Um;
    
    Out=filenameExtract(FilenameTotal);
    % MouseId
    MouseId=SingleStacks.MouseId(File);
    if isnan(MouseId)
        MouseId=Out.M;
        SingleStacks.MouseId(File,1)=MouseId;
    end
    
    % RoiId
    RoiId=SingleStacks.RoiId(File);
    if isnan(RoiId)
        SingleStacks.RoiId(File,1)=Out.Roi;
    end
    % TreatmentType
    if Out.Tr~=0
        SingleStacks.TreatmentType(File,1)={Out.Tr};
    end
    
    try; SingleStacks.Region(File,1)={Out.REG}; end;
    
    try; SingleStacks.SliceThickness(File,1)=TotalResults.SliceThickness; end;
    try; SingleStacks.TotalVolume(File,1)=TotalResults.TotalVolume; end;
    try; SingleStacks.MicrogliaInfo(File,1)={TotalResults.MicrogliaInfo}; end;
    try; SingleStacks.BoutonInfo(File,1)={TotalResults.BoutonInfo}; end;
    try; SingleStacks.ImarisSpot(File,1)={TotalResults.ImarisSpot}; end;
    try; SingleStacks.IntDistribution(File,1)={TotalResults.IntDistribution}; end;
    try; SingleStacks.TimeStamp(File,1)={TotalResults.TimeStamp}; end;
    try; SingleStacks.DistanceRelation(File,1)={TotalResults.DistanceRelation}; end;
    try; SingleStacks.PlaqueData(File,1)={TotalResults.PlaqueData}; end;
end

%% get MouseInfo
F2=W.G.T.F2{W.Task};
MouseInfoF2=table;
if isempty(F2)==0
    VariableNames={'MouseId';'BirthDate';'StartTreatment';'Dead';'TreatmentType';'Age'};
    VariableNames=VariableNames(ismember(VariableNames,F2.Properties.VariableNames));
    MouseInfoF2(:,VariableNames)=F2(:,VariableNames);
end

MouseInfo=table; MouseInfo.MouseId=unique(SingleStacks.MouseId);
if isempty(find(SingleStacks.TotalVolume==0))==0
%     keyboard; % check why some files lack TotalVolume (especially among Beckies)
end
for Mouse=1:size(MouseInfo,1)
    Selection=SingleStacks(SingleStacks.MouseId==MouseId,:);
    MouseInfo.RoiNumber(Mouse,1)=size(Selection,1);
    try; MouseInfo.TreatmentType(Mouse,1)=Selection.TreatmentType(1); end;
end
% insert data from F2
if isempty(F2)==0
    MouseInfoF2(ismember(MouseInfoF2.MouseId,MouseInfo.MouseId)==0,:)=[];
    MouseInfo(ismember2(MouseInfoF2.MouseId,MouseInfo.MouseId),MouseInfoF2.Properties.VariableNames)=MouseInfoF2;
end

if strfind1(MouseInfo.Properties.VariableNames.','TreatmentType')==0
    MouseInfo.TreatmentType(:,1)={'None'};
end

if strfind1(MouseInfo.Properties.VariableNames.','Age',1)==0
    MouseInfo.Age(:,1)=1;
end
if strfind1(SingleStacks.Properties.VariableNames,'Age',1)==0
    SingleStacks=fuseTable_MatchingColums_4(SingleStacks,MouseInfo,{'MouseId'},{'Age'});
end

for Mouse=1:size(MouseInfo,1)
    try
        MouseInfo.Age(Mouse,1)=(datenum(MouseInfo.Dead{Mouse}(2:end),'yyyy.mm.dd')-datenum(MouseInfo.BirthDate{Mouse}(2:end),'yyyy.mm.dd'))/(365/12);
    end
end

MouseInfo=sortrows(MouseInfo,{'TreatmentType';'Age';'MouseId'});