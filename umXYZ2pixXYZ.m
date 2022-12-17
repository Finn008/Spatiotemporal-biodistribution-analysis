function [Table,PixXYZ,Ind]=umXYZ2pixXYZ(UmXYZ,UmStart,UmEnd,Pix,Rotate)


Res=(UmEnd-UmStart)./double(Pix);
SpotNumber=size(UmXYZ,1);
UmStartVector=repmat(UmStart,[SpotNumber,1]);
UmEndVector=repmat(UmEnd,[SpotNumber,1]);
PixVector=repmat(Pix,[SpotNumber,1]);
ResVector=repmat(Res,[SpotNumber,1]);

% XYZind=Statistics{:,{'PositionX','PositionY','PositionZ'}};
PixXYZ=(UmXYZ-UmStartVector)./ResVector;
PixXYZ=uint16(ceil(PixXYZ));
PixXYZ(PixXYZ==0)=1;
for m=1:3
    Wave3=PixXYZ(:,m);
    Wave3(Wave3>PixVector(:,m))=Pix(m);
    PixXYZ(:,m)=Wave3;
end

if exist('Rotate')==1
    if ischar(Rotate)
        Rotate=variableExtract(Rotate,{'X';'Y';'Z'});
    end
    if isstruct(Rotate) && Rotate.Z==180 % rotate along Z
        PixXYZ(:,1)=Pix(1)+1-PixXYZ(:,1);
        PixXYZ(:,2)=Pix(2)+1-PixXYZ(:,2);
    end
end


Ind=sub2ind(Pix,PixXYZ(:,1),PixXYZ(:,2),PixXYZ(:,3)); % PixXYZ=double(PixXYZ); Ind(:,2)=PixXYZ(:,1)+3600*(PixXYZ(:,2)-1)+3600*3600*(PixXYZ(:,3)-1);

Table=table;
Table.PixXYZ=PixXYZ;
Table.Ind=Ind;
