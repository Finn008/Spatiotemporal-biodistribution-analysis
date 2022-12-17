
function intrDrift_2()
global w; global i; dbstop if error;
t=l(w.task); try; f=l(w.task).l(w.file); catch; end;

% load the DriftInfo file, if not present then create it
path=[i(1).g.pathIntrDrift,'\DriftInfo.mat'];
if exist(path)==0;
    DriftInfo(1,1:5)={'file1';'file2';'fitCoefs';'results';'range'};
else
    load(path);
end

% search if combination is already present
DriftInfoPos=cell(2,2);
DriftInfoPos(1,1:2)={f.filename,f.RefFile};
for m=1:2;
    if m==1; w5=[1,2]; else w5=[2,1]; end;
    wave1=strfind(DriftInfo(:,1),DriftInfoPos{1,w5(1)}); wave1 = ~cellfun(@isempty,wave1);
    wave2=strfind(DriftInfo(:,2),DriftInfoPos{1,w5(2)}); wave2 = ~cellfun(@isempty,wave2);
    wave3=wave1+wave2;
    wave4=find(wave3==2);
    if isempty(wave4); % if combination not present yet
        DriftInfoPos{2,m}=size(DriftInfo,1)+1;
    else
        DriftInfoPos{2,m}=wave4;
    end
    DriftInfo(DriftInfoPos{2,m},1)=DriftInfoPos(1,w5(1));
    DriftInfo(DriftInfoPos{2,m},2)=DriftInfoPos(1,w5(2));
end



% automatic selected
if isempty(f.IntrDriftProType)==0 && isempty(strfind(f.IntrDriftProType,'automatic'))==0;
    clear a; P0232_2(w.task,w.file); global a;

    [fileinfo]=GetFileInfo([a.filename,a.type]);%     [fileinfo]=P0236([a.filename,a.type]);
    path=w.pathImarisSample;
    croplimitsmax(1,1:5)=[fileinfo.pix(1),fileinfo.pix(2),fileinfo.pix(3),1,2];
    [vTimelineApplication]=P0237_2(path,[],croplimitsmax,[],'7.6.0');
    if strcmp(w.DoReport,'success')==0; return; end;
%     if strcmp(report,'file loaded')==0; w.DoReport=report; return; end;
    
    vTimedata=vTimelineApplication.GetDataSet;
    vTimedata.SetExtendMaxX(fileinfo.umEnd(1)); vTimedata.SetExtendMaxY(fileinfo.umEnd(2)); vTimedata.SetExtendMaxZ(fileinfo.umEnd(3));
    vTimedata.SetExtendMinX(fileinfo.umStart(1)); vTimedata.SetExtendMinY(fileinfo.umStart(2)); vTimedata.SetExtendMinZ(fileinfo.umStart(3));
    
    data=zeros(fileinfo.pix(1),fileinfo.pix(2),fileinfo.pix(3),'uint16');
    for m=w.file:w.file+1;
        clear a; P0232_2(w.task,m); global a;
        path=[i(1).g.pathRaw,'\',a.filename,a.type];
        croplimitsmin(1,1:5)=[0,0,0,a.SourceChannel-1,a.SourceTimepoint-1];
        croplimitsmax(1,1:5)=[fileinfo.pix(1),fileinfo.pix(2),fileinfo.pix(3),a.SourceChannel,a.SourceTimepoint];
        [vImarisApplication]=P0237_2(path,croplimitsmin,croplimitsmax,[],'7.6.0');
        if strcmp(w.DoReport,'success')==0; return; end;
%         if strcmp(report,'file loaded')==0; w.DoReport=report; return; end;
        [data]=Im2Matlab(vImarisApplication,data);
        Ex2Imaris(vTimelineApplication,data,a.TargetChannel,a.TargetTimepoint);
        quitImaris(vImarisApplication);
        clear vImarisApplication;
    end
    
    path=[i(1).g.pathIntrDrift,'\',DriftInfo{DriftInfoPos{2,1},1},'_vs_',DriftInfo{DriftInfoPos{2,1},2},'_IntrDrift.ims'];
    vTimelineApplication.FileSave(path,'writer="Imaris5"');
    quitImaris(vTimelineApplication);
    clear vTimelineApplication;
    
    [vTimelineApplication]=P0237_2(path,[],[],[],'7.6.5');
    if strcmp(w.DoReport,'success')==0; return; end;
%     if strcmp(report,'file loaded')==0; w.DoReport=report; return; end;
    
    
    
    vTimedata=vTimelineApplication.GetDataSet;
    aRegionsOfInterest=[];
    aChannelIndex=0;
    aSmoothFilterWidth=0.3;
    aLocalContrastFilterWidth=1.12;
    aLowerThresholdEnabled=1;
    aIntensityLowerThresholdAutomatic=0;
    aIntensityLowerThresholdManual=2700;
    aUpperThresholdEnabled=1;
    aIntensityUpperThresholdAutomatic=0;
    aIntensityUpperThresholdManual=65535;
    aSurfaceFiltersString=[];
    vSurfaces=vTimelineApplication.GetImageProcessing.DetectSurfacesWithUpperThreshold(vTimedata,aRegionsOfInterest,aChannelIndex,aSmoothFilterWidth,aLocalContrastFilterWidth,aLowerThresholdEnabled,aIntensityLowerThresholdAutomatic,aIntensityLowerThresholdManual,aUpperThresholdEnabled,aIntensityUpperThresholdAutomatic,aIntensityUpperThresholdManual,aSurfaceFiltersString);
    
    
    aMaximalDistance=30;
    aGapSize=3;
    aTrackFiltersString=[];
    vSurfaces=vTimelineApplication.GetImageProcessing.TrackSurfacesAutoregressiveMotion(vSurfaces,aMaximalDistance,aGapSize,aTrackFiltersString);
    
    % show surfaces
    vSurpassScene = vTimelineApplication.GetSurpassScene;
    vSurpassScene.AddChild(vSurfaces, -1);
    
    vStatistics = vSurfaces.GetStatistics;
    vNames = cell(vStatistics.mNames);
    vValues = vStatistics.mValues;
    vUnits = cell(vStatistics.mUnits);
    vFactors = cell(vStatistics.mFactors);
    vFactorNames = cellstr(char(vStatistics.mFactorNames));
    vIds = vStatistics.mIds;
    categories = unique(vNames);
    
    wave1={'Track Position X Start';'Track Position Y Start';'Track Position Z Start';'Track Position X Mean';'Track Position Y Mean';'Track Position Z Mean'};
    
    for m=1:size(wave1,1); % go through categories to extract
        wave2=strfind(vNames,wave1{m});
        wave3 = ~cellfun(@isempty,wave2);
        wave4=find(wave3==1);
        if m==1;
            NumberOfTracks=sum(wave3);
            results=zeros(NumberOfTracks,size(wave1,1));
        end
        results(:,m)=vValues(wave3==1);
    end
    DriftInfo{DriftInfoPos{2,1},4}=results;
    
    if isempty(f.IntrDriftProType)==0 && isempty(strfind(f.IntrDriftProType,'saveImaris'))==0;
%     if i(w.task).l(w.file).ProcessingType==2;
        path=[i(1).g.pathIntrDrift,'\',DriftInfo{DriftInfoPos{2,1},1},'_vs_',DriftInfo{DriftInfoPos{2,1},2},'_IntrDrift.ims'];
        vTimelineApplication.FileSave(path,'writer="Imaris5"');
    else
        delete([path,',IntrDrift.ims']);
    end
    quitImaris(vTimelineApplication);
    clear vTimelineApplication;
end

% auto selected, autoDraw if only redraw the fits
if isempty(f.IntrDriftProType)==0 && isempty(strfind(f.IntrDriftProType,'auto'))==0;
    results=DriftInfo{DriftInfoPos{2,1},4};
    
    start=results(:,1:3);
    mean=results(:,4:6);
    change=(mean-start)*2;
    
    % determine minimum and maximum ranges
    wave1=min(results(:,3));
    wave2=max(results(:,3));
    DriftInfo{DriftInfoPos{2,1},5}={wave1;wave2}; % in 5th row save min and max z-value
    wave1=min(results(:,3)+change(:,3));
    wave2=max(results(:,3)+change(:,3));
    DriftInfo{DriftInfoPos{2,2},5}={wave1;wave2}; % in 5th row save min and max z-value
end

% manually selected
if isempty(f.IntrDriftProType)==0 && isempty(strfind(f.IntrDriftProType,'manually'))==0; 
% if i(w.task).l(w.file).ProcessingType==21;
    % open excel sheet with the data to fit
    path=[i(1).g.pathIntrDrift,'\',i(w.task).l(w.file).filename,'.xls'];
    [num,txt,start] = xlsread(path,'Track Position Start');
    [num,txt,mean] = xlsread(path,'Track Position');
    start=start(3:end,1:3); start=cell2mat(start);
    mean=mean(3:end,1:3); mean=cell2mat(mean);
    change=(mean-start)*2;
    % calculate fits of second order, robust fit
    
end



% not 'set' selected
if isempty(f.IntrDriftProType)==0 && isempty(strfind(f.IntrDriftProType,'set'))==1; 
    [Xcurve,Xgof,Xoutput]=fit(start(:,3),change(:,1),'poly2','Robust','Bisquare');
    [Ycurve,Ygof,Youtput]=fit(start(:,3),change(:,2),'poly2','Robust','Bisquare');
    [Zcurve,Zgof,Zoutput]=fit(start(:,3),change(:,3),'poly2','Robust','Bisquare');
    i(w.task).l(w.file).error=min([Xgof.rsquare,Ygof.rsquare,Zgof.rsquare]);
    % generate figure
    wave1=figure(1); hold on;
    plot(Xcurve,'b',start(:,3),change(:,1),'.b');
    plot(Ycurve,'r',start(:,3),change(:,2),'.r');
    plot(Zcurve,'k',start(:,3),change(:,3),'.k');
    legend_handle=legend('X data','X fit','Y data','Y fit','Z data','Z fit','Location','best'); set(legend_handle, 'Box', 'off','Color', 'none');
    xlabel('Image depth [µm]'); ylabel('Drift [µm]');
    path=[i(1).g.pathIntrDrift,'\',DriftInfo{DriftInfoPos{2,1},1},'_vs_',DriftInfo{DriftInfoPos{2,1},2},'_IntrDrift.jpg'];
    saveas(wave1,path,'jpg');
    close figure 1;
    % get coefficients of polynomial fit and save under fileinfo.mat,
    FollowerFitCoefs=zeros(3,3,'double');
    FollowerFitCoefs(1,1:3)=coeffvalues(Xcurve);
    FollowerFitCoefs(2,1:3)=coeffvalues(Ycurve);
    FollowerFitCoefs(3,1:3)=coeffvalues(Zcurve);
end


% set selected
if isempty(f.IntrDriftProType)==0 && isempty(strfind(f.IntrDriftProType,'set'))==0; 
    FollowerFitCoefs=zeros(3,3,'double');
    FollowerFitCoefs(1,3)=f.XfitCoef3;
    FollowerFitCoefs(2,3)=f.YfitCoef3;
    FollowerFitCoefs(3,3)=f.ZfitCoef3;
    RefFitCoefs=-FollowerFitCoefs;
end

% save Coefs in DriftInfo
DriftInfo{DriftInfoPos{2,1},3}=FollowerFitCoefs;
DriftInfo{DriftInfoPos{2,2},3}=RefFitCoefs;

i(1).g.DriftInfo=DriftInfo;
save(w.pathi,'l'); % save projects
save([i(1).g.pathIntrDrift,'\DriftInfo.mat'],'DriftInfo');



w.DoReport='done';
