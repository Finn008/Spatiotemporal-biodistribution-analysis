function [OrigData,Output]=depthIntensityFitting_5(Data,Res,Percentile,TargetValue,Masking,Outside,Path2file,EndVersion)
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
PercProfile=smooth(smooth(smooth(double(PercProfile))));

%%
T=table;
T.X=(1:Pix(3)).'*Res(3);
T.Y=PercProfile;
Equation='a*exp((log(0.5)/-b)*x)*exp((log(0.5)/c)*x)+d';

Ft= fittype(Equation,...
    'dependent',{'y'},'independent',{'x'},...
    'coefficients',{'a','b','c','d'});
Opts=fitoptions('Method','NonlinearLeastSquares');
Start=round(size(T,1)/4);
End=round(size(T,1)*3/4);
T.Exclude(:,1)=1;
% T.Exclude(Start:End)=0;
Threshold=[NaN;2;1.5;1.3;1.1;1.05;1.02];
% Threshold=[NaN;2;1.5];
Opts.Upper=[Inf,0,Inf,max(T.Y)];
Opts.Start=[max(T.Y),-10,10,0];
Opts.Lower=[0,-Inf,0,0];
close all;
Figure=figure;
set(Figure,'WindowStyle','Docked')
T.Exclude(:)=1;
T.Exclude(Start:End)=0;
for m=1:size(Threshold,1)
    if m>=2
        T.Fit=Fit(T.X);
        T.Ratio=T.Fit./T.Y;
        T.Ratio(T.Ratio<1)=1./T.Ratio(T.Ratio<1);
        T.Exclude(:)=0;
        T.Exclude(T.Ratio>Threshold(m))=1;
        Start=find(T.Exclude==0,1);
        End=size(T,1)-find(flip(T.Exclude)==0,1)+1;
        T.Exclude(Start:End)=0;
    end
    Opts.Exclude=T.Exclude;
    [Fit,Gof]=fit(T.X,T.Y,Ft,Opts);
    
    hold off;
    plot(T.X,T.Y,'.k');
    hold on;
    plot(T.X(T.Exclude==1),T.Y(T.Exclude==1),'.r');
    plot(T.X,Fit(T.X),'g');
    ylim([0,max(T.Y)])
    A1=1;
%     FitCoefs=coeffvalues(Fit).';
end

close Figure 1;
End=End(end);
Start=Start(end);


    line([Start(m)*Res(3),Start(m)*Res(3)],[0,max(T.Y)],'Color','k');
    line([End(m)*Res(3),End(m)*Res(3)],[0,max(T.Y)],'Color','k');
%     pause(0.5);
    FitCoefs=coeffvalues(Fit).';
    T.Fit=Fit(T.X);
    T.Relation=T.Fit>T.Y;
    if T.Fit(Start(m))<T.Y(Start(m))
        Start(m+1)=Start(m)-1;
    else
        Start(m+1)=Start(m)+1;
    end
    if T.Fit(End(m))<T.Y(End(m))
        End(m+1)=End(m)+1;
    else
        End(m+1)=End(m)-1;
        Opts.Upper(3)=max([FitCoefs(3),1]);
    end
    if size(Start,2)>10 && size(unique([Start(end-4:end),End(end-4:end)]),2)==4
%         break;
    end

% for m=1:size(Threshold,1)
%     
%     Opts.Exclude=T.Exclude;
%     
%     [Fit,Gof]=fit(T.X,T.Y,Ft,Opts);
%     FitCoefs=coeffvalues(Fit).';
%     
%     T.Fit=Fit(T.X);
%     T.Ratio=T.Fit./T.Y;
%     T.Ratio(T.Ratio<1)=1./T.Ratio(T.Ratio<1);
%     T.Exclude(:)=0;
%     T.Exclude(T.Ratio>Threshold(m))=1;
% %     pause(1);
% end

% Opts.Upper=[PercProfile(Start)*10/8,0]; % 0.754
% Opts.Start=[PercProfile(Start),0]; % 0.754



Error=0;
if max(Error)==0
    FitCoefs=coeffvalues(Fit).';
    HalfDistance=FitCoefs(2);
    StDev=Gof.rmse;
    
%     Correction=feval(Fit,T.X);
    Correction=T.Fit;
    for Z=1:Pix(3)
        Slice=OrigData(:,:,Z);
        Slice=single(Slice)/Correction(Z)*TargetValue;
        Slice=cast(Slice,class(OrigData));
        OrigData(:,:,Z)=Slice;
    end
else % donot change anything
    OrigData=OrigData*(TargetValue/double(prctile(Data(:),Percentile)));
    %     Wave1=single(Data)/single(prctile(Data(:),Percentile))*TargetValue;
    %     Data=cast(Wave1,class(Data));
end



Figure=figure; hold on;
set(Figure,'WindowStyle','Docked')
plot(T.X,T.Y,'k');
try; plot(T.X,(Fit(T.X)),'r'); end;
line([Start*Res(3),Start*Res(3)],[0,max(T.Y)],'Color','k');
line([End*Res(3),End*Res(3)],[0,max(T.Y)],'Color','k');

% line([Start(1)*Res(3),Start(1)*Res(3)],[-1,1],'Color','k');
% line([End*Res(3),End*Res(3)],[-1,1],'Color','k');
set(gca,'ylim',[0;max(T.Y)]);
Legend=legend('Raw','Fit');
set(Legend,'color','none');
set(Legend,'location','northeastoutside');

text(T.X(round(size(T,1)/3)),max(T.Y)/2,[num2str(round(HalfDistance,1)),'µm (',num2str(round(StDev,1)),')'],'Color','r','FontSize',10);
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
Output.HalfDistance=HalfDistance;
Output.StDev=StDev;
