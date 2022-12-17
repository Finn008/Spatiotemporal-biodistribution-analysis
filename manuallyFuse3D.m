function manuallyFuse3D()

% FilenameTotal='2014.11.26_95b.czi';
% FilenameTotalTop='2014.11.26_95btop.czi';
FilenameTotal='2015.01.14_97a1.czi';
FilenameTotalTop='2015.01.14_97a2.czi';

[Fileinfo,IndFileinfo,~]=getFileinfo_2(FilenameTotal);

[Bottom3D]=im2Matlab_3(FilenameTotal);
Bottom3D=permute(Bottom3D,[1,2,3,5,4]);
[Top3D]=im2Matlab_3(FilenameTotalTop);
Top3D=permute(Top3D,[1,2,3,5,4]);
PixBot=size(Bottom3D).';
PixTop=size(Top3D).';
ChannelNumber=PixTop(4);
% CutSlice=77;

BottomZ=[1;77];
TopZ=[1;PixTop(3)];
XYumMove=[-1.2;-1.24]; % distance to move top to bottom
XYpixMove=round(XYumMove/Fileinfo.Res{1}(1));

PixFinal=[PixBot(1)+2*abs(XYpixMove(1)),PixBot(2)+2*abs(XYpixMove(2)),BottomZ(2)-BottomZ(1)+1+TopZ(2)-TopZ(1)+1,ChannelNumber];
FinalStack=zeros(PixFinal.','uint16');

for m=1:2
    if XYpixMove(m)<0
        PasteBottom(1,m)=-XYpixMove(m);
        PasteTop(1,m)=1;
    else
        PasteBottom(1,m)=1;
        PasteTop(1,m)=-XYpixMove(m);
    end
end
PasteBottom(3,1:2)=[1,BottomZ(2)-BottomZ(1)+1];
PasteTop(3,1:2)=[BottomZ(2)-BottomZ(1),PixFinal(3)];
FinalStack(PasteBottom(1,1):PasteBottom(1,2),PasteBottom(2,1):PasteBottom(2,2),PasteBottom(3,1):PasteBottom(3,2),:)=Bottom3D(:,:,BottomZ(1):BottomZ(2),:);
FinalStack(PasteTop(1,1):PasteTop(1,2),PasteTop(2,1):PasteTop(2,2),PasteTop(3,1):PasteTop(3,2),:)=Top3D(:,:,TopZ(1):TopZ(2),:);


J=struct;J.PixMax=[PixFinal(1);PixFinal(2);10;0;1]; J.Path2file=W.PathImarisSample; 
J.UmMinMax=[[0;0;0],[[PixFinal(1:2,1);10].'Fileinfo.Res{1}(3)]];
Application=openImaris_2(J); Application.SetVisible(1);

ex2Imaris_2(FinalStack(:,:,BottomZ(2)-4:BottomZ(2)+5,2),Application);


J=struct;J.PixMax=[PixFinal(1);PixFinal(2);PixFinal(3);0;1]; J.Path2file=W.PathImarisSample; 
J.UmMinMax=[[0;0;0],[PixFinal.'Fileinfo.Res{1}(3)]];
Application=openImaris_2(J); Application.SetVisible(1);
% J=struct;J.PixMax=[PixBot(1);PixBot(2);1;0;1]; J.Path2file=W.PathImarisSample; 
% J.UmMinMax=[[Fileinfo.UmStart{1}(1:2);0],[Fileinfo.UmStart{1}(1:2);Fileinfo.Res{1}(3)]];
% Application=openImaris_2(J); Application.SetVisible(1);

ex2Imaris_2(Bottom3D(:,:,CutSlice,2),Application,'Before');
ex2Imaris_2(Top3D(:,:,1,2),Application,'After');

Final3D=Bottom3D(:,:,1:CutSlice,:);
Final3D(:,:,end+1:end+PixTop(3),:)=Top3D(:,:,:,:);
PixFinal=size(Final3D).';
quitImaris(Application);

Um=Fileinfo.Res{1}.*PixFinal(1:3);
UmMinMax=[-Um/2,Um/2];
UmMinMax=[Fileinfo.UmStart{1},Fileinfo.UmEnd{1}];

J=struct;J.PixMax=[PixFinal(1);PixFinal(2);PixFinal(3);0;1]; J.Path2file=W.PathImarisSample; 
J.UmMinMax=UmMinMax;
Application=openImaris_2(J); Application.SetVisible(1);


FinalFilenameTotal=[FilenameTotal(1:end-4),'_Fuse.ims'];
Path2file=getPathRaw(FinalFilenameTotal);
Application.FileSave(Path2file,'writer="ICS"');
quitImaris(Application);

ex2Imaris_2(Final3D(:,:,:,1),FinalFilenameTotal,1);
ex2Imaris_2(Final3D(:,:,:,2),FinalFilenameTotal,2);
% Application=openImaris_2(Path2file);