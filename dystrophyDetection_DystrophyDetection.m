function [DystrophyData,DystrophyDiameter]=dystrophyDetection_DystrophyDetection(FilenameTotal,FctSpec,FilenameTotalOrig,ChannelListOrig)
timeTable('Start');
[Fileinfo,Ind,PathRaw]=getFileinfo_2(FilenameTotal);
Res=Fileinfo.Res{1};

% [Outside]=im2Matlab_3(FilenameTotal,'Outside');
[DystrophyData]=im2Matlab_3(FilenameTotalOrig,strfind1(ChannelListOrig,FctSpec.DystrophyChannelName,1));
if strfind1(Fileinfo.ChannelList{1},'Outside',1)
    [Outside]=im2Matlab_3(FilenameTotal,'Outside');
else
    Outside=zeros(size(Data3D),'uint8');
end
% if isfield(FctSpec,'RemoveBlood')==0; FctSpec.RemoveBlood=0; end;
% if isfield(FctSpec,'Roundation')==0; FctSpec.Roundation=0; end;

Settings={  'Name','CorrPrctile','CorrFactor','ThreshPrctile','WatershedMax';...
    'Vglut1',85,10000,75,7;...
    'Vglut1_InVivo',85,5000,75,7;...
    'Ab22C11',85,5000,90,0;...
    'APPY188',50,500,75,0;...
    'Lamp1',50,500,80,0;...
    'Bace1',50,2500,70,0;...
    };
Settings=array2table(Settings,'VariableNames',Settings(1,:),'RowNames',Settings(:,1));

[DystrophyData,DystrophyDiameter]=dystrophyDetection_IndividualDystros_3(DystrophyData,Outside,Res,Settings(FctSpec.DystrophyChannelName,:),FilenameTotal);

% make a quality control image

[DystrophyData2D,Wave1]=max(DystrophyData.*uint16(~Outside),[],3);
Wave1=(Wave1(:)-1)*prod(size(DystrophyData2D))+(1:prod(size(DystrophyData2D))).';
DystrophyDiameter2D=DystrophyData2D; DystrophyDiameter2D(:)=DystrophyDiameter(Wave1(:));

ChannelInfo=table;
Wave1={'Version',7.1;'IntensityData',DystrophyData2D;'Colormap','Spectrum1';'IntensityMinMax','Norm96';'ColorData',DystrophyDiameter2D;'ColorMinMax',[0;100];'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
ChannelInfo.SizeUm(:,1)={[100;100;0.4]};
ChannelInfo.Res(:,1)={[]};
Path2file=getPathRaw([FilenameTotal,'_QualityControl_',FctSpec.DystrophyChannelName,'Dystrophy.tif']);
imageGenerator_2(ChannelInfo,Path2file,[],struct('Rotate',-90));
timeTable('End');