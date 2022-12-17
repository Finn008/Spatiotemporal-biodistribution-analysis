function [Container]=intrDrift_Manual(FfilenameTotal,RfilenameTotal)
global W;

[NameTable,SibInfo]=fileSiblings_3();
FilenameTotalRatioA=NameTable.FilenameTotal{'RatioA'};
FilenameTotalRatioB=NameTable.FilenameTotal{'RatioB'};
FileinfoRatioA=getFileinfo_2(FilenameTotalRatioA);
FileinfoRatioB=getFileinfo_2(FilenameTotalRatioB);

keyboard; % input FitCoefA2B from TaskList_2
% % FitCoefA2B=[0,0,0;0,0,0;0,0,50];
Pix=FileinfoRatioB.Pix{1};
D2DRatioA=struct('FilenameTotal',FilenameTotalRatioA,...
        'Tpix',Pix,...
        'TumMinMax',[FileinfoRatioB.UmStart{1},FileinfoRatioB.UmEnd{1}],...
        'FitCoefs',FitCoefA2B);
    
%     Res=FileinfoTrace.Res{1};
%     Pix=uint16(FileinfoRatioB.Um{1}./Res);

VglutGreen=applyDrift2Data_4(D2DRatioA,'VglutGreen');
VglutRed=applyDrift2Data_4(D2DRatioA,'VglutRed');
ex2Imaris_2(VglutGreen/256,FilenameTotalRatioB,'VglutGreen');
ex2Imaris_2(VglutRed/256,FilenameTotalRatioB,'VglutRed');
imarisSaveHDFlock(FilenameTotalRatioB);

keyboard;
return;
Application=openImaris_2(FilenameTotalRatioB,1,1);

% FilenameTotalTL=['IntrDrift3_',NameTable.Filename{'OriginalB'},'_vs_',NameTable.Filename{'OriginalA'},'.ims'];
% [FileinfoTL]=getFileinfo_2(FilenameTotalTL);
% [PathRawTL,Report]=getPathRaw(FilenameTotalTL);

% check for manually defined initial xyz change
if Report==1
    keyboard;
    Application=openImaris_2(PathRawTL);
    [Vobject,Ind,ObjectList]=selectObject(Application,'Autofluo Selection');
    FitCoefB2A=FileinfoTL.Results{1}.MultiDimInfo.Var1{1}.U.FitCoefs(:,end);
    if isempty(Vobject)==0
%         keyboard;
        [Statistics]=getObjectInfo_2('Autofluo Selection',[],Application);
        FitCoefB2A=FitCoefB2A+[mean(Statistics.TrackInfo.TrackDisplacementX);mean(Statistics.TrackInfo.TrackDisplacementY);mean(Statistics.TrackInfo.TrackDisplacementZ)];
        Vobject.SetName('Autofluo_Selection_Remove');
        Application.GetSurpassScene.AddChild(Vobject, -1);
        Application.FileSave(PathRawTL,'writer="Imaris5"');
    end
    quitImaris(Application);
end



% Um=FileinfoB

J=struct;
Pix=round(FileinfoA.Pix{1}.*[0.5;0.5;1]);
Res=FileinfoA.Um{1}./Pix;

J.Pix=Pix;
J.Res=Res;
J.UmStart=FileinfoA.UmStart{1};
J.UmEnd=FileinfoA.UmEnd{1};
J.Channels=2;
J.Timepoints=1;
J.PathInitialFile=PathRawTL;

J.FA=FA;
J.BitType='uint16';
merge3D_4(J);

