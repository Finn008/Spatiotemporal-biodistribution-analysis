function [Xmesh,Ymesh,Zmesh]=surfPlotSeparateLines(X,Y,Z,Direction)
% keyboard;

if exist('Direction')~=1
    Direction='X';
end
if strcmp(Direction,'X') % put vertial nan columns
    Xmesh=X.';
    Xmesh(2,end)=0;
    Xmesh=Xmesh(:);
    Zmesh=Z;
    Zmesh=[Zmesh;nan(size(Zmesh))];
    Zmesh=reshape(Zmesh,[size(Z,1),size(Xmesh,1)]);
    Ymesh=Y;
elseif strcmp(Direction,'Y') % put horizontal nan rows
    keyboard;
    Ymesh=Y.';
    Ymesh(2,end)=0;
    Ymesh=Ymesh(:);
    
    Zmesh=Z.';
end



[Xmesh,Ymesh]=meshgrid(Xmesh,Ymesh);