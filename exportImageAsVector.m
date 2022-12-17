function exportImageAsVector(FilenameTotal,Slice)
keyboard; %remove

Data3D=im2Matlab_3(FilenameTotal,'DistInOut');

Slice=Data3D(:,:,79,16);
imshow(Slice);
Wave1=Slice==50;
imshow(Wave1);
Path2file=[W.G.PathOut,'\Unsorted\','Test'];
saveas(Wave1,'Test','tif')
A1=1;