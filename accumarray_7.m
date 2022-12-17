function [Output]=accumarray_7(Rois,Data,Function,OutputFormat,AccumMethod)

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
elseif iscell
    keyboard;
    if size(Rois,2)>1
        RoiNames=Rois(:,2);
    else
        RoiNames=strcat('Roi',num2strArray_3((1:size(Rois,1)).'));
    end
end



RoiNumber=size(Rois,1);


for Row=1:size(Rois,1)
    [Rois.Unique{Row},~,Rois.Data{Row}]=unique(Rois.Data{Row});
%     [Rois.Unique{Row},~,Rois.Data{Row}]=unique(uint16(Rois.Data{Row}));
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
Rois(:,'Data') = [];

if isempty(Data)
    Data=[{ones(Pix.','uint8'),'Count'};Data];
elseif isnumeric(Data)
        Data={Data};
elseif istable(Data)
    clear Wave1;
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

for Row=1:size(Data,1)
    
    if strcmp(AccumMethod,'Sparse')
        AccumArray=accumarray(double(Roi(:)),full(double(Data.Data{Row,1}(:))),[],Function,[],true);
    elseif strcmp(AccumMethod,'NonSparse')
        AccumArray=accumarray(Roi(:),Data.Data{Row,1}(:),[],Function);
    end
    
    
    if Row==1
        Values=nonzeros(AccumArray);
        Ind=find(AccumArray);
        
        Output=table;
        Output.LinRoi=Ind;
        for m=1:RoiNumber
            Wave1=floor(Ind/10^sum(Rois.Digits(m+1:end)));
%             Wave1=rem(Wave1,10^(Digits(m+1)-Digits(m)));
            Wave1=rem(Wave1,10^(Rois.Digits(m)));
            Wave1=Rois.Unique{m}(Wave1);
            
            Output{:,Rois.Name{m}}=Wave1;
        end
    end
    Output{:,Data.Name{Row}}=AccumArray(Output.LinRoi);
    clear AccumArray;
end
clear Roi; clear Data;

if strcmp(OutputFormat,'2D')
    keyboard;
    OrigOutput=Output;
    Output=zeros(0,0,'uint32');
    for m=1:max(OrigOutput.Roi2)
        Ind=find(OrigOutput.Roi2==m);
        Output(OrigOutput.Roi1(Ind),m)=OrigOutput.Value(Ind);
    end
end

% keyboard; % replace data again
% for m=1:RoiNumber
%     if RemoveExcludedRoi(m,1)==0; continue; end;
%     Wave1=find(Output{:,RoiNames{m}}==RemoveExcludedRoi(m,1));
%     Output(Wave1,:)=[];
% end
% if exist('ProvideLinInd')==1 & ProvideLinInd==1
%     Output.LinRowInd=Output.LinRoi;
% end
Output(:,'LinRoi')=[];
