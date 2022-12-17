function collectNormPlaqueInt()
global w; global l; dbstop if error;

% which files?

t=l.t(w.task,:);
% f=l.t(w.task).f(w.file);


wave1={t.f.normPlaqueInt}.';
wave1(cellfun(@(x) any(isnan(x)),wave1)) = {[]};
wave1=cellfun(@isempty,wave1);
fileInds=find(wave1==0);

fileNumber=size(fileInds,1);
% histogramTotal=zeros(65535,1);
for m=1:fileNumber;
    
    [fileinfo,ind]=GetFileInfo([t.f(fileInds(m)).filename,t.f(fileInds(m)).type]); % [fileinfo,ind]=P0236([t.f(fileInds(m)).filename,t.f(fileInds(m)).type]);
    if isempty(fileinfo)==0;
        histogramTotal(:,m)=fileinfo.normPlaqueIntInfo.histogramTotal;
        maxIncidenceIntensity(m,1)=fileinfo.normPlaqueIntInfo.maxIncidenceIntensityTotal;
        normHistogramTotal(:,m)=histogramTotal(:,m)/max(histogramTotal(:,m))*100;
        percMapTotal(:,m)=fileinfo.normPlaqueIntInfo.percMapTotal;
        filenameList(m,1)={fileinfo.filename};
        typeList(m,1)={fileinfo.type};
        
    end
end

%% make figure showing change in maxIncidenceIntensity
path=[l.g.pathOut,'\normPlaqueInt\',t.taskName,'_maxIncidenceIntensity.jpg'];
figureBuilder(path,(1:fileNumber).',maxIncidenceIntensity,'timepoint','intensity',[],[],[],'intensity at maximum incidence');

path=[l.g.pathOut,'\normPlaqueInt\',t.taskName,'_plaqueHistogram.jpg'];
figureBuilder(path,(1:65535).',normHistogramTotal,'intensity','incidence [%]',[0,1000],[0,100],'r2b','histograms at different timepoints');

%% generate movie of all histogramTotal as well as plot
path=[l.g.pathOut,'\normPlaqueInt\',t.taskName,'_plaqueHistogram.avi'];
for m=1:fileNumber;
    tit{m,1}=['Time point: ',num2str(m),' (',t.f(fileInds(m)).filename,')'];
end
movieBuilder(path,1,(1:65535).',normHistogramTotal,'intensity','incidence [%]',[0,1000],[0,100],'b-',tit);

%% calculate factor array 
%normalize such that 95% percentile is equalized


percMapProfile(100,fileNumber)=0;
x=linspace(0,100,200).'; percentiles=x; percentiles(:)=-1; 
percentiles=100*(percentiles./x+1);
for n=1:fileNumber;
    for m=1:size(percentiles,1);
        percMapProfile(m,n)=min(find(percMapTotal(:,n)>=percentiles(m)));
    end
end
for m=1:size(percentiles,1);
    percMapProfile(m,:)=percMapProfile(m,:)/max(percMapProfile(m,:));
end

normalizer=percMapProfile(min(find(percentiles>=95)),:);
normalizer=normalizer.';



% normalize position of incidence maximum
norm2PosIncMax=0;
if norm2PosIncMax==1;
    normMaxIncInt=maxIncidenceIntensity(:)/max(maxIncidenceIntensity(:)); % normalize maxIncInt
    normalizer=normMaxIncInt;
end


% try to get all of them to value 1 to equalize it, what factor is needed
normNormalizer2one=ones(fileNumber,1); normNormalizer2one=normNormalizer2one./normalizer;
% what would be the maximum factor for each dataset to be not
% oversaturated, use percentile 99.99% as measure
for m=1:fileNumber;
    maxSignal(m,1)=min(find(percMapTotal>=99.99));
end
factor2max=ones(fileNumber,1); factor2max(:)=65535; factor2max=factor2max./maxSignal;
% find out which of the datasets oversaturates most
overshoot=normNormalizer2one./factor2max;
% divide normMaxIncInt2one by this factor
finalFactor=normNormalizer2one./max(overshoot(:));
finalNormalizer=finalFactor.*normalizer;

container=table;
container.maxIncidenceIntensity=maxIncidenceIntensity;
container.normalizer=normalizer;
container.normNormalizer2one=normNormalizer2one;
container.maxSignal=maxSignal;
container.factor2max=factor2max;
container.overshoot=overshoot;
container.finalFactor=finalFactor;
container.finalNormalizer=finalNormalizer;
container.filename=filenameList;

% redo the same figure to show that histograms now are overlaid
path=[l.g.pathOut,'\normPlaqueInt\',t.taskName,'_finalFactor.jpg'];
figureBuilder(path,(1:fileNumber).',finalFactor,'timepoins','factor',[],[],'b-','final factor');
%% generate movie showing the factor change with the percentile
path=[l.g.pathOut,'\normPlaqueInt\',t.taskName,'_percMapChange.avi'];
for m=1:size(percentiles,1);
    tit{m,1}=['percentile: ',num2str(percentiles(m)),' %'];
end
movieBuilder(path,5,(1:fileNumber).',percMapProfile.','time points','intensity [a.u.]',[],[0,1],'b-',tit);


%% display

windowSize=ceil(finalFactor/2);
for m=1:fileNumber;
    
    for n=1:65535
        targetInt=round(n*finalFactor(m));
        try;
            correctedHistogram(targetInt-windowSize(m):targetInt+windowSize(m),m)=normHistogramTotal(n,m);
        catch;
        end
    end
%     correctedHistogram(:,m)=smooth(correctedHistogram(:,m),30,'moving');
end
correctedHistogram=correctedHistogram(1:65535,:);

% redo the same figure to show that histograms now are overlaid
path=[l.g.pathOut,'\normPlaqueInt\',t.taskName,'_plaqueHistogramCorr.jpg'];
figureBuilder(path,(1:65535).',correctedHistogram,'intensity','incidence [%]',[0,1000],[0,100],'r2b','histograms at different timepoints');

l.t(w.task).normPlaqueInfo=container;

for m=1:fileNumber;
    [fileinfo,ind]=GetFileInfo([filenameList{m},typeList{m}]); % [fileinfo,ind]=P0236([filenameList{m},typeList{m}]);
    
    l.g.fileinfo(ind).normPlaqueIntInfo.finalFactor=finalFactor(m);
end

