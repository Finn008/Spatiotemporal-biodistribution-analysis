function [MouseInfo,SingleStacks]=dystrophyDetection_LoadData_2(TreatmentType,DataSelection)
% UmCenter, PixCenter, DistanceCenter2TopBottom, BorderTouch, PlaqueRadius
global W;
F2=W.G.T.F2{W.Task};
MouseInfo=table;
try
    [MouseInfo.MouseId,Wave2]=unique(F2.MouseId,'stable');
    try;MouseInfo.BirthDate=F2.BirthDate(Wave2,1);end;
    try;MouseInfo.StartTreatment=F2.StartTreatment(Wave2,1);end;
    try;MouseInfo.Dead=F2.Dead(Wave2,1);end;
    try;MouseInfo.TreatmentType=F2.TreatmentType(Wave2,1);end;
%     MouseInfo(:,{'BirthDate','StartTreatment','Dead','TreatmentType'})=F2(Wave2,{'BirthDate','StartTreatment','Dead','TreatmentType'});
    for Mouse=1:size(MouseInfo,1)
        try
            BirthDate=datenum(MouseInfo.BirthDate{Mouse,1}(2:end),'yyyy.mm.dd');
        catch
            BirthDate=0;
        end
        MouseInfo.BirthDateNum(Mouse,1)=BirthDate;
        try
            StartTreatment=datenum(MouseInfo.StartTreatment{Mouse,1}(2:end),'yyyy.mm.dd')-BirthDate;
        catch
            StartTreatment=0;
        end
        MouseInfo.StartTreatmentNum(Mouse,1)=StartTreatment;
    end
catch
end


SingleStacks=table;
SingleStacks.Filename=W.G.T.F{W.Task}.Filename;
SingleStacks.MouseId(:,1)=NaN;
SingleStacks.RoiId(:,1)=NaN;
try; SingleStacks.MouseId=W.G.T.F{W.Task}.MouseId; end;
try; SingleStacks.RoiId=W.G.T.F{W.Task}.Roi; end;
SingleStacks.DystrophyDetection=W.G.T.F{W.Task}.DystrophyDetection;

SingleStacks=SingleStacks(strfind1(SingleStacks.DystrophyDetection,'Do#'),:);
if exist('DataSelection')==1 && isempty(DataSelection)==0
%     SingleStacks=SingleStacks(strfind1(SingleStacks.DystrophyDetection,DataSelection),:);
    for m=1:size(DataSelection,1)
        [~,Wave1(:,m)]=strfind1(SingleStacks.DystrophyDetection,DataSelection{m});
    end
    SingleStacks=SingleStacks(sum(Wave1,2)==size(Wave1,2),:);
end
if size(unique(SingleStacks.Filename),1)<size(SingleStacks,1) % some filenames are dublettes
    keyboard;
end

SingleStacks.Filename=regexprep(SingleStacks.Filename,'ExHazalS_IhcLamp1_m318_PL','ExHazalS_IhcLamp1_M318_PL');
for Row=1:size(SingleStacks,1)
    Wave1=SingleStacks.DystrophyDetection{Row,1};
    if strfind1(Wave1,'Step#1')==0; continue; end;
%     FilenameTotal=SingleStacks.Filename{Row,1}; FilenameTotal=regexprep(FilenameTotal,{'.lsm'},'.ims');
    FilenameTotal=SingleStacks.Filename{Row,1}; FilenameTotal=regexprep(FilenameTotal,{'.lsm';'.czi'},'.ims');
    Fileinfo=getFileinfo_2(FilenameTotal);
    Path=[FilenameTotal,'_Results.mat'];
    [Path,Report]=getPathRaw(Path);
    if Report==0; continue; end;
    load(Path);
%     Wave1=dir(Path); SingleStacks.Date(Row,1)={datestr(Wave1.datenum,'yyyy.mm.dd HH:MM')};
    SingleStacks.Date(Row,1)={datestr(TotalResults.TimeStamp.ExtractResults,'yyyy.mm.dd HH:MM')};
%     keyboard; % test if Res is correctly extracted
    SingleStacks.Res3D(Row,1)=prod(TotalResults.Res);
    SingleStacks.Um(Row,1)=Fileinfo.Um;
    
    Out=filenameExtract(FilenameTotal);
    % MouseId
    MouseId=SingleStacks.MouseId(Row);
    if isnan(MouseId)
        MouseId=Out.M;
        SingleStacks.MouseId(Row,1)=MouseId;
    end
    
    % RoiId
    RoiId=SingleStacks.RoiId(Row);
    if isnan(RoiId)
        SingleStacks.RoiId(Row,1)=Out.Roi;
    end
    % TreatmentType
    try; SingleStacks.TreatmentType(Row,1)={Out.Tr}; end;
    try; SingleStacks.Region(Row,1)={Out.REG}; end;
    
    try
        Mouse=find(MouseInfo.MouseId==MouseId);
        try
            Dead=datenum(MouseInfo.Dead{Mouse}(2:end),'yyyy.mm.dd');
            Birth=datenum(MouseInfo.BirthDate{Mouse}(2:end),'yyyy.mm.dd');
            Age=Dead-Birth;
            SingleStacks.Age(Row,1)=Age;
        end
        try; SingleStacks.Time2Treatment(Row,1)=Age-MouseInfo.StartTreatmentNum(Mouse); end;
        try; SingleStacks.TreatmentType(Row,1)=MouseInfo.TreatmentType(Mouse); end;
    end
    
%     try; SingleStacks.RatioResults(Row,1)={TotalResults.RatioResults}; end;
    try; SingleStacks.SliceThickness(Row,1)=TotalResults.SliceThickness; end;
    try; SingleStacks.TotalVolume(Row,1)=TotalResults.TotalVolume; end;
    try; SingleStacks.MicrogliaInfo(Row,1)={TotalResults.MicrogliaInfo}; end;
    try; SingleStacks.BoutonInfo(Row,1)={TotalResults.BoutonInfo}; end;
    try; SingleStacks.ImarisSpot(Row,1)={TotalResults.ImarisSpot}; end;
    try; SingleStacks.IntDistribution(Row,1)={TotalResults.IntDistribution}; end;
    try; SingleStacks.TimeStamp(Row,1)={TotalResults.TimeStamp}; end;
    try; SingleStacks.DistanceRelation(Row,1)={TotalResults.DistanceRelation}; end;
    try; SingleStacks.PlaqueData(Row,1)={TotalResults.PlaqueData}; end;
%     catch
%         SingleStacks.PlaqueData(Row,1)={[]};
%     end
    
end
SingleStacks(SingleStacks.MouseId==0,:)=[];
if isempty(MouseInfo)
    MouseInfo=table;
    MouseInfo.MouseId=unique(SingleStacks.MouseId);
    for Mouse=1:size(MouseInfo,1)
        MouseId=MouseInfo.MouseId(Mouse);
        Selection=SingleStacks(SingleStacks.MouseId==MouseId,:);
        MouseInfo.RoiNumber(Mouse,1)=size(Selection,1);
        MouseInfo.TreatmentType(Mouse,1)=Selection.TreatmentType(1);
    end
end

if isempty(TreatmentType)==0
    SingleStacks=SingleStacks(strfind1(SingleStacks.TreatmentType,TreatmentType),:);
    OrigMouseInfo=MouseInfo;
    [Wave1]=ismember(MouseInfo.MouseId,unique(SingleStacks.MouseId));
    MouseInfo=MouseInfo(Wave1,:);
end
if strfind1(MouseInfo.Properties.VariableNames.','TreatmentType')==0
    MouseInfo.TreatmentType(:,1)={'None'};
end

MouseInfo=sortrows(MouseInfo,'TreatmentType');