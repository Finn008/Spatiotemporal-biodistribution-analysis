function [Container]=processTraceGroups_Boutons1(Selection,BinInfo)

Container=struct;

% exclude traces
% PlaqueList(PlaqueList.MouseId==275,:)=[];
% PlaqueList(PlaqueList.MouseId==351,:)=[];
% PlaqueList(PlaqueList.MouseId==346,:)=[];
% PlaqueList(PlaqueList.MouseId==2PlaqueList(PlaqueList.MouseId==351,:)=[];79,:)=[];
% PlaqueList(PlaqueList.MouseId==347 & ceil(PlaqueList.Radius)==12,:)=[];
% PlaqueList(PlaqueList.MouseId==351 & ceil(PlaqueList.Radius)==16,:)=[];
Selection(isnan(Selection.RadiusFit1),:)=[];
Wave1=find(nansum(Selection.Boutons1(:,50:52),2)==0);
Selection(Wave1,:)=[];

if size(Selection,1)==0
    return;
end

Data=Selection.Boutons1;
Data(Data==Inf)=NaN;

Data=weightedMean(Data,[],100,3).'; % Settings.DistRel.MeanTrim
Xdata=(1:size(Data,1)).';

if nansum(Data(:))==0
    return;
end

DataMinMax=find(isnan(Data)==0,1);
Wave1=find(isnan(Data(DataMinMax:end)),1);
if isempty(Wave1)
    DataMinMax(2,1)=256;
else
    DataMinMax(2,1)=Wave1+DataMinMax-2;
end

if DataMinMax(1)>50 || DataMinMax(2)<60
%     keyboard;
    return;
end

X=(-49:206).';
Exclude=isnan(Data);
% IndZero=find(Data(1:50)==0);
Wave1=find(isnan(Data(1:51))==0&Data(1:51)~=0,1); % 51 not 50 to allow finding only 50==0
IndZero=find(Data(1:Wave1)==0);
% Wave1=find(isnan(Data(1:50)==0)&Data(1:50)~=0,1);
X(IndZero)=X(max(IndZero));
Weights=ones(size(Data,1),1);
Weights(IndZero)=7; % Weights(IndZero)=size(IndZero,1);
Weights(90:end)=0;


FitType='MonoPhasicAssociation';

%% fit mono-phasic association curve
if strcmp(FitType,'MonoPhasicAssociation')
    Coefficients=table;
    
    Coefficients.Top=[prctile(Data(1:70),80);0.1;0.03];
    Coefficients.Y0=[0;min(0.1,Coefficients.Top(1));0]; % Coefficients.Y0=[0;0.1;0];
    Coefficients.K=[0;1;1]; % Coefficients.K=[0;1;1];
    
    Ft= fittype('Y0+(Top-Y0)*(1-exp(-K*x))',...
        'dependent',{'y'},'independent',{'x'},...
        'coefficients',{'Y0','Top','K'});
    Opts=fitoptions('Method','NonlinearLeastSquares');
    Opts.Robust='Bisquare';
    Opts.Exclude=Exclude;
    Opts.Lower=[Coefficients.Y0(1),Coefficients.Top(1),Coefficients.K(1)];
    Opts.Upper=[Coefficients.Y0(2),Coefficients.Top(2),Coefficients.K(2)];
    Opts.Startpoint=[Coefficients.Y0(3),Coefficients.Top(3),Coefficients.K(3)];
    Opts.Weights=Weights;
%     Opts.MaxIter=1000;
    Fit=fit(X,Data,Ft,Opts);
    Coefs=coeffvalues(Fit).';
end

if strcmp(FitType,'SmoothingSpline')
    [Curve]=fit(Xdata,Data,'smoothingspline','SmoothingParam',Settings.DistRel.SmoothingParam,'Exclude',isnan(Data));
end

FitData=feval(Fit,-49:206);
FitData(Exclude)=NaN;
FitData(FitData<0)=0;
NormFitData=FitData./max(FitData(:))*100;
Container.FitData=FitData;
Container.NormFitData=NormFitData;


GenerateFigure=0;
if GenerateFigure==1
    figure;
    hold on;
    Path=['M',num2str(BinInfo.MouseId),',Id',num2str(BinInfo.Id),',T',BinInfo.TimeBin{1},',Rad',num2str(BinInfo.RadMin),'-',num2str(BinInfo.RadMax)];
    title([Path,', Y0: ',num2str(round(Coefs(1),3)),', Top: ',num2str(round(Coefs(2),3)),', K: ',num2str(round(Coefs(3),2))]);
    plot(X,Data,'.k');
    plot(Fit,'-k');
    Range=[-10,100,0,0.05];
    axis(Range);
    FolderPath=['\\GNP90N\share\Finn\Analysis\output\Boutons2\M',num2str(BinInfo.MouseId)];
    if exist(FolderPath)~=7
        mkdir(FolderPath);
    end
    saveas(gcf,[FolderPath,'\',Path,'.png'])
    close Figure 1;
end