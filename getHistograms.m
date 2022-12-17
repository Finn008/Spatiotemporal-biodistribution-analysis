function [container]=getHistograms(data4D,exclusionVolume,savePath,baseName,ZumBin,Zres)
global w; global l; dbstop if error;
if isempty(exclusionVolume)==0
    exclusionVolume=1-exclusionVolume(:,:,:); % included to 1 and excluded to 0
end
% t=l.t(w.task,:);
% f=l.t.f{w.task}(w.file,:);

chunkNumber=size(data4D,4);
pix=[size(data4D,1);size(data4D,2);size(data4D,3)];
% determine threshold for Methoxy-blue, Methoxy-red and ratiometric

% percMap(65536,chunkNumber)=0;
absPercMap(65535,chunkNumber)=0;
maxIntensity(chunkNumber,1)=0;
histogram(65536,chunkNumber)=0;

pixTotal=prod(size(data4D(:,:,:,1)));
for m=1:chunkNumber % 1: Methoxy-blue, 2: Methoxy-red, 3: ratio
%     data4D(:,:,:,m)=data4D(:,:,:,m)+1;
    if isempty(exclusionVolume)==0    
        data4D(:,:,:,m)=(data4D(:,:,:,m)+1).*uint16(exclusionVolume(:,:,:));
    end
    data1D = reshape(data4D(:,:,:,m),[pixTotal,1]);
    histogram(:,m) =histc(data1D,0:65535); 
    histogram(1)=[]; % zero values are excluded voxels
%     histogram(65536)=0;
%     histogram(1,m)=histogram(1,m)-sum(exclusionVolume(:)); % ind1 because at that position intensity zero
    normHistogram(:,m) = histogram(:,m)./ max(histogram(2:end,m))*100; % take out intensity value zero
    
%     for n=1:65536
%         percMap(n,m)=sum(histogram(1:n,m));
%     end
    
    absPercMap(1)=histogram(1);
    for n=2:65535
        absPercMap(n)=absPercMap(n-1)+histogram(n);
    end
        
    
    normPercMap(:,m)=absPercMap(:,m)/absPercMap(end,m)*100;
    maxIntensity(m)=max(data1D(:));
    
    if isempty(savePath)==0;
        path=[savePath,',',baseName{m},',PercMap','.jpg'];
        figureBuilder(path,normPercMap(:,m),normHistogram(:,m),'percentile [%]','abundance',[0,100],[0,100],[],'percMap');
        
        path=[savePath,',',baseName{m},',histogram','.jpg'];
        figureBuilder(path,(1:65535).',normHistogram(:,m),'intensity','abundance',[0,min(find(normPercMap(:,m)>90))],[0,100],[],'histogram');
        
        path=[savePath,',',baseName{m},',IntensityVsPercentile','.jpg'];
        figureBuilder(path,(1:65535).',normPercMap(:,m),'intensity','percentile [%]',[0,min(find(normPercMap(:,m)>90))],[0,90],[],'IntensityVsPercentile');
    end
    
    %% generate depthProfile
    
    if exist('ZumBin','var') && isempty(ZumBin)==0;
%         % determine bins of same voxel number (excluding exlusionVolume)
%          includedBinsPerLayer(1,pix(3))=0;
%          includedBinsPerLayer(1,:)=(pix(1)*pix(2))-sum(sum(exclusionVolume,1),2);
        
        ZpixBin=round(ZumBin/Zres);
        ZbinNumber=ceil(pix(3)/ZpixBin);
        pixPerBin=pix(1)*pix(2)*ZpixBin;
        virtualPixNumber=ZbinNumber*pixPerBin;
        data1D(virtualPixNumber,1)=0;
%         lastBinExcludedPix=virtualPixNumber-pixTotal;
        histogramProfile(65536,ZbinNumber)=0;
        for n=1:ZbinNumber
            dataBin=data1D((n-1)*pixPerBin+1:n*pixPerBin);
            histogramProfile(:,n)= histc(dataBin(:),0:65535);
        end
        % check if numbers correspond to excluded pixels
        % a1=pix(1)*pix(2)-sum(sum(exclusionVolume,1),2);
        histogramProfile(1,:)=[]; % remove exclusion volume
%         histogramProfile(1,ZbinNumber)=histogramProfile(1,ZbinNumber)-lastBinExcludedPix;
        
        % histogramProfile = histogramTotal;
        normHistogramProfile = histogramProfile ./ max(max(histogramProfile(2:end,:)))*100;
        container.histogramProfile=histogramProfile;
        container.normHistogramProfile=normHistogramProfile;
        
        absPercMapProfile(65535,ZbinNumber)=0;
        absPercMapProfile(1,:)=histogramProfile(1,:);
        for n=2:65535
            absPercMapProfile(n,:)=absPercMapProfile(n-1,:)+histogramProfile(n,:);
        end
        
        normPercMapProfile=absPercMapProfile;
        for n=1:ZbinNumber;
            normPercMapProfile(:,n)=absPercMapProfile(:,n)/absPercMapProfile(end,n)*100;
        end
        container.normPercMapProfile=normPercMapProfile;
        
        % for each depth bin determine intensity at which defined percentile of all pixels are included
        percentileProfile(100,ZbinNumber)=0;
        for n=1:ZbinNumber;
            for o=1:100
                percentileProfile(o,n)=min(find(normPercMapProfile(:,n)>=o));
            end
        end
        container.percentileProfile=percentileProfile;
        fitCoef=zeros(100,3);
        error=zeros(100,3);
        fittedPercentileProfile=percentileProfile;
        Xaxis=0:ZumBin:ZumBin*(ZbinNumber-1);
        for n=1:100
%             [fit1,gof1,output1]=fit((1:ZbinNumber).',percentileProfile(n,:).','poly1','Robust','on');
            [fit1,gof1]=fit(Xaxis.',percentileProfile(n,:).','poly2','Robust','on');
            fitCoef(n,:)=coeffvalues(fit1);
            error(n,1)=gof1.rsquare;
            fittedPercentileProfile(n,:)=YofBinFnc(Xaxis.',fitCoef(n,1),fitCoef(n,2),fitCoef(n,3),[]);
        end
        
        container.fitCoef=fitCoef;
        container.error=error;
        if isempty(savePath)==0;
            path=[savePath,',',baseName{m},',DepthVsPercentile','.jpg'];
            
%             Yaxes=percentileProfile([20,40,60],:).';
            Yaxes=[percentileProfile([20,40,60],:);fittedPercentileProfile([20,40,60],:)].';
            
            figureBuilder(path,Xaxis.',Yaxes,'depth [um]','intensity [%]',[],[],'b-','DepthVsPercentile');
            
            percentileThresholds=[10,20,30,40,50,60,70,80,90,99];
            for n=1:size(percentileThresholds,2)
                path=[savePath,',',baseName{m},',DepthVsPercentile',num2str(percentileThresholds(1,n)),'.jpg'];
                Yaxes=[percentileProfile(percentileThresholds,:);
                fittedPercentileProfile(percentileThresholds,:)].';
                figureBuilder(path,Xaxis.',Yaxes(:,n),'depth [um]','intensity [%]',[],[],'b-',['DepthVsPercentile',num2str(percentileThresholds(1,n))]);
            end
            
            
        end
        container.fittedPercentileProfile=fittedPercentileProfile;
        
% %         percentileDepthProfile(100,ZbinNumber)=0;
% %         for m=1:ZbinNumber;
% %             for n=1:100;
% %                 percentileDepthProfile(n,m)=min(find(percMapProfile(:,m)>=n));
% %             end
% %             meanPercentileDepthProfile(:,m)=percentileDepthProfile(:,m)/mean(percentileDepthProfile(:,m))*0.5;
% %         end
% %         path=[l.g.pathOut,'\normPlaqueInt\',f.filename,'_percDepthProfile.avi'];
% %         for m=1:100;
% %             tit{m,1}=['percentile: ',num2str(m),' %'];
% %         end
% %         movieBuilder(path,2,(1:ZbinNumber).',meanPercentileDepthProfile.','depth [µm]','intensity [a.u.]',[0,ZbinNumber],[0,1],'b-',tit);
        
    
        
    end
    
    
    
end
clear data1D;
container.normPercMap=normPercMap;
container.maxIntensity=maxIntensity;
container.histogram=histogram;



