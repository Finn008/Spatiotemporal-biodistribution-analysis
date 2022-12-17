function [oo]=getHistograms_2(ii,data3D,exclusionVolume)
global w; global l; dbstop if error;
v2struct(ii);

oo=struct;
if strcmp(class(data3D),'uint8')
    bitRange=255;
elseif strcmp(class(data3D),'uint16')
    bitRange=65535;
end
if isempty(exclusionVolume)==0
    exclusionVolume=1-exclusionVolume(:,:,:); % included to 1 and excluded to 0
end

pix=[size(data3D,1);size(data3D,2);size(data3D,3)];

pixTotal=prod(size(data3D(:,:,:,1)));
%% generate histogram and percMap of whole stack
if isempty(exclusionVolume)==0
    data3D=(data3D+1).*uint16(exclusionVolume(:,:,:));
end
data1D = reshape(data3D(:,:,:),[pixTotal,1]);
histogram =histc(data1D,0:bitRange); % histogram of whole stack
histogram(1)=[]; % zero values are excluded voxels
normHistogram = histogram(:)./ max(histogram(2:end))*100; % take out intensity value zero

absPercMap(1)=histogram(1);
for n=2:size(histogram,1) % previously 65535
    absPercMap(n)=absPercMap(n-1)+histogram(n);
end

normPercMap=absPercMap(:)/absPercMap(end)*100;
maxIntensity=max(data1D(:));

[percentiles]=percentileGenerator(normPercMap);

if exist('savePath')==1 && isempty(savePath)==0;
    path=[savePath,',',baseName,',PercMap','.jpg'];
    figureBuilder(path,normPercMap(:),normHistogram(:),'percentile [%]','abundance',[0,100],[0,100],[],'percMap');
    
    path=[savePath,',',baseName,',histogram','.jpg'];
    figureBuilder(path,(1:size(normHistogram,1)).',normHistogram(:),'intensity','abundance',[0,min(find(normPercMap(:)>90))],[0,100],[],'histogram');
    
    path=[savePath,',',baseName,',IntensityVsPercentile','.jpg'];
    figureBuilder(path,(1:size(normHistogram,1)).',normPercMap(:),'intensity','percentile [%]',[0,min(find(normPercMap(:)>90))],[0,90],[],'IntensityVsPercentile');
end

oo.normPercMap=normPercMap;
oo.maxIntensity=maxIntensity;
oo.histogram=histogram;
oo.percentiles=percentiles;

%% generate depthProfile
if exist('ZumBin') && isempty(ZumBin)==0;
    ZpixBin=round(ZumBin/Zres);
    ZbinNumber=ceil(pix(3)/ZpixBin);
    pixPerBin=pix(1)*pix(2)*ZpixBin;
    virtualPixNumber=ZbinNumber*pixPerBin;
    data1D(virtualPixNumber,1)=0;
    histogramProfile(bitRange+1,ZbinNumber)=0;
    for n=1:ZbinNumber
        dataBin=data1D((n-1)*pixPerBin+1:n*pixPerBin);
        histogramProfile(:,n)= histc(dataBin(:),0:bitRange);
    end
    
    % check if numbers correspond to excluded pixels
    histogramProfile(1,:)=[]; % remove exclusion volume
    normHistogramProfile = histogramProfile ./ max(max(histogramProfile(2:end,:)))*100;
    oo.histogramProfile=histogramProfile;
    oo.normHistogramProfile=normHistogramProfile;
    
    absPercMapProfile(bitRange,ZbinNumber)=0;
    absPercMapProfile(1,:)=histogramProfile(1,:);
    for n=2:bitRange
        absPercMapProfile(n,:)=absPercMapProfile(n-1,:)+histogramProfile(n,:);
    end
    
    normPercMapProfile=absPercMapProfile;
    for n=1:ZbinNumber;
        normPercMapProfile(:,n)=absPercMapProfile(:,n)/absPercMapProfile(end,n)*100;
    end
    oo.normPercMapProfile=normPercMapProfile;
    
    % for each depth bin determine intensity at which defined percentile of all pixels are included
    [percentileProfile]=percentileGenerator(normPercMapProfile);
    oo.percentileProfile=percentileProfile;
    fitCoef=zeros(100,3);
    error=zeros(100,3);
    fittedPercentileProfile=percentileProfile;
    Xaxis=0:ZumBin:ZumBin*(ZbinNumber-1);
    for n=1:size(percentileProfile,1)
        [fit1,gof1]=fit(Xaxis.',percentileProfile{n,:}.','poly2','Robust','on');
        fitCoef(n,:)=coeffvalues(fit1);
        error(n,1)=gof1.rsquare;
        fittedPercentileProfile{n,:}(:)=YofBinFnc(Xaxis.',fitCoef(n,1),fitCoef(n,2),fitCoef(n,3),[]);
    end
    
    oo.fitCoef=fitCoef;
    oo.error=error;
    if isempty(savePath)==0;
        path=[savePath,',',baseName,',DepthVsPercentile','.jpg'];
        
        Yaxes=[percentileProfile{[20,40,60],:};fittedPercentileProfile{[20,40,60],:}].';
        
        figureBuilder(path,Xaxis.',Yaxes,'depth [um]','intensity [%]',[],[],'b-','DepthVsPercentile');
        
        percentileThresholds=[10,20,30,40,50,60,70,80,90,99];
        for n=1:size(percentileThresholds,2)
            path=[savePath,',',baseName,',DepthVsPercentile',num2str(percentileThresholds(1,n)),'.jpg'];
            Yaxes=[percentileProfile{percentileThresholds,:};fittedPercentileProfile{percentileThresholds,:}].';
            figureBuilder(path,Xaxis.',Yaxes(:,n),'depth [um]','intensity [%]',[],[],'b-',['DepthVsPercentile',num2str(percentileThresholds(1,n))]);
        end
        
        
    end
    oo.fittedPercentileProfile=fittedPercentileProfile;
end
clear data1D;




