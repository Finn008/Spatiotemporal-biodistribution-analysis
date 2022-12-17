% Roi1=[1;1;3;4;4;6;7;7;7;10];
% Roi2=[1;1;3;1;1;2;2;2;3;999];
% Roi3=[1;1;1;1;1;2;2;2;2;2];
% Rois={Roi1;Roi2;Roi3};
% Data=[1;2;3;4;5;;
% [Result]=accumarray_2(Rois,Data,@mean)
function [Output]=accumarray_3(Rois,Data,Function,OutputFormat)
% keyboard;

if exist('OutputFormat')~=1
    OutputFormat='Table';
end

if iscell(Rois)==0
    Rois={Rois};
end
if size(Rois,2)>1
    RoiNames=Rois(:,2);
else
    RoiNames=strcat('Roi',num2strArray_3((1:size(Rois,1)).'));
end

RoiNumber=size(Rois,1);
RemoveExcludedRoi=zeros(RoiNumber,1);
Roi=zeros(size(Rois{1,1}),'uint32');
Digits=0;
for m=1:size(Rois,1)
    Min=min(Rois{m,1}(:));
    if Min<1
        Max=max(Rois{m,1}(:));
        Rois{m,1}(Rois{m,1}<1)=Max+1;
        RemoveExcludedRoi(m,1)=Max+1;
    end
    
    Roi=Roi+uint32(Rois{m,1})*10^Digits(m,1); % donot use double, otherwise weird summation problems!!!, rather try uint64
    Digits(m+1,1)=size(num2str(round(max(Roi(:)))),2);
end
clear Rois;
Pix=size(Roi).';
if isempty(Data)==0
    if isnumeric(Data)
        Data={Data};
    end
    if size(Data)==1
        keyboard; % check if working
        Data(:,2)=strcat('Value',num2strArray_3((1:size(Data,1).')));
    end
end
Data=[{ones(Pix.','uint8'),'Volume'};Data];


for Row=1:size(Data,1)
    AccumArray=accumarray(Roi(:),Data{Row,1}(:),[],Function);
    
    if Row==1
        Values=nonzeros(AccumArray);
        Ind=find(AccumArray);
        
        Output=table;
        Output.LinRoi=Ind;
        for m=1:RoiNumber
            Wave1=floor(Ind/10^Digits(m));
            Wave1=rem(Wave1,10^(Digits(m+1)-Digits(m)));
            Output{:,RoiNames{m}}=Wave1;
        end
    end
    Output{:,Data{Row,2}}=AccumArray(Output.LinRoi);
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

for m=1:RoiNumber
    if RemoveExcludedRoi(m,1)==0; continue; end;
    Wave1=find(Output{:,RoiNames{m}}==RemoveExcludedRoi(m,1));
    Output(Wave1,:)=[];
end

Output(:,'LinRoi')=[];
