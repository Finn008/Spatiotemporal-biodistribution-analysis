function [Container]=intrDrift_7(FfilenameTotal,RfilenameTotal,FitCoefB2A,RotateTrace2B,RotateTrace2A,In)
global W;
Container=struct;
v2struct(In);


[NameTable,SibInfo]=fileSiblings_3();
FilenameTotalRatioA=NameTable.FilenameTotal{'RatioA'};
FilenameTotalRatioB=NameTable.FilenameTotal{'RatioB'};
FileinfoRatioA=getFileinfo_2(FilenameTotalRatioA);
FileinfoRatioB=getFileinfo_2(FilenameTotalRatioB);
FilenameTotalTL=['IntrDrift3_',NameTable.Filename{'OriginalB'},'_vs_',NameTable.Filename{'OriginalA'},'.ims'];
[FileinfoTL]=getFileinfo_2(FilenameTotalTL);
[PathRawTL,Report]=getPathRaw(FilenameTotalTL);


% check for manually defined initial xyz change
if Report==1
    Application=openImaris_2(PathRawTL);
    [Vobject,Ind,ObjectList]=selectObject(Application,'Autofluo Selection');
% % % % % %     FitCoefB2A=FileinfoTL.Results{1}.MultiDimInfo.Var1{1}.U.FitCoefs(:,end);
    if isempty(Vobject)==0
%         keyboard; % test if correctly working
        [Statistics]=getObjectInfo_2('Autofluo Selection',[],Application);
        Wave1=[mean(Statistics.TrackInfo.TrackDisplacementX);mean(Statistics.TrackInfo.TrackDisplacementY);mean(Statistics.TrackInfo.TrackDisplacementZ)];
        FitCoefB2A=[zeros(3,2),FitCoefB2A(:,3)+Wave1];
        Vobject.SetName('Autofluo_Selection_Remove');
        Application.GetSurpassScene.AddChild(Vobject, -1);
        Application.FileSave(PathRawTL,'writer="Imaris5"');
    end
    quitImaris(Application);
end

if exist('FitCoefB2A')~=1
    FitCoefB2A=[0,0,0;0,0,0;0,0,0];
end

if size(FitCoefB2A,2)==1
    FitCoefB2A=[[0,0;0,0;0,0],FitCoefB2A];
end

FollowerInd=strfind1(W.G.T.F{W.Task}.Filename,NameTable.Filename{'OriginalA'});
Rotate=W.G.T.F{W.Task}.Rotate([W.File;FollowerInd(1)],1);

FileList=listAllFiles([W.G.PathOut,'\IntrDrift\']);
FileList=FileList(strfind1(FileList.FilenameTotal,[FilenameTotalRatioB,'_vs_',FilenameTotalRatioA,'.jpg'],[],1),:);
for m=1:size(FileList,1)
    Path=['del "',FileList.Path2file{m,1},'"'];
    try; [Status,Cmdout]=dos(Path); end;
end
% keyboard; % change in IntrDrift2 file the RawData imported, has no more contrast, limit number of structures to certain value?
Table=table;
for Loop=1:10
    Table.FitCoefB2A(Loop,1)={FitCoefB2A};
    if Loop==1
        MaxDistance=20;
        BorderDistance=5;
    elseif Loop>1
        MaxDistance=8;
        BorderDistance=3;
    end
    Table.MaxDistance(Loop,1)=MaxDistance;
    Table.BorderDistance(Loop,1)=BorderDistance;
    
    [Xcenter,Ycenter,Zcenter]=intrDrift_loop_2(FitCoefB2A,FilenameTotalRatioA,FilenameTotalRatioB,FileinfoRatioA,FileinfoRatioB,NameTable,FilenameTotalTL,MaxDistance,Rotate,Loop);
    [Out]=intrDrift_FitCoefTracer_2(FitCoefB2A,Xcenter,Ycenter,Zcenter,FilenameTotalRatioA,FilenameTotalRatioB,BorderDistance,Loop,DriftZcutoff);
    
    Table.RmseSum(Loop,1)=sum(Out.Rmse);
    Table.MinMaxB(Loop,1)={Out.MinMaxB};
    Table.DeleteVar(Loop,1)={Out};
    
    if sum(Out.Rmse)>6
        break;
    else
        FitCoefB2A=Out.FitCoefB2A;
        Xaxis=Out.MinMaxB; Xaxis=(Xaxis(3,1):1:Xaxis(3,2)).';
        clear Delta;
        for m=1:3
            Yaxis=FitCoefB2A(m,1).*Xaxis.^2+FitCoefB2A(m,2).*Xaxis+FitCoefB2A(m,3);
            Yaxis(:,2)=Table.FitCoefB2A{end}(m,1).*Xaxis.^2+Table.FitCoefB2A{end}(m,2).*Xaxis+Table.FitCoefB2A{end}(m,3);
            Delta(:,m)=Yaxis(:,2)-Yaxis(:,1);
        end
        Wave1=sum(abs(Delta),2);
        Table.MeanDelta(Loop,1)=mean(Wave1);
        if mean(Wave1)<0.5 && max(Wave1)<0.7
            break;
        end
    end
    disp(Loop)
end
% if Loop==5
%     keyboard;
% end

Container.Table=Table;
Container.Rmse=Table.RmseSum(end);
Container.FitCoefB2A=FitCoefB2A;


[DriftInfoPos,Driftinfo2add]=searchDriftCombi(FilenameTotalRatioB,FilenameTotalRatioA);
% save Coefs in DriftInfo
Driftinfo2add.Ffilename{1}=NameTable.Filename{'OriginalB'};
Driftinfo2add.Rfilename{1}=NameTable.Filename{'OriginalA'};
Results=struct;
Results.FitCoefs=Out.FitCoefB2A;
Results.Range=Out.MinMaxB(3,:).';
Results.Rmse=Out.Rmse;
Results.Rotate=Rotate;
Results.Date=datestr(datenum(now),'yyyy.mm.dd HH:MM:SS');
Driftinfo2add.Results{1}=Results;


Driftinfo2add.Ffilename{2}=NameTable.Filename{'OriginalA'};
Driftinfo2add.Rfilename{2}=NameTable.Filename{'OriginalB'};
Results=struct;
Results.FitCoefs=Out.FitCoefB2A;
Results.Range=Out.MinMaxA(3,:).';
Results.Rmse=Out.Rmse;
Results.Rotate=[Rotate(2);Rotate(1)];
Results.Date=datestr(datenum(now),'yyyy.mm.dd HH:MM:SS');
Driftinfo2add.Results{2}=Results;

% % % % % % keyboard; % place VglutGreen and VglutRed into RatioB file
% % % % % % % how to turn FitCoefB2A into FitCoefA2B????
% % % % % % [Table.X(:,1),Table.Y(:,1),Table.Z(:,1),]=intrDrift_invertFitCoef(FitCoef,Table.X(:,1),Table.Y(:,1),Table.Z(:,1),[-100;+100]);
% % % % % % Pix=FileinfoRatioB.Pix{1};
% % % % % % D2DRatioA=struct('FilenameTotal',FilenameTotalRatioA,...
% % % % % %     'Tpix',Pix,...
% % % % % %     'TumMinMax',[FileinfoRatioB.UmStart{1},FileinfoRatioB.UmEnd{1}],...
% % % % % %     'FitCoefs',FitCoefA2B);
% % % % % % 
% % % % % % 
% % % % % % VglutGreen=applyDrift2Data_4(D2DRatioA,'VglutGreen');
% % % % % % VglutRed=applyDrift2Data_4(D2DRatioA,'VglutRed');
% % % % % % ex2Imaris_2(VglutGreen/256,FilenameTotalRatioB,'VglutGreen');
% % % % % % ex2Imaris_2(VglutRed/256,FilenameTotalRatioB,'VglutRed');
% % % % % % imarisSaveHDFlock(FilenameTotalRatioB);



% export MaxIntensityProjection of MetRed and VglutRed
Pix=FileinfoRatioA.Pix{1};
D2DRatioB=struct('FilenameTotal',FilenameTotalRatioB,...
    'Tpix',Pix,...
    'TumMinMax',[-FileinfoRatioA.Um{1}/2,FileinfoRatioA.Um{1}/2],...
    'FitCoefs',FitCoefB2A,...
    'Rotate',RotateTrace2B,...
    'Interpolation','Bilinear');

D2DRatioA=struct('FilenameTotal',FilenameTotalRatioA,...
        'Tpix',Pix,...
        'Rotate',RotateTrace2A);
    
MetRed=applyDrift2Data_4(D2DRatioB,'MetRed');
VglutRed=applyDrift2Data_4(D2DRatioA,'VglutRed')/256;
% VglutRed=im2Matlab_3(FilenameTotalRatioA,'VglutRed')/256;

ChannelInfo=table;
ChannelInfo(1,{'Channel','Colormap','ColorMinMax'})={'MetRed',{[0;1;1]},{[0;255]}};
ChannelInfo(2,{'Channel','Colormap','ColorMinMax'})={'VglutRed',{[1;0;1]},{[0;255]}};
% keyboard; % intensityProjection Z profile is upside down
Res=FileinfoRatioA.Res{1};
[~,~,~,ChannelInfo.Data{1,1}]=intensityProjection(MetRed,Res,10);
[~,~,~,ChannelInfo.Data{2,1}]=intensityProjection(VglutRed,Res,10);
Path2file=[W.G.PathOut,'\IntrDrift\',regexprep(FilenameTotalRatioA,'.ims',''),'_MaxIntensityProjection.tif'];
imageGenerator(ChannelInfo,Path2file);




iFileChanger('W.G.Driftinfo(DriftInfoPos,:)',Driftinfo2add,{'DriftInfoPos',DriftInfoPos});
evalin('caller','global W;');
