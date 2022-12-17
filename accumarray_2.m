% Roi1=[1;1;3;4;4;6;7;7;7;10];
% Roi2=[1;1;3;1;1;2;2;2;3;999];
% Roi3=[1;1;1;1;1;2;2;2;2;2];
% Rois={Roi1;Roi2;Roi3};
% Data=[1;2;3;4;5;;
% [Result]=accumarray_2(Rois,Data,@mean)
function [Output]=accumarray_2(Rois,Data,Function,OutputFormat)
% keyboard;

if exist('OutputFormat')~=1
    OutputFormat='Table';
end

if iscell(Rois)==0
    Rois={Rois};
%     keyboard; % check if works correctly for the first time
end
RoiNumber=size(Rois,1);
RemoveExcludedRoi=zeros(RoiNumber,1);
Roi=zeros(size(Rois{1,1}),'uint64');
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
if isempty(Data)
    Data=ones(Pix.','uint8');
end


Wave1=accumarray(Roi(:),Data(:),[],Function);

% Method='NonSparse';
% if strcmp(Method,'Sparse')
%     Wave2=accumarray(double(Roi(:)),double(Data(:)),[],Function,[],true);
% else
%     if strcmp(char(Function),'sum')
%         Wave1=accumarray(Roi(:),single(Data(:)),[],@(x) sum(x,'native'));
%     elseif strcmp(char(Function),'mean')
%         keyboard;
%         Wave1=accumarray(Roi(:),single(Data(:)),[],@(x) mean(x,'native'));
%     elseif strcmp(char(Function),'min')
%         keyboard;
%         Wave1=accumarray(Roi(:),single(Data(:)),[],@(x) min(x,'native'));
%     elseif strcmp(char(Function),'max')
%         keyboard;
%         Wave1=accumarray(single(Roi(1:100).'),single(Data(1:100).'),[],@max);
%     else
%         keyboard;
%     end
% end
clear Roi; clear Data; 
Values=nonzeros(Wave1);
Ind=find(Wave1);

clear Wave1;

Output=table;
for m=1:RoiNumber
    Wave1=floor(Ind/10^Digits(m));
    Wave1=rem(Wave1,10^(Digits(m+1)-Digits(m)));
    Output{:,['Roi',num2str(m)]}=Wave1;
end
Output.Value=Values;

for m=1:RoiNumber
    if RemoveExcludedRoi(m,1)==0; continue; end;
    Wave1=find(Output{:,['Roi',num2str(m)]}==RemoveExcludedRoi(m,1));
    Output(Wave1,:)=[];
end
if strcmp(OutputFormat,'2D')
    OrigOutput=Output;
    Output=zeros(0,0,'uint32');
    for m=1:max(OrigOutput.Roi2)
        Ind=find(OrigOutput.Roi2==m);
        Output(OrigOutput.Roi1(Ind),m)=OrigOutput.Value(Ind);
    end
end