function allenBrainAtlas()
% Download and unzip the atlasVolume and annotation zip files
% 25 micron volume size
Pix=[528 320 456];
% VOL = 3-D matrix of atlas Nissl volume
Path2file=getPathRaw('AllenBrainAtlas_P56_Mouse_AtlasVolume_25um.raw');
fid=fopen(Path2file,'r','l');
% fid = fopen('atlasVolume/atlasVolume.raw', 'r', 'l' );
Nissl3D=fread(fid,prod(Pix),'uint8');
fclose( fid );
Nissl3D=reshape(Nissl3D,Pix);
% ANO = 3-D matrix of annotation labels
Path2file=getPathRaw('AllenBrainAtlas_P56_Mouse_Annotation_25um.raw');
fid=fopen(Path2file,'r','l');
Atlas3D=fread(fid,prod(Pix),'uint32');
fclose(fid);
Atlas3D=reshape(Atlas3D,Pix);
FilenameTotal='AllenBrainAtlas.ims';
Res=[25;25;25];
ex2Imaris_2(Nissl3D,FilenameTotal,'Nissl',1,Res);
ex2Imaris_2(Atlas3D,FilenameTotal,'Atlas3D',1,Res);
% % Display one coronal section
% figure;imagesc(squeeze(VOL(264,:,:)));colormap(gray);
% figure;imagesc(squeeze(ANO(264,:,:)));colormap(lines);
%  
% % Display one sagittal section
% figure;imagesc(squeeze(ANO(:,:,220)));colormap(lines);
% figure;imagesc(squeeze(VOL(:,:,220)));colormap(gray);