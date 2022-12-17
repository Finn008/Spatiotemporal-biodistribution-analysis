function [OrigData,Output]=depthIntensityFitting_6(Data,Res,Percentile,TargetValue,Masking,Outside,Path2file)
Pix=size(Data).';
OrigData=Data;
MaxVoxelNumber=1500000;
if prod(Pix(1:2))>MaxVoxelNumber
    Wave1=prod(Pix(1:2))/MaxVoxelNumber;
    PixCalc=ceil(Pix(1:2)/Wave1^0.5);
    Data=interpolate3D(Data,[],[],[PixCalc;Pix(3)]);
    InitialPix=Pix;
    Pix=size(Data).';
end


if exist('Outside') && isempty(Outside)==0 && isequal(size(Outside).',Pix)==0
    Outside=interpolate3D(Outside,[],[],Pix);
end

for Z=1:Pix(3)
    Slice=Data(:,:,Z);
    if exist('Outside') && isempty(Outside)==0
        Slice=Slice(Outside(:,:,Z)==0);
    end
    PercProfile(Z,1)=prctile(Slice(:),Percentile);
end
if exist('Masking')&& isempty(Masking)==0
    keyboard; % is still required? 2018.01.04
    for Z=1:Pix(3)
        Slice=Data(:,:,Z);
        Mask(:,:,Z)=Slice>PercProfile(Z,1);
    end
    J=struct('Connectivity',6,'Res',Res,'ThreshVolume',1,'ErodeWindow',ones(3,3));
    Wave1=generateSurfaceMatlab(Mask,J);
end

%%
T=table;
T.X=(1:Pix(3)).'*Res(3);
T.Y=smooth(smooth(smooth(double(PercProfile))));
% Equation='a*exp((log(0.5)/b)*x)+c*exp((log(0.5)/d)*x)';
Equation='a*exp(b*x)+c*exp(d*x)';

Ft= fittype(Equation,...
    'dependent',{'y'},'independent',{'x'},...
    'coefficients',{'a','b','c','d'});
Opts=fitoptions('Method','NonlinearLeastSquares');
Start=round(size(T,1)/4);
End=round(size(T,1)*3/4);
T.Exclude(:,1)=1;
% Threshold=[NaN;1.5;1.4;1.3;1.2;1.1;1.05];
Opts.Upper=[Inf,0,Inf,0.2];
Opts.Lower=[0,-0.2,0,0];
Opts.Start=[max(T.Y),-10,max(T.Y),10];
close all;
Figure=figure;
set(gcf,'Visible','off');
% set(Figure,'WindowStyle','Docked')
T.Exclude(:)=1;
T.Exclude(Start:End)=0;
Phase='Crude';
for m=1:100 %size(Threshold,1)
    if m>=2
        T.Fit2=Fit2(T.X);
        T.Ratio=T.Fit2./T.Y;
        T.Ratio(T.Ratio<1)=1./T.Ratio(T.Ratio<1);
        Wave1=T.Ratio(T.Exclude==0);
        MinMeanMaxRatioIncluded=[min(Wave1);mean(Wave1);max(Wave1)];
        if strcmp(Phase,'Crude')
            Threshold=max([prctile(Wave1,80);1.1]);
        else
            Threshold=max([prctile(Wave1,60);1.05]);
        end
        T.Exclude(:)=0;
        T.Exclude(T.Ratio>Threshold)=1;
        Start=find(T.Exclude==0,1);
        End=size(T,1)-find(flip(T.Exclude)==0,1)+1;
        T.Exclude(Start:End)=0;
        
        if strcmp(Phase,'Crude') && isequal(StartEnd,[Start;End])
            Phase='Fine';
        elseif strcmp(Phase,'Fine') && isequal(StartEnd,[Start;End])
            break;
        end
    end
    Opts.Exclude=T.Exclude;
    [Fit2,Gof2]=fit(T.X,T.Y,Ft,Opts);
    hold off;
    plot(T.X,T.Y,'.k');
    hold on;
    plot(T.X(T.Exclude==1),T.Y(T.Exclude==1),'.r');
    plot(T.X,Fit2(T.X),'g');
    ylim([0,max(T.Y)])
    try; text(T.X(1),max(T.Y)/2,num2str(round(Threshold,2)),'FontSize',10); end;
    
    Opts.Start=coeffvalues(Fit2);
    StartEnd=[Start;End];
    pause(0.2);
end
Fit2Coefs=coeffvalues(Fit2).';
StDev2=Gof2.rmse;
HalfDistance2=log(2)./Fit2Coefs([2;4]);
% HalfDistance2=log(2)./Fit2Coefs([4]);
End=End(end);
Start=Start(end);


%% fit with one-exponential function
Ft= fittype('a*exp(b*x)+c',...
    'dependent',{'y'},'independent',{'x'},...
    'coefficients',{'a','b','c'});
Opts=fitoptions('Method','NonlinearLeastSquares');
Opts.Upper=[Inf,0.2,max(T.Y)];
Opts.Lower=[0,-0.2,0];
Opts.Start=[max(T.Y),0,0];
Opts.Exclude=T.Exclude;
[Fit1,Gof1]=fit(T.X,T.Y,Ft,Opts);
Fit1Coefs=coeffvalues(Fit1).';
StDev1=Gof1.rmse;
T.Fit1=Fit1(T.X);
HalfDistance1=log(2)/Fit1Coefs(2);
Fit1Coefs(2)=HalfDistance1;
plot(T.X,Fit1(T.X),'r');

close Figure 1;


%% decide between Fit1 or Fit2
if StDev1<1.5*StDev2
    T.Correction=T.Fit1;
    FitType='Exp1';
    HalfDistance=HalfDistance1;
    StDev=StDev1;
else
    T.Correction=T.Fit2;
    FitType='Exp2';
    HalfDistance=HalfDistance2;
    StDev=StDev2;
end
  
Error=0;
if max(Error)==0
    for Z=1:Pix(3)
        Slice=OrigData(:,:,Z);
        Slice=single(Slice)/T.Correction(Z)*TargetValue;
        Slice=cast(Slice,class(OrigData));
        OrigData(:,:,Z)=Slice;
    end
else % donot change anything
    OrigData=OrigData*(TargetValue/double(peprctile(Data(:),Percentile)));
    %     Wave1=single(Data)/single(prctile(Data(:),Percentile))*TargetValue;
    %     Data=cast(Wave1,class(Data));
end



Figure=figure; hold on;
set(gcf,'Visible','off');
% set(Figure,'WindowStyle','Docked')
plot(T.X,T.Y,'.k');
plot(T.X(T.Exclude==1),T.Y(T.Exclude==1),'.r');
try; plot(T.X,T.Fit2,'m'); end;
try; plot(T.X,T.Fit1,'c'); end;
line([Start*Res(3),Start*Res(3)],[0,max(T.Y)],'Color','k');
line([End*Res(3),End*Res(3)],[0,max(T.Y)],'Color','k');

% line([Start(1)*Res(3),Start(1)*Res(3)],[-1,1],'Color','k');
% line([End*Res(3),End*Res(3)],[-1,1],'Color','k');
set(gca,'ylim',[0;max(T.Y)]);
Legend=legend('Raw','Exp2','Exp1');
set(Legend,'color','none');
set(Legend,'location','northeastoutside');

if strcmp(FitType,'Exp1')
    Wave1=['Exp1: ',num2str(round(HalfDistance1,1)),'µm, ','StDev: ',num2str(round(StDev2,1))];
    Color='c';
elseif strcmp(FitType,'Exp2')
    Wave1=['Exp2: ',num2str(round(HalfDistance2(1),1)),'µm, ',num2str(round(HalfDistance2(2),1)),'µm , StDev: ',num2str(round(StDev2,1))];
    Color='m';
end
text(T.X(round(size(T,1)/3)),max(T.Y)/2,Wave1,'Color',Color,'FontSize',10);
% dim = [.2 .5 .3 .3];
% str = 'Straight Line Plot from 1 to 10';
% annotation('textbox',dim,'String',str)
% if exist(Path2file)~=7
%     mkdir(Path2file);
% end
% saveas(gcf,[Path,'\',Filename,'.png']);
saveas(gcf,Path2file);

close Figure 1;

if exist('InitialPix')==1
    Data=interpolate3D(Data,[],[],InitialPix);
end
Output=struct;
Output.Error=Error;
Output.StartEndUm=[Start;End]*Res(3);
Output.SliceThickness=(End-Start)*Res(3);
Output.Fit1Coefs=Fit1Coefs;
Output.Fit2Coefs=Fit2Coefs;
Output.StDev1=StDev1;
Output.StDev2=StDev2;
Output.StDev=StDev;
Output.HalfDistance=HalfDistance;
Output.PercentileProfile=PercProfile;
