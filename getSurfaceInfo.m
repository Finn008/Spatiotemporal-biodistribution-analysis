function [results]=getSurfaceInfo(vSurfaces,properties)

vStatistics = vSurfaces.GetStatistics;
vNames = cell(vStatistics.mNames);
vValues = vStatistics.mValues;
vUnits = cell(vStatistics.mUnits);
vFactors = cell(vStatistics.mFactors);
vFactorNames = cellstr(char(vStatistics.mFactorNames));
vIds = vStatistics.mIds;
categories = unique(vNames);

% % % % wave1={'Track Position X Start';'Track Position Y Start';'Track Position Z Start';'Track Position X Mean';'Track Position Y Mean';'Track Position Z Mean'};

if exist('properties','var')==0 || isempty(properties);
    properties=categories;
end
for m=1:size(properties,1); % go through categories to extract
    wave2=strfind(vNames,properties{m});
    wave3 = ~cellfun(@isempty,wave2);
    wave4=find(wave3==1);
    if m==1;
        NumberOfTracks=sum(wave3);
        results=zeros(NumberOfTracks,size(properties,1));
    end
    results(:,m)=vValues(wave3==1);
end
