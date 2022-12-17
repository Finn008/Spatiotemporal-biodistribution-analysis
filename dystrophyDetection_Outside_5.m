function [Outside,Output]=dystrophyDetection_Outside_5(FilenameTotal,ZenInfo,DataBrainArea)

% global W;

% % % [Fileinfo]=getFileinfo_2(FilenameTotal);
% % % Res=Fileinfo.Res{1};
% % % Pix=Fileinfo.Pix{1};
% % % 
% % % Data2Check={'MetBlue';'Vglut1';'Bace1';'Lamp1'};
% % % 
% % % ChannelInfo=ZenInfo.ChannelInfo;
% % % ChannelInfo.Name=Fileinfo.ChannelList{1};
% % % ChannelInfo=ChannelInfo(ismember(ChannelInfo.Name,Data2Check),:);
% % % 
% % % ResOrig=Res; PixOrig=Pix;
% % % ResCalc=[0.2;0.2;0.4];
% % % Wave1=Res<ResCalc;
% % % if max(Wave1(:))==1
% % %     ResCalc(Wave1==0)=Res(Wave1==0);
% % % end
% % % 
% % % for Ch=1:size(ChannelInfo,1)
% % %     ChannelName=ChannelInfo.Name{Ch};
% % %     Data3D=im2Matlab_3(FilenameTotal,ChannelName);
% % %     if isequal(ResOrig,ResCalc)~=1
% % %         [Data3D,Out]=interpolate3D(Data3D,ResOrig,ResCalc);
% % % %         Res=Out.Res;
% % %     end
% % %     EndVersion='Standard';
% % %     if strcmp(ChannelName,'MetBlue')
% % %         Percentile=50;
% % %         TargetValue=1000;
% % %         Threshold=500;
% % %         EndVersion='SteepFallingRaw';
% % %     end
% % %     if strcmp(ChannelName,'Vglut1')
% % %         Ind=strfind1(ChannelInfo.Name,'Vglut1',1);
% % %         Percentile=50;
% % %         TargetValue=8000;
% % %         Threshold=4000;
% % %     end
% % %     if strcmp(ChannelName,'Lamp1')
% % %         Percentile=50;
% % %         TargetValue=1000;
% % %         Threshold=1000;
% % %     end
% % %     Path2file=['\\GNP90N\share\Finn\Analysis\Output\DepthIntensityFitting\',ChannelName,'\',Fileinfo.Filename{1},'_',ChannelName,'.png'];
% % %     [Data3D,Output]=depthIntensityFitting_3(Data3D,ResCalc,Percentile,TargetValue,[],DataBrainArea==0,Path2file,EndVersion);
% % % %     [OrigData,Output]=depthIntensityFitting_3(Data,Res,Percentile,TargetValue,Masking,Outside,Filename,EndVersion);
% % %     ChannelInfo.StartEndUm(Ch,1:2)=Output.StartEndUm;
% % %     ChannelInfo.SliceThickness(Ch,1:2)=Output.SliceThickness;
% % %     ChannelInfo.HalfDistance(Ch,1:2)=Output.HalfDistance;
% % %     ChannelInfo.FitStDev(Ch,1:2)=Output.StDev;
% % %     ChannelInfo.Data3D(Ch,1)={Data3D};
% % %     ChannelInfo.Threshold(Ch,1)=Threshold;
% % %     ChannelInfo.Percentile(Ch,1)=Percentile;
% % % end
% % % 
% % % 
% % % if strfind1(ChannelInfo.Name,'Vglut1',1)
% % %     Ch=strfind1(ChannelInfo.Name,'Vglut1',1);
% % %     
% % % else
% % %     keyboard;
% % % end

%% determine Outside
Data3D=ChannelInfo.Data3D{Ch,1};
PixCalc=size(Data3D).';

Outside=Data3D<ChannelInfo.Threshold(Ch,1);
ChannelInfo(:,'Data3D') = [];
Outside=imdilate(Outside,imdilateWindow([0.6;0.6],ResCalc)); % Outside 1

Window2=imdilateWindow([1;1],ResCalc);
Outside=imerode(Outside,Window2); % Outside 2

% get Area dimensions in 2D
BW=bwconncomp(Outside,4);
Table=table;
Table.NumPix=cellfun(@numel,BW.PixelIdxList).';
Table.IdxList=BW.PixelIdxList.';
clear BW;
Res2D=prod(ResCalc(1:2));
Table.Area=Table.NumPix*Res2D;
Table=Table(Table.Area>700,:); % previously 1000
Outside=zeros(size(Outside),'uint16');
Outside(cell2mat(Table.IdxList))=1;


% 3D
BW=bwconncomp(Outside,6);
Table=table;
Table.NumPix=cellfun(@numel,BW.PixelIdxList).';
Table.IdxList=BW.PixelIdxList.';
clear BW;
Res3D=prod(ResCalc);
Table.Volume=Table.NumPix*Res3D;
Table=Table(Table.Volume>2500,:); % before 2016.12.22 Threshold 5000
% only regions touching top or bottom
for m=1:size(Table,1)
    Table.MinMaxIdx(m,1:2)=[min(Table.IdxList{m}),max(Table.IdxList{m})];
end
Table=Table(Table.MinMaxIdx(:,1)<(PixCalc(1)*PixCalc(2))|Table.MinMaxIdx(:,2)>(prod(PixCalc)-PixCalc(1)*PixCalc(2)),:); % before 2016.12.22 Threshold 5000

Outside=zeros(size(Outside),'uint16');
Outside(cell2mat(Table.IdxList))=1;

% correct for erosion
Outside=imdilate(Outside,Window2);
% Wave1=Data3D<ChannelInfo.Threshold(Ch,1);
% Outside(Wave1==0)=0;

% remove holes
BW=bwconncomp(1-Outside,4);
Table=table;
Table.NumPix=cellfun(@numel,BW.PixelIdxList).';
Table.IdxList=BW.PixelIdxList.';
clear BW;
Res2D=prod(ResCalc(1:2));
Table.Area=Table.NumPix*Res2D;
Table=Table(Table.Area<5,:); % previously 1000
Outside(cell2mat(Table.IdxList))=1;


if isequal(ResOrig,ResCalc)~=1
    Outside=interpolate3D(Outside,[],[],PixOrig);
end
Output=struct;
Output.ChannelInfo=ChannelInfo;

% Application=openImaris_2(FilenameTotal,1,0);


