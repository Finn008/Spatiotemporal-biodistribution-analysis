function [results]=getSurfaceInfo2(vSurfaces,properties)

Statistics = vSurfaces.GetStatistics;
Names = cell(Statistics.mNames);
Values = Statistics.mValues;
Units = cell(Statistics.mUnits);
Factors = cell(Statistics.mFactors).';
Category=Factors(:,1);
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
% Time=Factors(:,4);
% Time=cellfun(@str2num, Factors(:,4),'UniformOutput',false); Time=cell2mat(Time);

FactorNames = cellstr(char(Statistics.mFactorNames));
Ids = Statistics.mIds; % Surface number
Ids(Ids<0)=0;
categories = unique(Names);

all=table(Names,Values,Units,Ids,Channel,Time,Category,Collection);

% % % % wave1={'Track Position X Start';'Track Position Y Start';'Track Position Z Start';'Track Position X Mean';'Track Position Y Mean';'Track Position Z Mean'};

if exist('properties','var')==0 || isempty(properties);
    properties=categories;
end
[propertiesOut]=string2varname(properties);


for m=1:size(properties,1); % go through categories to extract
    disp(m);
    

%     wave1=strfind(Names,properties{m}); wave1 = ~cellfun(@isempty,wave1); % select elements of that property
    wave1=strcmp(Names,properties{m}); % select elements of that property
    cP=all(wave1==1,:);
    IdNumber=max(cP.Ids)+1; % plus 1 because id zero is first
    channelNumber=max(cP.Channel);
    timepoints=max(cP.Time);
    % go through channels
    out=NaN(IdNumber,channelNumber,timepoints,'double');
    for n=1:size(cP,1);
        out(cP.Ids(n)+1,cP.Channel(n),cP.Time(n))=cP.Values(n);
    end
    path=['results.',propertiesOut{m},'=out;'];
    eval(path);
end

a1=1;