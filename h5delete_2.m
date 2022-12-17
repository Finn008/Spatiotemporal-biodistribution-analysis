function h5delete_2(Path2file,Location)

fileattrib(Path2file,'+w');
Fid=H5F.open(Path2file,'H5F_ACC_RDWR','H5P_DEFAULT');
Gid=H5G.open(Fid,Location);
H5A.delete(Gid,'ImageSizeZ');
H5G.close(Gid);
H5F.close(Fid);
% srcFile = fullfile(matlabroot,'toolbox','matlab','demos','example.h5');
% copyfile(srcFile,'myfile.h5');
% fileattrib('myfile.h5','+w');
% fid = H5F.open('myfile.h5','H5F_ACC_RDWR','H5P_DEFAULT');
% gid = H5G.open(fid,'/');
% H5A.delete(gid,'attr1');
% H5G.close(gid);
% H5F.close(fid);

Location='/DataSet/ResolutionLevel 0/TimePoint 0';
Gid=H5G.open(Fid,Location);
H5A.delete(Gid,'Channel 4');
H5G.close(Gid);
H5F.close(Fid);