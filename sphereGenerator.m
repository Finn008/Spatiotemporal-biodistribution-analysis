function [Data3D]=sphereGenerator(In)
v2struct(In);

VariableNames=XYZ.Properties.VariableNames.';

if strfind1(VariableNames,'UmStart',1)==0
    XYZ.UmStart=[0;0;0];
end
if strfind1(VariableNames,{'UmEnd';'Pix'},1)==0
    XYZ.Pix=ceil(repmat(Radius*2,[3,1])./XYZ.Res);
    XYZ.UmEnd=XYZ.Pix.*XYZ.Res;
    XYZ.Center=XYZ.UmEnd/2;
end

XYZ.Um=XYZ.UmEnd-XYZ.UmStart;
XYZ.Res=XYZ.Um./XYZ.Pix;




[XX,YY,ZZ] = meshgrid(0:XYZ.Res(1):Radius*2,0:XYZ.Res(2):Radius*2,0:XYZ.Res(3):Radius*2);
SubChunk = sqrt((XX-Radius).^2+(YY-Radius).^2+(ZZ-Radius).^2)<=Radius;

XYZ.PixSubChunk=[size(SubChunk,1);size(SubChunk,2);size(SubChunk,3)];
Data3D=false(XYZ.Pix(1),XYZ.Pix(2),XYZ.Pix(3));

XYZ.CenterPix=round((XYZ.Center-XYZ.UmStart)./XYZ.Res);

XYZ.StartPaste=XYZ.CenterPix-floor(XYZ.PixSubChunk/2);
XYZ.EndPaste=XYZ.StartPaste+XYZ.PixSubChunk-1;
XYZ.StartCut=[1;1;1];
XYZ.EndCut=XYZ.PixSubChunk;
XYZ.OverHang=XYZ.EndPaste-XYZ.Pix;
XYZ.OverHang(XYZ.OverHang<1)=0;

XYZ.UnderHang=1-XYZ.StartPaste;
XYZ.UnderHang(XYZ.UnderHang<1)=0;

XYZ.StartPaste=XYZ.StartPaste+XYZ.UnderHang;
XYZ.StartCut=XYZ.StartCut+XYZ.UnderHang;
XYZ.EndPaste=XYZ.EndPaste-XYZ.OverHang;
XYZ.EndCut=XYZ.EndCut-XYZ.OverHang;


Data3D(XYZ.StartPaste(1):XYZ.EndPaste(1),XYZ.StartPaste(2):XYZ.EndPaste(2),XYZ.StartPaste(3):XYZ.EndPaste(3))=SubChunk(XYZ.StartCut(1):XYZ.EndCut(1),XYZ.StartCut(2):XYZ.EndCut(2),XYZ.StartCut(3):XYZ.EndCut(3));
