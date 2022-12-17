function [Container]=processTraceGroups_Fraction(Selection,BinInfo,DataType)

Container=struct;
Selection(isnan(Selection.RadiusFit1),:)=[];
% Wave1=find(nansum(Selection.Boutons1(:,50:52),2)==0);
% Selection(Wave1,:)=[];

if size(Selection,1)==0
    return;
end

if strcmp(DataType,'Dystrophy')
    Data=Selection.DystrophiesPl.';
% elseif strcmp(DataType,'Bace1Corona')
%     Data=Selection.Bace1Corona.';
%     keyboard;    
else
    Data=Selection{:,DataType}.';
end

Data(Data==Inf)=NaN;

Data=nanmedian(Data,2)*100;
MinMax=find(isnan(Data)==0,1);
if isempty(MinMax); return; end;
MinMax(2,1)=find(isnan(Data(MinMax(1):end)),1)+MinMax(1)-2;
Exclude=isnan(Data);
Fit=fit((1:256).',Data,'smoothingspline','Exclude',Exclude,'SmoothingParam',0.7);

Xaxis=(MinMax(1):0.1:MinMax(2)).';
Wave1=feval(Fit,Xaxis);
EC50=Xaxis(find(Wave1<50,1))-50;

FitData=feval(Fit,(1:256).');
FitData(Exclude)=NaN;
FitData(FitData<0)=0;
FitData(FitData>100)=100;

Container.FitData=FitData;
Container.EC50=EC50;


return;
figure;
plot(Fit,(1:256).',Data);
% plot((1:256).',Data);
axis([MinMax(1),MinMax(2),0,max(Data)]);