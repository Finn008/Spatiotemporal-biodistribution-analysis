function [Output]=accumarray_8(Rois,Data,Function,OutputFormat,AccumMethod,CountInstances)

if exist('OutputFormat')~=1
    OutputFormat='Table';
end

if istable(Rois)
    Wave1=table;
    for m=1:size(Rois,2)
        Wave1.Data(m,1)={Rois{:,m}};
    end
    Wave1.Name=Rois.Properties.VariableNames.';
    Rois=Wave1;
    clear Wave1;
elseif isnumeric(Rois)
    Wave1=table;
    Wave1.Data(1)={Rois};
    Wave1.Name(1)={'Roi1'};
    Rois=Wave1;
    clear Wave1;
elseif iscell(Rois)
    Rois=array2table(Rois,'VariableNames',{'Data';'Name'});
end
RoiNumber=size(Rois,1);

for Row=1:size(Rois,1)
    [Rois.Unique{Row},~,Rois.Data{Row}]=unique(Rois.Data{Row});
    Max=max(Rois.Data{Row});
    if Max<=255
        Rois.Data{Row}=uint8(Rois.Data{Row});
    elseif Max<=65535
        Rois.Data{Row}=uint16(Rois.Data{Row});
    elseif Max<=2^32-1
        Rois.Data{Row}=uint32(Rois.Data{Row});
    else
        keyboard;
    end
    Rois.Digits(Row,1)=size(num2str(round(Max)),2);
end

TotalDigits=sum(Rois.Digits);
Pix=size(Rois.Data{1,1}).';
Roi=zeros(Pix.','uint64');

for Row=1:size(Rois,1)
    Roi=Roi+uint64(Rois.Data{Row,1})*10^sum(Rois.Digits(Row+1:end)); % donot use double, otherwise weird summation problems!!!, rather try uint64
end

if max(Roi(:))==uint64(2^64); keyboard; end;
SparseRoi=Roi;
[UniqueRoi,~,Roi]=unique(Roi);
Rois(:,'Data') = [];
if isempty(Data)
    Data=[]; % in case an empty table is transferred
    Data=[{ones(Pix.','uint8'),'Count'};Data];
elseif isnumeric(Data)
    Data={Data};
elseif istable(Data)
    clear Wave1;
    if exist('CountInstances')==1 && strcmp(CountInstances,'CountInstances')
        Data.CountInstances(:,1)=1;
    end
    for m=1:size(Data,2)
        Wave1(m,1)={Data{:,m}};
    end
    Wave1(:,2)=Data.Properties.VariableNames.';
    Data=Wave1;
    clear Wave1;
end

if size(Data,2)==1
    Data(:,2)=strcat('Value',num2strArray_3((1:size(Data,1).')));
end

Data=array2table(Data,'VariableNames',{'Data';'Name'});

if exist('AccumMethod')~=1
    AccumMethod='NonSparse';
end
Output=table;
for Row=1:size(Data,1)
    if strcmp(Data.Name{Row,1},'CountInstances')
        Function=@nansum; % donot set back because is anyways the last Dataset
    end
    
    if strcmp(AccumMethod,'Sparse')
        keyboard; % attention! zero values in AccumArray are excluded!!!!
        AccumArray=accumarray(double(Roi(:)),full(double(Data.Data{Row,1}(:))),[],Function,[],true);
        Ind=find(AccumArray);
    elseif strcmp(AccumMethod,'NonSparse')
        AccumArray=accumarray(double(Roi(:)),full(double(Data.Data{Row,1}(:))),[],Function);
        Ind=(1:size(AccumArray,1)).';
    end
    if Row==1
        Output.LinRoi=Ind;
        Output{:,Data.Name{Row}}=AccumArray(Ind);
    else
        [~,Wave1]=ismember(Ind,Output.LinRoi);
        ZeroInd=find(Wave1==0);
        Wave1(ZeroInd)=(size(Output,1)+1:1:size(Output,1)+size(ZeroInd,1));
        Output.LinRoi(Wave1,1)=Ind;
        Output{Wave1,Data.Name{Row}}=AccumArray(Ind);
    end
    clear AccumArray;
end

Output.LinRoi=UniqueRoi(Output.LinRoi);
for m=1:RoiNumber
    MinMax=[sum(Rois.Digits(m+1:end))+1;sum(Rois.Digits(m:end))];
    Wave1=getNthNumeric(Output.LinRoi,MinMax);
    Wave1=Rois.Unique{m}(Wave1);
    Output{:,Rois.Name{m}}=Wave1;
end
clear Roi; clear Data;

if strcmp(OutputFormat,'2D')
%     keyboard;
    Output(Output.Roi1==0,:)=[];
    OrigOutput=Output;
    Output=zeros(0,0,'uint32');
    for m=1:max(OrigOutput.Roi2)
        Ind=find(OrigOutput.Roi2==m);
        Output(OrigOutput.Roi1(Ind),m)=OrigOutput.Value1(Ind);
%         Output(OrigOutput.Roi1(Ind),m)=uint64(OrigOutput.Value1(Ind));
    end
else
    Output(:,'LinRoi')=[];
end
