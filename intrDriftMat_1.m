% [Out]=intrDrift_5(struct('FitCoef',FctSpec.FitCoef));
function [Container]=intrDriftMat_1(In)
global W;

Container=struct;
v2struct(In);

[NameTable,SibInfo]=fileSiblings_3();

FilenameTotalA=NameTable.FilenameTotal{'RatioA'};
FilenameTotalB=NameTable.FilenameTotal{'RatioB'};


% [~,FNameTable,~]=fileSiblings(FfilenameTotal);
% [~,RNameTable,~]=fileSiblings(RfilenameTotal);
FileinfoA=getFileinfo_2(FilenameTotalA);
FileinfoB=getFileinfo_2(FilenameTotalB);

FilenameTotalTL=['IntrDrift2_',NameTable.Filename{'OriginalB'},'_vs_',NameTable.Filename{'OriginalA'},'.ims'];
% TLfilename=['IntrDrift_',FNameTable.Filename{'Original'},'_vs_',RNameTable.Filename{'Original'},'.ims'];
[FileinfoTL]=getFileinfo_2(FilenameTotalTL);
[PathRawTL,Report]=getPathRaw(FilenameTotalTL);

% check for manually defined initial xyz change
if Report==1
    Application=openImaris_2(PathRawTL);
    [Vobject,Ind,ObjectList]=selectObject(Application,'Autofluo Selection');
    if isempty(Vobject)==0
        [Statistics]=getObjectInfo_2('Autofluo Selection',[],Application);
        FitCoef=FileinfoTL.Results{1}.MultiDimInfo.Var1{1}.U.FitCoefs(:,end);
        FitCoef=FitCoef+[mean(Statistics.TrackInfo.TrackDisplacementX);mean(Statistics.TrackInfo.TrackDisplacementY);mean(Statistics.TrackInfo.TrackDisplacementZ)];
        Vobject.SetName('Autofluo_Selection_Remove');
        Application.GetSurpassScene.AddChild(Vobject,-1);
        Application.FileSave(PathRawTL,'writer="Imaris5"');
    end
    quitImaris(Application);
end

VglutRed=im2Matlab_3(FilenameTotalA,'VglutRedPerc');
MetRed=im2Matlab_3(FilenameTotalB,'MetRedPerc');

% Threshold=prctile(VglutRed(1:100:prod(size(VglutRed))),95);
% VglutRed2=VglutRed>100;


% Threshold=prctile(MetRed(1:100:prod(size(MetRed))),95);
% MetRed2=MetRed>=110; % 120


ResA=FileinfoA.Res{1};
ResB=FileinfoB.Res{1};
J=struct('Connectivity',6,'Res',ResA,'ThreshVolume',1,'CenterOfMass',1,'ErodeWindow',ones(3,3));
OutA=generateSurfaceMatlab(VglutRed>100,J);

J=struct('Connectivity',6,'Res',ResB,'ThreshVolume',1,'CenterOfMass',1);
OutB=generateSurfaceMatlab(MetRed>105,J);



FollowerInd=strfind1(W.G.T.F{W.Task}.Filename,NameTable.Filename{'OriginalA'});
try; Rotate=W.G.T.F{W.Task}.Rotate([W.File;FollowerInd(1)],1); end;

FA=table;
FA.Data3D={OutB.Data3D;OutA.Data3D};
FA.TargetChannel={'Autofluo';'Autofluo'};
FA.TargetTimepoint=[1;2];
FA.Rotate=Rotate;
FA.SumCoef{2}=-FitCoef;
FA.Fileinfo={FileinfoB;FileinfoA};

J=struct;
J.Res=FileinfoB.Res{1};
J.UmStart=FileinfoB.UmStart{1};
J.UmEnd=FileinfoB.UmEnd{1};
J.Timepoints=2;
J.PathInitialFile=PathRawTL;
J.FA=FA;
J.BitType='uint16';

[FA]=merge3D_4(J);

spotBasedDriftFinder(OutA.Table,OutB.Table,FitCoef,FileinfoA,FileinfoB);





keyboard;


imarisSaveHDFlock(FilenameTotalTL);
Application=openImaris_2(PathRawTL);
Application.SetVisible(1);
imarisSaveHDFlock(Application,PathRawTL);


Pix=round(Rfileinfo.Pix{1}.*[0.5;0.5;1]);
    Res=Rfileinfo.Um{1}./Pix;
    
    J.Pix=Pix;
    J.Res=Res;
    J.UmStart=Rfileinfo.UmStart{1};
    J.UmEnd=Rfileinfo.UmEnd{1};
    J.Channels=2;
    J.Timepoints=1;
    J.Overwrite=1;
    J.PathInitialFile=TLpathRaw;
    
    J.FA=FA;
    J.BitType='uint16';




[~,MetBlue]=sparseFilter(VglutRed,Outside,Res,10000,[100;100;1],[10;10;Res(3)],70,'Multiply1000');
VglutGreenBackground=sparseFilter(ExactVglutGreen,Exclude,Res,10000,[25;25;Um(3)],[2;2;Um(3)],85);

J=struct;
J.FilenameTotal=NameTable.FilenameTotal{'DeFin'};
J.DataOutput={'Normalize2Percentile',{'50',8000},[];...
    'Normalize2Percentile',{'50',20},['uint8']}; % export it also as 16bit for optimal determination of BRratio
J.TargetChannel=1;
Wave1=depthCorrection_6(J);
ExactVglutRed=Wave1{1};
VglutRed=Wave1{2};
clear Wave1;


return;



Step=0;
if exist('IntrDriftSettings')==1
    IntrDriftSettings='ExcludeRange$X65§';
    IntrDriftSettings=variableExtract(IntrDriftSettings,[],{'$';'§'});
    %     Step=1;
end

IntrDriftSettings.ExcludeThreshold=0.3;



if Step==0
    
    if exist('FitCoef')==1
        if size(FitCoef,2)==1
            FitCoef=[[0,0;0,0;0,0],FitCoef];
        end
    else
        FitCoef=[0,0,0;0,0,0;0,0,0];
    end
    
    %% first round
    FA=table;
    
    FA.FilenameTotal={FfilenameTotal;RfilenameTotal}; % first timepoint contains MetRed and the second VglutRed
    FA.RefFilename={RfilenameTotal;{''}};
    FA.SourceChannel={2;1};
    FA.SourceTimepoint=[1;1];
    FA.TargetChannel={1;1};
    FA.TargetTimepoint=[1;2];
    FA.Range={[];[]};
    try; FA.Rotate=Rotate; end;
    FA.SumCoef{1}=FitCoef;
    
    
    J=struct;
    if exist('Application')==1
        J.Application=Application;
        if TLfileinfo.GetSizeT>1
            FA(2,:)=[];
        end
    end
    
    Pix=round(Rfileinfo.Pix{1}.*[0.5;0.5;1]);
    Res=Rfileinfo.Um{1}./Pix;
    
    J.Pix=Pix;
    J.Res=Res;
    J.UmStart=Rfileinfo.UmStart{1};
    J.UmEnd=Rfileinfo.UmEnd{1};
    J.Channels=2;
    J.Timepoints=1;
    J.Overwrite=1;
    J.PathInitialFile=TLpathRaw;
    
    J.FA=FA;
    J.BitType='uint16';
    J.DataExporter='Imaris';
    [Application]=merge3D_3(J);
    FitCoef=FA.SumCoef{1};
    
    try
        AutofluoLowerManual=IntrDriftAutofluoLowerManual;
    catch
        AutofluoLowerManual=2000;
    end
    % determine autofluorescent stuff
    J = struct;
    J.Application=Application;
    J.SurfaceName='Autofluo';
    J.Channel=1;
    J.Smooth=0.3;
    J.Background=3;
    J.LowerManual=AutofluoLowerManual;
    J.Gap=0;
    J.MaxDist=20;
    J.SurfaceInfo=1;
    J.TrackAlgorythm='BrownianMotion';
    J.SurfaceFilter=['"Volume" above 1.0 um^3'];
    J.Roi=[0,0,0,0,   Pix(1),Pix(2),Pix(3),1];
    generateSurface3(J);
    
end
[Statistics]=getObjectInfo_2('Autofluo',[],Application);

Xcenter=Statistics.Obj2trackInfo.CenterofHomogeneousMassX;
Ycenter=Statistics.Obj2trackInfo.CenterofHomogeneousMassY;
Zcenter=Statistics.Obj2trackInfo.CenterofHomogeneousMassZ;

[Out1]=intrDrift_Fit(FitCoef,Xcenter,Ycenter,Zcenter,FfilenameTotal,RfilenameTotal,IntrDriftSettings);
%     [Out1]=intrDriftSub2(FitCoef,Xcenter,Ycenter,Zcenter,FfilenameTotal,RfilenameTotal,1,0.3);

Out.Rmse1=sum(Out1.Rmse(:));
if Out.Rmse1>10
    Application.FileSave(TLpathRaw,'writer="Imaris5"');
    [TLfileinfo,FileinfoInd]=extractFileinfo(TLfilename,Application,1);
    evalin('caller','global W;'); return;
end

%% recalculate the drift

Xcenter2=Statistics.Obj2trackInfo.CenterofHomogeneousMassX;
Xcenter2=[Xcenter2(:,3),Xcenter2(:,2)];
Ycenter2=Statistics.Obj2trackInfo.CenterofHomogeneousMassY;
Ycenter2=[Ycenter2(:,3),Ycenter2(:,2)];
Zcenter2=Statistics.Obj2trackInfo.CenterofHomogeneousMassZ;
Zcenter2=[Zcenter2(:,3),Zcenter2(:,2)];

[Out2]=intrDrift_Fit(Out1.FFitCoef,Xcenter2,Ycenter2,Zcenter2,FfilenameTotal,RfilenameTotal,2,IntrDriftSettings);
Out.Rmse2=sum(Out2.Rmse(:));

%% now put the refined data onto vglut channel
FA=table;
FA.FilenameTotal={FfilenameTotal};
FA.RefFilename={RfilenameTotal};
FA.SourceChannel={2};
FA.TargetChannel={'Refined'};
FA.TargetTimepoint=[2];
try; FA.Rotate=Rotate(1); end;
FA.SumCoef{1}=Out2.FFitCoef;

J=struct;
J.Application=Application;
J.FA=FA;
J.PathInitialFile=TLpathRaw;

[Application]=merge3D_3(J);

%% save the data
Application.FileSave(TLpathRaw,'writer="Imaris5"');
[TLfileinfo,FileinfoInd]=extractFileinfo(TLfilename,Application,1);

[DriftInfoPos,Driftinfo2add]=searchDriftCombi(FfilenameTotal,RfilenameTotal);
% save Coefs in DriftInfo
Driftinfo2add.Ffilename{1}=FNameTable.Filename{'Original'};
Driftinfo2add.Rfilename{1}=RNameTable.Filename{'Original'};
Results=struct;
Results.FitCoefs=Out2.FFitCoef;
Results.Range=[min(Out2.Table.ZstartF);max(Out2.Table.ZstartF)];
Results.Rmse=Out2.Rmse;
Results.RawData=Out2.Table(:,{'ZstartF';'ZstartR';'Xchange';'Ychange';'Zchange'});
Results.Rotate=Rotate;
Results.Date=datestr(datenum(now),'yyyy.mm.dd HH:MM:SS');
Driftinfo2add.Results{1}=Results;


Driftinfo2add.Ffilename{2}=RNameTable.Filename{'Original'};
Driftinfo2add.Rfilename{2}=FNameTable.Filename{'Original'};
Results=struct;
Results.FitCoefs=Out2.RFitCoef;
Results.Range=[min(Out2.Table.ZstartR);max(Out2.Table.ZstartR)];
Results.Rmse=Out2.Rmse;
Results.RawData=Out2.Table(:,{'ZstartF';'ZstartR';'Xchange';'Ychange';'Zchange'});
Results.Rotate=[Rotate(2);Rotate(1)];
Results.RawData.Properties.VariableNames={'ZstartR';'ZstartF';'Xchange';'Ychange';'Zchange'};
Results.Date=datestr(datenum(now),'yyyy.mm.dd HH:MM:SS');
Driftinfo2add.Results{2}=Results;

iFileChanger('W.G.Driftinfo(DriftInfoPos,:)',Driftinfo2add,{'DriftInfoPos',DriftInfoPos});



Out.FitCoef=Out2.FFitCoef;
evalin('caller','global W;');