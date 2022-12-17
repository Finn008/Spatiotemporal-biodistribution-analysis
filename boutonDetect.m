function boutonDetect()
% disp(['1: ',datestr(now,'HH:MM')]);
global W;

F=W.G.T.F{W.Task}(W.File,:);
[FctSpec]=variableExtract(W.G.T.F{W.Task,1}.BoutonDetect{W.File},{'Step';'Do';'SumCoef'});

[NameTable,SibInfo]=fileSiblings_3();

deconController(NameTable{'OriginalA','FilenameTotal'});
if NameTable{'DeFinA','Report'}==0
    W.ErrorMessage=['DeFin file not present: ',NameTable{'DeFinA','FilenameTotal'}{1}];
    A1=qwertzuiop % DeFin-file not present yet
end


% FctSpec.Step=1;
% FctSpec.Step=0;
% if FctSpec.Step==1 || FctSpec.Step==0
%     FctSpec.Step=0;
% else
%     FctSpec.Step=3;
% end
FilenameTotalRatioA=NameTable.FilenameTotal{'RatioA'};
FileinfoRatioA=getFileinfo_2(FilenameTotalRatioA);
FilenameTotalDeFinA=NameTable.FilenameTotal{'DeFinA'};
FileinfoDeFinA=getFileinfo_2(FilenameTotalDeFinA);
%% Step=0, generate a_ratio file, 1 for everything, 1.1 only refresh DistInOut, Membership and Relationship
if FctSpec.Step==0
    % for large stacks takes up to 70GB of RAM and up to 3.5h during boutonDetect_DetermineDystrophies_2
    % % % %     ramController(100,70,60); % previously ramController(60,20,15);
    disp(['2: ',datestr(now,'HH:MM')]);
    Path2fileRatioA=getPathRaw(FilenameTotalRatioA);
    if NameTable{'RatioA','Report'}~=1
        J=struct;
        J.PixMax=[FileinfoDeFinA.Pix{1};0;0];
        J.UmMinMax=[FileinfoDeFinA.UmStart{1},FileinfoDeFinA.UmEnd{1}];
        J.Path2file=W.PathImarisSample;
        Application=openImaris_2(J);
        Application.FileSave(Path2fileRatioA,'writer="Imaris5"');
        quitImaris(Application);
        clear Application;
    end
    [FileinfoRatioA,~,Path2fileRatioA]=getFileinfo_2(FilenameTotalRatioA);
    disp(['3: ',datestr(now,'HH:MM')]);
    % remove all Channels except MetBlue, MetRed, MetBluePerc
    ChannelList=FileinfoRatioA.ChannelList{1};
    Wave1=strfind1(ChannelList,{'GRratio';'Blood';'VglutRed';'VglutGreen';'Dystrophies2';'Outside';'Autofluo2';'Boutons2';'Dystrophies2Radius';'(name not specified)'},1);
    ChannelsRemove=ChannelList;
    ChannelsRemove(Wave1,:)=[];
    if size(ChannelsRemove,1)>0
        accessImarisManually_2(FilenameTotalRatioA,[],struct('Function','DeleteChannel','ChannelList',{ChannelsRemove}));
        disp(['4: ',datestr(now,'HH:MM')]);
    end
    Res=FileinfoRatioA.Res{1};
    ChannelList=FileinfoRatioA.ChannelList{1};
    % determine outside cortex
    [OrigVglutRed]=im2Matlab_3(NameTable.FilenameTotal{'DeFinA'},1);
    if strfind1(ChannelList,'Outside',1)==0
        
        [Outside]=boutonDetect_DetermineOutsideCortex(FileinfoRatioA,OrigVglutRed); % 2min, 3min % on 2017.02.06 switched to OrigVglutRed instead of exact
        ex2Imaris_2(Outside,FilenameTotalRatioA,'Outside');
        disp(['5: ',datestr(now,'HH:MM')]);
    else
        Outside=im2Matlab_3(FilenameTotalRatioA,'Outside');
    end
    % detect blood
    if strfind1(ChannelList,'Blood',1)==0
        [Blood]=boutonDetect_DetermineBlood_2(OrigVglutRed,Outside,Res); % 9min, 7min
        ex2Imaris_2(Blood,FilenameTotalRatioA,'Blood');
        disp(['6: ',datestr(now,'HH:MM')]);
    else
        Blood=im2Matlab_3(FilenameTotalRatioA,'Blood');
    end
    % determine autofluorescence2
    if strfind1(ChannelList,'Dystrophies2Radius',1)==0 % change back when doing Hazals stuff!!!
        %         [OrigVglutRed]=im2Matlab_3(NameTable.FilenameTotal{'DeFinA'},1);
        [Autofluo2,VglutRedCorr]=boutonDetect_DetermineAutofluorescence(OrigVglutRed,Outside>0|Blood==1,Res); % 51min, 54min
        disp(['7: ',datestr(now,'HH:MM')]);
        clear OrigVglutRed;
        ex2Imaris_2(Autofluo2,FilenameTotalRatioA,'Autofluo2'); clear Autofluo2;
        ex2Imaris_2(VglutRedCorr,FilenameTotalRatioA,'VglutRed');
    else
        VglutRedCorr=im2Matlab_3(FilenameTotalRatioA,'VglutRed');
    end
    clear OrigVglutRed;
    % determine dystrophies
    disp(['8: ',datestr(now,'HH:MM')]);
% % % %     if strfind1(ChannelList,'Dystrophies2Radius',1) % change back when doing Hazals stuff!!!
% % % %         VglutGreenCorr=im2Matlab_3(FilenameTotalRatioA,'VglutGreen');
% % % %         [BoutonList,BoutonIds,Dystrophies2,Dystrophies2Radius,VglutGreenCorr,GRratio]=boutonDetect_DetermineDystrophies_2(VglutGreenCorr,Outside>0|Blood==1,Res,VglutRedCorr,'SkipVglutGreenCorr');
% % % %     else
    [OrigVglutGreen]=im2Matlab_3(NameTable.FilenameTotal{'DeFinA'},2);
    [BoutonList,BoutonIds,Dystrophies2,Dystrophies2Radius,VglutGreenCorr,GRratio]=boutonDetect_DetermineDystrophies_2(OrigVglutGreen,Outside>0|Blood==1,Res,VglutRedCorr);
% % % %     end
    disp(['9: ',datestr(now,'HH:MM')]);
    clear OrigVglutGreen; clear Outside; clear Blood; clear VglutRedCorr;
    ex2Imaris_2(VglutGreenCorr,FilenameTotalRatioA,'VglutGreen'); clear VglutGreenCorr;
    ex2Imaris_2(GRratio,FilenameTotalRatioA,'GRratio'); clear GRratio;
    ex2Imaris_2(BoutonIds,FilenameTotalRatioA,'Boutons2'); clear BoutonIds;
    ex2Imaris_2(Dystrophies2,FilenameTotalRatioA,'Dystrophies2'); clear Dystrophies2;
    ex2Imaris_2(Dystrophies2Radius,FilenameTotalRatioA,'Dystrophies2Radius'); clear Dystrophies2Radius;
    
    [PathStatistics,Report]=getPathRaw([FilenameTotalRatioA,'_StatisticsBoutons2.mat']);
    save(PathStatistics,'BoutonList');
    disp(['10: ',datestr(now,'HH:MM')]);
    % detect boutons
    PathStatistics=[FilenameTotalRatioA,'_StatisticsBoutons1.mat'];
    [PathStatistics,Report]=getPathRaw(PathStatistics);
    
    if Report==999
        keyboard;
        Timer=datenum(now);
        IntermediateFilenameTotal=strrep(FilenameTotalRatioA,'.ims','_BoutonDetection.ims');
        IntermediatePath2file=strrep(Path2fileRatioA,'.ims','_BoutonDetection.ims');
        Path=['copy "',Path2fileRatioA,'" "',IntermediatePath2file,'"'];
        [Status,Cmdout]=dos(Path);
        ex2Imaris_2(ExactVglutGreen,IntermediateFilenameTotal,'ExactVglutGreen'); clear ExactVglutGreen;
        Application=openImaris_2(IntermediatePath2file);
        J=struct;
        J.Application=Application;
        J.ObjectType='Spot';
        J.Channel='ExactVglutGreen';
        J.SurfaceName='Boutons1';
        J.RGBA=[0.5,1,0,0];
        J.SurfaceFilter=['"Quality" above automatic threshold'];
        J.DiaXYZ=[1,1,3];
        J.Background=1;
        J.RegionsFromLocalContrast=1;
        J.LowerManual=30;
        J.GrowingType=0;
        generateSurface3(J);
        [Statistics]=im2Matlab_3(Application,'Boutons1',1,'Spot');
        [Statistics.ObjInfo]=spotIntensityReader(Statistics.ObjInfo,{VglutGreen;VglutRed;GRratio},{'VglutGreen';'VglutRed';'GRratio'},'Sphere',FileinfoDeFinA.Res{1});
        
        save(PathStatistics,'Statistics');
        quitImaris(Application);
        pause(5);
        Path=['del "',IntermediatePath2file,'"'];
        [Status,Cmdout]=dos(Path);
        disp(['12: ',datestr(now,'HH:MM')]);
    end
    
    Wave1=variableSetter_2(W.G.T.F{W.Task,1}.BoutonDetect{W.File},{'Do','Fin';'Step','3'});
    iFileChanger('W.G.T.F{W.Task,1}.BoutonDetect{W.File}',Wave1);
    disp(['12: ',datestr(now,'HH:MM')]);
    FctSpec.Step=3;
end
%% calculate FitCoefs
if floor(FctSpec.Step)==1 || FctSpec.Step==3
    PlaqueReport=0;
    try; PlaqueReport=NameTable.Report('Trace'); end;
    if PlaqueReport==1
        FilenameTotalTrace=NameTable.FilenameTotal{'Trace'};
        FilenameTotalRatioB=NameTable.FilenameTotal{'RatioB'};
        FilenameTotalDeFinB=NameTable.FilenameTotal{'DeFinB'};
        FileinfoRatioB=getFileinfo_2(FilenameTotalRatioB);
        FileinfoDeFinB=getFileinfo_2(FilenameTotalDeFinB);
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
        [DriftInfoPos,Driftinfo]=searchDriftCombi(NameTable.FilenameTotal{'OriginalB'},[F.Filename{1},'.lsm']);
        try % first try to get saved FitCoefB2A
            FitCoefB2A=Driftinfo.Results{1,1}.FitCoefs;
        catch % if nothing there
            FitCoefB2A=zeros(3,3);
        end
        
        RotateTrace2A=W.G.T.F{W.Task}.Rotate(W.File);
        ResQuanti=FileinfoTrace.Res{1};
    else
        ResQuanti=[0.47;0.47;0.4];
        RotateTrace2A=NaN;
    end
end
%% Step==1, drift correction
if floor(FctSpec.Step)==1 %  || RedoDriftCorr==1
    deconController(NameTable{'OriginalB','FilenameTotal'});
    if NameTable{'DeFinB','Report'}==0
        W.ErrorMessage=['DeFin file not present: ',NameTable{'DeFinB','FilenameTotal'}{1}];
        A1=qwertzuiop % DeFin-file not present yet
    end
    try % then try to get manual entries
        FitCoefB2A=[[0,0;0,0;0,0],FctSpec.FitCoef];
    catch % if nothing there
        FitCoefB2A=zeros(3,3);
    end
    
    J=struct;
    try; J.DriftZcutoff=FctSpec.DriftZcutoff; catch; J.DriftZcutoff=[]; end;
%     if FctSpec.Step==1.1
%         keyboard;
%     end
    [Out]=intrDrift_7(NameTable.FilenameTotal{'DeFinB'},NameTable.FilenameTotal{'DeFinA'},FitCoefB2A,RotateTrace2B,RotateTrace2A,J);
    Wave2=round(Out.FitCoefB2A(:,3),1);
    Wave2=num2strArray_2(Wave2);
    Wave2=['[',Wave2{1},';',Wave2{2},';',Wave2{3},']'];
    
    if Out.Rmse>10
        Wave3='1';
    else
        Wave3='3';
    end
    
    Wave1=variableSetter_2(W.G.T.F{W.Task,1}.BoutonDetect{W.File},{'Do','Fin';'Step',Wave3;'FitCoef',Wave2;'Rmse',num2str(round(Out.Rmse,1))});
    iFileChanger('W.G.T.F{W.Task,1}.BoutonDetect{W.File}',Wave1);
end

%% Step=3, read out the data
if FctSpec.Step==3
       
    Pix=uint16(FileinfoDeFinA.Um{1}./ResQuanti);
    
    
    D2DRatioA=struct('FilenameTotal',FilenameTotalRatioA,...
        'Tpix',Pix,...
        'Rotate',RotateTrace2A);
    D2DDeFinAgreen=struct('FilenameTotal',FilenameTotalDeFinA,...
        'Tpix',Pix,...
        'Interpolation','Bilinear',...
        'Rotate',RotateTrace2A,...
        'DepthCorrectionInfo',struct('DataOutput',{{'Normalize2Percentile',{'50',40},['uint8']}}));
    D2DDeFinAred=D2DDeFinAgreen;
    D2DDeFinAred.DepthCorrectionInfo.DataOutput={'Normalize2Percentile',{'50',20},['uint8']};
    
    if PlaqueReport==1
        D2DTrace=struct('FilenameTotal',FilenameTotalTrace,...
            'SourceTimepoint',Timepoint,...
            'TumMinMax',[FileinfoDeFinA.UmStart{1},FileinfoDeFinA.UmEnd{1}],...
            'FitCoefs',FitCoefB2A+FitCoefTrace2B); %         'FitCoefs',FitCoefB2A+FitCoefTrace2B,...
        D2DRatioB=struct('FilenameTotal',FilenameTotalRatioB,...
            'Tpix',Pix,...
            'TumMinMax',[FileinfoDeFinA.UmStart{1},FileinfoDeFinA.UmEnd{1}],...
            'FitCoefs',FitCoefB2A,...
            'Rotate',RotateTrace2B,...
            'Interpolation','Bilinear');
        Membership=applyDrift2Data_4(D2DTrace,'Membership');
        DistInOut=applyDrift2Data_4(D2DTrace,'DistInOut');
        Relationship=applyDrift2Data_4(D2DTrace,'Relationship');
        Outside=applyDrift2Data_4(D2DRatioB,'Outside');
        PlaqueIDs=unique(Membership(:)); PlaqueIDs(PlaqueIDs==0)=[];
    else
        Relationship=ones(Pix.','uint8')*2;
        Outside=applyDrift2Data_4(D2DRatioA,'Outside');
        DistInOut=ones(Pix.','uint8')*51;
        Membership=ones(Pix.','uint8');
        PlaqueIDs=0;
    end
    
    % include blood into Relationship
    
    Blood=uint8(applyDrift2Data_4(D2DRatioA,'Blood'));
    Relationship(Blood==1)=5;
    
    Relationship(Outside>1)=6;
    
    clear Blood;
    
    VglutGreen=applyDrift2Data_4(D2DDeFinAgreen,2);
    VglutRed=applyDrift2Data_4(D2DDeFinAred,1);
    GRratio=applyDrift2Data_4(D2DRatioA,'GRratio');
    Dystrophies2Volume=uint8(applyDrift2Data_4(D2DRatioA,'Dystrophies2'));
    Dystrophies2Radius=uint8(applyDrift2Data_4(D2DRatioA,'Dystrophies2Radius'));
    
    Dystrophies2=(Dystrophies2Volume>=50 & Dystrophies2Radius>=10);
    %     keyboard; % check if accumarray_8 provides same results as accumarray_2
    Array1=accumarray_8({DistInOut,'DistInOut';Membership,'Membership';Relationship,'Relationship'},{ones(size(DistInOut),'uint8'),'Volume';VglutGreen,'VglutGreen';VglutRed,'VglutRed';GRratio,'GRratio';Dystrophies2,'Dystrophies2';Dystrophies2Volume,'Dystrophies2Volume';Dystrophies2Radius,'Dystrophies2Radius'},@sum);
    Array2=accumarray_8({DistInOut,'DistInOut';Membership,'Membership';Relationship,'Relationship';Dystrophies2Radius,'Dystrophies2Radius'},{ones(size(DistInOut),'uint8'),'Volume'},@sum);
    % % % % % %     VolumeEdges=[(0:1:20).';(25:5:60).';(80:20:200).';255];
    % % % % % %     [~,Wave1]=histc(Dystrophies2Volume,VolumeEdges); Wave1=uint8(Wave1);
    % % % % % % Array3=accumarray_3({DistInOut,'DistInOut';Membership,'Membership';Relationship,'Relationship';Wave1,'Dystrophies2Volume'},[],@sum);
    
    % get Boutons2
    [Path,Report]=getPathRaw([FilenameTotalRatioA,'_StatisticsBoutons1.mat']);
    if Report==1
        load(Path);
        BoutonList=Statistics.ObjInfo;
        BoutonList.XYZum=[BoutonList.PositionX,BoutonList.PositionY,BoutonList.PositionZ];
        [BoutonList1]=boutonDetect_LoadBoutonData(BoutonList,D2DRatioA,Pix,DistInOut,Membership,Relationship);
    end
    [Path,Report]=getPathRaw([FilenameTotalRatioA,'_StatisticsBoutons2.mat']);
    if Report==1
        load(Path);
        [BoutonList2]=boutonDetect_LoadBoutonData(BoutonList,D2DRatioA,Pix,DistInOut,Membership,Relationship);
    end
    
    GenerateFusedStack=0;
    if GenerateFusedStack==1
        FilenameTotalFusedStack=[NameTable.Filename{'OriginalA'},'_Fused.ims'];
        J=struct('PixMax',Pix,'UmMinMax',[-double(Pix).*ResQuanti/2,double(Pix).*ResQuanti/2],'Path2file',W.PathImarisSample);
        Application=openImaris_2(J);
        Application.FileSave(getPathRaw(FilenameTotalFusedStack),'writer="Imaris5"');
        quitImaris(Application); clear Application;
        if PlaqueReport==1
            ex2Imaris_2(Membership,FilenameTotalFusedStack,'Membership');
            ex2Imaris_2(DistInOut,FilenameTotalFusedStack,'DistInOut');
            ex2Imaris_2(Relationship,FilenameTotalFusedStack,'Relationship');
            MetBlue=applyDrift2Data_4(D2DTrace,'MetBlue');
            MetRed=applyDrift2Data_4(D2DTrace,'MetRed');
            ex2Imaris_2(MetBlue,FilenameTotalFusedStack,'MetBlue');
            ex2Imaris_2(MetRed,FilenameTotalFusedStack,'MetRed');
        end
        ex2Imaris_2(VglutGreen,FilenameTotalFusedStack,'VglutGreen');
        ex2Imaris_2(VglutRed,FilenameTotalFusedStack,'VglutRed');
        ex2Imaris_2(GRratio,FilenameTotalFusedStack,'GRratio');
        ex2Imaris_2(Dystrophies2,FilenameTotalFusedStack,'Dystrophies2');
        ex2Imaris_2(Dystrophies2Volume,FilenameTotalFusedStack,'Dystrophies2Volume');
        ex2Imaris_2(Dystrophies2Radius,FilenameTotalFusedStack,'Dystrophies2Radius');
        
        Boutons1=zeros(Pix.','uint8');
        Boutons1(BoutonList1.PlaquePixLinInd)=1;
        ex2Imaris_2(Boutons1,FilenameTotalFusedStack,'Boutons1');
        
        if exist('BoutonList2')~=0
            Boutons2=zeros(Pix.','uint8');
            Boutons2(BoutonList2.PlaquePixLinInd)=1;
            ex2Imaris_2(Boutons2,FilenameTotalFusedStack,'Boutons2');
            imarisSaveHDFlock(FilenameTotalFusedStack);
        end
    end
    
    Path=[NameTable{'OriginalA','Filename'}{1},'_RatioResults.mat'];
    [Path,Report]=getPathRaw(Path);
    if Report==1
        load(Path);
    else
        RatioResults=struct;
    end
    RatioResults.Array1=Array1;
    RatioResults.Array2=Array2;
    % % %     RatioResults.Array3=Array3;
    RatioResults.Res=ResQuanti;
    try; RatioResults.BoutonList1=BoutonList1; end;
    try; RatioResults.BoutonList2=BoutonList2; end;
    RatioResults.PlaqueIDs=PlaqueIDs;
    save(Path,'RatioResults');
    
    
    Wave1=variableSetter_2(W.G.T.F{W.Task,1}.BoutonDetect{W.File},{'Do','Fin';'Step','4'});
    iFileChanger('W.G.T.F{W.Task,1}.BoutonDetect{W.File}',Wave1);
    %     FctSpec.Step=4;
end


%% Step=5, generate Timeline stack for single plaque
if FctSpec.Step==5
    keyboard; %is now performed from finalEvaluation
    FilenameTotalTrace=NameTable.FilenameTotal{'Trace'};
    FileinfoTrace=getFileinfo_2(FilenameTotalTrace);
    if isfield(FctSpec,'EdgeRadius')
        EdgeRadius=FctSpec.EdgeRadius;
    else
        EdgeRadius=50;
    end
    
    PathTotalResults=regexprep(FilenameTotalTrace,'_Trace.ims','_RatioResults.mat');
    [PathTotalResults,Report]=getPathRaw(PathTotalResults);
    PlaqueData=load(PathTotalResults);
    PlaqueData=PlaqueData.TotalResults.TracePlaqueData;
    PlUmCenter=PlaqueData.Data{FctSpec.Plaque}.UmCenter;
    
    FAa=W.G.T.F{W.Task}(:,{'Filename','TargetTimepoint','Rotate'});
    FAa=FAa(strfind1(FAa.Filename,['_',SibInfo.FamilyName]),:);
    FAa(isnan(FAa.TargetTimepoint),:)=[];
    for m=1:size(FAa,1)
        [Wave1,Wave2]=fileSiblings_3(FAa.Filename{m,1});
        FAa.SourceChannel(m,1)={{'VglutGreen';'VglutRed';'Boutons2';'Dystrophies2Radius'}};
        FAa.TargetChannel(m,1)=FAa.SourceChannel(m,1);
        FAa.FilenameTotal(m,1)=Wave1{'RatioA','FilenameTotal'};
        FAa.SourceTimepoint(m,1)=1;
    end
    
    FAb=W.G.T.F{W.Task}(:,{'Filename','TargetTimepoint','Rotate'});
    FAb=FAb(strfind1(FAb.Filename,['_',SibInfo.FamilyNameB]),:);
    FAb(isnan(FAb.TargetTimepoint),:)=[];
    FAtrace=FAb(:,'TargetTimepoint'); FAtrace.FilenameTotal(:,1)=NameTable{'Trace','FilenameTotal'};
    for m=1:size(FAb,1)
        [Wave1,~]=fileSiblings_3(FAb.Filename{m,1});
        FAb.SourceChannel(m,1)={{'MetBlue';'MetRed';'Dystrophies1'}};
        FAb.TargetChannel(m,1)=FAb.SourceChannel(m,1);
        FAb.FilenameTotal(m,1)=Wave1{'RatioB','FilenameTotal'};
        FAb.SourceTimepoint(m,1)=1;
        FitCoefB2A=zeros(3,3);
        try
            Wave2=FAa.Filename(find(FAa.TargetTimepoint==FAb.TargetTimepoint(m)),1);
            [Wave2,~]=fileSiblings_3(Wave2);
            [~,Driftinfo]=searchDriftCombi(Wave1.FilenameTotal{'OriginalB'},Wave2.FilenameTotal{'OriginalA'});
            FitCoefB2A=Driftinfo.Results{1,1}.FitCoefs;
        end
        FAb.SumCoef(m,1)={FitCoefB2A}; % PlUmCenter{FAtrace.TargetTimepoint(m)}
        
        FAtrace.SourceTimepoint(m,1)=FAtrace.TargetTimepoint(m,1);
        FAtrace.SourceChannel(m,1)={{'DistInOut';'Membership';'Relationship'}};
        FAtrace.TargetChannel(m,1)={{'DistInOut';'Membership';'Relationship'}};
        
        try
            MultiDimInfo=FileinfoTrace.Results{1}.MultiDimInfo;
            FitCoefTrace2B=-MultiDimInfo.MetBlue{m,1}.U.FitCoefs;
            RotateTrace2B=MultiDimInfo.MetBlue{m,1}.Rotate;
        catch
            keyboard;
            FitCoefTrace2B=FileinfoRatioB.Results{1}.MultiDimInfo.DistInOut{1}.U.FitCoefs;
            RotateTrace2B=FileinfoRatioB.Results{1}.MultiDimInfo.DistInOut{1}.Rotate;
        end
        FAtrace.SumCoef(m,1)={FitCoefB2A+FitCoefTrace2B};
        
        PlXYZtrace=PlUmCenter{FAtrace.TargetTimepoint(m)};
        [Wave1]=YofBinFnc(repmat(PlXYZtrace(3),[3,1]),FitCoefTrace2B(:,1),FitCoefTrace2B(:,2),FitCoefTrace2B(:,3));
        PlXYZb=PlXYZtrace+Wave1;
        [Wave1]=YofBinFnc(repmat(PlXYZb(3),[3,1]),FitCoefB2A(:,1),FitCoefB2A(:,2),FitCoefB2A(:,3));
        PlXYZa=PlXYZb+Wave1;
        Wave1=[PlXYZa-EdgeRadius,PlXYZa+EdgeRadius];
        FAtrace.IndividualUmMinMax(m,1)={Wave1};
        FAb.IndividualUmMinMax(m,1)={Wave1};
    end
    for m=1:size(FAa,1)
        FAa.IndividualUmMinMax(m,1)=FAtrace.IndividualUmMinMax(find(FAtrace.TargetTimepoint==FAa.TargetTimepoint(m)));
    end
    
    
    FA=joinTable({FAa;FAb;FAtrace});
    J=struct; J.FA=FA;
    [FAout,Volume]=calcSummedFitCoef_2(J);
        
    TLfilenameTotal=[SibInfo.Experiment,'_',SibInfo.FamilyName,'_Pl',num2str(FctSpec.Plaque),'.ims'];
    [TLpath,Report]=getPathRaw(TLfilenameTotal);
    if Report==1
        [Fileinfo]=getFileinfo_2(TLfilenameTotal);
        if isequal(Fileinfo.Um{1},repmat(EdgeRadius*2,[3,1]))==0
            W.ErrorMessage='Desired chunk size unequal to size of previous file';
            A1=asdf;
        end
    end
    
    J=struct;
    J.Res=Volume.Resolution;
    J.UmStart=-repmat(EdgeRadius,[3,1]);
    J.UmEnd=repmat(EdgeRadius,[3,1]);
    J.Pix=round((J.UmEnd-J.UmStart)./J.Res);
    J.PathInitialFile=TLpath;
    J.FA=FA;
    J.BitType='uint16';
    
    merge3D_3(J);
    Application=openImaris_2(TLpath);
    imarisSaveHDFlock(Application,TLpath);
    
    Wave1=variableSetter_2(W.G.T.F{W.Task,1}.BoutonDetect{W.File},{'Do','Fin';'Step','4'});
    iFileChanger('W.G.T.F{W.Task,1}.BoutonDetect{W.File}',Wave1);
end

evalin('caller','global W;'); return;