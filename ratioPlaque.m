% step0: for each file make depth correction and store image with perc50 set to 1
% step1: save all files with step=1 at reduced resolution to one file
% manually: trace similar plaques
% step2: use plaque traces to adjust xyz drift, generate new drift-corrected file containing: 1.) 50% set to 1 2.) <50% set to zero and >50% set to 1
% generate surfaces for first and second channel
% manually: trace similar plaques
% step3: make DistInOut for traced plaques, define in channel2 the membership, paste missing plaques, make DistInOut again for channel2, store DistInOut and Membership
function ratioPlaque()
global W;
F=W.G.T.F{W.Task}(W.File,:);
[FctSpec]=variableExtract(F.RatioPlaque{1},{'Do';'Step';'Version';'ExVol';'DetailLevel';'Mergeall';'CorrectMetBlueLocal';'OutsideModel';'Zcutoff'});
if FctSpec.Step==7
    FctSpec.Step=6;
end
try; Co=W.G.T.F{W.Task}.Results{W.File};
catch; Co=struct;
end;
[NameTable,SibInfo]=fileSiblings_3();
FilenameTotalRatioB=NameTable{'RatioB','FilenameTotal'}{1};
FilenameTotalDeFinB=NameTable{'DeFinB','FilenameTotal'}{1};
% FctSpec.Step=0.8;
%% Step=0 , define outside
if FctSpec.Step==0
    
    deconController(NameTable{'OriginalB','FilenameTotal'});
    if NameTable{'DeFinB','Report'}==0
        W.ErrorMessage=['DeFin file not present: ',FilenameTotalDeFinB]; % DeFin-file not present yet
        return; % A1=qwertzuiop
    end
    FileinfoDeFinB=getFileinfo_2(FilenameTotalDeFinB);
    
    if NameTable{'RatioB','Report'}~=1 || FctSpec.Step==0
        J=struct;
        J.PixMax=[FileinfoDeFinB.Pix{1}(1,1);FileinfoDeFinB.Pix{1}(2,1);FileinfoDeFinB.Pix{1}(3,1);0;0];
        J.UmMinMax=[FileinfoDeFinB.UmStart{1},FileinfoDeFinB.UmEnd{1}];J.Path2file=W.PathImarisSample; % J.BitType='uint8';
        Application=openImaris_2(J);
        Application.FileSave(NameTable{'RatioB','Path2file'}{1},'writer="Imaris5"');
        quitImaris(Application);
        clear Application;
        
        J=struct;
        J.FilenameTotal=NameTable.FilenameTotal{'DeFinB'};
        J.DataOutput={'IntensityBinning2D',{'AllPercentiles'},['uint8']};
        J.TargetChannel=2;
        MetRedPerc=depthCorrection_6(J);
        ex2Imaris_2(MetRedPerc,FilenameTotalRatioB,'MetRedPerc');
    end
    
    FitCoefCorr=[];
    if FctSpec.OutsideModel~=0
        Wave1=find(SibInfo.FileList.TargetTimepoint==FctSpec.OutsideModel & cellfun('isempty',strfind(SibInfo.FileList.Filename,SibInfo.FamilyName))==0);
        [Wave2,Wave3]=fileSiblings_3(SibInfo.FileList.Filename{Wave1});
        Rotate=Wave3.FileList.Rotate{strfind1(Wave3.FileList.Filename,Wave2.Filename{'OriginalB'}),1};
        
        Path2file=[Wave2.FilenameTotal{'RatioB'},'_Outside.mat'];
        Path2file=getPathRaw(Path2file);
        Wave1=load(Path2file);
        FitCoefCorr=Wave1.Container.Results.FitCoef(end,:);
        if (strcmp(F.Rotate{1},'Z#180|') && isnan(Rotate)) || (strcmp(Rotate,'Z#180|') && isnan(F.Rotate{1}))
            FitCoefCorr(1,[2,4])=-FitCoefCorr(1,[2,4]);
        end
    end
    
    ratioPlaque_DetermineOutside(FilenameTotalRatioB,FitCoefCorr);
    
    
    Wave1=variableSetter_2(F.RatioPlaque{1},{'Do','Fin';'Step','0.5'});
    iFileChanger('W.G.T.F{W.Task,1}.RatioPlaque{W.File}',Wave1);
    
    ratioPlaque_Data2DriftCorr({'Outside'},'CurrentFile');
    % % % % % % % % % % % % % %     determineOutside_2;
end

%% Step==0.7
if FctSpec.Step==0.7
    FileinfoDeFinB=getFileinfo_2(FilenameTotalDeFinB);
    Res=FileinfoDeFinB.Res{1};
    
    % blue channel
    J=struct();
    J.FilenameTotal=NameTable.FilenameTotal{'DeFinB'};
    J.DataOutput={...
        'Normalize2Percentile',{'70',1},['uint8'];...
        'None',[],[]};
    J.TargetChannel=1;
    [Data,~]=depthCorrection_6(J);
    MetBlue=Data{1,1};
    ExactMetBlue=Data{2,1};
    clear Data;
    ex2Imaris_2(MetBlue,FilenameTotalRatioB,'MetBlue');
    
    Outside=im2Matlab_3(FilenameTotalRatioB,'Outside');
    if max(Outside(:))>3
        Outside=ratioPlaque_DetermineOutside(FilenameTotalRatioB,[],'ReplaceExisting');
        ratioPlaque_Data2DriftCorr({'Outside'},'CurrentFile');
        %         Outside=im2Matlab_3(FilenameTotalRatioB,'Outside');
    end
    Outside=Outside>1;
    
    [~,ExactMetBlue]=sparseFilter(ExactMetBlue,Outside,Res,10000,[100;100;Res(3)*3],[10;10;Res(3)*3],70,'Multiply100');
    
    [HistogramInfo]=getHistograms_3(struct('ZumBin',Res(3),'Zres',Res(3)),ExactMetBlue,1-Outside);
    MetBlueCorr=uint8(ExactMetBlue/HistogramInfo.PercentilesAvg.a(70)*1);
    J=struct('DataOutput','AllPercentiles','Zres',Res(3),'HistogramInfo',HistogramInfo);
    MetBluePerc=percentiler(ExactMetBlue,[],J);
    ex2Imaris_2(MetBlueCorr,FilenameTotalRatioB,'MetBlueCorr');
    ex2Imaris_2(MetBluePerc,FilenameTotalRatioB,'MetBluePerc');
    clear MetBluePerc;
    ExactMetBlue=ExactMetBlue/(HistogramInfo.PercentilesAvg.a(70)/100);
    
    %             imarisSaveHDFlock(FilenameTotalRatioB);
    %             Application=openImaris_2(FilenameTotalRatioB);
    %             Application.SetVisible(1);
    
    % get red channel data
    J=struct;
    J.FilenameTotal=NameTable.FilenameTotal{'DeFinB'};
    J.DataOutput={'None'};
    J.TargetChannel=2;
    ExactMetRed=depthCorrection_6(J);
    
    [~,ExactMetRed]=sparseFilter(ExactMetRed,Outside,Res,10000,[100;100;Res(3)*3],[10;10;Res(3)*3],70,'Multiply100');
    
    [HistogramInfo]=getHistograms_3(struct('ZumBin',Res(3),'Zres',Res(3)),ExactMetRed,1-Outside);
    
    MetRed=uint8(ExactMetRed/(HistogramInfo.PercentilesAvg.a(70)/4));
    ex2Imaris_2(MetRed,FilenameTotalRatioB,'MetRed');
    clear MetRed;
    
    J=struct('DataOutput','AllPercentiles','Zres',Res(3),'HistogramInfo',HistogramInfo);
    MetRedPerc=percentiler(ExactMetRed,[],J);
    ex2Imaris_2(MetRedPerc,FilenameTotalRatioB,'MetRedPerc');
    clear MetBluePerc;
    ExactMetRed=ExactMetRed/(HistogramInfo.PercentilesAvg.a(70)/100);
    
    
    BRratio=uint8(divideInt(ExactMetBlue,ExactMetRed,10));
    Plaque=MetBlue;
    Plaque(BRratio<=20)=0; % exclude everything twice blueish than redish    %     Plaque(BlueRealPlaque~=100)=0; % set everything below 70th percentile to zero
    % % % %     Plaque(MetBlue==0)=0; % set everything below 70th percentile to zero
    Plaque(ExactMetRed<100)=0;  % set everything below 70th percentile to zero % Plaque(RedRealPlaque~=100)=0;
    clear ExactMetBlue; clear ExactMetRed; clear MetBlue;
    ex2Imaris_2(BRratio,FilenameTotalRatioB,'BRratio');
    ex2Imaris_2(Plaque,FilenameTotalRatioB,'Plaque');
    
    Wave1=variableSetter_2(F.RatioPlaque{1},{'Do','Fin';'Step','0.8'});
    iFileChanger('W.G.T.F{W.Task,1}.RatioPlaque{W.File}',Wave1);
    FctSpec.Step=0.8;
end

%% Step=0.8 auotofluorescence
if FctSpec.Step==0.8
    FileinfoRatioB=getFileinfo_2(FilenameTotalRatioB);
    Res3D=prod(FileinfoRatioB.Res{1}(1:3));
    %     % determine Dystrophies1
    %     [Dystrophies1]=ratioPlaque_DetermineDystrophies(FilenameTotalRatioB,FileinfoRatioB);
    %     ex2Imaris_2(Dystrophies1,FilenameTotalRatioB,'Dystrophies1');
    %     clear Dystrophies1;
    % determine autofluorescent stuff
    Autofluo1=im2Matlab_3(FilenameTotalRatioB,'MetRedPerc');
    BRratio=im2Matlab_3(FilenameTotalRatioB,'BRratio');
    
    if strfind1(FilenameTotalRatioB,'Hazal')
        Autofluo1=Autofluo1>105&BRratio<23;
    else
        Autofluo1=Autofluo1>105&BRratio<7;
    end
    
    Autofluo1b=imerode(Autofluo1,ones(3,3,3));
    BW=bwconncomp(Autofluo1b,6);
    NumPixels=cellfun(@numel,BW.PixelIdxList).';
    Wave1=find(NumPixels<(0.8/Res3D));
    for m=Wave1.'
        Autofluo1b(BW.PixelIdxList{m})=0;
    end
    Autofluo1b=imdilate(Autofluo1b,ones(3,3,3));
    Autofluo1=Autofluo1.*Autofluo1b;
    
    ex2Imaris_2(Autofluo1,FilenameTotalRatioB,'Autofluo1');
    clear BRratio; clear Autofluo1; clear Autofluo1b;
    
    [Dystrophies1]=ratioPlaque_DetermineDystrophies(FilenameTotalRatioB,FileinfoRatioB);
    ex2Imaris_2(Dystrophies1,FilenameTotalRatioB,'Dystrophies1');
    
    
    
    
    
    Wave1=variableSetter_2(F.RatioPlaque{1},{'Do','Fin';'Step','1'});
    iFileChanger('W.G.T.F{W.Task,1}.RatioPlaque{W.File}',Wave1);
end

%% Step=1, put together all files into one DriftCorr file
if FctSpec.Step==1
    
%     keyboard;
    [FA,Path2fileDriftCorr]=ratioPlaque_Data2DriftCorr('Plaque','None');
    
    Application=openImaris_2(Path2fileDriftCorr);
    % detect large Plaques
    J=struct; J.Application=Application;
    J.SurfaceName='Plaques';
    J.Channel='Plaque';
    J.Smooth=1;
    J.Background=10;
    J.LowerManual=1.5;
    J.SurfaceFilter='"Volume" above 3.0 um^3';
    [PlaqueSurface,PlaqueSurfaceInfo]=generateSurface3(J);
    imarisSaveHDFlock(Application,Path2fileDriftCorr);
    FA.Selection=regexprep(FA.Selection,'Do#Go','Do#Fin');
    FA.Selection=regexprep(FA.Selection,'Step#1','Step#2');
    
    iFileChanger('W.G.T.F{W.Task,1}.RatioPlaque(Q1)',FA.Selection,{'Q1',FA.RowSpecifier});
    
end

%% cleanup
if FctSpec.Step>=1000 % FctSpec.Step>=2
    keyboard;
    FilenameTotalTrace=NameTable.FilenameTotal{'Trace'};
    [FileinfoTrace,~,Path2fileTrace]=getFileinfo_2(FilenameTotalTrace);
    ChannelList=FileinfoTrace.ChannelList{1};
    if strfind1(ChannelList,'Plaque',1)
        SourceChannels={'MetBlueCorr'};
        TargetChannels={'MetBlue'};
        ratioPlaque_Data2Trace(SourceChannels,TargetChannels,'None');
        
        % remove all Channels except MetBlue, MetRed, MetBluePerc
        Wave1=strfind1(ChannelList,{'MetBlue';'MetRed';'MetBluePerc';'DistInOut';'Membership';'Relationship'},1);
        ChannelsRemove=ChannelList; ChannelsRemove(Wave1,:)=[];
        %         keyboard;
        Application=openImaris_2(FilenameTotalTrace);
        % remove superfluos channels
        %         [Report]=deleteChannel(Application,ChannelsRemove,FileinfoTrace);
        accessImarisManually(Application,struct('Function','DeleteChannel','ChannelList',{ChannelsRemove}));
        % delete PlaquesStart
        try; deleteSurface(Application,'PlaquesStart'); end;
        % regenerate PlaquesStart
        J = struct;
        J.Application=Application;
        J.SurfaceName='PlaquesStart';
        J.Channel='MetBlue'; % J.Channel='Plaque';
        J.Smooth=1;
        J.Background=15;
        J.LowerManual=2; % J.LowerManual=1.7;
        J.SeedsDiameter=10;
        %         J.SeedsFilter='"Quality" above automatic threshold';
        J.SurfaceFilter=['"Volume" above 1.0 um^3'];
        %         J.MaxDist=8;
        %         J.Gap=0;
        %         J.TrackAlgorythm='BrownianMotion';
        generateSurface3(J);
        imarisSaveHDFlock(Application,Path2fileTrace,'_BeforeCleanup');
        %         imarisSaveHDFlock(Application,Path2fileTrace);
        if FctSpec.Step==2
            Wave1=variableSetter_2(F.RatioPlaque{1},{'Do','Fin';'Step','2.5'});
            iFileChanger('W.G.T.F{W.Task,1}.RatioPlaque{W.File}',Wave1);
            
            %         FA.Selection=regexprep(FA.Selection,'Do#Go','Do#Fin');
            %         FA.Selection=regexprep(FA.Selection,'Step#2','Step#2.5');
            %         iFileChanger('W.G.T.F{W.Task,1}.RatioPlaque(Q1)',FA.Selection,{'Q1',FA.RowSpecifier});
            return;
        end
    end
    
end

%% Step=2, put together into Trace file
if FctSpec.Step==2
    FilenameTotalTrace=NameTable.FilenameTotal{'Trace'};
    [FileinfoTrace,~,Path2fileTrace]=getFileinfo_2(FilenameTotalTrace);
    SourceChannels={'MetBlueCorr';'MetRed';'MetBluePerc'};
    TargetChannels={'MetBlue';'MetRed';'MetBluePerc'};
    keyboard; % also put Outside
    ratioPlaque_Data2Trace(SourceChannels,TargetChannels,'None');
    
    %     [FA,Path2fileDriftCorr]=ratioPlaque_Data2DriftCorr('Plaque','None');
    
    
    
    % % %     if isfield(J,'OnlyMultiDimInfo') || strcmp(FctSpec.Version,'AddMetBluePerc') || strcmp(FctSpec.Version,'AddOutside') || strcmp(FctSpec.Version,'AddMetBluePerc&MetBlue') || strcmp(FctSpec.Version,'AddMetBluePerc&Outside')
    % % %         return;
    % % %     end
    % detemine plaque
    Application=openImaris_2(Path2fileTrace);
    [~,~,ObjectList]=selectObject(Application);
    if strfind1(ObjectList(:,1),'PlaquesStart',1)==0
        J = struct;
        J.Application=Application;
        J.SurfaceName='PlaquesStart';
        J.Channel='MetBlue'; % J.Channel='Plaque';
        J.Smooth=1;
        J.Background=15;
        J.LowerManual=2; % J.LowerManual=1.7;
        J.SeedsDiameter=10;
        %         J.SeedsFilter='"Quality" above automatic threshold';
        J.SurfaceFilter=['"Volume" above 1.0 um^3'];
        %         J.MaxDist=8;
        %         J.Gap=0;
        %         J.TrackAlgorythm='BrownianMotion';
        generateSurface3(J);
    end
    
    imarisSaveHDFlock(Application,Path2fileTrace);
    Wave1=variableSetter_2(F.RatioPlaque{1},{'Do','Fin';'Step','2.5'});
    iFileChanger('W.G.T.F{W.Task,1}.RatioPlaque{W.File}',Wave1);
    %     FA.Selection=regexprep(FA.Selection,'Do#Go','Do#Fin');
    %     FA.Selection=regexprep(FA.Selection,'Step#2','Step#2.5');
    %     iFileChanger('W.G.T.F{W.Task,1}.RatioPlaque(Q1)',FA.Selection,{'Q1',FA.RowSpecifier});
end
%% Step=2.5, find missing plaques
if FctSpec.Step==2.5
    FilenameTotal=NameTable{'Trace','FilenameTotal'};
    plaqueCorrection(struct('FilenameTotal',FilenameTotal,'RealPlaqueSettings','MetBluePerc','Version','MissingPlaques'));
    
    Wave1=variableSetter_2(W.G.T.F{W.Task,1}.RatioPlaque{W.File},{'Do','Fin';'Step','3'});
    iFileChanger('W.G.T.F{W.Task,1}.RatioPlaque{W.File}',Wave1);
    
    FctSpec.Step=3;
end

%% Step=3
if FctSpec.Step==3
    FilenameTotal=NameTable{'Trace','FilenameTotal'};
    Wave1=struct('FilenameTotal',FilenameTotal,'RealPlaqueSettings','MetBluePerc','RoundationType','SphereLike','Zcutoff',FctSpec.Zcutoff);
    [PlaqueData]=plaqueCorrection(Wave1);
    PathTotalResults=regexprep(FilenameTotal,'_Trace.ims','_RatioResults.mat');
    [PathTotalResults,Report]=getPathRaw(PathTotalResults);
    if Report==1
        TotalResults=load(PathTotalResults);
        TotalResults=TotalResults.TotalResults;
    else
        TotalResults=struct;
    end
    TotalResults.TracePlaqueData=PlaqueData;
    save(PathTotalResults,'TotalResults');
    
    FctSpec.Step=3.5;
%     Wave1=variableSetter_2(W.G.T.F{W.Task,1}.RatioPlaque{W.File},{'Do','Fin';'Step','6'});
%     iFileChanger('W.G.T.F{W.Task,1}.RatioPlaque{W.File}',Wave1);
end


if FctSpec.Step==3.5
    FilenameTotal=NameTable{'Trace','FilenameTotal'};
    ratioPlaque_InterPlaqueDistance(FilenameTotal);
    
    Wave1=variableSetter_2(W.G.T.F{W.Task,1}.RatioPlaque{W.File},{'Do','Fin';'Step','6'});
    iFileChanger('W.G.T.F{W.Task,1}.RatioPlaque{W.File}',Wave1);
end

%%
if FctSpec.Step==4 || FctSpec.Step==6
    FilenameTotalRatioB=NameTable.FilenameTotal{'RatioB'};
    FileinfoRatioB=getFileinfo_2(FilenameTotalRatioB);
    FilenameTotalTrace=NameTable.FilenameTotal{'Trace'};
    FileinfoTrace=getFileinfo_2(FilenameTotalTrace);
    Timepoint=F.TargetTimepoint;
    
    try
        MultiDimInfo=FileinfoTrace.Results{1}.MultiDimInfo;
        FitCoefTrace2B=-MultiDimInfo.MetBlue{Timepoint,1}.U.FitCoefs;
        RotateTrace2B=MultiDimInfo.MetBlue{Timepoint,1}.Rotate;
    catch
        FitCoefTrace2B=FileinfoRatioB.Results{1}.MultiDimInfo.DistInOut{1}.U.FitCoefs;
        RotateTrace2B=FileinfoRatioB.Results{1}.MultiDimInfo.DistInOut{1}.Rotate;
    end
end

%% Step=6, export DistRelation data
if FctSpec.Step==6
    D2DTrace=struct('FilenameTotal',FilenameTotalTrace,...
        'SourceTimepoint',Timepoint,...
        'TumMinMax',[FileinfoRatioB.UmStart{1},FileinfoRatioB.UmEnd{1}],...
        'FitCoefs',FitCoefTrace2B);
    
    Res=FileinfoTrace.Res{1};
    Pix=uint16(FileinfoRatioB.Um{1}./Res);
    
    
    D2DRatioB=struct('FilenameTotal',FilenameTotalRatioB,...
        'Interpolation','Bilinear',...
        'Tpix',Pix,...
        'Rotate',RotateTrace2B);
    
    DistInOut=applyDrift2Data_4(D2DTrace,'DistInOut');
    Membership=applyDrift2Data_4(D2DTrace,'Membership');
    Relationship=applyDrift2Data_4(D2DTrace,'Relationship');
        
    MetBlue=applyDrift2Data_4(D2DRatioB,'MetBlue');
    MetRed=applyDrift2Data_4(D2DRatioB,'MetRed');
    BRratio=applyDrift2Data_4(D2DRatioB,'BRratio');
    Autofluo1=applyDrift2Data_4(D2DRatioB,'Autofluo1');
    MetBlueCorr=applyDrift2Data_4(D2DRatioB,'MetBlueCorr');
    
    

    [Dystrophies1,DystrophiesPl]=boutonDetect_DystrophyPlaqueTouch_3(FilenameTotalRatioB,FilenameTotalTrace,Timepoint,D2DRatioB);
    Dystrophies1=applyDrift2Data_4(D2DRatioB,'Dystrophies1');
    DystrophiesPl=Dystrophies1==2;
    Dystrophies1=Dystrophies1>0;
    Outside=applyDrift2Data_4(D2DRatioB,'Outside');
    Relationship(Outside>1)=6;
%     keyboard; % check if accumarray_8 provides same results as accumarray_3
    Array1=accumarray_8({DistInOut,'DistInOut';Membership,'Membership';Relationship,'Relationship'},{ones(size(DistInOut),'uint8'),'Volume';MetBlue,'MetBlue';MetRed,'MetRed';BRratio,'BRratio';Autofluo1,'Autofluo1';MetBlueCorr,'MetBlueCorr';Dystrophies1,'Dystrophies1';DystrophiesPl,'DystrophiesPl'},@sum);
    
    GenerateFusedStack=0;
    if GenerateFusedStack==1
        FilenameTotalFusedStack=[NameTable.Filename{'OriginalB'},'_Fused.ims'];
        J=struct('PixMax',Pix,'UmMinMax',[-double(Pix).*Res/2,double(Pix).*Res/2],'Path2file',W.PathImarisSample);
        Application=openImaris_2(J);
        Application.FileSave(getPathRaw(FilenameTotalFusedStack),'writer="Imaris5"');
        quitImaris(Application); clear Application;
        
        ex2Imaris_2(Membership,FilenameTotalFusedStack,'Membership');
        ex2Imaris_2(DistInOut,FilenameTotalFusedStack,'DistInOut');
        ex2Imaris_2(Relationship,FilenameTotalFusedStack,'Relationship');
        ex2Imaris_2(MetBlue,FilenameTotalFusedStack,'MetBlue');
        ex2Imaris_2(MetRed,FilenameTotalFusedStack,'MetRed');
        ex2Imaris_2(BRratio,FilenameTotalFusedStack,'BRratio');
        ex2Imaris_2(Autofluo1,FilenameTotalFusedStack,'Autofluo1');
        ex2Imaris_2(MetBlueCorr,FilenameTotalFusedStack,'MetBlueCorr');
        ex2Imaris_2(Dystrophies1,FilenameTotalFusedStack,'Dystrophies1');
        ex2Imaris_2(DystrophiesPl,FilenameTotalFusedStack,'DystrophiesPl');
        
        imarisSaveHDFlock(FilenameTotalFusedStack);
    end
    PlaqueIDs=unique(Membership(:)); PlaqueIDs(PlaqueIDs==0)=[];
    
    
    DistanceReal=applyDrift2Data_4(D2DTrace,'DistanceReal');
    DistanceReal=DistanceReal(Outside<2);
    [~,~,~,HistogramDistanceReal]=cumSumGenerator(DistanceReal,(0:1:256).');
    HistogramDistanceReal=table((0:255).',HistogramDistanceReal,'VariableNames',{'Distance';'Volume'});
    
    
    Path=[NameTable{'OriginalB','Filename'}{1},'_RatioResults.mat'];
    [Path,Report]=getPathRaw(Path);
    if Report==1
        load(Path);
    else
        RatioResults=struct;
    end
    RatioResults.Array1=Array1;
    RatioResults.Res=Res;
    RatioResults.Histograms.DistanceReal2=HistogramDistanceReal;
    RatioResults.PlaqueIDs=PlaqueIDs;
    save(Path,'RatioResults');
    
    Wave1=variableSetter_2(W.G.T.F{W.Task,1}.RatioPlaque{W.File},{'Do','Fin';'Step','7'});
    iFileChanger('W.G.T.F{W.Task,1}.RatioPlaque{W.File}',Wave1);
end
%% Step=7, evaluate the data
if FctSpec.Step==8
    keyboard;
    finalEvaluation();
end

%% Step=5, export DistTransform to single files
if FctSpec.Step==5
    keyboard; % not needed anymore 2016.04.11?
    FilenameTotalTrace=NameTable{'Trace','FilenameTotal'};
    FileinfoTrace=getFileinfo_2(FilenameTotalTrace);
    FilenameTotalRatioB=NameTable{'RatioB','FilenameTotal'};
    [FileinfoRatioB,~,Path2fileRatioB]=getFileinfo_2(FilenameTotalRatioB);
    Timepoint=F.TargetTimepoint;
    try
        MultiDimInfo=FileinfoTrace.Results{1}.MultiDimInfo;
        FitCoefTrace2B=-MultiDimInfo.MetBlue{Timepoint,1}.U.FitCoefs;
    catch
        keyboard;
        J=struct;
        J.FilenameTotal=FilenameTotalTrace{1};
        J.SourceChannel={'MetBlue'};
        J.SourceTimepoint=Timepoint;
        [MetBlue]=applyDrift2Data_4(J);
        
        XYZ=table;
        XYZ.Res=FileinfoTrace.Res{1};
        XYZ.UmStart=FileinfoTrace.UmStart{1};
        XYZ.UmEnd=FileinfoTrace.UmEnd{1};
        
        [XYZ.QPixMin,XYZ.QPixMax]=firstLastNonzero_4(MetBlue,'Total',1);
        XYZ.QUmStart=XYZ.UmStart+((XYZ.QPixMin-1).*XYZ.Res);
        XYZ.QUmEnd=XYZ.UmStart+((XYZ.QPixMax).*XYZ.Res);
        XYZ.QUmRange=XYZ.QUmEnd-XYZ.QUmStart;
        XYZ.QUmCenter=XYZ.QUmStart+XYZ.QUmRange/2;
        clear MetBlue;
        FitCoefTrace2B=-[[0,0;0,0;0,0],[XYZ.QUmCenter]];
    end
    
    FA=table;
    FA.FilenameTotal=FilenameTotalTrace;
    FA.SourceChannel{1}={'DistInOut'};
    FA.SourceTimepoint=Timepoint;
    FA.TargetChannel{1}={'DistInOut'};
    try; FA.Rotate=W.G.T.F{W.Task}.Rotate{W.File,1}; end;
    FA.SumCoef={FitCoefTrace2B};
    
    J=struct;
    J.FilenameTotal=FilenameTotalRatioB;
    J.FA=FA;
    merge3D_3(J);
       
    Wave1=variableSetter_2(W.G.T.F{W.Task,1}.RatioPlaque{W.File},{'Do','Fin';'Step','6'});
    iFileChanger('W.G.T.F{W.Task,1}.RatioPlaque{W.File}',Wave1);
    FctSpec.Step=6;
end

evalin('caller','global W;');