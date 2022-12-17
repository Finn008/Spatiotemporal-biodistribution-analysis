function [PlaqueChannelData,PlaqueData]=dystrophyDetection_PlaqueDetection_2(FctSpec)
timeTable('Start');
global ChannelTable;

[Outside]=uint8(im2Matlab_3(ChannelTable{'Outside','TargetFilename'},'Outside'));
[PlaqueChannelData]=im2Matlab_3(ChannelTable{FctSpec.PlaqueChannelName,'SourceFilename'},ChannelTable{FctSpec.PlaqueChannelName,'SourceChannelName'});
Fileinfo=getFileinfo_2(ChannelTable{FctSpec.PlaqueChannelName,'SourceFilename'});
Res=Fileinfo.Res{1};


if isfield(FctSpec,'RemoveBlood')==0; FctSpec.RemoveBlood=0; end;
if isfield(FctSpec,'Roundation')==0; FctSpec.Roundation=0; end;

Settings={  'Name','Core2BackgroundRatio','DistanceFromCoreThreshold','SeparatePlaques','RemoveBlood','Roundation','MergeFrayedPlaques','PlaqueGeometryFilter';...
    'MetBlue',4,15,'Intensity&Morphology',FctSpec.RemoveBlood,FctSpec.Roundation,0,0;...
    'NAB228',2.5,4,'Morphology',FctSpec.RemoveBlood,FctSpec.Roundation,1,0;...
    'Ab126468',2.5,4,'Morphology',FctSpec.RemoveBlood,FctSpec.Roundation,1,0;...
    'RBB',2.5,4,'Morphology',FctSpec.RemoveBlood,FctSpec.Roundation,1,0;...
    'CongoRed',1.5,15,'Intensity&Morphology',FctSpec.RemoveBlood,FctSpec.Roundation,0,1;...
    };
Settings=array2table(Settings(2:end,:),'VariableNames',Settings(1,:),'RowNames',Settings(2:end,1));

[PlaqueMap,DistInOut,Membership,PlaqueData,PlaqueChannelData]=wholeSliceQuantification_PlaqueDetection_9(PlaqueChannelData,Outside,Res,Settings(FctSpec.PlaqueChannelName,:));
% ex2Imaris_2(PlaqueMap,FilenameTotal,'PlaqueMap');
ex2Imaris_2(PlaqueChannelData,ChannelTable.TargetFilename{FctSpec.PlaqueChannelName},FctSpec.PlaqueChannelName,[],Res);
ex2Imaris_2(PlaqueMap,ChannelTable.TargetFilename{FctSpec.PlaqueChannelName},'PlaqueMap');
ex2Imaris_2(DistInOut,ChannelTable.TargetFilename{FctSpec.PlaqueChannelName},'DistInOut');
ex2Imaris_2(Membership,ChannelTable.TargetFilename{FctSpec.PlaqueChannelName},'Membership');

Wave1={'PlaqueMap';'DistInOut';'Membership'};
ChannelTable.TargetFilename(Wave1)=ChannelTable.TargetFilename(FctSpec.PlaqueChannelName);
% ex2Imaris_2(PlaqueChannelData,FilenameTotal,FctSpec.PlaqueChannelName);
% ex2Imaris_2(DistInOut,FilenameTotal,'DistInOut');
% ex2Imaris_2(Membership,FilenameTotal,'Membership');

[PlaqueChannelData2D,Wave1]=max(PlaqueChannelData.*uint16(~Outside),[],3);
Wave1=(Wave1(:)-1)*prod(size(PlaqueChannelData2D))+(1:prod(size(PlaqueChannelData2D))).';
PlaqueMap2D=PlaqueChannelData2D; PlaqueMap2D(:)=PlaqueMap(Wave1(:));

ChannelInfo=table;
Wave1={'Version',7.1;'IntensityData',PlaqueChannelData2D;'Colormap','Random';'IntensityMinMax','Norm98';'ColorData',PlaqueMap2D;'ColorMinMax',[0;65535];'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).'; 

ChannelInfo.SizeUm(:,1)={[100;100;0.4]};
ChannelInfo.Res(:,1)={[]};
Path2file=getPathRaw([ChannelTable{FctSpec.PlaqueChannelName,'TargetFilename'}{1},'_QualityControl_Plaques.tif']);
imageGenerator_2(ChannelInfo,Path2file,[],struct('Rotate',-90));
timeTable('End');
% FilenameTotal=ChannelTable{FctSpec.PlaqueChannelName,'TargetFilename'}{1};imarisSaveHDFlock(FilenameTotal); Application=openImaris_4(FilenameTotal,[],1,1);