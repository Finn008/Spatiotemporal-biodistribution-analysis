function [Results]=getObjectInfo_2(Vobject,Properties,Application,Single2Track)
% global W;
% if W.SingularImarisInstance==1
%     mouseMoveController(1);
% end

if ischar(Vobject)
    [Vobject,Ind,ObjectList]=selectObject(Application,Vobject);
end
includeAllImarisStatistics(Application,Vobject);
Statistics = Vobject.GetStatistics;
Name = cell(Statistics.mNames); % name of statistical readout
[Name]=string2varname(Name,0); % turn names into chars that are valid variable names
Value = Statistics.mValues;
Unit = cell(Statistics.mUnits);
Factors = cell(Statistics.mFactors).';
try
    Category=Factors(:,1); % type of data, surface, spot, track...
catch
    Results=[];
    return;
end
Channel=cellfun(@str2num, Factors(:,2),'UniformOutput',false);
EmptyCells= cellfun(@isempty,Channel);
Channel(EmptyCells==1)={0};
Channel=cell2mat(Channel);
Channel(Channel==0)=1;

Time=cellfun(@str2num, Factors(:,4),'UniformOutput',false);
EmptyCells= cellfun(@isempty,Time);
Time(EmptyCells==1)={0};
Time=cell2mat(Time);
Time(Time==0)=1;

Collection=Factors(:,3);

FactorNames = cellstr(char(Statistics.mFactorNames));
Id = Statistics.mIds; % Surface number
Id(Id<0)=0;

All=table(Name,Value,Unit,Id,Channel,Time,Category,Collection);

ChannelNumber=max(All.Channel);
Timepoints=max(All.Time);
UniqueNames = unique(All.Name);
UniqueIds = unique(All.Id);
UniqueCategories = unique(All.Category);
UniqueCollection = unique(All.Collection);
ObjIds=UniqueIds(UniqueIds<1000000000);
ObjNumber=size(ObjIds,1);
TrackIds=UniqueIds(UniqueIds>=1000000000)-1000000000;
TrackNumber=size(TrackIds,1);

if exist('Properties','var')==0 || isempty(Properties);
    Properties=UniqueNames;
end

ObjInfo=table(ObjIds,'variableName',{'Id'});
% determine trackID
ObjTrackIds=NaN(ObjNumber,1);
if TrackNumber>0 % GetTrackIDs
    TrackEdges=Vobject.GetTrackEdges; % Matrix with pairs of objIds making up one edge of a track
    TrackIdsUnsorted=Vobject.GetTrackIds; TrackIdsUnsorted=TrackIdsUnsorted-1000000000; % TrackIDs in the same order as TrackEdges
    for m = 1:size(TrackEdges,1)
        for n = 1:size(TrackEdges,2)
            ObjTrackIds(TrackEdges(m,n)+1,1)=TrackIdsUnsorted(m);
        end
    end
    TrackInfo=table(TrackIds,'variableName',{'Id'});
end
ObjInfo.TrackId=ObjTrackIds; %     ObjInfo=table(ObjIds,ObjTrackIds,'variableName',{'Id','TrackId'});

GeneralInfo=struct;

%% now go through all and extract each value separately
for m=1:size(Properties,1); % go through categories to extract
    wave1=strcmp(Name,Properties{m}); % select elements of that property
    CP=All(wave1==1,:);
    EntryNumber=size(CP,1);
    EntryChannelNumber=max(CP.Channel);
    EntryTimepointNumber=max(CP.Time);
    if isempty(CP.Category{1})
        Path=['GeneralInfo','.',Properties{m},'=CP.Value;'];
        eval(Path);
    elseif strcmp(CP.Category{1},'Track') % tracks infos only appear with one timepoint therefore use channels for horizontal table dim
        Values=nan(TrackNumber,1);
        for n=1:EntryNumber
            Ind=find(TrackIds==CP.Id(n)-1000000000);
            Values(Ind,CP.Channel(n))=CP.Value(n);
        end
        Path=['TrackInfo','.',Properties{m},'=Values;'];
        eval(Path);
    else % object, sice objects only have one single timepoint use horizontal table dim for channels
        Values=nan(ObjNumber,EntryChannelNumber);
       for n=1:EntryNumber
            Ind=find(ObjIds==CP.Id(n)); % stops here
            Values(Ind,CP.Channel(n))=CP.Value(n);
        end
        Path=['ObjInfo','.',Properties{m},'=Values;'];
        eval(Path);
    end
end


%% assign values in objInfo to each track
if exist('Single2Track')==1
    Wave2=isnan(ObjInfo.TrackId(:));
    Wave2=find(Wave2==1);
    MaxTrack=max(ObjInfo.TrackId(:));
    Wave1=(MaxTrack+1:MaxTrack+size(Wave2,1)).';
    ObjInfo.TrackId(Wave2,1)=Wave1;
    TrackNumber=max(ObjInfo.TrackId(:))+1;
end

if TrackNumber>0 % GetTrackIDs
    NanInd=isnan(ObjInfo.TrackId);
    TrackPositive=ObjInfo;
    TrackPositive(NanInd==1,:)=[];
    
    for m=3:size(ObjInfo,2)
        PropertyChannelNumber=size(ObjInfo{:,m},2);
        Values=nan(TrackNumber,Timepoints,PropertyChannelNumber);
        for n=1:size(TrackPositive,1)
            try
                Values(TrackPositive.TrackId(n)+1,TrackPositive.TimeIndex(n),:)=TrackPositive{n,m};
            catch error
                keyboard; % not all statistic values were selected
            end
        end
        Path=['Obj2trackInfo.',TrackPositive.Properties.VariableNames{m},'=Values;'];
        eval(Path);
    end
    IDmap=nan(TrackNumber,Timepoints);
    for m=1:size(ObjInfo,1)
        if isnan(ObjInfo.TrackId(m,1))==0 % donot process SurfaceIds that are not part of Track
            IDmap(ObjInfo.TrackId(m,1)+1,ObjInfo.TimeIndex(m,1))=ObjInfo.Id(m,1);
        end
    end
    TrackInfo.Properties.RowNames=strtrim(cellstr(num2str(TrackInfo.Id)));
    
    
    
    Results.TrackInfo=TrackInfo;
    Results.Obj2trackInfo=Obj2trackInfo;
    Results.IDmap=IDmap;
end



ObjInfo.Properties.RowNames=strtrim(cellstr(num2str(ObjInfo.Id)));

Results.ObjInfo=ObjInfo;
Results.GeneralInfo=GeneralInfo;
[~,Results.ChannelNames]=getChannelId(Application);

% mouseMoveController(0);