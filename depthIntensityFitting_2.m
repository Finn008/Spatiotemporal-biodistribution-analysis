function [OrigData,Output]=depthIntensityFitting_2(Data,Res,Percentile,TargetValue,Masking,Outside,Filename,EndVersion)
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
    for Z=1:Pix(3)
        Slice=Data(:,:,Z);
        Mask(:,:,Z)=Slice>PercProfile(Z,1);
    end
    J=struct('Connectivity',6,'Res',Res,'ThreshVolume',1,'ErodeWindow',ones(3,3));
    Wave1=generateSurfaceMatlab(Mask,J);
end
PercProfile=double(PercProfile);
Deviation1=diff(smooth(smooth(smooth(PercProfile))));
Deviation2=diff(smooth(smooth(smooth(Deviation1))));
Deviation3=diff(smooth(smooth(smooth(Deviation2))));
Deviation1=Deviation1/max(abs(Deviation1(:)));
Deviation2=Deviation2/max(abs(Deviation2(:)));
Deviation3=Deviation3/max(abs(Deviation3(:)));



% Start: intensity is maximal, Dev1 positive before and negative afterwards, Dev2 is minimal

X=(1:Pix(3)).'*Res(3);
[~,Start]=max(PercProfile); % first try real max
[~,Wave1]=max(smooth(smooth(PercProfile)));
if abs(Start-Wave1)*Res(3)>3
    Start=Wave1;
end
um2=ceil(2/Res(3));
Wave1=min(size(Deviation1,1),Start+um2);
Dev1After=mean(Deviation1(Start+1:Wave1));
Wave1=max(1,Start-um2);
Dev1Before=mean(Deviation1(Wave1:Start-1));
[~,Dev2min]=min(Deviation2);
Distance2Top=(Pix(3)-Start)*Res(3);
Distance2Bottom=Start*Res(3);
Distance2Dev2min=abs(Dev2min-Start)*Res(3);
if Dev1Before>0 & Dev1After<0 & Distance2Top>3 & (Distance2Bottom>1 | Distance2Dev2min<1.1)
    Error(1)=0;
else
    Error(1)=1;
    Start=1;
    disp('depthIntensityFitting not successful');
end

if exist('EndVersion')~=1
    EndVersion='Standard';
end

if strcmp(EndVersion,'Standard')
    % Raw: sharply up, long slightly falling plateau, sharp down
    % Dev1: sharp peak upward, long around zero, sharp peak downwards
    % Dev2: sharp peaks up-down, long zero, sharp down-up
    
    % Definition: after Start, first minimal Dev2 after Dev3<0, Dev1 negative before and even stronger after
    EndOfInitialDev2=find(Deviation3(Start:end)<0,1)+Start; % point when Dev becomes less than 0 is middel maximum of Dev2
    [~,End]=min(Deviation2(EndOfInitialDev2:end)); End=End+EndOfInitialDev2;
    
    Wave1=min(size(Deviation1,1),End+um2);
    Dev1After=mean(Deviation1(End+1:Wave1));
    Wave1=max(1,End-um2);
    Dev1Before=mean(Deviation1(Wave1:End-1));
    Distance2Start=(End-Start)*Res(3);
    Distance2Top=(Pix(3)-End)*Res(3);
    if Dev1Before<0 & Dev1After<Dev1Before & (Distance2Top<1 | Distance2Start>3) % & Distance2Dev2min<1.1
        Error(2)=0;
    else
        Error(2)=1;
        disp('depthIntensityFitting not successful');
    end
end

if strcmp(EndVersion,'SteepFallingRaw')
    % Raw: sharply up, long steep fall (no plateau), bends into bottom (no sharp down)
    % Dev1: sharp peak upward, broad downward valley (instad zero plateau followed by sharp down)
    % Dev2: sharp peaks up-down, rather undefined slightly decreasing with slight downward bump in the end
    % Dev3: 

    %%%% Definition before: Dev1 above -0.01 %     End=find(Deviation1(Start:end)>=-0.01,1)+Start;
    % Definition 2017.08.28: minimal Deviation3 after maximal Deviation1
    [~,Wave1]=max(Deviation1(Start:end)); Wave1=Wave1+Start;
    [Min,End]=min(Deviation3(Wave1:end));
    End=End+Wave1;
    Distance2Start=(End-Start)*Res(3);
    Distance2Top=(Pix(3)-End)*Res(3);
    if (Distance2Top<1 | Distance2Start>3)
        Error(2)=0;
    else
        Error(2)=1;
        End=Pix(3);
        disp('depthIntensityFitting not successful');
    end
end

if max(Error)==0
    End=End-round(0.8/Res(3));
    Zaxis=X-Start*Res(3);
    Ft= fittype('a*exp(b*x)',...
        'dependent',{'y'},'independent',{'x'},...
        'coefficients',{'a','b'});
    Opts=fitoptions('Method','NonlinearLeastSquares');
    Opts.Upper=[PercProfile(Start)*10/8,0]; % 0.754
    Opts.Start=[PercProfile(Start),0]; % 0.754
    Opts.Lower=[PercProfile(Start)*8/10,-0.5];

    Type='Max&Dev2Min';
    if strcmp(Type,'Max&Dev2Min')
        Wave1=ones(Pix(3),1);
        Wave1(Start:End,1)=0;
        Opts.Exclude=Wave1;
        Fit=fit(Zaxis,PercProfile,Ft,Opts);
    else
        Fit=fit(X,PercProfile,Ft,Opts);
        Difference=abs(feval(Fit,X)-PercProfile);
        Exclude=Difference>prctile(Difference,80);
        Opts.Exclude=Exclude;
        Fit=fit(X,PercProfile,Ft,Opts);
    end
    
    Correction=feval(Fit,Zaxis);
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

figure; hold on;
plot(X,PercProfile/max(PercProfile(:)),'r');
plot(X(2:end),Deviation1,'k'); % black
plot(X(2:end-1),Deviation2,'b'); % green
plot(X(2:end-2),Deviation3,'g'); % green
try; Fit=Fit(X)/Fit(X(Start)); end;
try; plot(X,Fit,'m'); end;
line([Start(1)*Res(3),Start(1)*Res(3)],[-1,1],'Color','k');
line([End*Res(3),End*Res(3)],[-1,1],'Color','k');
line([min(X),max(X)],[0,0],'Color','k');
set(gca,'ylim',[-1;1]);
legend('Raw','Dev1','Dev2','Dev3','Fit');
Path=['\\GNP90N\share\Finn\Analysis\Output\DepthIntensityFitting\'];
if exist(Path)~=7
    mkdir(Path);
end
saveas(gcf,[Path,'\',Filename,'.png']);
close Figure 1;

if exist('InitialPix')==1
    Data=interpolate3D(Data,[],[],InitialPix);
end
Output=struct;
Output.Error=Error;
Output.StartEndUm=[Start;End]*Res(3);
Output.SliceThickness=(End-Start)*Res(3);
