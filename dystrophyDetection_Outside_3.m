function [Outside]=dystrophyDetection_Outside_3(FilenameTotal,Application,DataBrainArea)

[Fileinfo,Ind,PathRaw]=getFileinfo_2(FilenameTotal);

Res=Fileinfo.Res{1};
Pix=Fileinfo.Pix{1};
% Um=Fileinfo.Um{1};
ChannelList=Fileinfo.ChannelList{1,1};
ResCalc=[0.2;0.2;0.4];

if strfind1(ChannelList,'AT8',1)
    ImportChannel='AT8';
    Percentile=99;
    TargetValue=50000;
    Threshold=2500;
    Window1=[3;3];
    Window2=[5;5;3];
    Data3D=depthIntensityFitting_2(Data3D,Res,Percentile,TargetValue,[],DataBrainArea==0,Fileinfo.Filename{1});
    Outside=Data3D<Threshold;
    Window1=[5;5;1];
    Outside=imerode(Outside,ones(Window1.'));
    Outside(DataBrainArea==0)=1;
    Outside=imdilate(Outside,ones(Window1.')); % Outside 1
    Outside=interpolate3D(Outside,[],[],InitialPix);
    return
%     Data3D=depthIntensityFitting_2(Data3D,Res,Percentile,TargetValue,[],DataBrainArea==0,Fileinfo.Filename{1});
%     Outside=Data3D<Threshold;
%     return;
elseif strfind1(ChannelList,'Vglut1',1)
    ImportChannel='Vglut1';
    Percentile=50;
    TargetValue=8000;
    Threshold=4000;
elseif strfind1(ChannelList,'Lamp1',1)
%     keyboard;
    ImportChannel='Lamp1';
    Percentile=50;
    TargetValue=1000;
    Threshold=1000;
elseif strfind1(ChannelList,'MetBlue',1)
    ImportChannel='MetBlue';
    Percentile=50;
    TargetValue=1000;
    Threshold=500;
elseif strfind1(ChannelList,'Iba1',1)
    ImportChannel='Iba1';
    Data3D=im2Matlab_3(FilenameTotal,ImportChannel);
    Percentile=90; % previously 70
    Wave1=reshape(Data3D,[Pix(1)*Pix(2),Pix(3)]);
    PercProfile=double(prctile(Wave1,Percentile,1).');
    Deviation1=diff(smooth(smooth(smooth(PercProfile))));
    Deviation2=diff(diff(smooth(smooth(smooth(PercProfile)))));
    PercProfile=PercProfile/max(PercProfile(:));
    Deviation1=Deviation1/max(Deviation1(:));
    Deviation2=Deviation2/max(Deviation2(:));
    X=(1:Pix(3)).'*Res(3);
    [~,Start]=max(Deviation1);
    [~,Start(2,1)]=min(Deviation1);
    figure; hold on;
    plot(X,PercProfile);
    plot(X(2:end),Deviation1);
    plot(X(2:end-1),Deviation2);
    line([Start(1)*Res(3),Start(1)*Res(3)],[0,1]);
    line([Start(2)*Res(3),Start(2)*Res(3)],[0,1]);
    
    Path=['\\GNP90N\share\Finn\Analysis\Output\Microglia\Outside\'];
    if exist(Path)~=7
        mkdir(Path);
    end
    Filename=Fileinfo.Filename{1};
    saveas(gcf,[Path,'\',Filename,'.png'])
    close Figure 1;
    
    Outside=ones(Pix.','uint16');
    Outside(:,:,Start(1):Start(2))=0;
    
    
        
    return;
else
    keyboard;
end

Data3D=im2Matlab_3(FilenameTotal,ImportChannel);

Wave1=Res<ResCalc;
if max(Wave1(:))==1
    ResOrig=Res;
    ResCalc(Wave1==0)=Res(Wave1==0);
    PixOrig=Pix;
    [Data3D,Out]=interpolate3D(Data3D,Res,ResCalc);
    Res=Out.Res;
    Pix=Out.Pix;
end
    

% MaxVoxelNumber=1000000;
% if prod(Pix(1:2))>MaxVoxelNumber
%     
%     Wave1=prod(Pix(1:2))/MaxVoxelNumber;
%     PixCalc=ceil(Pix(1:2)/Wave1^0.5);
%     InitialPix=Pix;
%     Data3D=interpolate3D(Data3D,[],[],[PixCalc;Pix(3)]);
%     Pix=size(Data3D).';
%     Res=Res.*InitialPix./Pix;
% end

if exist('DataBrainArea') && isempty(DataBrainArea)==0 && isequal(size(DataBrainArea).',Pix)==0
    DataBrainArea=interpolate3D(DataBrainArea,[],[],Pix);
end



if strcmp(ImportChannel,'MetBlue')
    Data3D=depthIntensityFitting_2(Data3D,Res,Percentile,TargetValue,[],DataBrainArea==0,Fileinfo.Filename{1},'SteepFallingRaw');
else
    Data3D=depthIntensityFitting_2(Data3D,Res,Percentile,TargetValue,[],DataBrainArea==0,Fileinfo.Filename{1});
end

Outside=Data3D<Threshold;


% Window1=[0.3;0.3]./Res(1:2); Window1=round(Window1/2)*2+1;
% Window1(Window1<3)=3;
Outside=imdilate(Outside,imdilateWindow([0.6;0.6],Res)); % Outside 1

% Window2=[1;1;1]./Res; Window2=round(Window2/2)*2+1;
% Window2(Window2<3)=3;
Window2=imdilateWindow([1;1],Res);
Outside=imerode(Outside,Window2); % Outside 2

% first make 3D
BW=bwconncomp(Outside,6);
Table=table;
Table.NumPix=cellfun(@numel,BW.PixelIdxList).';
Table.IdxList=BW.PixelIdxList.';
clear BW;
Res3D=prod(Res);
Table.Volume=Table.NumPix*Res3D;
Table=Table(Table.Volume>2500,:); % before 2016.12.22 Threshold 5000
Outside=zeros(size(Outside),'uint16');
Outside(cell2mat(Table.IdxList))=1;

% for m=1:size(Table,1)
%     Outside(Table.IdxList{m})=1;
% end
% get Area dimensions in 2D
BW=bwconncomp(Outside,4);
Table=table;
Table.NumPix=cellfun(@numel,BW.PixelIdxList).';
Table.IdxList=BW.PixelIdxList.';
clear BW;
Res2D=prod(Res(1:2));
Table.Area=Table.NumPix*Res2D;
Table=Table(Table.Area>700,:); % previously 1000
Outside=zeros(size(Outside),'uint16');
Outside(cell2mat(Table.IdxList))=1;
Outside=imdilate(Outside,Window2);
Wave1=Data3D<Threshold;

Outside(Wave1==0)=0;

% remove holes
BW=bwconncomp(1-Outside,4);
Table=table;
Table.NumPix=cellfun(@numel,BW.PixelIdxList).';
Table.IdxList=BW.PixelIdxList.';
clear BW;
Res2D=prod(Res(1:2));
Table.Area=Table.NumPix*Res2D;
Table=Table(Table.Area<5,:); % previously 1000
Outside(cell2mat(Table.IdxList))=1;

if exist('ResOrig')~=0
    Outside=interpolate3D(Outside,[],[],PixOrig);
end

