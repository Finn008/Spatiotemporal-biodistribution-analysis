function [Skeleton]=dystrophyDetection_Microglia_Fibers(Fibers,Pix,Res,FilenameTotal)
global W;

Application=openImaris_2(FilenameTotal);
J = struct;
J.Application=Application;
J.SurfaceName='MicrogliaFibers';
J.Channel='Fibers';
J.Smooth=0.25;
% J.Background=1;
J.LowerManual=0.4;
J.SurfaceFilter=['"Volume" above 20 um^3'];
generateSurface3(J);
[Fibers]=im2Matlab_3(Application,'MicrogliaFibers',1,'Surface');
quitImaris(Application);

ex2Imaris_2(Fibers,FilenameTotal,'Fibers');


Skeleton=Skeleton3D(Fibers);
% % % % [Window]=generateEllipse([0.8],Res);
% % % % Skeleton=imdilate(Skeleton,Window);
% % % % Skeleton=Skeleton3D(Skeleton);

[~,Nodes,Links]=Skel2Graph3D(Skeleton,10);
Nodes=struct2table(Nodes);
Links=struct2table(Links);

for m=1:size(Links,1)
    Wave1=Links.point{m,1}.';
    Links.PointNumber(m,1)=size(Wave1,1);
    Links.Endpoints(m,1:2)=[Wave1(1),Wave1(end)];
end

Nodes.LinInd=sub2ind(Pix.',ceil(Nodes.comx),ceil(Nodes.comy),ceil(Nodes.comz));


% % Skeleton=zeros(Pix.','uint16');
% % Skeleton(cell2mat(Links.point.'))=1;
% % Skeleton(Nodes.LinInd)=2;


% Branchpoints
for m=1:size(Nodes,1)
    Skeleton(Nodes.LinInd(m))=m;
end

ex2Imaris_2(Skeleton,FilenameTotal,'MicrogliaSkeleton3');


return;

Application=openImaris_2(FilenameTotal);
Application.SetVisible(1);
% Links3D=zeros(Pix.','uint8');
% Links3D(cell2mat(Links.point.'))=1;
% Nodes3D=zeros(Pix.','uint8');
% Nodes3D(cell2mat(Nodes.idx))=1;

Skeleton=zeros(Pix.','uint8');
Skeleton(cell2mat(Links.point.'))=1;
Skeleton(cell2mat(Nodes.idx))=2;

% imarisSaveHDFlock(Application,FilenameTotal);
ex2Imaris_2(Skeleton,FilenameTotal,'MicrogliaSkeleton2');

return;

% imarisSaveHDFlock(FilenameTotal);




% Nodes.XYZ=[ceil(Nodes.comx),ceil(Nodes.comy),ceil(Nodes.comz)];








ex2Imaris_2(Skeleton,FilenameTotal,'MicrogliaSkeleton');
imarisSaveHDFlock(FilenameTotal);
Application=openImaris_2(FilenameTotal);
Application.SetVisible(1);


Mask=Iba1Perc>prctile(Iba1Corr,70);
Mask(Soma>0)=1;

BW=bwconncomp(Mask,6);
Table=table;
Table.NumPix=cellfun(@numel,BW.PixelIdxList).';
Table.IdxList=BW.PixelIdxList.';
Table.Volume=Table.NumPix*prod(Res(1:3));

Table(Table.Volume<=1,:)=[];

Ind=cell2mat(Table.IdxList);
Mask=zeros(Pix.','uint16');
Mask(Ind)=1;

Skeleton=Skeleton3D(FiberMask);



keyboard;


Application=openImaris_2(FilenameTotal);
J = struct;
J.Application=Application;
J.SurfaceName='MicrogliaFibrils';
J.Channel='Iba1';
J.Smooth=0.25;
J.Background=1;
J.LowerManual=1000;
J.SurfaceFilter=['"Volume" above 4 um^3'];
generateSurface3(J);
[MicrogliaFibrils]=im2Matlab_3(Application,'MicrogliaFibrils',1,'Surface');

[FiberMask]=im2Matlab_3(Application,'MicrogliaFibers',1,'Surface');

ex2Imaris_2(Skeleton,Application,'MicrogliaSkeleton');

% Remove stuff smaller than volume and with skeleton shorter than something


keyboard;



% Skeleton=Mask;
% Skeleton(MicrogliaSoma==1)=0;

% % % [~,Node,Link]=Skel2Graph3D(Skeleton,1);
% % % Skeleton=Graph2Skel3D(Node,Link,Pix(1),Pix(2),Pix(3));
skel = Skeleton3D(testvol);
inds = find(skel);
[yskel,xskel,zskel] = ind2sub(size(skel),inds);