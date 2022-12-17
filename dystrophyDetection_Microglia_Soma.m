function [Soma,Fibers]=dystrophyDetection_Microglia_Soma(Iba1Perc,Iba1Corr,Pix,Res,FilenameTotal)



% use only parts with high contrast
Threshold=prctile(Iba1Corr(:),90);
Contour=Iba1Corr>Threshold;
Contour(Iba1Perc<95)=0;

% remove structures smaller than 1µm^3
BW=bwconncomp(Contour,6);
Table=table(cellfun(@numel,BW.PixelIdxList).',BW.PixelIdxList.','VariableNames',{'NumPix','IdxList'}); clear BW;
Table.Volume=Table.NumPix*prod(Res);
Table=Table(Table.Volume>1,:);
Contour=zeros(Pix.','uint8');
Contour(cell2mat(Table.IdxList))=1;
% Contour=1-Contour;

ex2Imaris_2(Contour,FilenameTotal,'Contour1');

% detect islands smaller than 10µm
SizeMinMax=[0.4,10;1.6,10;1.4,8.2]; % diameter 10
[Islands]=detectIslands(1-Contour,SizeMinMax,Res,'3D','Ones10');
Islands(Iba1Perc<86)=0; % remove stuff outside microglia
ex2Imaris_2(Islands,FilenameTotal,'Nuclei');
IslandThreshold=10;

% DistanceOut to melt pixelated stuff together
J=struct;
J.OutCalc=1;
J.ZeroBin=0;
J.Output={'DistInOut'};
J.Res=Res;
J.UmBin=0.1;
[Out]=distanceMat_2(J,Nuclei>IslandThreshold);
Distance=Out.DistInOut; clear Out;

% make DistanceInside
[Out]=distanceMat_2(J,Distance>10);
DistanceIn=Out.DistInOut; clear Out;

% keep only structures that after removing 1.6µm shell still have volume larger 10µm^3
BW=bwconncomp(DistanceIn>16,6);
Table=table(cellfun(@numel,BW.PixelIdxList).',BW.PixelIdxList.','VariableNames',{'NumPix','IdxList'}); clear BW;
Table.Volume=uint16(Table.NumPix*prod(Res));
Table=Table(Table.Volume>10,:);
Wave1=zeros(Pix.','uint16');
Wave1(cell2mat(Table.IdxList))=1;
[Wave1,AddBorderMinMaxPaste]=addBorder3D(Wave1,Res,10,'Zeros');
[Out]=distanceMat_2(J,Wave1);
DistanceOut=Out.DistInOut; clear Out;

[Contour2,AddBorderMinMaxPaste]=addBorder3D(1-Contour,Res,10,'Ones');
Contour2(DistanceOut>16)=1; % readd the removed 1.6µm shell
Contour2(DistanceOut>16+110)=0;

ex2Imaris_2(addBorder3D(Contour2,AddBorderMinMaxPaste),FilenameTotal,'Contour2');


% second island detection
[Nuclei2]=detectIslands(1-Contour2,SizeMinMax,Res,'3D');
Nuclei2(DistanceOut>16)=0; % remove everything inbetween

Nuclei2=addBorder3D(Nuclei2,AddBorderMinMaxPaste);

ex2Imaris_2(Nuclei2,FilenameTotal,'Nuclei2');

% loop through each strcuture and segregate with increasing threshold
Data3D=Nuclei2>=10;
for Run=1:1000
    BW=bwconncomp(Data3D,6);
    Table=table(cellfun(@numel,BW.PixelIdxList).',BW.PixelIdxList.','VariableNames',{'NumPix','IdxList'}); clear BW;
    Table.Volume=Table.NumPix*prod(Res);
    Table.Radius=(Table.Volume*3/4/pi).^(1/3);
    Table=Table(Table.Radius>1,:);
    for Id=find(Table.Radius>5).'
        Voxels=Table.IdxList{Id};
        Values=Nuclei2(Voxels);
        Voxels(Values==min(Values(:)))=[];
        Table.IdxList{Id}=Voxels;
    end
    Data3D=zeros(Pix.','uint16');
    Data3D(cell2mat(Table.IdxList))=1;
    if max(Table.Radius)<=5; break; end;
end


Nuclei3=Data3D;
ex2Imaris_2(Nuclei3,FilenameTotal,'Nuclei3');

Application=openImaris_2(FilenameTotal); Application.SetVisible(1);
J = struct;
J.Application=Application;
J.SurfaceName='Nuclei';
J.Channel='Nuclei';
J.Smooth=1.5;
% J.Background=15;
J.LowerManual=0.2;
J.SurfaceFilter=['"Volume" above 5 um^3'];
J.SeedsDiameter=6;
J.SeedsFilter=['"Quality" above 0.1'];
generateSurface3(J);

% [Results]=getObjectInfo_2('Nuclei',[],Application,1);
[Nuclei]=im2Matlab_3(Application,'Nuclei',1,'Surface');
imarisSaveHDFlock(Application,FilenameTotal);
% ex2Imaris_2(Nuclei,FilenameTotal,'Nuclei');
% J=struct;J.Application=Application;J.Channels='Plaques';J.Feature='Id'; J.ObjectInfo=Results;
% [PlaqueMapTotal]=im2Matlab_3(J);
% imarisSaveHDFlock(Application,FilenameTotal);



% DistanceOut to melt pixelated stuff together
[Out]=distanceMat_2(J,Nuclei);
% Wave1=Out.DistInOut>10;

Soma=Nuclei;
Soma(Contour==1&Out.DistInOut<=15)=1;
Soma=Soma+imclearborder(1-Soma,4); % close islands in Soma

ex2Imaris_2(Soma,FilenameTotal,'Soma');

Fibers=Contour;
Fibers(Soma==1)=0;

BW=bwconncomp(Fibers,6);
Table=table(cellfun(@numel,BW.PixelIdxList).',BW.PixelIdxList.','VariableNames',{'NumPix','IdxList'}); clear BW;
Table.Volume=Table.NumPix*prod(Res);
Table=Table(Table.Volume>1,:);
Fibers=zeros(Pix.','uint8');
Fibers(cell2mat(Table.IdxList))=1;

ex2Imaris_2(Fibers,FilenameTotal,'Fibers');
keyboard;

return;
%%
% 
% keyboard;
% 
% 
% 
% % Nuclei3=zeros(Pix.','uint16');
% % Table.Volume=uint16(Table.Volume);
% % for m=unique(Table.Volume).'
% %     Ind=cell2mat(Table.IdxList(find(Table.Volume==m)));
% %     Wave1(Ind)=m;
% % end
% 
% ex2Imaris_2(Data3D,FilenameTotal,'Data3D');
% Nuclei3=Nuclei2;
% Nuclei3(Data3D==0)=0;
% 
% ex2Imaris_2(Nuclei3,FilenameTotal,'Nuclei3');
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% return;
% 
% 
% 
% 
% 
% 
% 
% 
% ex2Imaris_2(Nuclei3,FilenameTotal,'Test1');
% ex2Imaris_2(Mask,FilenameTotal,'Test2');
% ex2Imaris_2(Nuclei3,FilenameTotal,'Test3');
% [Out]=distanceMat_2(J,DistanceIn>16);
% DistanceOut=Out.DistInOut;
% 
% Wave1=zeros(Pix.','uint16');
% Table.Volume=uint16(Table.Volume);
% for m=unique(Table.Volume).'
%     Ind=cell2mat(Table.IdxList(find(Table.Volume==m)));
%     Wave1(Ind)=m;
% end
% 
% % [Distance]=distanceMat2D(Nuclei>10,uint16(Res(1)*100));
% 
% BW=bwconncomp(Distance<=10,6);
% Table=table(cellfun(@numel,BW.PixelIdxList).',BW.PixelIdxList.','VariableNames',{'NumPix','IdxList'}); clear BW;
% Table.Volume=uint16(Table.NumPix*prod(Res));
% Table=Table(Table.Volume>4,:);
% Wave1=zeros(Pix.','uint16');
% Wave1(cell2mat(Table.IdxList))=1;
% % % % Table.Volume=uint16(Table.Volume);
% % % % for m=unique(Table.Volume).'
% % % %     Ind=cell2mat(Table.IdxList(find(Table.Volume==m)));
% % % %     Wave1(Ind)=m;
% % % % end
% 
% Mask(Wave1==0)=1;
% Mask(Distance>110)=0;
% [Nuclei2]=detectIslands(Mask,SizeMinMax,Res,'3D');
% 
% 
% 
% % FilenameTotal='ExTanjaB_IhcIba1_Ihd160708_M105_Roi1.ims';
% 
% 
% 
% 
% 
% Application=openImaris_2(FilenameTotal); Application.SetVisible(1);
% 
% 
% J = struct;
% J.Application=Application;
% J.SurfaceName='Nuclei';
% J.Channel='Nuclei';
% J.Smooth=0.7;
% %     J.Background=15;
% J.LowerManual=10;
% J.SurfaceFilter=['"Volume" above 27 um^3'];
% generateSurface3(J);
% 
% % [Results]=getObjectInfo_2('Nuclei',[],Application,1);
% [Nuclei]=im2Matlab_3(Application,'Nuclei',1,'Surface');
% imarisSaveHDFlock(Application,FilenameTotal);
% ex2Imaris_2(Nuclei,FilenameTotal,'Nuclei');
% % J=struct;J.Application=Application;J.Channels='Plaques';J.Feature='Id'; J.ObjectInfo=Results;
% % [PlaqueMapTotal]=im2Matlab_3(J);
% imarisSaveHDFlock(Application,FilenameTotal);
% 
% 
% return;
% 
% SizeMinMax=[0.4,10;2,80;1.5,300]; % diameter 10
% [Data3Db]=detectIslands(1-Mask,SizeMinMax,Res,'3D');
% 
% 
% ex2Imaris_2(Data3Dc,FilenameTotal,'Data3Dc');
% 
% return;
% ex2Imaris_2(Data3Db,FilenameTotal,'Nuclei');
% Application=openImaris_2(FilenameTotal); Application.SetVisible(1);
% %%
% 
% % first make 3D
% BW=bwconncomp(1-Mask,4);
% Table=table(cellfun(@numel,BW.PixelIdxList).',BW.PixelIdxList.','VariableNames',{'NumPix','IdxList'}); clear BW;
% Table.Volume=Table.NumPix*prod(Res);
% Table=Table(Table.Volume>1,:);
% 
% Mask=zeros(Pix.','uint16');
% Mask(cell2mat(Table.IdxList))=1;
% 
% % for m=1:size(Table,1)
% %     Mask(Table.IdxList{m})=Table.Volume(m);
% % end
% 
% % define nuclei
% BW=bwconncomp(1-Mask,4);
% Table=table(cellfun(@numel,BW.PixelIdxList).',BW.PixelIdxList.','VariableNames',{'NumPix','IdxList'}); clear BW;
% Table.Volume=Table.NumPix*prod(Res);
% Table=Table(Table.Volume>1,:);
% % Table=Table(Table.Volume<15*Res(3),:);
% 
% Nuclei=zeros(Pix.','uint16');
% % Nuclei(cell2mat(Table.IdxList))=1;
% for m=1:size(Table,1)
%     Nuclei(Table.IdxList{m})=Table.Volume(m);
% end
% 
% ex2Imaris_2(Nuclei,Application,'Nuclei');
% 
% % % % Mask=zeros(Pix.','uint16');
% % % % Mask(cell2mat(Table.IdxList))=1;
% 
% % Mask=zeros(Pix.','uint16');
% % for m=1:size(Table,1)
% %     Mask(Table.IdxList{m})=Table.Volume(m);
% % end
% 
% Nucleus1=Table(Table.Volume<1000,:);
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% Soma=Iba1Perc>96;
% 
% 
% BW=bwconncomp(Soma,6);
% Table=table(cellfun(@numel,BW.PixelIdxList).',BW.PixelIdxList.','VariableNames',{'NumPix','IdxList'}); clear BW;
% Table.Volume=Table.NumPix*prod(Res);
% Table=Table(Table.Volume>50,:);
% 
% Soma=zeros(Pix.','uint16');
% Soma(cell2mat(Table.IdxList))=1;
% 
% % remove holes
% BW=bwconncomp(1-Soma,4);
% Table=table(cellfun(@numel,BW.PixelIdxList).',BW.PixelIdxList.','VariableNames',{'NumPix','IdxList'}); clear BW;
% Table.Volume=Table.NumPix*prod(Res);
% Table=Table(Table.Volume<10*Res(3),:);
% 
% Soma(cell2mat(Table.IdxList))=1;
% % Soma=Soma+imclearborder(1-Soma,4);
% 
% ex2Imaris_2(Soma,Application,'Soma');
% 
% 
% 
% 
% 
% Mask=65535-Iba1;
% Mask(Soma==0)=0;
% Mask(Iba1Corr>prctile(Iba1Corr(:),90))=0;
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% Soma=zeros(Pix.','uint16');
% for m=1:size(Table,1)
%     Soma(Table.IdxList{m})=Table.Volume(m);
% end
% 
% Soma=Soma+imclearborder(1-Soma,4);
% 
% 
% 
% ex2Imaris_2(Soma,Application,'Soma');
% 
% 
% 
% 
% 
% % Nucleus1=Table(Table.Volume<1000,:);
% 
% 
% Mask(Iba1Perc<95)=0;
% 
% 
% 
% 
% 
% 
% Threshold=prctile(Iba1Corr(:),90);
% Mask=Iba1Corr>Threshold;
% 
% Mask(Iba1Perc<95)=0;
% 
% 
% % first make 3D
% BW=bwconncomp(1-Mask,4);
% Table=table(cellfun(@numel,BW.PixelIdxList).',BW.PixelIdxList.','VariableNames',{'NumPix','IdxList'}); clear BW;
% Table.Volume=Table.NumPix*prod(Res);
% Table=Table(Table.Volume>1,:);
% 
% % % % Mask=zeros(Pix.','uint16');
% % % % Mask(cell2mat(Table.IdxList))=1;
% 
% Mask=zeros(Pix.','uint16');
% for m=1:size(Table,1)
%     Mask(Table.IdxList{m})=Table.Volume(m);
% end
% 
% Nucleus1=Table(Table.Volume<1000,:);
% 
% 
% 
% ex2Imaris_2(Mask,Application,'Soma');
% 
% 
% 
% 
% % Window1=[0.3;0.3]./Res(1:2);
% % Window1=round(Window1/2)*2+1;
% % Window1(Window1<3)=3;
% Mask=Mask+imclearborder(1-Mask,4);
% Mask=imerode(Mask,ones(3,3));
% 
% 
% return;
% 
% % get Area dimensions in 2D
% BW=bwconncomp(Outside,4);
% Table=table;
% Table.NumPix=cellfun(@numel,BW.PixelIdxList).';
% Table.IdxList=BW.PixelIdxList.';
% clear BW;
% Res2D=prod(Res(1:2));
% Table.Area=Table.NumPix*Res2D;
% Table=Table(Table.Area>700,:); % previously 1000
% Outside=zeros(size(Outside),'uint16');
% for m=1:size(Table,1)
%     % % %     Outside(Table.IdxList{m})=Table.Area(m);
%     Outside(Table.IdxList{m})=1;
% end
% 
% % Window=[1;1;1]./Res;
% % Window=round(Window/2)*2+1;
% % Window(Window<3)=3;
% Outside=imdilate(Outside,ones(Window2.'));
% Wave1=Data3D<Threshold;
% 
% Outside(Wave1==0)=0;
% 
% 
% % remove holes
% BW=bwconncomp(1-Outside,4);
% Table=table;
% Table.NumPix=cellfun(@numel,BW.PixelIdxList).';
% Table.IdxList=BW.PixelIdxList.';
% clear BW;
% Res2D=prod(Res(1:2));
% Table.Area=Table.NumPix*Res2D;
% Table=Table(Table.Area<5,:); % previously 1000
% for m=1:size(Table,1)
%     Outside(Table.IdxList{m})=1;
% end