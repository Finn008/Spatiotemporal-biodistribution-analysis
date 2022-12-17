function [Val]=autoquantGetParameters(DeconFileList)
global W;
Val=table;
%% for all Files
Val.Modality='Multi-Photon Fluorescence';
Val.Lens='W Plan-Apochromat 20x/1.0 DIC M27 75mm';
Val.ImmMedium='Water (1,333)';
Val.SampleMedium='Water (1,333)';
Val.BitType='16 bit unsigned integer';

Val.FilenameTotal=Fileinfo.FilenameTotal{1};
Val.Type=Fileinfo.Type{1};
Val.Path2file=PathRaw;
Val.Filename=Fileinfo.Filename{1};
Val.Path2fileXML=[Val.Path2file,'.xml'];
Val.Ch1Wavelength='450 nm';
Val.Ch2Wavelength='620 nm';
Val.SA='0,4';
return;

%% File specific stuff
FileNumber=size(DeconFileList,1);
for m=1:FileNumber
    Fileinfo=DeconFileList(m,:);
    [PathRaw,~]=getPathRaw(DeconFileList.FilenameTotal{m,1});
    if Fileinfo.MB<3900 && strcmp(Fileinfo.Type,'.czi')==0
        Val.FilenameTotal=Fileinfo.FilenameTotal{1};
        Val.Type=Fileinfo.Type{1};
        Val.Path2file=PathRaw;
        Val.Filename=Fileinfo.Filename{1};
    else
        Val.Filename=['4decon_',Fileinfo.Filename{1}];
        Val.Type='.ids';
        Val.FilenameTotal=[Val.Filename,Val.Type];
        [Val.Path2file,Report]=getPathRaw(Val.FilenameTotal);
    end
    Val.Path2fileXML=[Val.Path2file,'.xml'];
    
    DeconParam=variableExtract(Fileinfo.Decon{1},{'SA'});
    if strcmp(Fileinfo.Filename{1}(end,end),'b')
        Val.Ch1Wavelength='450 nm';
        Val.Ch2Wavelength='620 nm';
        Val.SA='0,4';
    elseif strcmp(Fileinfo.Filename{1}(end,end),'a')
        Val.Ch1Wavelength='620 nm';
        Val.Ch2Wavelength='530 nm';
        A1=asdf;
    end
    DeconFileList.Val{m,1}=catstruct(IniVal,Val);
end
