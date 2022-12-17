function manuallyFuse3D_2()
global W;
F=W.G.T.F{W.Task}(W.File,:);
[FctSpec]=variableExtract(F.ManuallyFuse3D{1},{'FileBot';'FileTop';'BottomZ';'TopZ';'XYumMove'});
FilenameTotal=FctSpec.FileBot;
FilenameTotalTop=FctSpec.FileTop;

XYumMove=FctSpec.XYumMove;
% XYumMove=[-1.2;-1.24]; % distance to move top to bottom

[Fileinfo,IndFileinfo,~]=getFileinfo_2(FilenameTotal);

[Bottom3D]=im2Matlab_3(FilenameTotal);
Bottom3D=permute(Bottom3D,[1,2,3,5,4]);
[Top3D]=im2Matlab_3(FilenameTotalTop);
Top3D=permute(Top3D,[1,2,3,5,4]);
PixBot=size(Bottom3D).';
PixTop=size(Top3D).';
ChannelNumber=PixTop(4);
% CutSlice=77;
if FctSpec.TopZ==0
    TopZ=[1;PixTop(3)];
else
    TopZ=FctSpec.TopZ;
end
if FctSpec.BottomZ==0
    BottomZ=[1;PixBot(3)];
else
    BottomZ=FctSpec.BottomZ;
end
XYpixMove=round(XYumMove/Fileinfo.Res{1}(1));
XYumMove=XYpixMove*Fileinfo.Res{1}(1);
% XYpixMoveTop=round(XYpixMove/2);
% XYpixMoveBot=XYpixMoveTop-XYpixMove;

% PixFinal=[PixBot(1)+2*abs(XYpixMove(1));PixBot(2)+2*abs(XYpixMove(2));BottomZ(2)-BottomZ(1)+1+TopZ(2)-TopZ(1)+1;ChannelNumber];
PixFinal=[PixBot(1)+abs(XYpixMove(1));PixBot(2)+abs(XYpixMove(2));BottomZ(2)-BottomZ(1)+1+TopZ(2)-TopZ(1)+1;ChannelNumber];
FinalStack=zeros(PixFinal(:).','uint16');

for m=1:2
%     Wave1=[-XYpixMove(m)+1,-XYpixMove(m)+PixBot(m)];
    Wave1=[abs(XYpixMove(m))+1,abs(XYpixMove(m))+PixBot(m)];
    Wave2=[1,PixBot(m)];
    if XYpixMove(m)<0
        PasteBottom(m,1:2)=Wave1;
        PasteTop(m,1:2)=Wave2;
    else
        PasteBottom(m,1:2)=Wave2;
        PasteTop(m,1:2)=Wave1;
    end
end
PasteBottom(3,1:2)=[1,BottomZ(2)-BottomZ(1)+1];
PasteTop(3,1:2)=[BottomZ(2)-BottomZ(1)+2,PixFinal(3)];
FinalStack(PasteBottom(1,1):PasteBottom(1,2),PasteBottom(2,1):PasteBottom(2,2),PasteBottom(3,1):PasteBottom(3,2),:)=Bottom3D(:,:,BottomZ(1):BottomZ(2),:);
FinalStack(PasteTop(1,1):PasteTop(1,2),PasteTop(2,1):PasteTop(2,2),PasteTop(3,1):PasteTop(3,2),:)=Top3D(:,:,TopZ(1):TopZ(2),:);

ManuallyInterfere=1;
if ManuallyInterfere==1
    J=struct;J.PixMax=[PixFinal(1);PixFinal(2);10;0;1]; J.Path2file=W.PathImarisSample;
    J.UmMinMax=[[0;0;0],[PixFinal(1:2,1);10].*Fileinfo.Res{1}];
    Application=openImaris_2(J);
    ex2Imaris_2(FinalStack(:,:,BottomZ(2)-4:BottomZ(2)+5,2),Application);
    Application.SetVisible(1);
    keyboard;
    quitImaris(Application);
end

J=struct;J.PixMax=[PixFinal(1);PixFinal(2);PixFinal(3);0;1]; J.Path2file=W.PathImarisSample; 
J.UmMinMax=[[0;0;0],[PixFinal(1:3,1).*Fileinfo.Res{1}]];
Application=openImaris_2(J);

ImarisName=[FilenameTotal,'_Fused.ims'];
ImarisPath=getPathRaw(ImarisName);
Application.FileSave(ImarisPath,'writer="Imaris5"');
quitImaris(Application);

ex2Imaris_2(FinalStack(:,:,:,1),ImarisName,1);
ex2Imaris_2(FinalStack(:,:,:,2),ImarisName,2);




% keyboard; % produced corrupt data file last time
Application=openImaris_2(ImarisPath);
imarisSaveHDFlock(Application,ImarisPath);

Application=openImaris_2(ImarisPath);
% Application.SetVisible(1);
FinalName=[F.Filename{1},'_4decon.ids'];
FinalPath=getPathRaw(FinalName);
Application.FileSave(FinalPath,'writer="ICS"');
quitImaris(Application);
clear Application;

deleteFile(ImarisPath);


Wave1=variableSetter_2(F.ManuallyFuse3D{1},{'Do','Fin';'XYumMove',['[',num2str(XYumMove(1)),';',num2str(XYumMove(2)),']']});
iFileChanger('W.G.T.F{W.Task,1}.ManuallyFuse3D{W.File}',Wave1);
