function [Out]=getHistograms_3(ii,Data3D,Inclusion)
global W;
v2struct(ii);
DepthInfo=table;

DataClass=class(Data3D);
if strcmp(DataClass,'uint8')
    BitRange=255;
elseif strcmp(DataClass,'uint16')
    BitRange=65535;
end
Pix=[size(Data3D,1);size(Data3D,2);size(Data3D,3)];
% ZumRange=[0,ceil(Pix(3)*Zres/10)*10];
PixTotal=prod(size(Data3D(:,:,:,1)));

%% generate histogram and percMap of whole stack
Data3D=Data3D+1;
if isempty(Inclusion)==0
%     Data3D=Data3D.*uint8(Inclusion(:,:,:));
    Data3D=Data3D.*cast(Inclusion,DataClass);
end
Data1D = reshape(Data3D(:,:,:),[PixTotal,1]);
Histogram =histc(Data1D,0:BitRange); % histogram of whole stack
% Histogram=cast(Histogram,DataClass);
Histogram(1)=[]; % zero values are excluded voxels
NormHistogram = Histogram(:)./ max(Histogram(2:end))*100; % take out intensity value zero

AbsPercMap(1)=Histogram(1);
for n=2:size(Histogram,1) % previously 65535
    AbsPercMap(n,1)=AbsPercMap(n-1,1)+Histogram(n);
end

NormPercMap=AbsPercMap(:)/AbsPercMap(end)*100;
MaxIntensity=max(Data1D(:));

[Percentiles,PercentilesAvg]=percentileGenerator(NormPercMap);

%% generate depthProfile
if exist('ZumBin') && isempty(ZumBin)==0;
    
    ZpixBin=round(ZumBin/Zres);
    ZbinNumber=ceil(Pix(3)/ZpixBin);

    DepthXaxis=(0:ZumBin:ZumBin*(ZbinNumber-1)).';
    PixPerBin=Pix(1)*Pix(2)*ZpixBin;
    virtualPixNumber=ZbinNumber*PixPerBin;
    Data1D(virtualPixNumber,1)=0;
    HistogramProfile(BitRange+1,ZbinNumber)=0;
%     HistogramProfile=cast(HistogramProfile,DataClass);
    MeanProfile(ZbinNumber,1)=0;
    MeanProfileAllIncluded(ZbinNumber,1)=0;
    for n=1:ZbinNumber
        DataBin=Data1D((n-1)*PixPerBin+1:n*PixPerBin);
        HistogramProfile(:,n)= histc(DataBin(:),0:BitRange);
        MeanProfileAllIncluded(n,1)=mean(DataBin);
        MeanProfile(n,1)=mean(DataBin(DataBin>0));
    end
    HistogramProfile(1,:)=[]; % zero values are excluded voxels
    NormMeanProfile=MeanProfile ./ max(MeanProfile(:))*100;
    NormMeanProfileAllIncluded=MeanProfileAllIncluded./ max(MeanProfileAllIncluded(:))*100;
    % check if numbers correspond to excluded pixels
    NormHistogramProfile = HistogramProfile ./ max(max(HistogramProfile(2:end,:)))*100;
    
%     AbsPercMapProfile(BitRange,ZbinNumber)=0;
%     AbsPercMapProfile=zeros(BitRange,ZbinNumber,DataClass);
    AbsPercMapProfile=zeros(BitRange,ZbinNumber,'double');
    AbsPercMapProfile(1,:)=HistogramProfile(1,:);
    for n=2:BitRange
        AbsPercMapProfile(n,:)=AbsPercMapProfile(n-1,:)+HistogramProfile(n,:);
    end
    
    NormPercMapProfile=AbsPercMapProfile;
    for n=1:ZbinNumber;
        NormPercMapProfile(:,n)=AbsPercMapProfile(:,n)/AbsPercMapProfile(end,n)*100;
    end
    
    % for each depth bin determine intensity at which defined percentile of all pixels are included
    [PercentileProfile,PercentileProfileAvg]=percentileGenerator(NormPercMapProfile);
    NormPercentileProfile=PercentileProfile;
    NormPercentileProfileAvg=PercentileProfileAvg;
    for n=1:size(PercentileProfile,1);
        NormPercentileProfile{n,:}=PercentileProfile{n,:}/max(PercentileProfile{n,:})*100;
        NormPercentileProfileAvg{n,:}=PercentileProfileAvg{n,:}/max(PercentileProfileAvg{n,:})*100;
    end
    
    % convert to uint16
    

%     %% fit the data
%     if exist('CorrType')==1 && strcmp(CorrType,'InVivoFixed')==0
%         J=struct;
%         J.CorrType=CorrType;
%         J.Xaxis=DepthXaxis;
%         J.NormPercentileProfile=NormPercentileProfileAvg;
%         J.SavePath=SavePath;
%         J.BaseName=BaseName;
%         J.ZumRange=ZumRange;
%         J.Zres=Zres;
%         J.Fileinfo=Fileinfo;
%         try; J.FitMinCenterMax=FitMinCenterMax; end;
%         [Out1]=fitFunction(J);
%         Out.FitTotal=Out1.FitTotal;
%         DepthInfo.FitTotal={Out.FitTotal};
%         Out.FitMinCenterMax=Out1.FitMinCenterMax;
%         DepthInfo.FitMinCenterMax={Out.FitMinCenterMax};
%         Out.Exponent=Out1.Exponent;
%         DepthInfo.Exponent={Out.Exponent};
%         
%     end
end
clear Data1D;

%% output
% convert to uint16
Wave1={'HistogramProfile';'NormHistogramProfile';'PercentileProfile';'Percentiles''NormPercentileProfile';'NormPercentileProfileAvg';'NormPercMapProfile';};
for m=1:size(Wave1,1)
    if exist(Wave1{m,1})==1
        [Out2]=convert2uint16(eval(Wave1{m,1}),'uint16');
        Path=[Wave1{m,1},'=Out2;'];
        eval(Path);
    end
end
% Wave1{m,2}=eval(Wave1{m,1});
% v2struct(Out);
Out=struct;
if exist('ZumBin') && isempty(ZumBin)==0;
    Out.HistogramProfile=HistogramProfile;
    Out.NormHistogramProfile=NormHistogramProfile;
    Out.NormPercMapProfile=NormPercMapProfile;
    Out.PercentileProfile=PercentileProfile;
%     DepthInfo.PercentileProfile={uint16(PercentileProfile{:,:})};
    DepthInfo.PercentileProfile={PercentileProfile};
%     DepthInfo.PercentileProfile={uint16(PercentileProfile{:,:})};
    Out.NormPercentileProfile=NormPercentileProfile;
    Out.NormPercentileProfileAvg=NormPercentileProfileAvg;
end
Out.NormPercMap=NormPercMap;
Out.MaxIntensity=MaxIntensity;
Out.Histogram=Histogram;
Out.Percentiles=Percentiles;
DepthInfo.Percentiles={Percentiles};
Out.PercentilesAvg=PercentilesAvg;
DepthInfo.PercentilesAvg={PercentilesAvg};


DepthInfo.Datenum=datenum(now);
Out.DepthInfo=DepthInfo;



