% uint8: PlaqueMapTotal, plaqueMap, Membership, 3x 1.5GB = 4.5GB
% uint16: stack1, 3GB
% int16: 2x DistInOut, 2x 3GB = 6GB
% total: 13.5GB
% PlaqueMapTotal,UmMinMax,Speci,UmBin
% Out
function [Out]=distance_3(In,PlaqueMapTotal)
global W;% 4GB + 1.5GB
if exist('ZeroBin','var')==0
    ZeroBin=50;
end
% keyboard % A1=asdf; % convert 8bit to 16bit distancetransformation
v2struct(In);
[Speci]=variableExtract(Speci,{'In';'Out'});


if exist('DistanceBitType','var')==0
    DistanceBitType='uint8';
end

%% if imaris file with Surfaces is provided
if exist('Application','var')==1
    VdataSetIn=Application.GetDataSet;
    Timepoints=VdataSetIn.GetSizeT;
    Pix=[VdataSetIn.GetSizeX,VdataSetIn.GetSizeY,VdataSetIn.GetSizeZ];
    PlaqueMapTotal= zeros(Pix(1),Pix(2),Pix(3),Timepoints,'uint8');
    if exist('SuperObject')==1
        J=struct;J.Application=Application;J.Channels=SuperObject;J.Feature='TrackId'; %J.Timepoints=m1;
        [PlaqueMapTotal]=im2Matlab_2(J);
    elseif exist('ObjectList')==1
        
        for m1=1:Timepoints
            PlaqueMap2=zeros(Pix(1),Pix(2),Pix(3),'uint8');
            for m=1:size(ObjectList,1)
                
                J=struct;J.Application=Application;J.Channels=ObjectList(m,1);J.Identity='Surface';J.Timepoints=m1;
                [PlaqueMap]=im2Matlab_2(J);
                PlaqueMap2(PlaqueMap==1)=m;
            end
            PlaqueMapTotal(:,:,:,m1)=PlaqueMap2;
        end
        clear PlaqueMap; clear PlaqueMap2;
    end
    UmMinMax= [VdataSetIn.GetExtendMinX,VdataSetIn.GetExtendMaxX; VdataSetIn.GetExtendMinY, VdataSetIn.GetExtendMaxY; VdataSetIn.GetExtendMinZ,VdataSetIn.GetExtendMaxZ];
end



%% when data table with plaques is provided

if exist('UmBin','var') && isempty(UmBin)==0
    UmMinMax=UmMinMax./UmBin;
end

Timepoints=size(PlaqueMapTotal,4);
Pix=[size(PlaqueMapTotal,1);size(PlaqueMapTotal,2);size(PlaqueMapTotal,3);size(PlaqueMapTotal,4)];
PlaqueNumber=max(PlaqueMapTotal(:));
J=struct;
J.PixMax=[Pix(1:3,1);1;1];
J.Path2file=W.PathImarisSample;
if strcmp(DistanceBitType,'uint8'); J.BitType='uint8'; end;
J.ImarisVersion='7.6.0';
J.UmMinMax=UmMinMax;
[Application2]=openImaris_2(J);


DistInOut2=zeros(Pix(1),Pix(2),Pix(3),2,DistanceBitType); % only for one timepoint
Membership2=zeros(Pix(1),Pix(2),Pix(3),'uint8');
Stack1=zeros(Pix(1),Pix(2),Pix(3),DistanceBitType); % for exporting distance data and Dist2Border 12.5GB + 3GB = 15.5GB
PlaqueMap=zeros(Pix(1),Pix(2),Pix(3),'uint8'); %

Membership=zeros(Pix(1),Pix(2),Pix(3),Timepoints,'uint8');
DistInOut=zeros(Pix(1),Pix(2),Pix(3),Timepoints,DistanceBitType);

J=struct; J.Application=Application2; J.TargetChannel=1; J.TargetTimepoint=1;
for m1=1:Timepoints
    DistInOut2(:,:,:,1)=65535; % 255 incase uint8
    PlaqueIDs=unique(PlaqueMapTotal(:,:,:,m1));PlaqueIDs(PlaqueIDs==0)=[];PlaqueIDs=PlaqueIDs.';
    for m=PlaqueIDs % go through PlaqueTracks
        PlaqueMap(:)=0; % 9.1GB
        PlaqueMap(PlaqueMapTotal(:,:,:,m1)==m)=1;
        if Speci.Out==1;
            ex2Imaris_2(PlaqueMap,J); % 12.8GB
            Application2.GetImageProcessing.DistanceTransformChannel(Application2.GetDataSet,0,1, false); % outside, first bin outside is zero, 10GB
            [Stack1(:)]=Im2Matlab(Application2,1,1); % 9.5GB Mat + 10.3GB Im
            Stack1(:)=Stack1(:)+ZeroBin; % 16 Mat + 10 Im
            Stack1(PlaqueMap==1)=ZeroBin; % now anything within plaque is set to ZeroBin
            DistInOut2(:,:,:,2)=Stack1; % 19 Mat, 10 Im
        end
        if Speci.In==1;
            ex2Imaris_2(PlaqueMap,J); % 17 Mat 10 Im
            Application2.GetImageProcessing.DistanceTransformChannel(Application2.GetDataSet,0,1, true); % outside
            [Stack1]=Im2Matlab(Application2,1,1); % 17 Mat 10 Im
            DistInOut2(:,:,:,2)=DistInOut2(:,:,:,2)-Stack1;
        end
        [DistInOut2(:,:,:,1)]=min(DistInOut2,[],4); % first bin outside plaque is 1, first inside is zero,
        Membership2(DistInOut2(:,:,:,1)==DistInOut2(:,:,:,2))=m;
    end
    DistInOut(:,:,:,m1)=DistInOut2(:,:,:,1);
    Membership(:,:,:,m1)=Membership2(:,:,:);
end
clear DistInOut2; clear Membership2; clear PlaqueMapTotal; clear PlaqueMap;
% calculate distance to border in channel 0
Dist2Border=zeros(Pix(1),Pix(2),Pix(3),DistanceBitType);
Stack1(:)=0; Stack1(1,:,:)=1; Stack1(end,:,:)=1; Stack1(:,1,:)=1; Stack1(:,end,:)=1; Stack1(:,:,1)=1; Stack1(:,:,end)=1;
ex2Imaris_2(Stack1,J);
Application2.GetImageProcessing.DistanceTransformChannel(Application2.GetDataSet,0,1, false); % outside
[Dist2Border]=Im2Matlab(Application2,1,1);
Dist2Border=Dist2Border+1;

Container.PlaqueNumber=PlaqueNumber;

quitImaris(Application2);
% Application2.Quit;
clear Application2;


if exist('Output')==0
    Output={'DistInOut';'Membership';'Dist2Border';};
end

Out.Container=Container;
for m=1:size(Output,1)
    Path=['Out.',Output{m,1},'=',Output{m,1},';'];
    eval(Path);
    
end
if exist('Application','var')==1
    for m=1:size(Output,1)
        for m2=1:Timepoints
            J=struct; J.Application=Application; J.TargetChannel=Output{m,1}; J.TargetTimepoint=m2;
            Path=['ex2Imaris_2(',Output{m,1},'(:,:,:,m2),J);'];
            eval(Path);
        end
    end
end
% pack DistInOut,Membership,Dist2Border,Container into Out




