% requires only MetRedPerc
function [Surface]=ratioPlaque_DetermineOutside(FilenameTotalRatioB,FitCoefCorr,ReplaceExisting)

global W;

FileinfoRatioB=getFileinfo_2(FilenameTotalRatioB);
Res=FileinfoRatioB.Res{1};
Um=FileinfoRatioB.Um{1};
Pix=FileinfoRatioB.Pix{1};

[Surface]=im2Matlab_3(FilenameTotalRatioB,'MetRedPerc');
Surface=Surface>90;
Surface=imerode(Surface,ones(3,3)); % 449
BW=bwconncomp(Surface,6);

Table=table;
Table.NumPix=cellfun(@numel,BW.PixelIdxList).';
Table.IdxList=BW.PixelIdxList.';
Table.Volume=Table.NumPix*prod(Res(1:3));
Wave1=find(Table.Volume>=50&Table.Volume<=1000);
Table=Table(Wave1,:);
BW.PixelIdxList=BW.PixelIdxList(1,Wave1);
BW.NumObjects=size(Wave1,1);
Center=regionprops(BW,'Centroid');
Center={Center.Centroid}.';

for m=1:size(Table,1)
    Table.XYZpix(m,1:3)=[Center{m,1}(2),Center{m,1}(1),Center{m,1}(3)];
    Table.XYZum(m,1:3)=Table.XYZpix(m,1:3).*Res.';
end

if exist('ReplaceExisting')~=1
    Path=[W.G.PathOut,'\DetermineOutside\DetermineOutside_',FilenameTotalRatioB,'.avi'];
    J=struct('XYZdata',Table.XYZum,'Type','MeshDensity','MoviePath',Path,'Um',Um,'PlaneDistance',10,'DepthStep',5,'FitModel','SinusBrain');
    try; J.FitCoefCorr=FitCoefCorr; end;
    [Results,Con]=letCurtainFall_3(J);
    Container=Con; Container.Results=Results;
    Path=[FilenameTotalRatioB,'_Outside.mat'];
    Path=getPathRaw(Path);
    save(Path,'Container');
else
    Path=[FilenameTotalRatioB,'_Outside.mat'];
    Path=getPathRaw(Path);
    load(Path,'Container');
    Results=Container.Results;
end



% ratioPlaque_DetermineOutside_PlaceData(Results,Um,Pix,Res);

% function ratioPlaque_DetermineOutside_PlaceData(Results,Um,Pix,Res)

Curve=feval(Results.Fit{end,1},repmat(linspace(0,Um(1),100).',[1,100]),repmat(linspace(0,Um(2),100),[100,1]));
Curve=imresize(Curve,[Pix(1),Pix(2)],'bilinear');
Curve=uint16(Curve/Res(3));
Curve=Curve-round(3/Res(3));
if min(Curve(:))<1
    W.ErrorMessage='Curtain is below dataset';
    A1=asdf;
end

Wave1=sortrows(Results.Table{end,1},'Order','ascend');
Table(:,{'ZDistAbs','MinDist','Weight','ZDist','Order'})=Wave1(1:size(Table,1),{'ZDistAbs','MinDist','Weight','ZDist','Order'});
Surface=zeros(Pix(1),Pix(2),Pix(3),'uint8');
ShowSelectedSpots=1;
if ShowSelectedSpots==1
    for m=1:size(Table,1)
        Surface(Table.IdxList{m,1})=1;
    end
end


for X=1:Pix(1)
    for Y=1:Pix(2)
        Surface(X,Y,Curve(X,Y):end)=Surface(X,Y,Curve(X,Y):end)+2; %             Surface(X,Y,Curve(X,Y):end)=Surface(X,Y,Curve(X,Y):end)-2;
    end
end


ex2Imaris_2(Surface,FilenameTotalRatioB,'Outside');
