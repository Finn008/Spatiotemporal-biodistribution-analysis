function [Data3D]=imarisImporter_2(In,Data3D)
global W;
v2struct(In);
Trials=1;
% % % Report=table;
if exist('Data3D')==1
   Direction='Matlab2Imaris';
   Pix=size(Data3D).';
   if size(Pix,1)==2
       Pix(3,1)=1;
   end
   BitType= class(Data3D);
else
    Direction='Imaris2Matlab';
    Data3D=zeros(Pix(1),Pix(2),Pix(3),BitType);
end
if exist('TargetChannel')~=1
    TargetChannel=1;
end
if exist('TargetTimepoint')~=1
    TargetTimepoint=1;
end

LayerStart=1;
LayerSize=Pix(3);
m=0;
if strcmp(Direction,'Matlab2Imaris')
    cprintf('text',[num2str(Pix(3)),'/']);
end
while LayerStart<=Pix(3);
    m=m+1;
    if LayerStart+LayerSize-1 > Pix(3);
        LayerSize=Pix(3)-LayerStart+1;
    end
    LayerEnd=LayerStart+LayerSize-1;
    try
% % %         Report.Dofunction{m,1}=W.Dofunction;
% % %         try; Report.Filename{m,1}=W.Filename; end;
% % %         Report.Computer{m,1}=W.ComputerInfo.Name;
% % %         Report.Time{m,1}=datestr(now,'yy.mm.dd HH:MM:SS');
% % %         Report.BitType{m,1}=BitType;
% % %         Report.LayerSize(m,1)=LayerSize;
% % %         Report.LayerEnd(m,1)=LayerEnd;
% % %         Report.LayerStart(m,1)=LayerStart;
% % %         Report.Pix{m,1}=Pix;
% % %         Report.TargetChannel{m,1}=TargetChannel;
% % %         Report.TargetTimepoint(m,1)=TargetTimepoint;
        
        
        if strcmp(Direction,'Matlab2Imaris')
%             keyboard; % check the secure export to Imaris
            Chunk=Data3D(:,:,LayerStart:LayerEnd);
            if strcmp(BitType,'uint8')
                DataImarisObject.SetDataSubVolumeAs1DArrayBytes(Chunk(:), 0, 0, LayerStart-1, TargetChannel-1, TargetTimepoint-1, Pix(1), Pix(2), LayerSize);
                Arr=DataImarisObject.GetDataSubVolumeAs1DArrayBytes(0, 0, LayerStart-1, TargetChannel-1, TargetTimepoint-1, Pix(1), Pix(2), LayerSize);
            elseif strcmp(BitType,'uint16')
                DataImarisObject.SetDataSubVolumeAs1DArrayShorts(Chunk(:), 0, 0, LayerStart-1, TargetChannel-1, TargetTimepoint-1, Pix(1), Pix(2), LayerSize);
                Arr=DataImarisObject.GetDataSubVolumeAs1DArrayShorts(0, 0, LayerStart-1, TargetChannel-1, TargetTimepoint-1, Pix(1), Pix(2), LayerSize);
            elseif strcmp(BitType,'single')
                DataImarisObject.SetDataVolumeAs1DArrayFloats(Chunk(:), 0, 0, LayerStart-1, TargetChannel-1, TargetTimepoint-1, Pix(1), Pix(2), LayerSize);
                Arr=DataImarisObject.GetDataSubVolumeAs1DArrayFloats(0, 0, LayerStart-1, TargetChannel-1, TargetTimepoint-1, Pix(1), Pix(2), LayerSize);
            end
            Arr=typecast(Arr,BitType);
            if sum(Arr(:))~=sum(Chunk(:))
                disp('Data was not correctly placed to Imaris');
                A1=asdf;
                keyboard;
            end
            clear Arr;
            cprintf('text',[num2str(LayerEnd),',']);
        elseif strcmp(Direction,'Imaris2Matlab')
            if strcmp(BitType,'uint8')
                Arr=DataImarisObject.GetDataSubVolumeAs1DArrayBytes(0, 0, LayerStart-1, TargetChannel-1, TargetTimepoint-1, Pix(1), Pix(2), LayerSize);
            elseif strcmp(BitType,'uint16')
                Arr=DataImarisObject.GetDataSubVolumeAs1DArrayShorts(0, 0, LayerStart-1, TargetChannel-1, TargetTimepoint-1, Pix(1), Pix(2), LayerSize);
            elseif strcmp(BitType,'single')
                Arr=DataImarisObject.GetDataSubVolumeAs1DArrayFloats(0, 0, LayerStart-1, TargetChannel-1, TargetTimepoint-1, Pix(1), Pix(2), LayerSize);
            end
            Chunk=zeros(Pix(1),Pix(2),LayerSize,BitType);
            Chunk(:)= typecast(Arr,BitType);
            clear Arr;
            Data3D(:,:,LayerStart:LayerEnd)=Chunk(:,:,:);
        end
        LayerStart=LayerStart+LayerSize;
        LayerSize=LayerSize+2;
% % %         Report.Error{m,1}='';
    catch error
        pause(2);
        JavaHeapMemory=java.lang.Runtime.getRuntime.freeMemory;
        [Wave1,Wave2]=memory;
        AvailableRAM=Wave2.PhysicalMemory.Available;
        
% % %         Report.AvailableRAM(m,1)=AvailableRAM;
% % %         Report.JavaHeapMemory(m,1)=JavaHeapMemory;
        Error=displayError(error,0);
% % %         Report.Error{m,1}=Error;
        
        if LayerSize>1
            LayerSize=ceil(LayerSize/2);
        else
            disp('Error occurred when exporting data from Imaris to Matlab');
% % %             iFileChanger('W.G.Error.Im2MatlabReport=fuseTable(W.G.Error.Im2MatlabReport,Q1);','ExecuteTarget',{'Q1',Report});
            if strfind1(Error,'OutOfMemoryError occurred while allocating a ByteBuffer') && Trials<=5
%                 try; Application.SetVisible(1); end;
                try; setVisible(Application); end;
                Trials=Trials+1;
                LayerSize=Pix(3);
            else
                A1=qwertzuiop;
            end
        end
    end
end


