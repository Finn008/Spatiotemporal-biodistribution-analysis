function immunoAdjust()
keyboard; % not in use since 2015.10.06

global w; global l;
t=l.t(w.task,:);
f=l.t.f{w.task}(w.file,:);
[f.immunoAdjust]=variableExtract(f.immunoAdjust{1},{'lll';'Type'});
[Fileinfo,IndFileinfo,Path2file]=GetFileInfo([f.filename{1},f.type{1}]);

i=struct;
i.Path2file=Path2file;
Application=openImaris_2(i);
w.ImmunoAdjustType=f.immunoAdjust.Type;
Inclusion=[];
% Chengy1: cortex all included
% Chengy2: cortex with manually defined inclusion
% Chengy3: hippocampus, automatic inclusion detection
% Chengy4: hippocampus, manually defined inclusion
if strcmp(f.immunoAdjust.Type,'Chengy2') % use manually calculated Inclusion
    [Inclusion]=Im2Matlab(Application,'Inclusion',1,'surface');
    MaximumProjection=max(Inclusion,[],3);
    Inclusion=repmat(MaximumProjection,[1,1,size(Inclusion,3)]);
elseif strcmp(f.immunoAdjust.Type,'Chengy3')
    i=struct;
    i.Application=Application;
    i.SurfaceName='Inclusion';
    i.Channel=2;
    i.Smooth=10;
    i.Background=10;
    i.LowerManual=150;
    i.RGBA=[1,1,1,0];
    i.SurfaceFilter='"Volume" above 2.00e5 um^3';
    [plaqueSurface,plaqueSurfaceInfo]=generateSurface3(i);
    [Inclusion]=Im2Matlab(Application,'Inclusion',1,'surface');
    [Inclusion]=layerAreaThreshold(Inclusion,0.25);
    
%     IncludedAreaProfile=sum(sum(Inclusion,1),2);
%     IncludedAreaProfile=permute(IncludedAreaProfile,[3,1,2]);
%     Threshold=max(IncludedAreaProfile(:))*0.25;
%     Inclusion(:,:,IncludedAreaProfile<Threshold)=0;
%     IncludedAreaProfile(IncludedAreaProfile<Threshold)=1;
%     IncludedAreaProfile(IncludedAreaProfile>=Threshold)=2;
%     for m=1:size(Inclusion,3)
%         Inclusion(:,:,m)=Inclusion(:,:,m)*IncludedAreaProfile(m);
%     end
%     Ex2Imaris(Application,Inclusion,'Inclusion',1,'Inclusion');
%     Inclusion(Inclusion==1)=0;
%     Inclusion=logical(Inclusion);
elseif strcmp(f.immunoAdjust.Type,'Chengy4')
    [Inclusion]=Im2Matlab(Application,'Inclusion',1,'surface');
    [Inclusion]=layerAreaThreshold(Inclusion,0.25);
end

%% define inclusion volume
DeterminInclusionVolume=0;
if DeterminInclusionVolume==1
    i=struct;
    i.Application=Application;
    i.SurfaceName='Inclusion';
    i.Channel=2;
    i.Smooth=40;
    i.Background=20;
    i.LowerManual=1;
    i.RGBA=[1,1,1,0];
    i.StoreAsChannel=1;
    [plaqueSurface,plaqueSurfaceInfo]=generateSurface3(i);
    [Inclusion]=Im2Matlab(Application,'Inclusion');
    IncludedAreaProfile=sum(sum(Inclusion,1),2);
    IncludedAreaProfile=permute(IncludedAreaProfile,[3,1,2]);
    Threshold=max(IncludedAreaProfile(:))*0.8;
    IncludedAreaProfile(IncludedAreaProfile<Threshold)=1;
    IncludedAreaProfile(IncludedAreaProfile>=Threshold)=2;
    for m=1:size(Inclusion,3)
        Inclusion(:,:,m)=Inclusion(:,:,m)*IncludedAreaProfile(m);
    end
    Ex2Imaris(Application,Inclusion,'Inclusion',1,'Inclusion');
    Inclusion(Inclusion==1)=0;
    Inclusion=logical(Inclusion);
end

%%
i=struct;
i.FilenameTotal=[f.filename{1},f.type{1}];
i.TargetChannel=2;
i.Zres=Fileinfo.res{1}(3);
i.Inclusion=Inclusion;
i.DataOutput={   'Normal',[];...
                    'AdjustmentFactor',[];...
                    'Normalize2FirstFile','allPercentiles';...
                    'Normalize2FirstFile',[50;100];...
                    'Normalize2Percentile',{'100',30000};...
                    'IntensityBinningLayer','allPercentiles';...
                    'IntensityBinning3D','allPercentiles';...
                 };
                    
i.Display=  {   'PercMap',1;...
                'histogram',1;...
                'IntensityVsPercentile',1;...
                'normMeanProfile',1;...
        };
i.CorrType='Immuno';
[Out1,Data4D]=depthCorrection_6(i);

Ex2Imaris(Application,Data4D(:,:,:,1),'DepthCorrected',1,'DepthCorrected',[],[0;6000]);
Ex2Imaris(Application,Data4D(:,:,:,2),'AdjustmentFactor',1,'AdjustmentFactor',[],[0;250]);
Ex2Imaris(Application,Data4D(:,:,:,3),'NormalizeAllPercentiles',1,'NormalizeAllPercentiles',[],[0;6000]);
Ex2Imaris(Application,Data4D(:,:,:,4),'NormalizeMean50to100',1,'NormalizeMean50to100',[],[0;6000]);
Ex2Imaris(Application,Data4D(:,:,:,5),'NormalizeMean100',1,'NormalizeMean100',[],[0;65535]);
Ex2Imaris(Application,Data4D(:,:,:,6),'PercentileProfile',1,'PercentileProfile',[],[0;100]);
Ex2Imaris(Application,Data4D(:,:,:,7),'PercentileMap',1,'PercentileMap',[],[0;100]);



% Application.SetVisible(1);

[Data3DGFP]=Im2Matlab(Application,1,1);
PercentileMap=Data4D(:,:,:,7);
DepthCorrected=Data4D(:,:,:,1);
Data3DGFP(PercentileMap<80)=0;
% Data3DGFP(DepthCorrected==0)=0;
Ex2Imaris(Application,Data3DGFP,'GFP',1,'GFP');

i=struct;
i.Application=Application;
i.SurfaceName='GFPcells';
i.Channel='GFP';
i.Smooth=1;
i.Background=3;
i.LowerManual=1000;
i.SurfaceFilter='"Volume" above 500 um^3';
i.RGBA=[0,1,0,0];
[plaqueSurface,plaqueSurfaceInfo]=generateSurface3(i);


% [a1,a2,a3]=GetFileInfo([f.filename{1},'g',f.type{1}]);
[CorrFileinfo,CorrInd,CorrPath]=GetFileInfo([f.filename{1},'_corr.ims']);
% [Fileinfo,IndFileinfo,Path2file]=GetFileInfo([f.filename{1},f.type{1}]);
Application.FileSave(CorrPath,'writer="Imaris5"');
extractFileinfo([f.filename{1},'_corr.ims'],Application);

clear Application;
variableSetter('l.t.f{w.task,w.doN}.immunoAdjust{w.file}',{'lll','done'});



Wave1.DepthCorrectionInfo=Out1.DepthCorrectionInfo;
l.t.f{w.task,w.doN}.Results{w.file}=Wave1;


function [Array]=layerAreaThreshold(Array,Threshold)
IncludedAreaProfile=sum(sum(Array,1),2);
IncludedAreaProfile=permute(IncludedAreaProfile,[3,1,2]);
Threshold=max(IncludedAreaProfile(:))*Threshold;
Array(:,:,IncludedAreaProfile<Threshold)=0;