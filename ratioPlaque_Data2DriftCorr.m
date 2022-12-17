function [FAtotal,Path2fileDriftCorr]=ratioPlaque_Data2DriftCorr(Channels,Criterium)
global W;
F=W.G.T.F{W.Task}(W.File,:);
% Criterium='CurrentFile';
SibInfo=evalin('caller','SibInfo');
NameTable=evalin('caller','NameTable');

FileList=SibInfo.FileList;
FileList=FileList(strfind1(FileList.Filename,SibInfo.FamilyName),:);
FA=table;
FA.FilenameTotal=strcat(FileList.Filename);
FA.SourceChannel=repmat({Channels},[size(FA,1),1]);
FA.SourceTimepoint(:,1)=1;
FA.TargetChannel=repmat({Channels},[size(FA,1),1]);
FA.TargetTimepoint=FileList.TargetTimepoint(:,1);
try; FA.Rotate=strcat(FileList.Rotate); end;
FA.RowSpecifier=FileList.RowSpecifier;
FA.Selection=FileList.RatioPlaque(:,1);
FA=FA(strfind1(FA.Selection,'Do#'),:);
for m=1:size(FA,1)
    [Wave1]=fileSiblings_3(FA.FilenameTotal{m,1});
    FA.FilenameTotal{m,1}=Wave1.FilenameTotal{'RatioB'};
end

J=struct;
J.FA=FA;
J.ResAdjust=[2;2;1];
[FA,Volume]=calcSummedFitCoef_2(J);

if strcmp(Criterium,'Step#1')
    FA=FA(strfind1(FA.Selection,'Step#1'),:);
% elseif strcmp(Criterium,'Do#')
%     FA=FA(strfind1(FA.Selection,'Do#'),:);
elseif strcmp(Criterium,'CurrentFile')
    FA=FA(strfind1(FA.FilenameTotal,F.Filename),:);
end

% define initial file

FilenameTotalDriftCorr=NameTable{'DriftCorr','FilenameTotal'};
FAtotal=FA;
try % only put data if the source file was changed inbetween
    [FileinfoDriftCorr,~,Path2fileDriftCorr]=getFileinfo_2(FilenameTotalDriftCorr);
    MultiDimInfo=FileinfoDriftCorr.Results{1}.MultiDimInfo;
    for File=1:size(FA,1)
        Fileinfo=getFileinfo_2(FA.FilenameTotal{File});
        Wave1=MultiDimInfo{FA.TargetTimepoint(File),Channels{1}}{1}.Fileinfo.Datenum;
        if Fileinfo.Datenum(1)==Wave1
           FA.Delete(File,1)=1; 
        end
    end
    FA(FA.Delete==1,:)=[];
end
% return;
J=struct;
J.Pix=Volume.TotalVolumePix;
J.Res=Volume.Resolution;
J.UmStart=Volume.TotalVolumeUm(:,1);
J.UmEnd=Volume.TotalVolumeUm(:,2);
J.PathInitialFile=Path2fileDriftCorr;
J.FA=FA;
J.BitType='uint8';
merge3D_3(J);