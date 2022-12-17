function [Out]=intrDrift_4(FfilenameTotal,RfilenameTotal,In)
global W;
Out=struct;

v2struct(In);
% search if combination is already present
[~,FNameTable,~]=fileSiblings(FfilenameTotal);
[~,RNameTable,~]=fileSiblings(RfilenameTotal);
[Ffileinfo]=getFileinfo_2(FfilenameTotal);
[Rfileinfo]=getFileinfo_2(RfilenameTotal);

TLfilename=['IntrDrift_',FNameTable.Filename{'Original'},'_vs_',RNameTable.Filename{'Original'},'.ims'];
[TLfileinfo]=getFileinfo_2(TLfilename);
[TLpathRaw,Report]=getPathRaw(TLfilename);
% check for manually defined initial xyz change
if Report==1
    Application=openImaris_2(TLpathRaw);
    [Vobject,Ind,ObjectList]=selectObject(Application,'Autofluo Selection');
    if isempty(Vobject)==0
        [Statistics]=getObjectInfo_2('Autofluo Selection',[],Application);
        FitCoef=TLfileinfo.Results{1}.MultiDimInfo.Var1{1}.U.FitCoefs(:,end);
        FitCoef=FitCoef+[mean(Statistics.TrackInfo.TrackDisplacementX);mean(Statistics.TrackInfo.TrackDisplacementY);mean(Statistics.TrackInfo.TrackDisplacementZ)];
%         keyboard; %rename or delete Autofluo Selection Surface
        Vobject.SetName('Autofluo_Selection_Remove');
        Application.GetSurpassScene.AddChild(Vobject, -1);
    end
end

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
% Res=Rfileinfo.Res{1}.*[2;2;1];

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
% J.SeedsDiameter=3;
[~,Statistics]=generateSurface3(J);

Xcenter=Statistics.Obj2trackInfo.CenterofHomogeneousMassX;
Ycenter=Statistics.Obj2trackInfo.CenterofHomogeneousMassY;
Zcenter=Statistics.Obj2trackInfo.CenterofHomogeneousMassZ;

[Out1]=intrDriftSub2(FitCoef,Xcenter,Ycenter,Zcenter,FfilenameTotal,RfilenameTotal,1,0.3);

Out.Rmse1=sum(Out1.Rmse(:));
if Out.Rmse1>10
    Application.FileSave(TLpathRaw,'writer="Imaris5"');
    [TLfileinfo,FileinfoInd]=extractFileinfo(TLfilename,Application,1);
    evalin('caller','global W;'); return;
end

%% second round

% now put MetRed data with corrected FitCoef in tp 3
FA=table;
FA.FilenameTotal={FfilenameTotal}; % first timepoint contains MetRed and the second VglutRed
FA.RefFilename={RfilenameTotal};
FA.SourceChannel={2};
FA.SourceTimepoint=1;
FA.TargetChannel={1};
FA.TargetTimepoint=[3];
FA.Range={[]};
try; FA.Rotate=Rotate(1); end;
FA.SumCoef{1}=Out1.FFitCoef;

J=struct;
J.Application=Application;
J.FA=FA;
J.PathInitialFile=TLpathRaw;

[Application]=merge3D_3(J);

% determine autofluorescent stuff
J = struct;
J.Application=Application;
J.SurfaceName='Autofluo2';
J.Channel=1;
J.Smooth=0.3;
J.Background=3;
J.LowerManual=AutofluoLowerManual;
J.Gap=0;
J.MaxDist=8;
J.SurfaceInfo=1;
J.TrackAlgorythm='BrownianMotion';
J.SurfaceFilter=['"Volume" above 1.0 um^3'];
J.Roi=[0,0,0,1,   Pix(1),Pix(2),Pix(3),3];
[~,Statistics]=generateSurface3(J);

Xcenter2=Statistics.Obj2trackInfo.CenterofHomogeneousMassX;
Xcenter2=[Xcenter2(:,3),Xcenter2(:,2)];
Ycenter2=Statistics.Obj2trackInfo.CenterofHomogeneousMassY;
Ycenter2=[Ycenter2(:,3),Ycenter2(:,2)];
Zcenter2=Statistics.Obj2trackInfo.CenterofHomogeneousMassZ;
Zcenter2=[Zcenter2(:,3),Zcenter2(:,2)];

[Out2]=intrDriftSub2(Out1.FFitCoef,Xcenter2,Ycenter2,Zcenter2,FfilenameTotal,RfilenameTotal,2,0.3);
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