function [results]=getObjectInfo(vObject,properties)

Statistics = vObject.GetStatistics;
Name = cell(Statistics.mNames); % name of statistical readout
[Name]=string2varname(Name,0); % turn names into chars that are valid variable names
Value = Statistics.mValues;
Unit = cell(Statistics.mUnits);
Factors = cell(Statistics.mFactors).';
Category=Factors(:,1); % type of data, surface, spot, track...
% Channel=Factors(:,2);
Channel=cellfun(@str2num, Factors(:,2),'UniformOutput',false);
emptyCells= cellfun(@isempty,Channel); 
Channel(emptyCells==1)={0};
Channel=cell2mat(Channel);
Channel(Channel==0)=1;

Time=cellfun(@str2num, Factors(:,4),'UniformOutput',false);
emptyCells= cellfun(@isempty,Time); 
Time(emptyCells==1)={0};
Time=cell2mat(Time);
Time(Time==0)=1;

Collection=Factors(:,3);

FactorNames = cellstr(char(Statistics.mFactorNames));
Id = Statistics.mIds; % Surface number
Id(Id<0)=0;


all=table(Name,Value,Unit,Id,Channel,Time,Category,Collection);

channelNumber=max(all.Channel);
timepoints=max(all.Time);
uniqueNames = unique(all.Name);
uniqueIds = unique(all.Id);
uniqueCategories = unique(all.Category);
uniqueCollection = unique(all.Collection);
objIds=uniqueIds(uniqueIds<1000000000);
objNumber=size(objIds,1);
trackIds=uniqueIds(uniqueIds>=1000000000)-1000000000;
trackNumber=size(trackIds,1);

if exist('properties','var')==0 || isempty(properties);
    properties=uniqueNames;
end

% determine trackID
if trackNumber>0 % GetTrackIDs
    trackEdges=vObject.GetTrackEdges; % Matrix with objIds at different timepoints
    trackIdsUnsorted=vObject.GetTrackIds; trackIdsUnsorted=trackIdsUnsorted-1000000000;
    objTrackIds=NaN(objNumber,1);
    for m = 1:size(trackEdges,1)
        for n = 1:size(trackEdges,2)
            objTrackIds(trackEdges(m,n)+1,1)=trackIdsUnsorted(m);
        end
    end
    objInfo=table(objIds,objTrackIds,'variableName',{'Id','trackId'});
    trackInfo=table(trackIds,trackEdges,'variableName',{'Id','objId'});
else
    trackInfo=[];
end


generalInfo=struct;

% now go through all and extract each value separately
for m=1:size(properties,1); % go through categories to extract
    wave1=strcmp(Name,properties{m}); % select elements of that property
    cP=all(wave1==1,:);
    entryNumber=size(cP,1);
    entryChannelNumber=max(cP.Channel);
    entryTimepointNumber=max(cP.Time);
    if isempty(cP.Category{1})
        path=['generalInfo','.',properties{m},'=cP.Value;'];
        eval(path);
    elseif strcmp(cP.Category{1},'Track') % tracks infos only appear with one timepoint therefore use channels for horizontal table dim
        values=nan(trackNumber,1);
        for n=1:entryNumber
            ind=find(trackIds==cP.Id(n)-1000000000);
            values(ind,cP.Channel(n))=cP.Value(n);
        end
        path=['trackInfo','.',properties{m},'=values;'];
        eval(path);
    else % object, sice objects only have one single timepoint use horizontal table dim for channels
        values=nan(objNumber,entryChannelNumber);
        for n=1:entryNumber
            ind=find(objIds==cP.Id(n));
            values(ind,cP.Channel(n))=cP.Value(n);
        end
        path=['objInfo','.',properties{m},'=values;'];
        eval(path);
    end
end

% assign values in objInfo to each track
nanInd=isnan(objInfo.trackId);
trackPositive=objInfo;
trackPositive(nanInd==1,:)=[];

for m=3:size(objInfo,2)
    propertyChannelNumber=size(objInfo{:,m},2);
    values=nan(trackNumber,propertyChannelNumber,timepoints);
    for n=1:size(trackPositive,1)
        values(trackPositive.trackId(n)+1,:,trackPositive.TimeIndex(n))=trackPositive{n,m};
    end
    path=['obj2trackInfo.',trackPositive.Properties.VariableNames{m},'=values;'];
    eval(path);
end

results.objInfo=objInfo;
results.generalInfo=generalInfo;
results.trackInfo=trackInfo;
results.obj2trackInfo=obj2trackInfo;
a1=1;