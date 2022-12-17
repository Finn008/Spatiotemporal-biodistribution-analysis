function [MouseInfo,SingleStacks]=finalEvaluation_LoadData()
Timer=datenum(now);
global W;

F2=W.G.T.F2{W.Task};
MouseInfo=table;
[MouseInfo.MouseId,Wave2]=unique(F2.Mouse,'stable');
MouseInfo(:,{'BirthDate','StartTreatment','Dead','TreatmentType'})=F2(Wave2,{'BirthDate','StartTreatment','Dead','TreatmentType'});
Experiment=W.G.T.TaskName{W.Task};

MouseInfo(isnan_2(MouseInfo.BirthDate),:)=[];

for Mouse=1:size(MouseInfo,1)
    
    MouseId=MouseInfo.MouseId(Mouse);
    Ind=find(F2.Mouse==MouseId);
    if size(unique(F2.BirthDate(Ind)),1)>1 || size(unique(F2.TreatmentType(Ind)),1)>1
        keyboard; % mice with same number
    end
    RoiInfo=F2(Ind,{'Roi';'StackB';'StackA'});
    BirthDate=datenum(MouseInfo.BirthDate{Mouse,1}(2:end),'yyyy.mm.dd');
    MouseInfo.BirthDateNum(Mouse,1)=BirthDate;
    StartTreatment=datenum(MouseInfo.StartTreatment{Mouse,1}(2:end),'yyyy.mm.dd')-BirthDate;
    MouseInfo.StartTreatmentNum(Mouse,1)=StartTreatment;
    %     keyboard; % underMouse Info.RoiInfo store Volume in µm of the b as well as the a stack
    for Roi=1:size(RoiInfo,1)
        RoiId=RoiInfo.Roi(Roi);
        FileList=W.G.T.F{W.Task};
        FileList=FileList(FileList.Mouse==MouseId & isnan(FileList.TargetTimepoint)==0,:);
        % StackB
        Files=table;
        try
            Wave2=strfind1(FileList.Filename,RoiInfo.StackB{Roi});
            Files.Filenames(FileList.TargetTimepoint(Wave2),1)=FileList.Filename(Wave2);
        catch
            continue;
        end
        % StackA
        try
            Wave2=strfind1(FileList.Filename,RoiInfo.StackA{Roi});
            Files.Filenames(FileList.TargetTimepoint(Wave2),2)=FileList.Filename(Wave2);
        end
        
        % get Age at timepoints
        for m=1:size(Files,1)
            if strfind1(FileList.Properties.VariableNames,'Date')==0
                if isempty(Files.Filenames{m,1})==0; Ind=1; else; Ind=2; end;
                [Wave1]=extractStringPart(Files.Filenames{m,Ind},'Date_yyyy.mm.dd');
                Files.Age(m,1)=datenum(Wave1,'yyyy.mm.dd');
            else
                %                 keyboard;
                Files.Age(m,1)=datenum(FileList.Date{m}(2:end),'yyyy.mm.dd');
            end
        end
        Files.Age=Files.Age-BirthDate;
        RoiInfo.Files(Roi,1)={Files};
    end
    MouseInfo.RoiInfo(Mouse,1)={RoiInfo};
    %     MouseInfo.PlaqueContainer(Mouse,1)={struct};
end

%% read out Trace info
for m=1:size(F2,1)
    if ceil(F2.Roi(m))~=F2.Roi(m); continue; end;
    Path2file=[Experiment,'_M',num2str(F2.MouseId(m)),'_',F2.StackB{m},'_RatioResults.mat'];
    [Path2file,Report]=getPathRaw(Path2file);
    if Report==0; continue; end;
    load(Path2file);
    
    Mouse=find(MouseInfo.MouseId==F2.MouseId(m));
    Roi=find(MouseInfo.RoiInfo{Mouse}.Roi==F2.Roi(m));
    MouseInfo.RoiInfo{Mouse}.TraceData(Roi,1)={TotalResults.TracePlaqueData};
    MouseInfo.PlaqueTrace(Mouse,1)=1;
end

%% read out single timepoint info
SingleStacks=W.G.T.F{W.Task}(:,{'Filename';'Mouse';'Roi';'TargetTimepoint';'BoutonDetect'});

for m=1:size(SingleStacks,1)
    Wave1=SingleStacks.BoutonDetect{m,1};
    if ischar(Wave1) && strfind1(Wave1,'Step#4')==0
        continue;
    end
    
    Path=[SingleStacks.Filename{m,1},'_RatioResults.mat'];
    [Path,Report]=getPathRaw(Path);
    if Report==0; continue; end;
    load(Path);
    [RatioResults]=struct2table_2(RatioResults);
    try
        RatioResults(:,'PlaqueMetBlueHistogram') = [];
    end
    if isnumeric(RatioResults.PlaqueIDs) % if only single plaque in whole chunk
        RatioResults.PlaqueIDs={RatioResults.PlaqueIDs};
    end
    Wave1=dir(Path);
    SingleStacks.Date(m,1)={datestr(Wave1.datenum,'yyyy.mm.dd HH:MM')};
    VariableNames=RatioResults.Properties.VariableNames;
    SingleStacks(m,VariableNames)=RatioResults(1,VariableNames);
end
if strfind1(SingleStacks.Properties.VariableNames,'PlaqueIDs')
    SingleStacks=SingleStacks(cellfun(@isempty,SingleStacks.PlaqueIDs)==0,:);
else
    SingleStacks=[];
end

disp(['finalEvaluation_LoadData: ',num2str(round((datenum(now)-Timer)*24*60)),'min']);