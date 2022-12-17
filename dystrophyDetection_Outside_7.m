function [Outside,Output]=dystrophyDetection_Outside_7(DataBrainArea)
global NameTable; global ChannelTable;
[Fileinfo]=getFileinfo_2(NameTable.Filename{'FilenameTotalOrig'});
ZenInfo=Fileinfo.Results{1,1}.ZenInfo;
Res=Fileinfo.Res{1};
Pix=Fileinfo.Pix{1};
ChannelListOrig=ChannelTable.ChannelName(strfind1(ChannelTable.SourceFilename,NameTable.Filename{'FilenameTotalOrig'}));
Settings={  'Name','Prctile1','TargetValue','IntThreshold','Dilation','MaxInt';...
    'Vglut1',50,8000,4000,NaN,35000;...
    'NAB228',90,10000,10000,30,NaN;...
    'DAPI',95,10000,10000,35,NaN;...
    'Iba1',93,10000,10000,18,NaN;...
    'Bace1',50,8000,4000,NaN,15000;...
    'APPY188',50,2000,600,NaN,5000;...
    'Lamp1',50,1000,1000,NaN,5000;...
    'MetBlue',50,1000,500,NaN,3000;...
    'Autofluo488',50,8000,4000,NaN,35000;...
    'RBB',90,10000,10000,30,NaN;...
    };
Settings=array2table(Settings(2:end,:),'VariableNames',Settings(1,:),'RowNames',Settings(2:end,1));

ChannelInfo=ZenInfo.ChannelInfo;
% % ChannelInfo.Name=Fileinfo.ChannelList{1}(1:size(ChannelInfo,1));
ChannelInfo.Name=ChannelListOrig;
ChannelInfo=ChannelInfo(ismember(ChannelInfo.Name,Settings.Name),:);
if size(ChannelInfo,1)==0
    Outside=zeros(Pix.','uint8');
    Output=[];
    A1=asdf; % return;
end
ResOrig=Res; PixOrig=Pix;
ResCalc=[0.2;0.2;0.4];
Wave1=Res<ResCalc;
if max(Wave1(:))==1
    ResCalc(Wave1==0)=Res(Wave1==0);
end


for Ch=1:size(ChannelInfo,1)
    ChannelName=ChannelInfo.Name{Ch};
    Data3D=im2Matlab_3(NameTable.Filename{'FilenameTotalOrig'},ChannelTable.SourceChannelName{ChannelName});
    if isequal(ResOrig,ResCalc)~=1
        [Data3D,Out]=interpolate3D(Data3D,ResOrig,ResCalc);
    end
    
    Settings{ChannelName,'Prctile1'}{1};
    Path2file=[W.PathExp,'\Output\DepthIntensityFitting\',ChannelName,'\'];
    mkdir(Path2file);
    Path2file=[Path2file,Fileinfo.Filename{1},'_',ChannelName,'.png'];
    [Data3D,Output]=depthIntensityFitting_6(Data3D,ResCalc,Settings{ChannelName,'Prctile1'}{1},Settings{ChannelName,'TargetValue'}{1},[],DataBrainArea==0,Path2file);
    ChannelInfo.StartEndUm(Ch,1:2)=Output.StartEndUm;
    ChannelInfo.SliceThickness(Ch,1)=Output.SliceThickness;
    ChannelInfo.HalfDistance(Ch,1:size(Output.HalfDistance,1))=Output.HalfDistance;
    ChannelInfo.FitStDev(Ch,1:2)=Output.StDev;
    ChannelInfo.Data3D(Ch,1)={Data3D};
    ChannelInfo.Percentile(Ch,1)=Settings{ChannelName,'Prctile1'}{1};
    ChannelInfo.PercentileProfile(Ch,1)={Output.PercentileProfile};
end

%% determine Outside
ChannelName=Settings.Name{find(ismember(Settings.Name,ChannelInfo.Name),1)};
Outside=dystrophyDetection_Outside_Global_2(ChannelInfo,Settings,ChannelName,ResCalc,PixOrig);
FilenameTotal=[];
%% resize Outside
if isequal(ResOrig,ResCalc)~=1
    Outside=interpolate3D(Outside,[],[],PixOrig);
end
Output=struct;
Output.ChannelInfo=ChannelInfo;

% make a quality control image
[~,~,~,Outside2D]=intensityProjection_2(Outside,ResOrig,10,'Center');
% Data3D=im2Matlab_3(FilenameTotal,ChannelName);
Data3D=im2Matlab_3(NameTable.Filename{'FilenameTotalOrig'},ChannelTable.SourceChannelName{ChannelName});
[~,~,~,Data2D]=intensityProjection_2(Data3D,ResOrig,10,'Center');

ChannelInfo=table;
Wave1={'Channel','Outside';'Colormap',[0;1;1];'IntensityMinMax',[0;3];'IntensityData',Outside2D}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
Wave1={'Channel','Data';'Colormap',[1;0;1];'IntensityMinMax',[0;Settings{ChannelName,'MaxInt'}{1}];'IntensityData',Data2D}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';

Path2file=getPathRaw([NameTable.Filename{'FilenameTotalOrig'},'_QualityControl_Outside@',ChannelName,'.tif']);
imageGenerator_2(ChannelInfo,Path2file);

% % Application=openImaris_2(FilenameTotal,1,0); global Application;
% % imarisSaveHDFlock(Application,FilenameTotal);
% global Application;
% Data3D_2=interpolate3D(Data3D,[],[],PixOrig);
% ex2Imaris_2(Data3D_2,Application,'Test2');

