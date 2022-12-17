function [PlaqueChannelData,PlaqueData]=dystrophyDetection_PlaqueDetection(FilenameTotal,FctSpec,FilenameTotalOrig,ChannelListOrig)
timeTable('Start');
[Fileinfo,Ind,PathRaw]=getFileinfo_2(FilenameTotal);
Res=Fileinfo.Res{1};

if isfield(FctSpec,'Specimen') && strcmp(FctSpec.Specimen,'InToto')
    FilenameTotal_Outside=regexprep(FilenameTotal,'.ims','_Outside.ims');
    Outside=uint8(im2Matlab_3(FilenameTotal_Outside,'Outside'));
    [PlaqueChannelData]=im2Matlab_3(FilenameTotal,FctSpec.PlaqueChannelName);
    Outside=interpolate3D_2(Outside,[],[],size(PlaqueChannelData));
else
    [Outside]=im2Matlab_3(FilenameTotal,'Outside');
    [PlaqueChannelData]=im2Matlab_3(FilenameTotalOrig,strfind1(ChannelListOrig,FctSpec.PlaqueChannelName,1));
end


if isfield(FctSpec,'RemoveBlood')==0; FctSpec.RemoveBlood=0; end;
if isfield(FctSpec,'Roundation')==0; FctSpec.Roundation=0; end;

Settings={  'Name','Core2BackgroundRatio','DistanceFromCoreThreshold','SeparatePlaques','RemoveBlood','Roundation','MergeFrayedPlaques';...
    'MetBlue',4,15,'Intensity&Morphology',FctSpec.RemoveBlood,FctSpec.Roundation,0;...
    'NAB228',2.5,4,'Morphology',FctSpec.RemoveBlood,FctSpec.Roundation,1;...
    'Ab126468',2.5,4,'Morphology',FctSpec.RemoveBlood,FctSpec.Roundation,1;...
    'RBB',2.5,4,'Morphology',FctSpec.RemoveBlood,FctSpec.Roundation,1;...
    'CongoRed',4,15,'Morphology',FctSpec.RemoveBlood,FctSpec.Roundation,1;...
    };
Settings=array2table(Settings(2:end,:),'VariableNames',Settings(1,:),'RowNames',Settings(2:end,1));

[PlaqueMap,DistInOut,Membership,PlaqueData,PlaqueChannelData]=wholeSliceQuantification_PlaqueDetection_8(PlaqueChannelData,Outside,Res,FilenameTotal,Settings(FctSpec.PlaqueChannelName,:));
ex2Imaris_2(PlaqueMap,FilenameTotal,'PlaqueMap');
ex2Imaris_2(PlaqueChannelData,FilenameTotal,FctSpec.PlaqueChannelName);
ex2Imaris_2(DistInOut,FilenameTotal,'DistInOut');
ex2Imaris_2(Membership,FilenameTotal,'Membership');
% UmCenter, PixCenter, DistanceCenter2TopBottom, BorderTouch, PlaqueRadius

% make a quality control image


% keyboard; % check if it works
[PlaqueChannelData2D,Wave1]=max(PlaqueChannelData.*uint16(~Outside),[],3);
Wave1=(Wave1(:)-1)*prod(size(PlaqueChannelData2D))+(1:prod(size(PlaqueChannelData2D))).';
PlaqueMap2D=PlaqueChannelData2D; PlaqueMap2D(:)=PlaqueMap(Wave1(:));

ChannelInfo=table;
Wave1={'Version',7.1;'IntensityData',PlaqueChannelData2D;'Colormap','Random';'IntensityMinMax','Norm98';'ColorData',PlaqueMap2D;'ColorMinMax',[0;65535];'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).'; 

ChannelInfo.SizeUm(:,1)={[100;100;0.4]};
ChannelInfo.Res(:,1)={[]};
Path2file=getPathRaw([FilenameTotal,'_QualityControl_Plaques.tif']);
imageGenerator_2(ChannelInfo,Path2file,[],struct('Rotate',-90));
timeTable('End');

% PlaqueMap=Membership; PlaqueMap(DistInOut>50)=0;
% PlaqueChannelData2D=max(PlaqueChannelData.*uint16(~Outside),[],3);
% Wave1=double(prctile(PlaqueChannelData2D(:),98));
% PlaqueChannelData2D=uint16(PlaqueChannelData2D/(Wave1/65535));
% Colormap=repmat(linspace(0,1,65535).',[1,3]);
% Image=ind2rgb(gray2ind(PlaqueChannelData2D,65535),Colormap);
% PlaqueMap2D=uint16(max(PlaqueMap,[],3));
% Colormap=rand(65535,3);
% Image(find(PlaqueMap2D~=0))=Colormap(PlaqueMap2D(PlaqueMap2D~=0),1).*double(PlaqueChannelData2D(PlaqueMap2D~=0))/65535;
% Image(find(PlaqueMap2D~=0)+prod(size(Image(:,:,1))))=Colormap(PlaqueMap2D(PlaqueMap2D~=0),2).*double(PlaqueChannelData2D(PlaqueMap2D~=0))/65535;
% Image(find(PlaqueMap2D~=0)+2*prod(size(Image(:,:,1))))=Colormap(PlaqueMap2D(PlaqueMap2D~=0),3).*double(PlaqueChannelData2D(PlaqueMap2D~=0))/65535;
% [Path,Report]=getPathRaw([FilenameTotal,'_QualityControl_Plaques.tif']);
% imwrite(permute(Image,[2,1,3]),Path);
% timeTable('End');