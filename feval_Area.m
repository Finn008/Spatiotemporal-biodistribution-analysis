function [Area,Edge]=feval_Area(Fit,Pix,SpotNumber)

if exist('SpotNumber') && isempty(SpotNumber)==0
    Edge=(Pix(1)*Pix(2)/SpotNumber)^0.5;
else
    Edge=1;
end

X=round(linspace(1,Pix(1),Pix(1)/Edge)).';
Y=round(linspace(1,Pix(2),Pix(2)/Edge)).';
% Y=round(linspace(1,Pix(2),Pix(2)/Edge)).';
    

XY=repmat(X,[size(Y,1),1]);
Y=repmat(Y.',[size(X,1),1]);
XY(:,2)=Y(:);

Z=Fit(XY);

Z=reshape(Z,[size(X,1),size(Y,2)]);
Area=imresize(Z,[Pix(1),Pix(2)],'bilinear');

return;

    

XY=repmat(X,[size(Y,1),1]);
Y=repmat(Y.',[size(X,1),1]);
XY(:,2)=Y(:);

Z=Fit(XY);

LinInd=sub2ind(Pix(1:2),XY(:,1),XY(:,2));
Area=zeros(Pix(1),Pix(2));
Area(LinInd)=1;
[Distance,Idx]=bwdist(Area,'quasi-euclidean');
for m=1:size(LinInd,1)
    Area(Idx==LinInd(m))=Z(m);
end
ex2Imaris_2(Area,Application,'Area');  
    
[Application]=dataInspector3D(Distance,'Distance');




Curve=feval(Results.Fit{end,1},repmat(linspace(0,Um(1),100).',[1,100]),repmat(linspace(0,Um(2),100),[100,1]));
    
    Curve=uint16(Curve/Res(3));
%     Curve=Curve-round(3/Res(3));
    
    Data3D=zeros(Pix(1),Pix(2),Pix(3),'uint8');
    Table.Pix=round([Table.X/Res(1),Table.Y/Res(2),Table.Z/Res(3)]);
    for X=1:Pix(1)
        for Y=1:Pix(2)
            %             Data3D(X,Y,Curve(X,Y))=1;
            Data3D(X,Y,Curve(X,Y):end)=1;
        end
    end
    if Surface==2
        for m=1:size(Table,1)
            Data3D(Table.Pix(m,1),Table.Pix(m,2),Table.Pix(m,3))=255;
        end
    end