function [DataOut,Table]=dataNesting(DataIn,Type)
BW=bwconncomp(DataIn,6);
Table=table(cellfun(@numel,BW.PixelIdxList).',BW.PixelIdxList.','VariableNames',{'NumPix','PixelIdxList'});
% Table.Volume=Table.NumPix*prod(Res(1:3));

% PlaqueData=[PlaqueData,struct2table(regionprops(BW,'BoundingBox','Centroid','PixelList','SubarrayIdx'))];
Wave1=struct2table(regionprops(BW,'BoundingBox','PixelList'));
Table.BBstart=Wave1.BoundingBox(:,1:3)+0.5;
Table.BBwidth=Wave1.BoundingBox(:,4:6);
Table.PixelList=Wave1.PixelList;
Max=max(Table.BBwidth);
Max(3)=9999999999999999; %sum(PlaqueData.BBwidth(:,3));
% %     Vector=[1;Max(1);Max(1)*Max(2)];
Table.BBvector=1-Table.BBstart;
Wave1=[1;cumsum(Table.BBwidth(1:end-1,3))+1];
Table.BBvector(:,3)=Wave1-Table.BBstart(:,3);
%     PlaqueData.BBLinearVector=sum(PlaqueData.BBvector.*repmat(Vector.',[size(PlaqueData,1),1]),2);
for Pl=1:size(Table,1)
    Wave1=Table.PixelList{Pl,1}+repmat(Table.BBvector(Pl,1:3),[Table.NumPix(Pl),1]);
    Table.PixelList2{Pl,1}=Wave1;
    Table.PixelIdxList2{Pl,1}=sub2ind(Max,Wave1(:,1),Wave1(:,2),Wave1(:,3));
end

keyboard;
Data3D=zeros(Max,class(DataIn));
Data3D(cell2mat(Table.PixelIdxList2))=DataIn(cell2mat(Table.PixelIdxList));