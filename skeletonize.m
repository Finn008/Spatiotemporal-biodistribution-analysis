function [Links,Nodes,TrackMap,LinkMap]=skeletonize(Skeleton)
% Skeleton=bwskel(Skeleton);
[Adjacency,Nodes,Links]=Skel2Graph3D(Skeleton,0);
Nodes=struct2table(Nodes);
Nodes.Properties.VariableNames={'Idx';'Links';'Conn';'Comx';'Comy';'Comz';'Ep';'Label'};
Links=struct2table(Links);
Links.Properties.VariableNames={'N1';'N2';'Idx';'Label'};
Links.NumPix=cellfun(@numel,Links.Idx);

for Link=1:size(Links,1)
    Links.Endpoint(Link,1:2)=Nodes.Ep([Links.N1(Link),Links.N2(Link)]).';
    Links.Idx{Link,1}=Links.Idx{Link,1}(2:end-1).';
end
Links.Endpoint=sum(Links.Endpoint,2);

% some Objects are missing
Objects=unique([Nodes.Label;Links.Label]);
clear Wave1; Wave1(Objects,1)=1:size(Objects,1);
Links.Label=Wave1(Links.Label);
Nodes.Label=Wave1(Nodes.Label);

% put together LinkMap
BW=struct('Connectivity',26,'ImageSize',size(Skeleton),'NumObjects',size(Links,1));
BW.PixelIdxList=Links.Idx.';
LinkMap=labelmatrix(BW);

% put together data stack of connected tracks
clear Wave1;
for Obj=1:size(Objects,1)
    Wave1(1,Obj)={[cell2mat(Nodes.Idx(Nodes.Label==Obj));cell2mat(Links.Idx(Links.Label==Obj))]};
end
BW=struct('Connectivity',26,'ImageSize',size(Skeleton),'NumObjects',size(unique(Nodes.Label),1));
BW.PixelIdxList=Wave1;
TrackMap=labelmatrix(BW);
