function [MaxValues,MaxLocs,MaxWidths,MaxProms]=findpeaksFinn(Yaxis,BorderType)

% if whole array is nan
if min(isnan(Yaxis))==1
    MaxValues=nan;MaxLocs=nan;MaxWidths=nan;MaxProms=nan;
    return;
end

% include border case
if exist('BorderType')==1 && strcmp(BorderType,'IncludeBoth')
    Add=3;
    IncludedRange=find(isnan(Yaxis)==0);
    Bottom=IncludedRange(1);
    Top=IncludedRange(end);
    Yaxis2=[Yaxis(Bottom+Add:-1:Bottom+1);Yaxis(Bottom:Top);Yaxis(Top-1:-1:Top-Add)];
    Yaxis=Yaxis2;
end
[MaxValues,MaxLocs,MaxWidths,MaxProms] = findpeaks(Yaxis);
MaxLocs=MaxLocs+Bottom-Add-1;

if exist('BorderType')==1
    PeaksOutside=find(MaxLocs>Top|MaxLocs<Bottom);
    MaxValues(PeaksOutside)=[];
    MaxLocs(PeaksOutside)=[];
    MaxWidths(PeaksOutside)=[];
    MaxProms(PeaksOutside)=[];
end

if isempty(MaxValues)
    MaxValues=nan;MaxLocs=nan;MaxWidths=nan;MaxProms=nan;
end