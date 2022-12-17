%    <CustomTools>
%      <Menu>
%       <Submenu name="Finn's Functions">
%        <Item name="Finn_AreaOutliner" icon="Matlab" tooltip="Outlines the border of specified surface.">
%          <Command>MatlabXT::Finn_AreaOutliner(%i)</Command>
%        </Item>
%       </Submenu>
%      </Menu>
%    </CustomTools>

function Finn_AreaOutliner(aImarisApplicationID) %Finn_AreaOutliner(0)

javaaddpath ImarisLib.jar;
vImarisLib = ImarisLib;
vImarisApplication = vImarisLib.GetApplication(aImarisApplicationID);
vDataSetIn=vImarisApplication.GetDataSet;

% ask for Outline width in pixel, target channel and value
prompt = {'Enter target channel number:','Enter target value:','Enter Distance bin:','Set to 1 for repetion:'};
dlg_title = 'Input';
num_lines = 1;
def = {'10','200','10','1'};
answer = inputdlg(prompt,dlg_title,num_lines,def);
TargetChannel=str2num(answer{1}); TargetValue=str2num(answer{2});DistanceBin=double(str2num(answer{3}));Repetition=str2num(answer{4});

% get data on Imaris file
vSizeT = vDataSetIn.GetSizeT; % get number of timepoints
vSizeC = vDataSetIn.GetSizeC; % get number of Channels
vDataSize = [vDataSetIn.GetSizeX, vDataSetIn.GetSizeY, vDataSetIn.GetSizeZ];
stack=zeros(vDataSize(1),vDataSize(2),vDataSize(3),'uint16');
DistTransOutIn=stack;wave1=stack; wave2=zeros(vDataSize(1)+20,vDataSize(2)+20,vDataSize(3)+20,'uint16');


h=msgbox('timepoint');
for TimePoint=0:vSizeT-1
%     for TimePoint=0:2-1
    delete(h); h=msgbox(['timepoint ',num2str(TimePoint+1),'/',num2str(vSizeT)]);
    % open 'DistTrans' channel
    [ChannelNumber,ChannelID]=P0213(vImarisApplication,'DistTrans');
    arr = vDataSetIn.GetDataVolumeAs1DArrayShorts(ChannelID,TimePoint);
    DistTransOutIn(:) = typecast(arr, 'uint16');
    
   
    % Get the stack to save the data in
    arr = vDataSetIn.GetDataVolumeAs1DArrayShorts(TargetChannel,TimePoint);
    stack(:) = typecast(arr, 'uint16');
    
    if Repetition==1
        % zero values are NaN, set zeros first to 65535, determine min
        t3=double(max(max(max(DistTransOutIn))));
        DistTransOutIn(DistTransOutIn==0)=65535;
        t1=double(min(min(min(DistTransOutIn))));
        uppercounter=floor(t3/DistanceBin)*DistanceBin; % find highest distance
        counter=ceil(t1/DistanceBin)*DistanceBin; % find lowest distance
%         a1=min(min(min(DistTransOutIn)));
%         a2=max(max(max(DistTransOutIn)));
        while (counter<=uppercounter);
            delete(h); h=msgbox(['timepoint ',num2str(TimePoint+1),'/',num2str(vSizeT),', bin ',num2str(counter-1000)]);
            %             if counter<0; subtract=1;else; subtract=0; end;
            
            wave1(:)=0; wave1(DistTransOutIn<=counter & DistTransOutIn>counter-10)=1;
            a1=max(max(max(wave1)));
%             wave1(DistTransOutIn>counter-10)=1;
%             wave1(DistTransOutIn==65535)=1;
%             Surface(:,:,:)=0; Surface(DistTransOutIn<=counter-subtract)=1;
%             wave2(:)=0; wave2(11:10+size(wave1,1),11:10+size(wave1,2),11:10+size(wave1,3))=wave1;
%             [wave2]=bwperim(wave2,OutlineWidth); % determine perimeter around values equal to zero
%             wave1=wave2(11:10+size(wave1,1),11:10+size(wave1,2),11:10+size(wave1,3));
%             [wave1]=bwboundaries(wave1,OutlineWidth); % determine perimeter around values equal to zero
% a1=counter+10-abs(counter-1000);
            stack(wave1~=0)=abs(counter-1000)+10;
            
%             a1=stack(:,:,88);
            counter=counter+DistanceBin;
%             a1=stack(1,1,1);
        end
    else % for single distancebin
%         if DistanceBin<0; subtract=1;else; subtract=0; end;
        wave1(:)=1; wave1(DistTransOutIn>=DistanceBin+1000)=0;
        wave1(DistTransOutIn<DistanceBin+990)=1;
%         [wave1]=bwperim(wave1,OutlineWidth); % determine perimeter around values equal to zero
        stack(wave1~=0)=DistanceBin;
    end
    LargeDataset=0;
    if LargeDataset==0;
%         a1=max(max(max(stack)));
        vImarisApplication.GetDataSet.SetDataVolumeAs1DArrayShorts(stack(:),TargetChannel,TimePoint);
    else
        for C1 = 1:vDataSize(3)
            vSlice=stack(:,:,C1);
            vDataSetIn.SetDataSliceShorts(vSlice(:,:),C1-1,TargetChannel,TimePoint);
        end
        vImarisApplication.SetDataSet(vDataSetIn);
    end
end


% vDataSetIn.SetSizeC(vSizeC);
% vImarisApplication.SetVisible(1);
clear vDataSetIn;
clear ImarisLib; clear vImarisLib;
delete(h); h=msgbox('Finished');