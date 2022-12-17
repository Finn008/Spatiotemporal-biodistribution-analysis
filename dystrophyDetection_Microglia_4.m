function [Microglia,Soma,Fibers,Iba1,MicrogliaInfo]=dystrophyDetection_Microglia_4()
timeTable('Start');
MicrogliaChannelName='Iba1';
global ChannelTable;

Fileinfo=getFileinfo_2(ChannelTable{MicrogliaChannelName,'SourceFilename'});
% Fileinfo=getFileinfo_2(FilenameTotal);
Res=Fileinfo.Res{1};
Pix=Fileinfo.Pix{1};

% [Iba1]=im2Matlab_3(ChannelTable{NucleiChannelName,'SourceFilename'},ChannelTable{NucleiChannelName,'SourceChannelName'});
[Iba1]=im2Matlab_3(ChannelTable{MicrogliaChannelName,'SourceFilename'},ChannelTable{MicrogliaChannelName,'SourceChannelName'});
try % if strfind1(Fileinfo.ChannelList{1},'Outside',1)
    [Outside]=uint8(im2Matlab_3(ChannelTable{'Outside','TargetFilename'},'Outside'));
catch
    Outside=zeros(Pix.','uint8');
end

% [Iba1]=im2Matlab_3(FilenameTotalOrig,strfind1(ChannelListOrig,'Iba1',1));
[~,Iba1]=percentileFilter3D_4(Iba1,70,Res,[2;2;2],Outside,300,[200;200;1],1);

global ShowIntermediateSteps;
% ShowIntermediateSteps=1;
if ShowIntermediateSteps==1
    Application=ChannelTable.TargetFilename{'ShowIntermediate'};
    ex2Imaris_2(Iba1,Application,MicrogliaChannelName,1,Res);
    %     imarisSaveHDFlock(Application);
    Application=openImaris_4(Application,[],1,1);
    %     global Application;
    
end

MicrogliaInfo=struct;

Pix=size(Iba1).';


% [DataPerc,OrigData]=percentileFilter3D_4(OrigData,Percentile,Res,ResCalc,OrigOutside,BackgroundCorrection,Window,ReplaceWithClosest,TilingSettings,RequestedOutput)


ResCalc=[2;2;1];
[~,Window]=imdilateWindow([50;50;10],ResCalc,1);
[Iba1Perc97]=percentileFilter3D(Iba1,97,Window,Res,ResCalc,Outside); %
timeTable('Iba1Perc97');
Exclude=Outside; Exclude(Iba1>=Iba1Perc97)=1;

% 60th within 4*4µm
ResCalc=[0.3;0.3;Res(3)];
Window=round([4;4]./ResCalc(1:2)/2)*2+1;
[Iba1LocalPerc]=percentileFilter2D(Iba1,60,Window,Res,ResCalc,Exclude); % 4.2min
timeTable('Iba1Perc60');
Mask=(Iba1>=Iba1LocalPerc);

% 70th within 20*20µm
ResCalc=[1;1;Res(3)];
Window=round([20;20]./ResCalc(1:2)/2)*2+1;
[Iba1LocalPerc]=percentileFilter2D(Iba1,70,Window,Res,ResCalc,Exclude); % 4.2min
timeTable('Iba1Perc70');
Mask(Iba1<Iba1LocalPerc)=0;

% 90th within 200*200µm
% 100µm plaque, max 40% mic coverage, 200µm window: 1/4*40%=0.1
ResCalc=[5;5;Res(3)];
Window=round([200;200]./ResCalc(1:2)/2)*2+1;
[Iba1LocalPerc]=percentileFilter2D(Iba1,90,Window,Res,ResCalc,Exclude); % 4.2min
timeTable('Iba1Perc90');
Mask(Iba1<Iba1LocalPerc)=0;
clear Iba1LocalPerc;

Wave1=imerode(Mask,ones(3,3));
Wave1=imdilate(Wave1,ones(3,3));
Wave1(Mask==0)=0; Mask=Wave1;
% remove structures smaller than 1µm^3
BW=bwconncomp(Mask,6);
Table=table(cellfun(@numel,BW.PixelIdxList).',BW.PixelIdxList.','VariableNames',{'NumPix','IdxList'}); clear BW;
Table.Volume=Table.NumPix*prod(Res);
Table=Table(Table.Volume>1,:);
Mask=zeros(Pix.','uint8');
Mask(cell2mat(Table.IdxList))=1;

if ShowIntermediateSteps==1; ex2Imaris_2(Mask,Application,'Microglia_All'); end
timeTable('All');

DetectNuclei=0;

if DetectNuclei==1
    [~,Distance,BasinMap]=basinDetection(Mask,Outside,Res,struct('BasinThreshold',20,'ThresholdDistanceMean',10,'ShowBasinMap','DistanceMean'));
    if ShowIntermediateSteps==1; ex2Imaris_2(Distance,Application,'Microglia_DistanceIn'); end;
    if ShowIntermediateSteps==1; ex2Imaris_2(BasinMap,Application,'Microglia_DistanceMean'); end;

    [Nuclei]=im2Matlab_3(ChannelTable{MicrogliaChannelName,'TargetFilename'},'Nuclei');
    Nuclei(BasinMap>10 | BasinMap==0)=0;
    Nuclei=imdilate(Nuclei,strel('sphere',1));
    if ShowIntermediateSteps==1; ex2Imaris_2(Nuclei,Application,'Microglia_Nuclei_1'); end;
    BW=bwconncomp(Nuclei,6);
    Table=table(cellfun(@numel,BW.PixelIdxList).',BW.PixelIdxList.','VariableNames',{'NumPix','PixelIdxList'});
    Table.Volume=Table.NumPix*prod(Res(1:3));
    Table=Table(Table.Volume>=1.5^3,:);
    Nuclei(:)=0;
    Nuclei(cell2mat(Table.PixelIdxList))=1;
    if ShowIntermediateSteps==1; ex2Imaris_2(Nuclei,Application,'Microglia_Nuclei_2'); end;
    Nuclei=imdilate(Nuclei,imdilateWindow_2([1;1;1],Res,1,'ellipsoid'));
    if ShowIntermediateSteps==1; ex2Imaris_2(Nuclei,Application,'Microglia_Nuclei_3'); end;
    
    % include microglia that have no hole
    Wave1=imerode(Mask,imdilateWindow_2([2.5;2.5;2.5],Res,1,'ellipsoid'));
    Wave1=imdilate(Wave1,imdilateWindow_2([3;3;3],Res,1,'ellipsoid'));
    Wave1(Mask==0)=0;
    if ShowIntermediateSteps==1; ex2Imaris_2(Wave1,Application,'Microglia_Nuclei_4'); end;
    
    Nuclei(Wave1==1)=1;
    if ShowIntermediateSteps==1; ex2Imaris_2(Nuclei,Application,'Microglia_Nuclei'); end;
    
    
    
    keyboard;
%     Nuclei(BasinMap==0 & Mask==0)=0;
    
    Soma=logical(Nuclei);
    Soma(BasinMap==0 & Mask==0)=0;
    Soma(BasinMap>10)=0;
    Soma=imdilate(Soma,strel('sphere',1));
    
    
    if ShowIntermediateSteps==1; ex2Imaris_2(Nuclei,Application,'Microglia_Nuclei'); end;
    Soma(BasinMap==0 & Mask==0)=0;
    Soma=imdilate(Soma,strel('sphere',1));
    
    
    BW=bwconncomp(Soma,6);
    Table=table(cellfun(@numel,BW.PixelIdxList).',BW.PixelIdxList.','VariableNames',{'NumPix','PixelIdxList'});
    Table.Volume=Table.NumPix*prod(Res(1:3));
    Table=Table(Table.Volume>=3^3,:);
    BW.PixelIdxList=Table.PixelIdxList.';
    BW.NumObjects=size(Table,1);
    Soma(:)=0;
    Soma(cell2mat(Table.PixelIdxList))=1;
    
    Wave1=imerode(Soma,imdilateWindow_2([1.5;1.5;1.5],Res,1,'ellipsoid'));
    Wave1=imdilate(Wave1,imdilateWindow_2([1.7;1.7;1.7],Res,1,'ellipsoid'));
    Soma(Wave1==0)=0;
    
    if ShowIntermediateSteps==1; ex2Imaris_2(Soma,Application,'Microglia_Soma'); end;
    Mask(Soma==1)=1;
    [Skeleton]=tubeDetection_2(logical(Mask),Res);
    if ShowIntermediateSteps==1; ex2Imaris_2(Skeleton,Application,'Microglia_Skeleton'); end;
    
else
    Microglia=Mask;
    Soma=[];
    Fibers=[];
end

%% Finalize and make a quality control image
% generate quality control image
global NameTable;
[Iba1_2D,Wave1]=max(Iba1.*uint16(~Outside),[],3);
Wave1=(Wave1(:)-1)*prod(size(Iba1_2D))+(1:prod(size(Iba1_2D))).';
MicrogliaMap2D=Iba1_2D; MicrogliaMap2D(:)=Microglia(Wave1(:));

ChannelInfo=table;
Wave1={'Version',7.1;'IntensityData',Iba1_2D;'Colormap',[1,1,1;1,1,0];'IntensityGamma',0.4;'IntensityMinMax','Norm99.99';'ColorData',MicrogliaMap2D;'ColorMinMax',[0;1];'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).'; 
Path2file=getPathRaw([NameTable.Filename{'FilenameTotal'},'_QualityControl_Microglia.tif']);
imageGenerator_2(ChannelInfo,Path2file,[],struct('Rotate',-90));