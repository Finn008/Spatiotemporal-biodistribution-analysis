function [MouseInfo,SingleStacks]=finalEvaluation_LoadData_2(LoadData)
Timer=datenum(now);
global W;

F2=W.G.T.F2{W.Task};
MouseInfo=table;
[MouseInfo.MouseId,Wave2]=unique(F2.MouseId,'stable');
MouseInfo(:,{'BirthDate','StartTreatment','Dead','TreatmentType'})=F2(Wave2,{'BirthDate','StartTreatment','Dead','TreatmentType'});
% % % % MouseInfo.StartTreatment=MouseInfo.BirthDate;
% Wave1=find(ismember(MouseInfo.TreatmentType,{'NB360';'NB360Vehicle';'Control'}));
Wave1=find(ismember(MouseInfo.TreatmentType,{'NB360';'NB360Vehicle';'Control';'TauKD';'TauKO'}));
MouseInfo=MouseInfo(Wave1,:);


Experiment=W.G.T.TaskName{W.Task};

MouseInfo(isnan_2(MouseInfo.BirthDate),:)=[];
MouseInfo(isnan_2(MouseInfo.StartTreatment),:)=[];

for Mouse=1:size(MouseInfo,1)
    
    MouseId=MouseInfo.MouseId(Mouse);
    Ind=find(F2.MouseId==MouseId);
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
        FileList=FileList(FileList.MouseId==MouseId & isnan(FileList.TargetTimepoint)==0,:);
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
                Files.Age(m,1)=datenum(FileList.Date{m}(2:end),'yyyy.mm.dd');
            end
        end
        Files.Age=Files.Age-BirthDate;
        RoiInfo.Files(Roi,1)={Files};
    end
    MouseInfo.RoiInfo(Mouse,1)={RoiInfo};
end

%% read out Trace info
for m=1:size(F2,1)
    if ceil(F2.Roi(m))~=F2.Roi(m); continue; end;
    Path2file=[Experiment,'_M',num2str(F2.MouseId(m)),'_',F2.StackB{m},'_RatioResults.mat'];
    [Path2file,Report]=getPathRaw(Path2file);
    if Report==0; continue; end;
    load(Path2file);
    
    Mouse=find(MouseInfo.MouseId==F2.MouseId(m));
    if isempty(Mouse); continue; end;
    Roi=find(MouseInfo.RoiInfo{Mouse}.Roi==F2.Roi(m));
    MouseInfo.RoiInfo{Mouse}.TraceData(Roi,1)={TotalResults.TracePlaqueData};
% % %     MouseInfo.RecentPlaqueTrace(Mouse,1)=1;
end

save(getPathRaw('FinalEvaluation_MouseInfo.mat'),'MouseInfo');
if exist('LoadData')==1 && strcmp(LoadData,'MouseInfo')
    SingleStacks=[];
    return;
end

%% read out single timepoint info
SingleStacks=W.G.T.F{W.Task}(:,{'Filename';'MouseId';'Roi';'TargetTimepoint';'BoutonDetect';'RatioPlaque'});
SingleStacks.Properties.VariableNames([3;4])={'RoiId';'Time'};
Wave1=find(ismember(SingleStacks.MouseId,MouseInfo.MouseId));
SingleStacks=SingleStacks(Wave1,:);


for iStack=1:size(SingleStacks,1)
    Path=[SingleStacks.Filename{iStack,1},'_RatioResults.mat'];
    [Path,Report]=getPathRaw(Path);
    if Report==0; continue; end;
    load(Path);
    
    [RatioResults]=struct2table_2(RatioResults);
    if isnumeric(RatioResults.PlaqueIDs) % if only single plaque in whole chunk
        RatioResults.PlaqueIDs={RatioResults.PlaqueIDs};
    end
    Wave1=dir(Path);
    SingleStacks.Date(iStack,1)={datestr(Wave1.datenum,'yyyy.mm.dd HH:MM')};
    VariableNames=RatioResults.Properties.VariableNames.';
    VariableNames=VariableNames(ismember(VariableNames,{'Array1';'Array2';'BoutonList2';'Histograms';'PlaqueIDs';'Res'})==1,:);
    SingleStacks(iStack,VariableNames)=RatioResults(1,VariableNames);
end

SingleStacks.Res3D=cellfun(@prod,SingleStacks.Res);

disp(['finalEvaluation_LoadData: ',num2str(round((datenum(now)-Timer)*24*60)),'min']);