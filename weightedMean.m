function [Mean,Values2]=weightedMean(Values,Weight,Percent,MinN)

if exist('Percent')
    [~,Ind]=sort(Values,1);
    for m=1:size(Values,2)
        NanInd=find(isnan(Values(:,m)));
        NanCount=size(NanInd,1);
        if NanCount>1
            Ind(:,m)=[NanInd(1:floor(NanCount/2));Ind(1:size(Values,1)-NanCount,m);NanInd(floor(NanCount/2)+1:end)];
        end
        Values2(:,m)=Values(Ind(:,m),m);
    end
    
    Range=floor(size(Values,1)*Percent/100/2);
    Range=sort([1+Range;size(Values,1)-Range]);
    Values2=Values2(Range(1):Range(2),:);
    
end

if isempty(Weight)
    Mean=nanmean(Values2,1);
else
%     keyboard; % check if working correctly
    for m=1:size(Values,2)
        Weight(:,m)=Weight(Ind(:,m),m);
    end
    Weight=Weight(Range(1):Range(2),:);
    Mean=Values2.*Weight;
    Wave2=nansum(Mean,1);
    Mean=Wave2./nansum(Weight,1);
end

if exist('MinN')==1
    NanIds=sum(~isnan(Values),1);
    NanIds=find(NanIds<MinN).';
    Mean(1,NanIds)=NaN;
    Values2(:,NanIds)=NaN;
end