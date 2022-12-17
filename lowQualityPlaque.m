function lowQualityPlaque()
global W;
F=W.G.T.F{W.Task}(W.File,:);
keyboard; % use differnt indexing to files, also change present files
% Path2file=[Experiment,'_M',num2str(F2.Mouse(m)),'_',F2.StackB{m},'_RatioResults.mat'];
TLfilenameCore=[W.G.T.TaskName{W.Task},'_M',num2str(F.Mouse),'_R',num2str(F.Roi)];


    
[FctSpec]=variableExtract(F.LowPlaque{1},{'Step';'Do'});
%% Step=0, put together all files into one DriftCorr file
if FctSpec.Step==0
    TLfilenameTotal=[TLfilenameCore,'.ims'];
    [TLfileinfo,TLind,TLpathRaw]=getFileinfo_2(TLfilenameTotal);
    FileList=W.G.T.F{W.Task};
    FA=table;
    FA.FilenameTotal=strcat(FileList.Filename,FileList.Type);
    FA.Mouse=FileList.Mouse;
    FA.Roi=FileList.Roi;
    FA.Treatment=FileList.Treatment;
    FA.TargetTimepoint=FileList.TargetTimepoint;
    FA.RowSpecifier=FileList.RowSpecifier;
    Wave1=find(FA.Mouse==F.Mouse & FA.Roi==F.Roi & FA.TargetTimepoint>0);
    FA=FA(Wave1,:);
    FA.SourceChannel{1}=1; FA.SourceChannel(:)=FA.SourceChannel(1);
    FA.TargetChannel{1}='MetBlue';FA.TargetChannel(:)={'MetBlue'};
    
    try; FA.Rotate=strcat(W.G.T.F{W.Task}.Rotate); end;
    [FA,Volume]=calcSummedFitCoef_2(FA);
    
    
    
    DepthCorrectionInfo=struct;
    DepthCorrectionInfo.CorrType='InVivoFixed';
    DepthCorrectionInfo.Exponent=0.003;
    DepthCorrectionInfo.DataOutput={'Normalize2Percentile',{'80',4}};
    FA.DepthCorrectionInfo(:,1)={DepthCorrectionInfo};
    
    J=struct;
    J.Pix=Volume.TotalVolumePix;
    J.Res=Volume.Resolution;
    J.UmStart=Volume.TotalVolumeUm(:,1);
    J.UmEnd=Volume.TotalVolumeUm(:,2);
    J.PathInitialFile=TLpathRaw;
    J.FA=FA;
    J.BitType='uint8';
%     keyboard; % check if value one is really added
    J.InterCalc={1,[]};
    [Application]=merge3D_3(J);
%     keyboard;
    Application=openImaris_2(TLpathRaw);
    
    % detect large Plaques
    J=struct; J.Application=Application;
    J.SurfaceName='Plaques';
    J.Channel='MetBlue';
    J.Smooth=1;
    J.Background=10;
    J.LowerManual=10;
    J.SurfaceFilter='"Volume" above 40.0 um^3';
    J.SeedsDiameter=15;
    J.MaxDist=25;
    J.Gap=1;
    J.TrackAlgorythm='BrownianMotion';
    [PlaqueSurface,PlaqueSurfaceInfo]=generateSurface3(J);
    
    [Fileinfo,FileinfoInd]=extractFileinfo(TLfilenameTotal,Application);    
%     keyboard; % why is original thing not deleted?
    imarisSaveHDFlock(Application,TLpathRaw);
%     Application.FileSave(TLpathRaw,'writer="Imaris5"');
    
    clear Application;
%     keyboard; % check if correctly set
    Wave1=variableSetter_2(W.G.T.F{W.Task,1}.LowPlaque{W.File},{'Do','Fin';'Step','1'});
    iFileChanger('W.G.T.F{W.Task,1}.LowPlaque{W.File}',Wave1);
%     FA.Selection=regexprep(FA.Selection,'Do#Go','Do#Fin');
%     FA.Selection=regexprep(FA.Selection,'Step#1','Step#2');
    
%     iFileChanger('W.G.T.F{W.Task,1}.RatioPlaque(Q1)',FA.Selection,{'Q1',FA.RowSpecifier});
end

%% Step=1
if FctSpec.Step==1
    TLfilenameTotal=[TLfilenameCore,'_Trace.ims'];
%     keyboard; % in Final rename "In" to "Plaques" and "Plaque" to "MetBlue", check if MetBluePlus1
    
    Fileinfo=getFileinfo_2(TLfilenameTotal);
    if strfind1(Fileinfo.ChannelList{1},'MetBlue')
        MetBluePlus1=0;
    else
        MetBluePlus1=1;
    end
    
    RealPlaqueSettings=struct('Smooth',0.8,'Background',20,'LowerManual',7,'Volume',0.2,'DistInOut',{[10;55]});
    [PlaqueData]=plaqueCorrection(struct('FilenameTotal',TLfilenameTotal,'MetBlueThreshold',2,'UmDilation',99999,'RealPlaqueSettings',RealPlaqueSettings,'MetBluePlus1',MetBluePlus1,'StackRotation',1));
    
%     RealPlaqueSettings=struct('Smooth',1,'Background',15,'LowerManual',2,'Volume',0.5,'DistInOut',{[10;53]});
%     [PlaqueData]=plaqueCorrection(struct('FilenameTotal',TLfilenameTotal,'MetBlueThreshold',2,'UmDilation',17,'RealPlaqueSettings',RealPlaqueSettings,'MetBluePlus1',MetBluePlus1,'StackRotation',1));
    
    % finish
    PathTotalResults=[TLfilenameCore,'_RatioResults.mat'];
    [PathTotalResults,Report]=getPathRaw(PathTotalResults);
    if Report==1
        TotalResults=load(PathTotalResults);
        TotalResults=TotalResults.TotalResults;
    else
        TotalResults=struct;
    end
    TotalResults.TracePlaqueData=PlaqueData;
    save(PathTotalResults,'TotalResults');
    Wave1=variableSetter_2(W.G.T.F{W.Task,1}.LowPlaque{W.File},{'Do','Fin';'Step','2'});
    iFileChanger('W.G.T.F{W.Task,1}.LowPlaque{W.File}',Wave1);
end

%% 
if FctSpec.Step==2
    finalEvaluation();
end