function [Xmesh,Ymesh,Zmesh]=surfPlotSeparateLines_2(X,Y,Z,Direction)
% keyboard;

if exist('Direction')~=1
    Direction='Vertical';
end

if strcmp(Direction,'Vertical') % put vertial nan columns
    Ymesh=Y.';
    Ymesh(2,end)=0;
    Ymesh=Ymesh(:);
    Zmesh=nan(size(X,1),size(Ymesh,1),size(Z,3));
    Ind=(1:2:size(Ymesh,1)-1).';
    Zmesh(:,Ind,:)=Z;
    Xmesh=X;
elseif strcmp(Direction,'Horizontal') % put horizontal nan rows
    Xmesh=X.';
    Xmesh(2,end)=0;
    Xmesh=Xmesh(:);
    Zmesh=nan(size(Xmesh,1),size(Y,1),size(Z,3));
    Ind=(1:2:size(Xmesh,1)-1).';
    Zmesh(Ind,:,:)=Z;
    Ymesh=Y;
end



[Xmesh,Ymesh]=meshgrid(Ymesh,Xmesh);