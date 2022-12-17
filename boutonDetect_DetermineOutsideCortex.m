function [Outside]=boutonDetect_DetermineOutsideCortex(Fileinfo,VglutRed)
global W;
Res=Fileinfo.Res{1};
Pix=Fileinfo.Pix{1};
Um=Fileinfo.Um{1};
FilenameTotal=Fileinfo.FilenameTotal{1};

[Range]=gridding3D(Pix,Res,[10;10]);

Table=table;
for X=Range{1}.'
    for Y=Range{2}.'
        Ind=size(Table,1)+1;
        Table.X(Ind,1)=mean(X);
        Table.Y(Ind,1)=mean(Y);
        Wave1=VglutRed(X(1):X(2),Y(1):Y(2),:);
        Wave1=mean(mean(Wave1,1),2);
%         Wave1=double(median(median(Wave1,1),2));
        for m=1:5
            Wave1=smooth(Wave1(:),20);
        end
        Wave1=flip(Wave1)/max(Wave1(:));
        Wave2=find(Wave1>0.5,1);
        if Wave2>1
            Table.Z(Ind,1)=size(Wave1,1)-Wave2+1;
        end
    end
end
Table(Table.Z==0,:)=[];
Table.X=Table.X*Res(1);
Table.Y=Table.Y*Res(2);
Table.Z=Table.Z*Res(3);


Path=[W.G.PathOut,'\Unsorted\Outside_',Fileinfo.Filename{1},'.avi'];
J=struct('Table',Table,'Type','MeshDensity','MoviePath',Path,'Um',Um,'PlaneDistance',5,'Pix',Pix,'Surface',1,'EnhanceDenseSpots',0,'DepthStep',0);
[Results,Con,Outside]=letCurtainFall_VglutRed(J);
Container=Con; Container.Results=Results;
Path=[Fileinfo.FilenameTotal{1},'_Outside.mat'];
Path=getPathRaw(Path);
save(Path,'Container');
% Outside=Con.Data3D;