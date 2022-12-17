%    <CustomTools>
%      <Menu>
%       <Submenu name="Finn's Functions">
%        <Item name="Finn_SurfaceOutliner_002" icon="Matlab" tooltip="Outlines the border of specified surface.">
%          <Command>MatlabXT::Finn_SurfaceOutliner_002(%i)</Command>
%        </Item>
%       </Submenu>
%      </Menu>
%    </CustomTools>

function Finn_SurfaceOutliner_002(aImarisApplicationID) %Finn_SurfaceOutliner_002(0)

javaaddpath ImarisLib.jar;
vImarisLib = ImarisLib;
vImarisApplication = vImarisLib.GetApplication(aImarisApplicationID);
vDataSetIn=vImarisApplication.GetDataSet;

% ask for Outline width in pixel, target channel and value
prompt = {'Enter outline width in pixel: 4,8,6,18,26','Enter target channel number:','Enter target value:','Enter Distance bin:','Set to 1 for repetion:','Delete present Volume:'};
dlg_title = 'Input';
num_lines = 1;
def = {'8','9','200','10','1','1'};
answer = inputdlg(prompt,dlg_title,num_lines,def);
OutlineWidth=str2num(answer{1}); TargetChannel=str2num(answer{2}); TargetValue=str2num(answer{3});DistanceBin=double(str2num(answer{4}));Repetition=str2num(answer{5});DeleteBefore=str2num(answer{6});

% get data on Imaris file
vSizeT = vDataSetIn.GetSizeT; % get number of timepoints
vSizeC = vDataSetIn.GetSizeC; % get number of Channels
vDataSize = [vDataSetIn.GetSizeX, vDataSetIn.GetSizeY, vDataSetIn.GetSizeZ];
stack=zeros(vDataSize(1),vDataSize(2),vDataSize(3),'uint16');
DistTransOutIn=stack;wave1=stack; wave2=zeros(vDataSize(1)+20,vDataSize(2)+20,vDataSize(3)+20,'uint16');


h=msgbox('timepoint');
for TimePoint=0:vSizeT-1
    delete(h); h=msgbox(['timepoint ',num2str(TimePoint+1),'/',num2str(vSizeT)]);
    % open 'DistTrans' channel
    [ChannelNumber,ChannelID]=P0213(vImarisApplication,'DistTrans');
    arr = vDataSetIn.GetDataVolumeAs1DArrayShorts(ChannelID,TimePoint);
    DistTransOutIn(:) = typecast(arr, 'uint16');
    
   
    % Get the stack to save the data in
    arr = vDataSetIn.GetDataVolumeAs1DArrayShorts(TargetChannel,TimePoint);
    stack(:) = typecast(arr, 'uint16');
    if DeleteBefore==1;
        stack(:)=0;
    end
    
    t3=max(max(max(DistTransOutIn)));
    DistTransOutIn(DistTransOutIn==0)=65535;
    t1=double(min(min(min(DistTransOutIn))));
    a1=min(min(min(DistTransOutIn)));
    a2=max(max(max(DistTransOutIn)));
    if Repetition==1
        % zero values are NaN, set zeros first to 65535, determine min
        
        counter=ceil(t1/DistanceBin)*DistanceBin; % find lowest distance
        
        while (counter<=t3);
            delete(h); h=msgbox(['timepoint ',num2str(TimePoint+1),'/',num2str(vSizeT),', bin ',num2str(counter-1000)]);
%             wave1(:)=0; wave1(DistTransOutIn<=counter)=1;
%             wave2(:)=0; wave2(11:10+size(wave1,1),11:10+size(wave1,2),11:10+size(wave1,3))=wave1;
%             [wave2]=bwperim(wave2,OutlineWidth); % determine perimeter around values equal to zero
%             wave1=wave2(11:10+size(wave1,1),11:10+size(wave1,2),11:10+size(wave1,3));
%             stack(wave1~=0)=TargetValue-abs(counter-1000);
            
            wave1(:)=1; wave2=wave1; wave1(DistTransOutIn<=counter)=0;
            [wave1]=bwperim(wave1,OutlineWidth); % determine perimeter around values equal to zero
            % remove outmost line, DistTransOut is 65535 outside imaged region
            wave2(DistTransOutIn~=65535)=0; % select whole volume containing distance information and set to zero
            [wave2]=bwperim(wave2,OutlineWidth); % determine perimeter around values equal to zero, sets the rings unequal zero
            wave1(wave2~=0)=0;
            stack(wave1~=0)=TargetValue-abs(counter-1000);
            counter=counter+DistanceBin;
        end
    else % for single distancebin
%         if DistanceBin<0; subtract=1;else; subtract=0; end;
        wave1(:)=1; wave2=wave1; wave1(DistTransOutIn<=DistanceBin+1000)=0; % set everything below that value to zero
        [wave1]=bwperim(wave1,OutlineWidth); % determine perimeter around values equal to zero, in wave1 now the ring is set to logical 1, everything else to zero
        % remove outmost line, DistTransOut is 65535 outside imaged region
        wave2(DistTransOutIn~=65535)=0; % select whole volume containing distance information and set to zero
        [wave2]=bwperim(wave2,OutlineWidth); % determine perimeter around values equal to zero, sets the rings unequal zero
        wave1(wave2~=0)=0;
        stack(wave1~=0)=TargetValue;
    end
             
    LargeDataset=0;
    if LargeDataset==0;
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