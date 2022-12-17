function [Data]=depthIntensityFitting(Data,Res,Percentile,TargetValue,Masking,Outside,FilenameTotal)
Pix=size(Data).';

MaxVoxelNumber=1000000;
if prod(Pix(1:2))>MaxVoxelNumber
    Wave1=prod(Pix(1:2))/MaxVoxelNumber;
    PixCalc=ceil(Pix(1:2)/Wave1^0.5);
    Data=interpolate3D(Data,[],[],[PixCalc;Pix(3)]);
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
%     if size(Slice,1)>MaxVoxelNumber
%         Ind=round(linspace(1,size(Slice,1),MaxVoxelNumber)).';
%         Slice=Slice(Ind);
%     end
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
Deviation2=diff(diff(smooth(smooth(smooth(PercProfile)))));
% PercProfile=PercProfile/max(PercProfile(:));
Deviation1=Deviation1/max(abs(Deviation1(:)));
Deviation2=Deviation2/max(abs(Deviation2(:)));


% Start: intensity is maximal, Dev1 positive before and negative afterwards, Dev2 is minimal

X=(1:Pix(3)).'*Res(3);
[~,Start]=max(smooth(smooth(PercProfile)));
um2=ceil(2/Res(3));
Wave1=min(size(Deviation1,1),Start+um2);
Dev1After=mean(Deviation1(Start+1:Wave1));
Wave1=max(1,Start-um2);
Dev1Before=mean(Deviation1(Wave1:Start-1));
[~,Dev2min]=min(Deviation2);
Distance2Top=(Pix(3)-Start)*Res(3);
Distance2Bottom=Start*Res(3);
Distance2Dev2min=abs(Dev2min-Start)*Res(3);
if Dev1Before>0 & Dev1After<0 & Distance2Top>3 & (Distance2Bottom<1 | Distance2Dev2min<1.1)
    Error(1)=0;
else
    Error(1)=1;
end

% End: Dev1 negative before and even stronger after, Dev2 is minimal
[~,End]=min(Deviation2(Start:end)); End=End+Start;

Wave1=min(size(Deviation1,1),End+um2);
Dev1After=mean(Deviation1(End+1:Wave1));
Wave1=max(1,End-um2);
Dev1Before=mean(Deviation1(Wave1:End-1));
[~,Dev2min]=min(Deviation2(End:end));
Distance2Start=(End-Start)*Res(3);
Distance2Top=(Pix(3)-End)*Res(3);
Distance2Dev2min=abs(Dev2min-Start)*Res(3);
if Dev1Before<0 & Dev1After<Dev1Before & Distance2Dev2min<1.1 & (Distance2Top<1 | Distance2Start>3)
    Error(2)=0;
else
    Error(2)=1;
end

if max(Error)==0
    End=End-round(0.8/Res(3));
    
    Ft= fittype('a*exp(b*x)',...
        'dependent',{'y'},'independent',{'x'},...
        'coefficients',{'a','b'});
    Opts=fitoptions('Method','NonlinearLeastSquares');
    Opts.Robust='Bisquare';
    % Opts.Exclude=Exclude;
    Opts.Upper=[+Inf,0]; % 0.754
    Opts.Lower=[-Inf,-Inf];
    % Opts.MaxIter=70; % default 400
    
    
    Type='Max&Dev2Min';
    if strcmp(Type,'Max&Dev2Min')
        Wave1=ones(Pix(3),1);
        Wave1(Start:End,1)=0;
        Opts.Exclude=Wave1;
        Fit=fit(X,PercProfile,Ft,Opts);
    else
        Fit=fit(X,PercProfile,Ft,Opts);
        Difference=abs(feval(Fit,X)-PercProfile);
        Exclude=Difference>prctile(Difference,80);
        Opts.Exclude=Exclude;
        Fit=fit(X,PercProfile,Ft,Opts);
    end
    
    Correction=feval(Fit,X);
    for Z=1:Pix(3)
        Slice=Data(:,:,Z);
        Slice=single(Slice)/Correction(Z)*TargetValue;
        Slice=cast(Slice,class(Data));
        Data(:,:,Z)=Slice;
    end
else % donot change anything
    Wave1=single(Data)/single(prctile(Data(:),Percentile))*TargetValue;
    Data=cast(Wave1,class(Data));
    Start=1;
    End=Pix(3);
end



figure; hold on;
plot(X(2:end),Deviation1); % blue
plot(X(2:end-1),Deviation2); % orange
try; plot(X,Fit(X)/max(PercProfile(:))); end;
plot(X,PercProfile/max(PercProfile(:))); % yellow
line([Start(1)*Res(3),Start(1)*Res(3)],[0,1],'Color','k');
line([End*Res(3),End*Res(3)],[0,1],'Color','k');

Path=['\\GNP90N\share\Finn\Analysis\Output\DepthIntensityFitting\'];
if exist(Path)~=7
    mkdir(Path);
end
saveas(gcf,[Path,'\',FilenameTotal,'.png'])
close Figure 1;
