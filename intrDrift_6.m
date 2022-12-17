function [Container]=intrDrift_6(FfilenameTotal,RfilenameTotal,In)
global W;
Container=struct;
v2struct(In);

keyboard; % change in IntrDrift2 file the RawData imported, has no more contrast, limit number of structures to certain value?

[NameTable,SibInfo]=fileSiblings_3();
FilenameTotalA=NameTable.FilenameTotal{'RatioA'};
FilenameTotalB=NameTable.FilenameTotal{'RatioB'};
FileinfoA=getFileinfo_2(FilenameTotalA);
FileinfoB=getFileinfo_2(FilenameTotalB);
FilenameTotalTL=['IntrDrift2_',NameTable.Filename{'OriginalB'},'_vs_',NameTable.Filename{'OriginalA'},'.ims'];
[FileinfoTL]=getFileinfo_2(FilenameTotalTL);
[PathRawTL,Report]=getPathRaw(FilenameTotalTL);

keyboard; % take FitCoefB2A from calculation in boutonDetect
% check for manually defined initial xyz change
if Report==1
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

if exist('FitCoefB2A')==1
    % donot delete
elseif exist('FitCoefB2A')~=1 && exist('ManualFitCoefB2A')==1 % if new ManualFitCoefB2A has to be used then delete the file beforehand
    FitCoefB2A=ManualFitCoefB2A;
else
    FitCoefB2A=[0,0,0;0,0,0;0,0,0];
end

if size(FitCoefB2A,2)==1
    FitCoefB2A=[[0,0;0,0;0,0],FitCoefB2A];
end

FollowerInd=strfind1(W.G.T.F{W.Task}.Filename,NameTable.Filename{'OriginalA'});
Rotate=W.G.T.F{W.Task}.Rotate([W.File;FollowerInd(1)],1);

FileList=listAllFiles([W.G.PathOut,'\IntrDrift\']);
FileList=FileList(strfind1(FileList.FilenameTotal,[FilenameTotalB,'_vs_',FilenameTotalA,'.jpg'],[],1),:);
for m=1:size(FileList,1)
    Path=['del "',FileList.Path2file{m,1},'"'];
    try; [Status,Cmdout]=dos(Path); end;
end

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
    
    [Xcenter,Ycenter,Zcenter]=intrDrift_loop(FitCoefB2A,FilenameTotalA,FilenameTotalB,FileinfoA,FileinfoB,NameTable,FilenameTotalTL,MaxDistance,Rotate);
    [Out]=intrDrift_FitCoefTracer(FitCoefB2A,Xcenter,Ycenter,Zcenter,FilenameTotalA,FilenameTotalB,BorderDistance,Loop,DriftZcutoff);
    
    Table.RmseSum(Loop,1)=sum(Out.Rmse);
    Table.MinMaxB(Loop,1)={Out.MinMaxB};
    Table.DeleteVar(Loop,1)={Out};
    
    if sum(Out.Rmse)>10
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
end
if Loop==5
    keyboard;
end

Container.Table=Table;
Container.Rmse=Table.RmseSum(end);
Container.FitCoefB2A=FitCoefB2A;


[DriftInfoPos,Driftinfo2add]=searchDriftCombi(FilenameTotalB,FilenameTotalA);
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

iFileChanger('W.G.Driftinfo(DriftInfoPos,:)',Driftinfo2add,{'DriftInfoPos',DriftInfoPos});
evalin('caller','global W;');
