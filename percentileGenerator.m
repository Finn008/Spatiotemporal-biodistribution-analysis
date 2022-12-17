function [Percentiles,PercentilesAvg]=percentileGenerator(NormPercMap,Percentiles2collect)

if exist('Percentiles2collect')==0
%     percentiles2collect=[(1:1:100),(200:100:1000),(2000:1000:10000),(20000:10000:100000),(200000:100000:1000000),(2000000:1000000:10000000),(20000000:10000000:100000000),(200000000:100000000:1000000000),(2000000000:1000000000:10000000000)].';
    Percentiles2collect=[(1:1:100),(99.1:0.1:99.9),(99.91:0.01:99.99),(99.991:0.001:99.999),(99.9991:0.0001:99.9999),(99.99991:0.00001:99.99999),(99.999991:0.000001:99.999999),(99.9999991:0.0000001:99.9999999),(99.99999991:0.00000001:99.99999999)].';
end

Percentiles=nan(size(Percentiles2collect,1),size(NormPercMap,2));
PercentilesAvg=Percentiles;
% generate NormPercMap2 that provides how many pixels of that intensity are there in percent
NormPercMap2=NormPercMap;
for m=2:size(NormPercMap,1)
    NormPercMap2(m,:)=NormPercMap(m,:)-NormPercMap(m-1,:);
end

for n=1:size(NormPercMap,2)
    if isnan(NormPercMap(1,n))
        continue
    end
    for m=1:size(Percentiles2collect,1)
        Percentiles(m,n)=min(find(NormPercMap(:,n)>=Percentiles2collect(m,1)));
    end
    PercentilesWith0=ones(size(Percentiles,1)+1,1,class(NormPercMap)); % provides maximum intensity at that percentile
    PercentilesWith0(2:end)=Percentiles(:,n);
    for m=1:size(Percentiles2collect,1)
        Bottom=PercentilesWith0(m); % lowest intensity value to calculate the mean
        Top=PercentilesWith0(m+1)-1; % highest intensity value
        if m==100
            Top=PercentilesWith0(m+1);
        elseif m==101
            Bottom=PercentilesWith0(m-2);
        elseif Top<Bottom
            if Top==0
                PercentilesAvg(m,n)=1;
            else
                PercentilesAvg(m,n)=PercentilesAvg(m-1,n);
            end
            continue;
        end
        WeighedSum=(Bottom:1:Top).'.*NormPercMap2(Bottom:Top,n);
        WeighedSum=sum(WeighedSum(:));
        Divider=sum(NormPercMap2(Bottom:Top,n));
        PercentilesAvg(m,n)=WeighedSum/Divider;
    end
    
%         PercentileRanges(m,n)=min(find(NormPercMap(:,n)>=Percentiles2collect(m,1)));
end

RowNames=num2str(Percentiles2collect,10);
RowNames=cellstr(RowNames);
a=cast(Percentiles,class(NormPercMap));
Percentiles=array2table(a,'RowNames',RowNames);
a=cast(PercentilesAvg,class(NormPercMap));
PercentilesAvg=array2table(a,'RowNames',RowNames);

