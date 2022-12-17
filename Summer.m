function [sumRes,numRes,MinMax]=Summer(sumArray,rois)

if isempty(sumArray);
    sumArray=rois{1}; sumArray{1}(:)=1;
end

roiNumber=size(rois,2);
arrayNumber=size(sumArray,2);
MinMax=zeros(roiNumber,2);
[factor,maxVal,minVal,valRange,digs,xPix,yPix,zPix]=deal(zeros(roiNumber,1,'double'));


for m=1:roiNumber; % get info on each of the stacks
%     minMax(m,1:2)=[min(rois{m}(:)),max(rois{m}(:))];
%     minMax(m,3)=minMax(m,2)-minMax(m,1)+1;
    minVal(m)=min(rois{m}(:));
    MinMax(m,1)=minVal(m);
    if minVal(m)<1;
        rois{m}=rois{m}+1-minVal(m);
    elseif minVal(m)>1;
        rois{m}=rois{m}+1-minVal(m);
    end
    minVal(m)=1;
    maxVal(m)=max(rois{m}(:));
    MinMax(m,2)=MinMax(m)+maxVal(m)-1;
    valRange(m)=maxVal(m)-minVal(m)+1;
    digs(m)=size( num2str(maxVal(m)),2);
    xPix(m)=size(rois{m},1);
    yPix(m)=size(rois{m},2);
    zPix(m)=size(rois{m},3);
end

% calculate how many digits will be necessary to concatenate all data in one array
if sum(digs(:))<3;
    type='uint8';
elseif sum(digs(:))<5;
    type='uint16';
elseif sum(digs(:))<10;
    type='uint32';
else
    type='single';
end

% for m=1:roiNumber;
%     factor(m)=10 .^ sum(digs(m+1:end));
% end

if all(xPix == xPix(1)) && all(yPix == yPix(1)) && all(yPix == yPix(1)); % check if all arrays have the same size
else
    disp('inequal dimensions, not able to perform summing');
    return
end

selector=zeros(xPix(1),yPix(1),zPix(1),type); % concatenate all rois into one array
for m=1:roiNumber;
%     selector=selector+cast(rois{m},type).*    10^sum(digs(m+1:end));
    factor=10 .^ sum(digs(m+1:end));
    selector=selector+cast(rois{m},type).*    factor;
end

% calculate the distribution of rois
selector = reshape(selector,[prod(size(selector(:))),1]);
for m=1:arrayNumber
    sumArray{m} = reshape(sumArray{m},[prod(size(selector(:))),1]);
%     ResultsSum{m} = accumarray(selector, sumArray{m});
    ResultsSum = accumarray(selector, sumArray{m});
    sumArray{m}(:)=1;
    ResultsNum = accumarray(selector, sumArray{m});
    
    % generate backbone for ouput-results
%     wave1=uint64(valRange); wave1=wave1.';
%     sumRes=zeros(wave1,1,'double');
    sumRes=zeros(uint64(valRange(m,1)),1,'double');
    
    numRes=sumRes;
    
    wave1=1:size(ResultsNum,1); wave1=wave1.';
    ids=zeros(size(ResultsNum,1),roiNumber,'uint64');
    for m=1:roiNumber;
        factor=10.^sum(digs(m:end));
        wave2=rem(wave1./factor,1);
        wave2=wave2 .* 10^digs(m);
        ids(:,m)=floor(wave2(:)+0.0001);
    end
    
    nonZero=find(ResultsNum~=0);
    
    for m=1:size(nonZero,1);
        wave1=nonZero(m);
        index=num2cell(ids(wave1,1:end));
        sumRes(index{:})=ResultsSum(wave1,1);
        numRes(index{:})=ResultsNum(wave1,1);
    end
    
end