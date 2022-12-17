function [Application2]=openData3DImaris(Data3D,Res,ChannelNames)
global W;
if isempty(W)
    initializeAnywhere();
end
% W.PathImarisSample='\\gnp90n\share\Finn\Finns programs\ImarisSample.ims';
% W.DefaultImarisVersion='7.7.2';
% W.ImarisLib.GetApplication(Ind)=
% if isempty(W)
%     W.DefaultImarisVersion='7.7.2';
%     W.PathImarisSample=[fileparts(mfilename('fullpath')),'\ImarisSample.ims'];
% end
Pix=[1;1;1];
Pix(1:ndims(Data3D))=size(Data3D).';
J=struct;
if exist('Res')==1 && isempty(Res) ~=1
    J.UmMinMax=[[0;0;0],Pix.*Res];
else
    Res=[1;1;1];
end

J.PixMax=[Pix(1);Pix(2);Pix(3);0;1];
J.Resolution=Res;
J.Path2file=W.PathImarisSample;
    

Application2=openImaris_2(J,1,0);
% Application2.SetVisible(1);

if exist('ChannelNames')~=1 || isempty(ChannelNames)==1
    ChannelNames={'Data3D'};
elseif ischar(ChannelNames)
    ChannelNames={ChannelNames};
end



ex2Imaris_2(Data3D,Application2,ChannelNames{1});

