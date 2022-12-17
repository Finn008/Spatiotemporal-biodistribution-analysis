% version 2-3: heading zeros in dimension 1 are cut out
function [Out]=Summer_3(SumArray,Rois,ExcludeRoiIds,In)
if exist('In')==1
    v2struct(In);
end
if isempty(SumArray)||isempty(SumArray{1})
    SumArray=Rois(1); SumArray{1}(:)=1;
end

RoiNumber=size(Rois,2);
ArrayNumber=size(SumArray,2);

MinMax=zeros(RoiNumber,2);

for m=1:ArrayNumber
    SumArray{1,m}=reshape(SumArray{1,m},[prod(size(SumArray{1,m}(:))),1]);
end
for Roi=1:RoiNumber
    Rois{1,Roi}=reshape(Rois{1,Roi},[prod(size(Rois{1,Roi}(:))),1]);
end

[Factor,MaxVal,MinVal,ValRange,Digs,Xpix,Ypix,Zpix]=deal(zeros(RoiNumber,1,'double'));

for Roi=1:RoiNumber; % get info on each of the stacks
    MinVal(Roi)=min(Rois{Roi}(:));
    MinMax(Roi,1)=MinVal(Roi);
    if MinVal(Roi)<1;
        Rois{Roi}=Rois{Roi}+1-MinVal(Roi);
    elseif MinVal(Roi)>1;
        Rois{Roi}=Rois{Roi}+1-MinVal(Roi);
    end
    MinVal(Roi)=1;
    MaxVal(Roi)=max(Rois{Roi}(:));
    MinMax(Roi,2)=MinMax(Roi)+MaxVal(Roi)-1;
    ValRange(Roi)=MaxVal(Roi)-MinVal(Roi)+1;
    Digs(Roi)=size( num2str(MaxVal(Roi)),2);
    Xpix(Roi)=size(Rois{Roi},1);
    Ypix(Roi)=size(Rois{Roi},2);
    Zpix(Roi)=size(Rois{Roi},3);
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

if all(Xpix == Xpix(1)) && all(Ypix == Ypix(1)) && all(Ypix == Ypix(1)); % check if all arrays have the same size
else
    disp('inequal dimensions, not able to perform summing');
    return
end

Selector=zeros(Xpix(1),Ypix(1),Zpix(1),Type); % concatenate all rois into one array
for Roi=1:RoiNumber;
    Factor=10 .^ sum(Digs(Roi+1:end));
    Selector=Selector+cast(Rois{Roi},Type).*    Factor;
end

% calculate the distribution of rois
for Ar=1:ArrayNumber
    ResultsSum = accumarray(Selector, SumArray{Ar});
    SumArray{Ar}(:)=1;
    ResultsNum = accumarray(Selector, SumArray{Ar});
    
    % generate backbone for ouput-results
    SumRes=zeros(uint64(ValRange(Ar,1)),1,'double');
    
    NumRes=SumRes;
    
    Wave1=1:size(ResultsNum,1); Wave1=Wave1.';
    Ids=zeros(size(ResultsNum,1),RoiNumber,'uint64');
    for Roi=1:RoiNumber;
        Factor=10.^sum(Digs(Roi:end));
        Wave2=rem(Wave1./Factor,1);
        Wave2=Wave2 .* 10^Digs(Roi);
        Ids(:,Roi)=floor(Wave2(:)+0.0001);
    end
    
    NonZero=find(ResultsNum~=0);
    
    for m=1:size(NonZero,1);
        Wave1=NonZero(m);
        Index=num2cell(Ids(Wave1,1:end));
        SumRes(Index{:})=ResultsSum(Wave1,1);
        NumRes(Index{:})=ResultsNum(Wave1,1);
    end
end

for Roi=1:RoiNumber
    %     RoiIds{m,1}=unique(Rois{m});
    RoiIds{Roi,1}=(MinMax(Roi,1):MinMax(Roi,2)).';
end

if exist('ExcludeRoiIds')~=1
    ExcludeRoiIds=repmat({[]},[1,RoiNumber]);
end
for Roi=1:RoiNumber
    AllInd=(1:size(NumRes,Roi)).';
    if isempty(ExcludeRoiIds{1,Roi})==0
        Wave1=find(RoiIds{Roi,1}==ExcludeRoiIds{1,Roi});
        AllInd(Wave1)=[];
        RoiIds{Roi,1}(Wave1)=[];
    end
    Index{1,Roi}=AllInd.';
end
SumRes=SumRes(Index{:});
NumRes=NumRes(Index{:});

% cut off heading zero chunk in dimension 1
for Roi=1:1 % RoiNumber dimensions
    [First,Last]=firstLastNonzero_2(NumRes,1);
    SumRes=SumRes(First:Last,:,:);
    NumRes=NumRes(First:Last,:,:);
    RoiIds{1,1}=RoiIds{1,1}(First:Last,1);
end
for Roi=1:RoiNumber
    MinMax(Roi,1:2)=[min(RoiIds{Roi,1}(:)),max(RoiIds{Roi,1}(:))];
end


Out=struct;
Out.SumRes=SumRes;
Out.NumRes=NumRes;
Out.MinMax=MinMax;
Out.RoiIds=RoiIds;

if exist('asdfasdfasdfadsf') && RoiNumber==2
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
