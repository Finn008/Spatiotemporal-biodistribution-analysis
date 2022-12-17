function [results]=getSurfaceInfo3(vSurfaces,properties)

Statistics = vSurfaces.GetStatistics;
Name = cell(Statistics.mNames); % name of statistical readout
[Name]=string2varname(Name,0);
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
surfaceIds=uniqueIds(uniqueIds<1000000000);
surfaceNumber=size(surfaceIds,1);
trackIds=uniqueIds(uniqueIds>=1000000000)-1000000000;
trackNumber=size(trackIds,1);

if exist('properties','var')==0 || isempty(properties);
    properties=uniqueNames;
end

% determine trackID
if trackNumber>0 % GetTrackIDs
    TrackEdges=vSurfaces.GetTrackEdges; % Matrix with surfaceIds at different timepoints
    trackIdsUnsorted=vSurfaces.GetTrackIds; trackIdsUnsorted=trackIdsUnsorted-1000000000;
    surfacesTrackIds=NaN(surfaceNumber,1);
    for m = 1:size(TrackEdges,1)
        for n = 1:size(TrackEdges,2)
            surfacesTrackIds(TrackEdges(m,n)+1,1)=trackIdsUnsorted(m);
        end
    end
else
    surfacesTrackIds=surfaceIds;
end

surfaceInfo=table(surfaceIds,surfacesTrackIds,'variableName',{'Id','trackId'});
generalInfo=table;
trackInfo=table(trackIds);
% now go through all and extract each value separately
for m=1:size(all,1)
    if isempty(all.Category{m,1})
    end
end


for m=1:size(properties,1); % go through categories to extract
%     disp(m);
    

%     wave1=strfind(Names,properties{m}); wave1 = ~cellfun(@isempty,wave1); % select elements of that property
    wave1=strcmp(Name,properties{m}); % select elements of that property
    cP=all(wave1==1,:);
    IdNumber=max(cP.Ids)+1; % plus 1 because id zero is first
    
    
    % go through channels
    out=NaN(IdNumber,channelNumber,timepoints,'double');
    for n=1:size(cP,1);
        out(cP.Ids(n)+1,cP.Channel(n),cP.Time(n))=cP.Value(n);
    end
    path=['results.',propertiesOut{m},'=out;'];
    eval(path);
end






a1=1;