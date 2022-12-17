%    <CustomTools>
%      <Menu>
%       <Submenu name="Finn's Functions">
%        <Item name="Finn_DistInsideOut" icon="Matlab" tooltip="Outlines the border of specified surface.">
%          <Command>MatlabXT::Finn_DistInsideOut(%i)</Command>
%        </Item>
%       </Submenu>
%      </Menu>
%    </CustomTools>

function Finn_DistInsideOut(aImarisApplicationID) % Finn_DistInsideOut(0);


h=msgbox('Finn_DistInsideOut');

javaaddpath ImarisLib.jar;
vImarisLib = ImarisLib;
vImarisApplication = vImarisLib.GetApplication(aImarisApplicationID);
vDataSetIn=vImarisApplication.GetDataSet;



% get data on Imaris file
vSizeC = vDataSetIn.GetSizeC; % get number of Channels
vSizeT = vDataSetIn.GetSizeT; % get number of timepoints
vDataSize = [vDataSetIn.GetSizeX, vDataSetIn.GetSizeY, vDataSetIn.GetSizeZ];

% add two more channels if not already present
delete(h); h=msgbox('add channels');
if vSizeC<4; vDataSetIn.SetSizeC(4); end;

% get list of all surfaces

NameList=cell(100,1);
for i=0:100
    delete(h); h=msgbox(['get surface list, ',num2str(i)]);
    vImarisApplication.SetSurpassSelection(vImarisApplication.GetSurpassScene.GetChild(i));
    vImarisObject = vImarisApplication.GetSurpassSelection;
    NameList{i+1,1}=char(vImarisObject.GetName);
    if strcmp('end',char(vImarisObject.GetName))==1;
        NameList=NameList(1:i,1);
        PlaqueNumber=i-4;
        break;
    end;
end

% export all surfaces
allSurfaces=logical(zeros(vDataSize(1),vDataSize(2),vDataSize(3),vSizeT,PlaqueNumber+1));
for TimePoint=0:vSizeT-1
    for i=0:PlaqueNumber
        delete(h); h=msgbox(['get all surfaces, ', num2str(i),'/',num2str(PlaqueNumber),', tp ',num2str(TimePoint+1),'/',num2str(vSizeT)]);
        if i==0; PlaqueName='all'; else; PlaqueName=num2str(i);end
        [Surface]=P0183(vImarisApplication,PlaqueName,TimePoint);
        allSurfaces(:,:,:,TimePoint+1,i+1)=logical(Surface(:,:,:));
    end
end

% import surfaces into both channels
for TimePoint=0:vSizeT-1
    delete(h); h=msgbox(['set surfaces to ch2+3, tp ',num2str(TimePoint) ]);
    %     [Surface]=P0183(vImarisApplication,'all',TimePoint);
    Surface=allSurfaces(:,:,:,TimePoint+1,1);
    vDataSetIn.SetDataVolumeAs1DArrayShorts(Surface(:),2,TimePoint);
    vDataSetIn.SetDataVolumeAs1DArrayShorts(Surface(:),3,TimePoint);
end

% do distance transform
delete(h); h=msgbox('DistTrans outside');
vImarisApplication.GetImageProcessing.DistanceTransformChannel(vDataSetIn,2,1, false); % outside
delete(h); h=msgbox('DistTrans inside');
vImarisApplication.GetImageProcessing.DistanceTransformChannel(vDataSetIn,3,1, true); % inside

% Get the stack to save the data in
outside=zeros(vDataSize(1),vDataSize(2),vDataSize(3),'uint16'); inside=outside; DistInOut=outside; % prepare stacks to feed into disttrans

for TimePoint=0:vSizeT-1
    delete(h); h=msgbox(['calculate DistInOut tp ',num2str(TimePoint+1),'/',num2str(vSizeT)]);
    Surface=allSurfaces(:,:,:,TimePoint+1,1);
    %     [Surface]=P0183(vImarisApplication,'all',TimePoint);
    % calculate outside, sets first µm bin as well as inside to zero
    arr = vImarisApplication.GetDataSet.GetDataVolumeAs1DArrayShorts(2,TimePoint);
    outside(:) = typecast(arr, 'uint16');
    % calculate inside, keep inside at value 1 so that subtraction
    arr = vImarisApplication.GetDataSet.GetDataVolumeAs1DArrayShorts(3,TimePoint);
    inside(:) = typecast(arr, 'uint16'); inside(:)=inside(:)+1; inside(Surface~=1)=0;
    % define 1000 as first inside bin and place the data in the Imaris file
    DistInOut(:)=outside(:)+1001-inside(:);
    vImarisApplication.GetDataSet.SetDataVolumeAs1DArrayShorts(DistInOut(:),1,TimePoint);
end

% calculate distance to border
delete(h); h=msgbox('distance to border');
DistBorder=zeros(vDataSize(1),vDataSize(2),vDataSize(3),'uint16');
for TimePoint=0:vSizeT-1 % allocate empty channel 3
    Surface(:)=0;
    vDataSetIn.SetDataVolumeAs1DArrayShorts(Surface(:),3,TimePoint);
end
Surface(:)=0; Surface(1,:,:)=1; Surface(end,:,:)=1; Surface(:,1,:)=1; Surface(:,end,:)=1; Surface(:,:,1)=1; Surface(:,:,end)=1;
vImarisApplication.GetDataSet.SetDataVolumeAs1DArrayShorts(Surface(:),3,0);
vImarisApplication.GetImageProcessing.DistanceTransformChannel(vDataSetIn,3,1, false); % outside
arr = vImarisApplication.GetDataSet.GetDataVolumeAs1DArrayShorts(3,0);
DistBorder(:) = typecast(arr, 'uint16'); DistBorder(:)=DistBorder(:)+1001;



% calculate region of single plaques
Membership=zeros(vDataSize(1),vDataSize(2),vDataSize(3),vSizeT,'uint8');
SinglePlaque=zeros(vDataSize(1),vDataSize(2),vDataSize(3),'uint16');
for i=1:PlaqueNumber
    delete(h); h=msgbox(['single plaque ', num2str(i),'/',num2str(PlaqueNumber)]);
    for TimePoint=0:vSizeT-1 % import single surfaces one after the other to channel 3
        Surface=allSurfaces(:,:,:,TimePoint+1,i+1);
        %         [Surface]=P0183(vImarisApplication,num2str(i),TimePoint);
        vDataSetIn.SetDataVolumeAs1DArrayShorts(Surface(:),3,TimePoint);
    end
    vImarisApplication.GetImageProcessing.DistanceTransformChannel(vDataSetIn,3,1, false); % do distance transformation
    
    for TimePoint=0:vSizeT-1
        delete(h); h=msgbox(['single plaque ', num2str(i),'/',num2str(PlaqueNumber),', tp ',num2str(TimePoint+1),'/',num2str(vSizeT)]);
        Surface=allSurfaces(:,:,:,TimePoint+1,i+1);
        if max(max(max(Surface)))==1;
            
            % get disttrans of single channel
            arr = vImarisApplication.GetDataSet.GetDataVolumeAs1DArrayShorts(3,TimePoint);
            SinglePlaque(:) = typecast(arr, 'uint16');
            SinglePlaque(:)=SinglePlaque(:)+1001; SinglePlaque(Surface(:)==1)=0;
            % get DistInOut
            arr = vImarisApplication.GetDataSet.GetDataVolumeAs1DArrayShorts(1,TimePoint);
            DistInOut(:) = typecast(arr, 'uint16');
            % get Membership
            
            wave1=Membership(:,:,:,TimePoint+1);
            wave1(SinglePlaque(:)<=DistInOut(:))=i;
            Membership(:,:,:,TimePoint+1)=uint8(wave1(:,:,:));
            
            %         inside(:)=0; inside(SinglePlaque(:)<=DistInOut(:))=i;
            %         Membership(:,:,:,TimePoint+1)=Membership(:,:,:,TimePoint+1)+uint8(inside(:,:,:));
        end
        if i==PlaqueNumber; % at last plaque integrate distance to border and place the data
            %             delete(h); h=msgbox('allocate Membership');
            inside(:)=0; inside(DistBorder(:)<=DistInOut(:))=1;
            wave1=Membership(:,:,:,TimePoint+1); wave1=uint16(wave1);
            inside(:)=inside(:)+wave1(:)*100;
            vImarisApplication.GetDataSet.SetDataVolumeAs1DArrayShorts(inside(:),2,TimePoint);
        end
        
    end
end











vDataSetIn.SetChannelName(0,'Methoxy_blue');
vDataSetIn.SetChannelName(1,'DistTrans');
vDataSetIn.SetChannelName(2,'Membership');
vDataSetIn.SetSizeC(3);

% path='\\SUPERRECHNERII\Finn 002 (I)\X0156\output\raw data';
% TimeLineApplication.FileSave(path,'writer="Imaris5"');
% vImarisApplication.SetVisible(0);

clear vDataSetIn;
clear ImarisLib; clear vImarisLib;

delete(h); h=msgbox('Finished');
