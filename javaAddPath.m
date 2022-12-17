function javaAddPath()
keyboard;
global W;
% cd(['C:\Program Files\Bitplane\Imaris x64 ',W.DefaultImarisVersion,'\XT\matlab']);
OrigW=W;
% javaaddpath ImarisLib.jar;

if strfind1(javaclasspath('-all'),'loci_tools.jar')==0
    javaaddpath('\\GNP90N\share\Finn\Finns programs\file Exchange\bfmatlab\bioformats_package.jar','-end');
end
if strfind1(javaclasspath('-all'),'bioformats_package.jar')==0
    javaaddpath('\\GNP90N\share\Finn\Finns programs\file Exchange\bfmatlab\loci_tools.jar','-end');
end

W=OrigW;
W.ImarisLib=ImarisLib;
global W;

