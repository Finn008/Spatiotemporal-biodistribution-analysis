function [Out]=Summer_2(SumArray,Rois,In)
if exist('In')==1
    v2struct(In);
end
if isempty(SumArray)||isempty(SumArray{1})
    SumArray=Rois(1); SumArray{1}(:)=1;
end

RoiNumber=size(Rois,2);
ArrayNumber=size(SumArray,2);

MinMax=zeros(RoiNumber,2);
for m=1:RoiNumber
    RoiIds{m,1}=unique(Rois{m});
end
% if exist('ExcludeRoiIds')~=1
%     ExcludeRoiIds=repmat({[]},[1,RoiNumber]);
% end
% for m=1:RoiNumber
%     RoiIds{m,1}=unique(Rois{m});
%     if isempty(ExcludeRoiIds{1,m})==0
%         Wave1=find(RoiIds{m,1}==ExcludeRoiIds{1,m});
%         RoiIds{m,1}(Wave1)=[];
%         Wave2=RoiIds{m,1}(1)-1; % define excluded ID as one below the lowest
%         ExcludeRoiIds{1,m}=Wave2;
%         if isempty(Wave1)==0
%             Rois{1,m}(Rois{1,m}==ExcludeRoiIds{1,m})=Wave2; % set all excluded roi values to the ExcludeValue
%         end
%     end
% end

for m=1:ArrayNumber
    SumArray{1,m}=reshape(SumArray{1,m},[prod(size(SumArray{1,m}(:))),1]);
%     SumArray{1,m}(end+1,1)=0;
end
for m=1:RoiNumber
    Rois{1,m}=reshape(Rois{1,m},[prod(size(Rois{1,m}(:))),1]);
%     if isempty(ExcludeRoiIds{1,m})==0
%         Rois{1,m}(end+1,1)=ExcludeRoiIds{1,m};
%     else
%         Rois{1,m}(end+1,1)=0;
%     end
end


[Factor,MaxVal,MinVal,ValRange,Digs,Xpix,Ypix,Zpix]=deal(zeros(RoiNumber,1,'double'));

for m=1:RoiNumber; % get info on each of the stacks
    
    %     minMax(m,1:2)=[min(rois{m}(:)),max(rois{m}(:))];
    %     minMax(m,3)=minMax(m,2)-minMax(m,1)+1;
    MinVal(m)=min(Rois{m}(:));
    MinMax(m,1)=MinVal(m);
    if MinVal(m)<1;
        Rois{m}=Rois{m}+1-MinVal(m);
    elseif MinVal(m)>1;
        Rois{m}=Rois{m}+1-MinVal(m);
    end
    MinVal(m)=1;
    MaxVal(m)=max(Rois{m}(:));
    MinMax(m,2)=MinMax(m)+MaxVal(m)-1;
    ValRange(m)=MaxVal(m)-MinVal(m)+1;
    Digs(m)=size( num2str(MaxVal(m)),2);
    Xpix(m)=size(Rois{m},1);
    Ypix(m)=size(Rois{m},2);
    Zpix(m)=size(Rois{m},3);
end

% calculate how many digits will be necessary to concatenate all data in one array
if sum(Digs(:))<3;
    Type='uint8';
elseif sum(Digs(:))<5;
    Type='uint16';
elseif sum(Digs(:))<10;
    Type='uint32';
else
    Type='single';
end

% for m=1:roiNumber;
%     factor(m)=10 .^ sum(digs(m+1:end));
% end

if all(Xpix == Xpix(1)) && all(Ypix == Ypix(1)) && all(Ypix == Ypix(1)); % check if all arrays have the same size
else
    disp('inequal dimensions, not able to perform summing');
    return
end

Selector=zeros(Xpix(1),Ypix(1),Zpix(1),Type); % concatenate all rois into one array
for m=1:RoiNumber;
    %     selector=selector+cast(rois{m},type).*    10^sum(digs(m+1:end));
    Factor=10 .^ sum(Digs(m+1:end));
    Selector=Selector+cast(Rois{m},Type).*    Factor;
end

% calculate the distribution of rois
% Selector = reshape(Selector,[prod(size(Selector(:))),1]);
for m=1:ArrayNumber
    %     SumArray{m} = reshape(SumArray{m},[prod(size(Selector(:))),1]);
    %     ResultsSum{m} = accumarray(selector, sumArray{m});
    ResultsSum = accumarray(Selector, SumArray{m});
    SumArray{m}(:)=1;
    ResultsNum = accumarray(Selector, SumArray{m});
    
    % generate backbone for ouput-results
    %     wave1=uint64(valRange); wave1=wave1.';
    %     sumRes=zeros(wave1,1,'double');
    SumRes=zeros(uint64(ValRange(m,1)),1,'double');
    
    NumRes=SumRes;
    
    Wave1=1:size(ResultsNum,1); Wave1=Wave1.';
    Ids=zeros(size(ResultsNum,1),RoiNumber,'uint64');
    for m=1:RoiNumber;
        Factor=10.^sum(Digs(m:end));
        Wave2=rem(Wave1./Factor,1);
        Wave2=Wave2 .* 10^Digs(m);
        Ids(:,m)=floor(Wave2(:)+0.0001);
    end
    
    NonZero=find(ResultsNum~=0);
    
    for m=1:size(NonZero,1);
        Wave1=NonZero(m);
        Index=num2cell(Ids(Wave1,1:end));
        SumRes(Index{:})=ResultsSum(Wave1,1);
        NumRes(Index{:})=ResultsNum(Wave1,1);
    end
end



% if exist('ExcludeRoiIds')~=1
%     ExcludeRoiIds=repmat({[]},[1,RoiNumber]);
% end
% for m=1:RoiNumber
%     RoiIds{m,1}=unique(Rois{m});
%     if isempty(ExcludeRoiIds{1,m})==0
%         Wave1=find(RoiIds{m,1}==ExcludeRoiIds{1,m});
%         RoiIds{m,1}(Wave1)=[];
%         Wave2=RoiIds{m,1}(1)-1; % define excluded ID as one below the lowest
%         ExcludeRoiIds{1,m}=Wave2;
%         if isempty(Wave1)==0
%             Rois{1,m}(Rois{1,m}==ExcludeRoiIds{1,m})=Wave2; % set all excluded roi values to the ExcludeValue
%         end
%     end
% end


if exist('ExcludeRoiIds')~=1
    ExcludeRoiIds=repmat({[]},[1,RoiNumber]);
end
for m=1:RoiNumber
    AllInd=(1:size(NumRes,m)).';
    if isempty(ExcludeRoiIds{1,m})==0
        Wave1=find(RoiIds{m,1}==ExcludeRoiIds{1,m});
        AllInd(Wave1)=[];
        RoiIds{m,1}(Wave1)=[];
    end
    Index{1,m}=AllInd.';
    MinMax(m,1:2)=[min(RoiIds{m,1}(:)),max(RoiIds{m,1}(:))];
end
SumRes=SumRes(Index{:});
NumRes=NumRes(Index{:});
% MinMax(:,1)=MinMax(:,1)+1;

Out=struct;
Out.SumRes=SumRes;
Out.NumRes=NumRes;
Out.MinMax=MinMax;
Out.RoiIds=RoiIds;

if RoiNumber<3
    RoiClass=table;
    % single class version
    for m=1:size(NumRes,2)
        [First,Last]=firstLastNonzero(NumRes(:,m));
        if First==0
            keyboard;
        end
        RoiClass.MinMax(m,1)={[First;Last]};
        RoiClass.RoiId(m,1)=RoiIds{2,1}(m,1);
        Wave1=table;
        Wave1.Axis=(MinMax(1,1)+First-1:MinMax(1,1)+Last-1).';
        Wave1.NumRes=NumRes(First:Last,m);
        Wave1.SumRes=SumRes(First:Last,m);
        Wave1.MeanRes=Wave1.SumRes./Wave1.NumRes;
        RoiClass.Data(m,1)={Wave1};
    end
    
    Out.RoiClass=RoiClass;
    
end
