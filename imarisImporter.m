function [Data3D]=imarisImporter(DataImarisObject,IndC,IndT,Pix,BitType,Data3D)
keyboard; % replaced by version _2
global W;

Report=table;
if exist('Data3D')==1 % send data from Matlab to Imaris
    Direction='Matlab2Imaris';
else % send data from Imaris to Matlab
    Data3D=zeros(Pix(1),Pix(2),Pix(3),BitType);
    Direction='Imaris2Matlab';
end

LayerStart=1;
LayerSize=Pix(3);
m=0;
while LayerStart<=Pix(3);
    m=m+1;
    if LayerStart+LayerSize-1 > Pix(3);
        LayerSize=Pix(3)-LayerStart+1;
    end
    LayerEnd=LayerStart+LayerSize-1;
    try
        Report.Dofunction{m,1}=W.Dofunction;
        try; Report.Filename{m,1}=W.Filename; end;
        Report.Computer{m,1}=W.ComputerInfo.Name;
        Report.Time{m,1}=datestr(now,'yy.mm.dd HH:MM:SS');
        Report.BitType{m,1}=BitType;
        Report.LayerSize(m,1)=LayerSize;
        Report.LayerEnd(m,1)=LayerEnd;
        Report.LayerStart(m,1)=LayerStart;
        Report.Pix{m,1}=Pix;
        Report.TargetChannel{m,1}=IndC;
        Report.TargetTimepoint(m,1)=IndT;
        if strcmp(Direction,'Matlab2Imaris')
            Chunk=Data3D(:,:,LayerStart:LayerEnd);
            if strcmp(BitType,'uint8')
                DataImarisObject.SetDataSubVolumeAs1DArrayBytes(Chunk(:), 0, 0, LayerStart-1, IndC-1, IndT-1, Pix(1), Pix(2), LayerSize);
            elseif strcmp(BitType,'uint16')
                DataImarisObject.SetDataSubVolumeAs1DArrayShorts(Chunk(:), 0, 0, LayerStart-1, IndC-1, IndT-1, Pix(1), Pix(2), LayerSize);
            end
        elseif strcmp(Direction,'Imaris2Matlab')
            if strcmp(BitType,'uint8')
                Arr=DataImarisObject.GetDataSubVolumeAs1DArrayBytes(0, 0, LayerStart-1, IndC-1, IndT-1, Pix(1), Pix(2), LayerSize);
            elseif strcmp(BitType,'uint16')
                Arr=DataImarisObject.GetDataSubVolumeAs1DArrayShorts(0, 0, LayerStart-1, IndC-1, IndT-1, Pix(1), Pix(2), LayerSize);
            end
            Chunk=zeros(Pix(1),Pix(2),LayerSize,BitType);
            Chunk(:)= typecast(Arr,BitType);
            clear Arr;
            Data3D(:,:,LayerStart:LayerEnd)=Chunk(:,:,:);
        end
        
        LayerStart=LayerStart+LayerSize;
        Report.Error{m,1}='';
    catch error
        pause(2);
        JavaHeapMemory=java.lang.Runtime.getRuntime.maxMemory;
        [Wave1,Wave2]=memory;
        AvailableRAM=Wave2.PhysicalMemory.Available;
        
        Report.AvailableRAM(m,1)=AvailableRAM;
        Report.JavaHeapMemory(m,1)=JavaHeapMemory;
        Report.Error{m,1}=displayError(error,0);
        
        LayerSize=floor(LayerSize/2);
        if LayerSize==0
            disp('Error occurred when exporting data from Imaris to Matlab');
            iFileChanger('W.G.Error.Im2MatlabReport=fuseTable(W.G.Error.Im2MatlabReport,Q1);','ExecuteTarget',{'Q1',Report});
            A1=qwertzuiop;
        end
    end
end


