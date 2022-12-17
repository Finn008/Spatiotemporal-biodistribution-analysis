function boutonDetect_Test()

global W;
F=W.G.T.F{W.Task}(W.File,:);
[FctSpec]=variableExtract(F.BoutonDetect{1},{'Step';'Do';'SumCoef'});
FctSpec.Step=4;
[NameTable,SibInfo]=fileSiblings_3();

% define Follower file
% AllFiles=W.G.T.F{W.Task};
% FollowerInd=find(AllFiles.TargetTimepoint==F.TargetTimepoint);
% FollowerInd(FollowerInd==W.File)=[];
% FollowerInd=FollowerInd(1);
% FFilename=AllFiles.Filename{FollowerInd,1};
% [Sibling,FNameTable,ImageGroup]=fileSiblings([FFilename,'.lsm']);
% try; Wave1=NameTable{'OriginalB','FilenameTotal'}; catch; W.ErrorMessage; end;
% try
    
% catch
%     W.ErrorMessage=strjoin([{'OriginalBfile not present'}]);
%     A1=qwertzuiop % DeFin-file not present yet
% end

deconController(NameTable{'OriginalB','FilenameTotal'});
deconController(NameTable{'OriginalA','FilenameTotal'});

Wave1=NameTable({'DeFinA';'DeFinB'},:);
Wave1(Wave1.Report==1,:)=[];
if size(Wave1,1)>0
    W.ErrorMessage=strjoin([{'DeFin file not present: '};Wave1{:,'FilenameTotal'}]);
    A1=qwertzuiop % DeFin-file not present yet
end

% FctSpec.Step=0;
%% Step==0, drift correction
if FctSpec.Step==0
    % no file available: use manually defined FitCoef
    % File present with Autofluo Selection: use that together with manually defined FitCoef
    %     keyboard; % include Rotation
%     keyboard;
    J=struct;
    try; J.FitCoef=FctSpec.FitCoef; end;
    FollowerInd=strfind1(W.G.T.F{W.Task}.Filename,NameTable.Filename{'OriginalA'});
    try; J.Rotate=W.G.T.F{W.Task}.Rotate([W.File;FollowerInd(1)],1); end;
    try; J.IntrDriftAutofluoLowerManual=FctSpec.IntrDriftAutofluoLowerManual; end;
    [Out]=intrDrift_3(NameTable.FilenameTotal{'DeFinB'},NameTable.FilenameTotal{'DeFinA'},J);
    if isfield(Out,'FitCoef')
        Wave2=round(Out.FitCoef(:,3),1);
        Wave2=num2strArray_2(Wave2);
        Wave2=['[',Wave2{1},';',Wave2{2},';',Wave2{3},']'];
        
        Wave1=variableSetter_2(F.BoutonDetect{1},{'Do','Fin';'Step','1';'FitCoef',Wave2;'Rmse',num2str(round(Out.Rmse2,1))});
    else
        Wave1=variableSetter_2(F.BoutonDetect{1},{'Do','Go';'Step','0';'Rmse',num2str(round(Out.Rmse1,1))});
    end
    
    iFileChanger('W.G.T.F{W.Task,1}.BoutonDetect{W.File}',Wave1);
end

%% Step==1 or Step==3
% FctSpec.Step=1;
if FctSpec.Step==1 || FctSpec.Step==3 || FctSpec.Step==4
    FilenameTotalRatioA=NameTable.FilenameTotal{'RatioA'};
    FilenameTotalDeFinA=NameTable.FilenameTotal{'DeFinA'};
    FilenameTotalRatioB=NameTable.FilenameTotal{'RatioB'};
    FilenameTotalDeFinB=NameTable.FilenameTotal{'DeFinB'};
    FilenameTotalTrace=NameTable.FilenameTotal{'Trace'};
    FileinfoDeFinA=getFileinfo_2(FilenameTotalDeFinA);
    FileinfoRatioB=getFileinfo_2(FilenameTotalRatioB);
    FileinfoDeFinB=getFileinfo_2(FilenameTotalDeFinB);
    FileinfoTrace=getFileinfo_2(FilenameTotalTrace);
end

%% Step=1, generate a_ratio file, 1 for everything, 1.1 only refresh DistInOut, Membership and Relationship
if FctSpec.Step==1
    
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
    
    IntermediateFilenameTotal=strrep(FilenameTotalRatioA,'.ims','_BoutonDetection.ims');
    IntermediatePath2file=strrep(Path2fileRatioA,'.ims','_BoutonDetection.ims');
    Path=['copy "',Path2fileRatioA,'" "',IntermediatePath2file,'"'];
    [Status,Cmdout]=dos(Path);
%     if isempty(Cmdout)==0; keyboard; end;

% % % % %     % get DistInOut from Trace file (for Dystrophies2)
% % % % %     D2DTrace=struct('FilenameTotal',FilenameTotalTrace,...
% % % % %         'SourceTimepoint',Timepoint,...
% % % % %         'TumMinMax',[FileinfoRatioA.UmStart{1},FileinfoRatioA.UmEnd{1}],...
% % % % %         'FitCoefs',FitCoefB2A+FitCoefTrace2B,...
% % % % %         'Tpix',FileinfoDeFinA.Pix{1});
% % % % %     DistInOut=applyDrift2Data_4(D2DTrace,'DistInOut');

    
    
    
    % get VglutRed and ExactVglutRed from DeFinA (for Blood, Dystrophies and Boutons1)
    J=struct;
    J.FilenameTotal=NameTable.FilenameTotal{'DeFinA'};
    J.DataOutput={'Normalize2Percentile',{'50',8000},[];...
        'Normalize2Percentile',{'50',20},['uint8']}; % export it also as 16bit for optimal determination of BRratio
    J.TargetChannel=1;
    Wave1=depthCorrection_6(J);
    ExactVglutRed=Wave1{1};
    VglutRed=Wave1{2};
    clear Wave1;
    
    % get ExactVglutGreen from DeFinA (for Dystrophies and Boutons1)
    J.DataOutput={'Normalize2Percentile',{'50',10000},[];...
        'Normalize2Percentile',{'50',40},['uint8']}; % export it also as 16bit for optimal determination of BRratio
    J.TargetChannel=2;
    Wave1=depthCorrection_6(J);
    ExactVglutGreen=Wave1{1};
    VglutGreen=Wave1{2};
    clear Wave1;
    
    
    GRprod=divideInt_2(ExactVglutGreen,ExactVglutRed,0.00005,'*');
    GRratio=uint8(divideInt_2(ExactVglutGreen,ExactVglutRed,30,'/')); %    RGratio=uint8(divideInt_2(ExactVglutRed,ExactVglutGreen,70,'/'));
    clear ExactVglutGreen; clear ExactVglutRed; clear VglutGreen;
    
    ex2Imaris_2(GRratio,FilenameTotalRatioA,'GRratio'); clear GRratio;
    
%     ex2Imaris_2(GRratio,struct('FilenameTotal',FilenameTotalRatioA,'Channels','GRratio','GZIPcompression',9));clear GRratio;
%     ex2Imaris_2(VglutGreen,struct('FilenameTotal',FilenameTotalRatioA,'Channels','VglutGreen','GZIPcompression',9));
%     ex2Imaris_2(VglutRed,struct('FilenameTotal',FilenameTotalRatioA,'Channels','VglutRed','GZIPcompression',9));
    
% % % % %     % get MetRed and BRratio from RatioB (for Dystrophies2)
% % % % %     D2DRatioB=struct('FilenameTotal',FilenameTotalRatioB,...
% % % % %         'Tpix',FileinfoDeFinA.Pix{1},...
% % % % %         'TumMinMax',[FileinfoDeFinA.UmStart{1},FileinfoDeFinA.UmEnd{1}],...
% % % % %         'FitCoefs',FitCoefTrace2B,...
% % % % %         'SourceChannel',{{'MetRed';'BRratio'}},...
% % % % %         'Interpolation','Bilinear');
% % % % %     Wave1=applyDrift2Data_4(D2DRatioB);
% % % % %     
% % % % %     MetRed=Wave1(:,:,:,1);
% % % % %     BRratio=Wave1(:,:,:,2);
% % % % %     clear Wave1;
    
    
%     Dystrophies2=RGratio;
%     Dystrophies2(VglutGreen<=50)=0;
%     clear RGratio; clear VglutGreen;
%     Dystrophies2=MetRed;
%     Dystrophies2(MetRed<=6)=0;
%     Dystrophies2(GRratio<=20)=0;
%     Dystrophies2(BRratio>=21)=0;
        
%     ex2Imaris_2(MetRed,FilenameTotalRatioA,'MetRed');
%     ex2Imaris_2(VglutGreen,FilenameTotalRatioA,'VglutGreen');
%     ex2Imaris_2(VglutRed,FilenameTotalRatioA,'VglutRed');
%     ex2Imaris_2(GRratio,FilenameTotalRatioA,'GRratio');
%     ex2Imaris_2(BRratio,FilenameTotalRatioA,'BRratio');
%     ex2Imaris_2(DistInOut,FilenameTotalRatioA,'DistInOut');
%     ex2Imaris_2(Dystrophies2,FilenameTotalRatioA,'Dystrophies2');
%     ex2Imaris_2(RGratio,Application,'RGratio');
    
    
%     ex2Imaris_2(Dystrophies2,FilenameTotalRatioA,'Dystrophies2');clear Dystrophies2;
    ex2Imaris_2(VglutRed,IntermediateFilenameTotal,'VglutRed'); clear VglutRed;
    ex2Imaris_2(GRprod,IntermediateFilenameTotal,'GRprod'); clear GRprod;
%     ex2Imaris_2(DistInOut,FilenameTotalRatioA,4); clear DistInOut;
    
    Application=openImaris_2(IntermediatePath2file);
    
    % detect boutons
    J=struct;
    J.Application=Application;
    J.ObjectType='Spot';
    J.Channel='GRprod';
    J.SurfaceName='Boutons1';
    J.RGBA=[0.5,1,0,0];
    J.SurfaceFilter=['"Quality" above automatic threshold'];
    J.DiaXYZ=[1,1,3];
    J.Background=1;
    J.RegionsFromLocalContrast=1;
    J.LowerManual=31;
    J.GrowingType=0;
    generateSurface3(J);
    
%     keyboard;
    [Statistics]=im2Matlab_3(Application,'Boutons1',1,'Spot');
    Path=[FilenameTotalRatioA,'_StatisticsBoutons1.mat'];
    Path=getPathRaw(Path);
    save(Path,'Statistics');
    
%     imarisSaveHDFlock(Application,Path2fileRatioA);
%     Application=openImaris_2(Path2fileRatioA);
        
%     IntermediatePath2file=strrep(Path2fileRatioA,'.ims','_HDFlocked.ims');
%     Application.FileSave(IntermediatePath2file,'writer="Imaris5"');
        
% % %     % detect Dystrophies2
% % %     [ID,ChannelList]=getChannelId(Application);
% % %     J = struct;
% % %     J.Application=Application;
% % %     J.SurfaceName='Dystrophies2Surf';
% % %     J.Channel='Dystrophies2';
% % %     J.Smooth=1;
% % %     J.LowerManual=40;
% % %     J.UpperManual=100;
% % % % % %     J.SurfaceFilter=['"Intensity Min Ch=4" between 10.0 and 51.0']; %   ChannelList=varName2Col(ChannelList); J.SurfaceFilter=['"Intensity Min Ch=',num2str(ChannelList.DistInOut),'" between 10.0 and 51.0'];
% % %     generateSurface3(J);
% % %     [Dystrophies2]=im2Matlab_3(Application,'Dystrophies2Surf',[],'Surface');
    
% % %     % determine autofluorescent stuff
% % %     J = struct;
% % %     J.Application=Application;
% % %     J.SurfaceName='AutofluoSurf2';
% % %     J.Channel='Dystrophies2';
% % %     J.Smooth=0.3;
% % %     J.LowerManual=100;
% % %     J.SurfaceFilter='"Volume" above 1.0 um^3';
% % %     generateSurface3(J);
% % %     [Autofluo2]=im2Matlab_3(Application,'AutofluoSurf2',[],'Surface');
    
    % detect blood
    J = struct;
    J.Application=Application;
    J.SurfaceName='Blood';
    J.Channel='VglutRed';
    J.Smooth=1;
    J.LowerManual=0;
    J.UpperManual=20;
    J.SurfaceFilter=['"Volume" above 30.0 um^3'];
    generateSurface3(J);
    [Blood]=im2Matlab_3(Application,'Blood',[],'Surface');
    ex2Imaris_2(uint16(Blood),struct('FilenameTotal',FilenameTotalRatioA,'Channels','Blood','GZIPcompression',9)); clear Blood;
    
    quitImaris(Application);
    
    pause(5);
    Path=['del "',IntermediatePath2file,'"'];
    [Status,Cmdout]=dos(Path);
%     if isempty(Cmdout)==0; keyboard; end;
    
%     Path=['del "',Path2fileRatioA,'"'];
%     [Status,Cmdout]=dos(Path);
%     if isempty(Cmdout)==0
%         keyboard;
%     end
%     Path=['rename "',IntermediatePath2file,'" "',FilenameTotalRatioA,'"'];
%     [Status,Cmdout]=dos(Path);
    
    
%     ex2Imaris_2(zeros(size(Dystrophies2),'uint16'),FilenameTotalRatioA,'DistInOut');
%     ex2Imaris_2(zeros(size(Dystrophies2),'uint16'),FilenameTotalRatioA,'GRprod');

    
    
%     ex2Imaris_2(uint16(Blood),FilenameTotalRatioA,'Blood'); clear Blood;
%     ex2Imaris_2(GRratio,FilenameTotalRatioA,'GRratio');clear GRratio;
% % %     ex2Imaris_2(uint16(Autofluo2),FilenameTotalRatioA,'Autofluo2'); clear Autofluo2;
    
    
    
% % %     J=struct('DilateInOut',1.2,'Um',FileinfoRatioA.Um{1});
% % %     [Mask]=distanceMat_2(J,Dystrophies2);
    
%     [Mask]=dilateInOut(Dystrophies2,1,1.2,FileinfoRatioA.Res{1});
% % %     Dystrophies2=Dystrophies2.*Mask; clear Mask;    
    
% % %     ex2Imaris_2(uint16(Dystrophies2),FilenameTotalRatioA,'Dystrophies2'); clear Dystrophies2;
    
%     Application=openImaris_2(Path2fileRatioA);
%     imarisSaveHDFlock(Application,Path2fileRatioA);
    
    Wave1=variableSetter_2(F.BoutonDetect{1},{'Do','Fin';'Step','3'});
    iFileChanger('W.G.T.F{W.Task,1}.BoutonDetect{W.File}',Wave1);
% % %     FctSpec.Step=3;
end


%% Step=3, read out the data
if FctSpec.Step==3
%     keyboard;
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
    FitCoefB2A=Driftinfo.Results{1,1}.FitCoefs;
    try
        RotateB2A=Driftinfo.Results{1,1}.Rotate;
        keyboard; % sum Rotates from both A and B file together because might equalize themselves
    catch
        RotateTrace2A=W.G.T.F{W.Task}.Rotate(W.File);
    end
    
    FileinfoRatioA=getFileinfo_2(FilenameTotalRatioA);
    Pix=uint16(FileinfoDeFinA.Um{1}./FileinfoTrace.Res{1});
    
    % get DistInOut data
    D2DTrace=struct('FilenameTotal',FilenameTotalTrace,...
        'SourceTimepoint',Timepoint,...
        'TumMinMax',[FileinfoDeFinA.UmStart{1},FileinfoDeFinA.UmEnd{1}],...
        'FitCoefs',FitCoefB2A+FitCoefTrace2B); %         'FitCoefs',FitCoefB2A+FitCoefTrace2B,...
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
    
    D2DRatioB=struct('FilenameTotal',FilenameTotalRatioB,...
        'Tpix',Pix,...        
        'TumMinMax',[FileinfoDeFinA.UmStart{1},FileinfoDeFinA.UmEnd{1}],...
        'FitCoefs',FitCoefB2A,...
        'Rotate',RotateTrace2B,...
        'Interpolation','Bilinear');
    
    % include blood into Relationship
    Relationship=applyDrift2Data_4(D2DTrace,'Relationship');
    Blood=uint8(applyDrift2Data_4(D2DRatioA,'Blood'));
    Relationship(Blood==1)=5;
    clear Blood;
    
%     VglutGreen=applyDrift2Data_4(D2DDeFinAgreen,'VglutGreen');
    VglutGreen=applyDrift2Data_4(D2DDeFinAgreen,2);
    VglutRed=applyDrift2Data_4(D2DDeFinAred,1);
    MetRed=applyDrift2Data_4(D2DRatioB,'MetRed');
    GRratio=applyDrift2Data_4(D2DRatioA,'GRratio');
    BRratio=applyDrift2Data_4(D2DRatioB,'BRratio');
    
    if strfind1(FilenameTotalRatioA,'Hazal')
        Dystrophies2=VglutGreen>30&MetRed>10;
    else
        Dystrophies2=VglutGreen>30&MetRed>6;
    end
    Autofluo2=VglutRed>180; % settings before 2015.12.04: Autofluo2=VglutGreen>50&GRratio<20;
    
    ReadOuts={'DistInOut','Channel','Mask','DistInOut',D2DTrace;...
        'Membership','Channel','Mask','Membership',D2DTrace;...
        'Relationship','Channel','Mask','Relationship',Relationship;...
        'VglutGreen','Channel','Data',2,VglutGreen;...
        'VglutRed','Channel','Data',1,VglutRed;...
        'GRratio','Channel','Data','GRratio',GRratio;...
        'Dystrophies2','Channel','Data','Dystrophies2',Dystrophies2;...
        'Autofluo2','Channel','Data','Autofluo2',Autofluo2;...
        'Boutons1','StatisticsStorage','Data','Boutons1',D2DRatioA;...
        'MetBlue','Channel','Data','MetBlue',D2DRatioB;...
        'MetRed','Channel','Data','MetRed',MetRed;...
        'BRratio','Channel','Data','BRratio',BRratio};
        
    ReadOuts=array2table(ReadOuts,'VariableNames',{'Name';'Identity';'CalcType';'ChannelName';'ApplyD2D'},'RowNames',ReadOuts(:,1));
    
    
    FilenameTotalFusedStack=[NameTable.Filename{'OriginalA'},'_Fused.ims'];
%     J=struct;
%     J.PixMax=[Pix(1,1);Pix(2,1);Pix(3,1);0;1];
%     J.UmMinMax=[FileinfoDeFinA.UmStart{1},FileinfoDeFinA.UmEnd{1}];
%     J.Path2file=W.PathImarisSample;
%     Application=openImaris_2(J);
%     Application.FileSave(getPathRaw(FilenameTotalFusedStack),'writer="Imaris5"');
%     quitImaris(Application);
    
%     J=struct;
%     J.ReadOuts=ReadOuts;
%     J.ExcludeRoiIds={[0],[0],[0]};
%     J.FilenameTotalFusedStack=FilenameTotalFusedStack;
    [RatioResults]=extractDistRelation_2(struct('ReadOuts',ReadOuts,'Res',FileinfoTrace.Res{1},'ExcludeRoiIds',{{[0],[0],[0]}},'FilenameTotalFusedStack',FilenameTotalFusedStack));
    
    Path=[NameTable{'OriginalA','Filename'}{1},'_RatioResults.mat'];
    Path=getPathRaw(Path);
    save(Path,'RatioResults');
    
    
    Wave1=variableSetter_2(F.BoutonDetect{1},{'Do','Fin';'Step','4'});
    iFileChanger('W.G.T.F{W.Task,1}.BoutonDetect{W.File}',Wave1);
%     FctSpec.Step=4;
end


%% Step=4, generate Timeline stack for single plaque
if FctSpec.Step==4
%     FctSpec.Plaque=79;
    EdgeRadius=50;
    
    PathTotalResults=regexprep(FilenameTotalTrace,'_Trace.ims','_RatioResults.mat');
    [PathTotalResults,Report]=getPathRaw(PathTotalResults);
    PlaqueData=load(PathTotalResults);
    PlaqueData=PlaqueData.TotalResults.TracePlaqueData;
    PlUmCenter=PlaqueData.Data{FctSpec.Plaque}.UmCenter;
    
    FAa=W.G.T.F{W.Task}(:,{'Filename','TargetTimepoint','Rotate'});
    FAa=FAa(strfind1(FAa.Filename,['_',SibInfo.FamilyName]),:);
    for m=1:size(FAa,1)
        [Wave1,Wave2]=fileSiblings_3(FAa.Filename{m,1});
        FAa.SourceChannel(m,1)={[2;1]};
        FAa.TargetChannel(m,1)={{'VglutGreen';'VglutRed'}};
        FAa.FilenameTotal(m,1)=Wave1{'DeFinA','FilenameTotal'};
        FAa.DepthCorrectionInfo(m,1)=[...
            {struct('DataOutput',{{'Normalize2Percentile',{'50',40},['uint8']}})};... % VglutGreen
            {struct('DataOutput',{{'Normalize2Percentile',{'50',12},['uint8']}})}]; % VglutRed
        FAa.SourceTimepoint(m,1)=1;
%         Wave1=[-37;98;-3];
%         FAa.IndividualUmMinMax(m,1)={[Wave1-EdgeRadius,Wave1+EdgeRadius]};
    end
            
    FAb=W.G.T.F{W.Task}(:,{'Filename','TargetTimepoint','Rotate'});
    FAb=FAb(strfind1(FAb.Filename,['_',SibInfo.FamilyNameB]),:);
    FAtrace=FAb(:,'TargetTimepoint'); FAtrace.FilenameTotal(:,1)=NameTable{'Trace','FilenameTotal'};
    for m=1:size(FAb,1)
        [Wave1,~]=fileSiblings_3(FAb.Filename{m,1});
        FAb.SourceChannel(m,1)={{'MetBlue';'MetRed';'BRratio'}};
        FAb.TargetChannel(m,1)={{'MetBlue';'MetRed';'BRratio'}};
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
        FAtrace.IndividualUmMinMax(m,1)={[PlXYZa-EdgeRadius,PlXYZa+EdgeRadius]};
        FAb.IndividualUmMinMax(m,1)={[PlXYZa-EdgeRadius,PlXYZa+EdgeRadius]};
    end
    for m=1:size(FAa,1)
        FAa.IndividualUmMinMax(m,1)=FAtrace.IndividualUmMinMax(find(FAtrace.TargetTimepoint==FAa.TargetTimepoint(m)));
    end
    
    
    FA=joinTable({FAa;FAb;FAtrace});
    J=struct; J.FA=FA;
    [FAout,Volume]=calcSummedFitCoef_2(J);
    
    
    TLfilenameTotal=[SibInfo.Experiment,'_',SibInfo.FamilyName,'_Pl',num2str(FctSpec.Plaque),'.ims'];
    [Fileinfo,~,TLpath]=getFileinfo_2(TLfilenameTotal);
    if isempty(Fileinfo)
        ChunkSize=repmat([-EdgeRadius,EdgeRadius],[3,1]);
    else
        ChunkSize=[-Fileinfo.Um{1}/2,Fileinfo.Um{1}/2];
    end
    
    J=struct;
    J.Res=Volume.Resolution;
    J.UmStart=ChunkSize(:,1);
    J.UmEnd=ChunkSize(:,2);
    J.Pix=round((J.UmEnd-J.UmStart)./J.Res);
    J.PathInitialFile=TLpath;
    J.FA=FA;
    J.BitType='uint8';
    
    merge3D_3(J);
    Application=openImaris_2(TLpath);
    imarisSaveHDFlock(Application,TLpath);
    
    Wave1=variableSetter_2(F.BoutonDetect{1},{'Do','Fin';'Step','4'});
    iFileChanger('W.G.T.F{W.Task,1}.BoutonDetect{W.File}',Wave1);
end

evalin('caller','global W;'); return;