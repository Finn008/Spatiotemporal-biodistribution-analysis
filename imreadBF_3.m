function [Data3D]=imreadBF_3(Path2file,PixMinMax,Timepoint,Channel,BitType)
global W;
OrigW=W;
try
    Path = fullfile(fileparts(mfilename('fullpath')), 'loci_tools.jar');
    
    javaaddpath(Path);
    if exist('lurawaveLicense')
        Path = fullfile(fileparts(mfilename('fullpath')), 'lwf_jsdk2.6.jar');
        javaaddpath(Path);
        java.lang.System.setProperty('lurawave.license', lurawaveLicense);
    end
    
    % check MATLAB version, since typecast function requires MATLAB 7.1+
    canTypecast = versionCheck(version, 7, 1);
    
    % check Bio-Formats version, since makeDataArray2D function requires trunk
    bioFormatsVersion = char(loci.formats.FormatTools.VERSION);
    isBioFormatsTrunk = versionCheck(bioFormatsVersion, 5, 0);
    
    % initialize logging
    loci.common.DebugTools.enableLogging('INFO');
    
    r = loci.formats.ChannelFiller();
    r = loci.formats.ChannelSeparator(r);
    evalc('r.setId(Path2file);');
    
    TotalPix(1)= r.getSizeX();
    TotalPix(2,1)= r.getSizeY();
    TotalPix(3,1)= r.getSizeZ();
    PixelType = r.getPixelType();
    if exist('PixMinMax')~=1 || isempty(PixMinMax)
        PixMinMax=[[1;1;1],[TotalPix]];
    end
    if exist('BitType')~=1 || isempty(BitType)
        BitType='uint16';
    end
    if exist('Timepoint')~=1 || isempty(Timepoint)
        Timepoint=1;
    end
    if exist('Channel')~=1 || isempty(Channel)
        Channel=1;
    end
    Pix=PixMinMax(:,2)-PixMinMax(:,1)+1;
    
    Bpp = loci.formats.FormatTools.getBytesPerPixel(PixelType);
    Fp = loci.formats.FormatTools.isFloatingPoint(PixelType);
    Little = r.isLittleEndian();
    Sgn = loci.formats.FormatTools.isSigned(PixelType);
    
    Data3D=zeros(Pix(1),Pix(2),Pix(3),BitType);
    if Timepoint>1
        keyboard; % check if correct data is chosen
    end
    Counter=1;
    for Zplane=PixMinMax(3,1):PixMinMax(3,2)
        %['importing file via bioFormats\\ ',num2str(100*zahler/(length(tframe)*length(zplane))),'%']
        Index=r.getIndex(Zplane-1,Channel-1,Timepoint-1);
        Plane = r.openBytes(Index);
        Arr = loci.common.DataTools.makeDataArray2D(Plane,Bpp,Fp,Little,TotalPix(2)).';
        Arr2=Arr(PixMinMax(1,1):PixMinMax(1,2),PixMinMax(2,1):PixMinMax(2,2));
        Arr=cast(Arr2,BitType);
        Arr(:)=typecast(Arr2(:),BitType);
        Data3D(:,:,Counter)=Arr;
        Counter=Counter+1;
    end
    
catch Error
    keyboard;
end

W=OrigW;
global W;
evalin('caller','global W;');

end


function [result] = versionCheck(v, maj, min)

tokens = regexp(v, '[^\d]*(\d+)[^\d]+(\d+).*', 'tokens');
majToken = tokens{1}(1);
minToken = tokens{1}(2);
major = str2num(majToken{1});
minor = str2num(minToken{1});
result = major > maj || (major == maj && minor >= min);
end















