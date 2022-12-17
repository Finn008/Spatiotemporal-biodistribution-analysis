function [FA]=ratioPlaque_Data2Trace(SourceChannels,TargetChannels,Criterium,Filename)
global W;
if exist('Filename')==1
    [NameTable,SibInfo]=fileSiblings_3(Filename);
else
    [NameTable,SibInfo]=fileSiblings_3();
end
% NameTable=evalin('caller','NameTable');
% SibInfo=evalin('caller','SibInfo');

try
    FilenameTotalTrace=NameTable.FilenameTotal{'Trace'};
    FileinfoTrace=getFileinfo_2(FilenameTotalTrace);
    MultiDimInfo=FileinfoTrace.Results{1}.MultiDimInfo;
    FitCoefB2Trace=checkMultiDimInfoEqualityInChannels(MultiDimInfo);
catch error
%     keyboard; % not used since 2016.07.08
    TLfilename=NameTable{'DriftCorr','FilenameTotal'};
    [TLfileinfo,TLind,TLpathRaw]=getFileinfo_2(TLfilename);
    Application=openImaris_2(TLpathRaw);
    
    % get center of mass of plaques
    [Vobject,A2,PlaqueList]=selectObject(Application,'Plaques Selection');
    if strfind1(PlaqueList,'Plaques Selection',1)==0
        disp('Surface Plaques does not exist in DriftCorr file');
        A1=asdf;
    end
    
    [Results]=getObjectInfo_2(Vobject,[],Application);
    quitImaris(Application);
    clear Application;
    Xcenter=Results.Obj2trackInfo.CenterofHomogeneousMassX.';
    Ycenter=Results.Obj2trackInfo.CenterofHomogeneousMassY.';
    Zcenter=Results.Obj2trackInfo.CenterofHomogeneousMassZ.';
    [Out1]=calcDrift({Xcenter;Ycenter;Zcenter});
    
    for m=1:size(Out1.MeanNorm2First{1},1)
        FitCoefB2Trace(m,1:3)=[Out1.MeanNorm2First{1}(m,1),...
            Out1.MeanNorm2First{2}(m,1),...
            Out1.MeanNorm2First{3}(m,1)];
    end
end
J=struct;
J.InterCalc=repmat({0,[]},[size(SourceChannels,1),1]);
try; J.InterCalc(strcmp(SourceChannels,'MetBlueCorr'),1:2)={1,[]}; end;
try; J.InterCalc(strcmp(SourceChannels,'Plaque'),1:2)={2,struct('Threshold',10)}; end;

FileList=SibInfo.FileList;
FileList=FileList(strfind1(FileList.Filename,SibInfo.FamilyName),:);
FA=table;
FA.FilenameTotal=strcat(FileList.Filename);
FA.SourceChannel=repmat({SourceChannels},[size(FA,1),1]);
FA.SourceTimepoint(1)=1;FA.SourceTimepoint(:)=1;
FA.TargetChannel=repmat({TargetChannels},[size(FA,1),1]);
FA.TargetTimepoint=FileList.TargetTimepoint(:,1);
try; FA.Rotate=strcat(FileList.Rotate); end;
FA.Selection=FileList.RatioPlaque(:,1);
FA.RowSpecifier=FileList.RowSpecifier;
FA=FA(strfind1(FA.Selection,'Do#'),:);
for m=1:size(FA,1)
    [Wave1]=fileSiblings_3(FA.FilenameTotal{m,1});
    FA.FilenameTotal{m,1}=Wave1.FilenameTotal{'RatioB'};
end
for m=1:size(FA,1)
    FA.SumCoef{m,1}=[zeros(3,2),FitCoefB2Trace(m,1:3).'];
end

[FA,Volume]=calcSummedFitCoef_2(struct('FA',FA,'ResAdjust',{[2;2;1]}));

if ischar(Criterium); Criterium={Criterium}; end;
if strcmp(Criterium{1},'Step#2')
    FA=FA(strfind1(FA.Selection,'Step#2'),:);
elseif strcmp(Criterium{1},'CurrentFile')
    FA=FA(strfind1(FA.FilenameTotal,F.Filename),:);
elseif strcmp(Criterium{1},'TargetTimepoint')
    FA=FA(FA.TargetTimepoint==Criterium{2},:);
end

TLfilename=NameTable{'Trace','FilenameTotal'};
[~,~,TLpathRaw]=getFileinfo_2(TLfilename);

J.Pix=Volume.TotalVolumePix;
J.Res=Volume.Resolution;
J.UmStart=Volume.TotalVolumeUm(:,1);
J.UmEnd=Volume.TotalVolumeUm(:,2);
J.Timepoints=max(FA.TargetTimepoint);
J.PathInitialFile=TLpathRaw;
J.FA=FA;
J.BitType='uint8';

[FA]=merge3D_4(J); % (ch1-1).*double(logical(uint8(ch2-10)))
