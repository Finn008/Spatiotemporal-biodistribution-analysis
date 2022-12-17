function [DataOut,Table]=dataNesting_2(DataIn,Type)
BW=bwconncomp(DataIn,6);
Table=table(cellfun(@numel,BW.PixelIdxList).',BW.PixelIdxList.','VariableNames',{'NumPix','PixelIdxList'});
% Table.Volume=Table.NumPix*prod(Res(1:3));

% PlaqueData=[PlaqueData,struct2table(regionprops(BW,'BoundingBox','Centroid','PixelList','SubarrayIdx'))];
Wave1=struct2table(regionprops(BW,'BoundingBox','PixelList'));
Table.BBstart=Wave1.BoundingBox(:,1:3)+0.5;
Table.BBwidth=Wave1.BoundingBox(:,4:6);
Table.PixelList=Wave1.PixelList;
Max=max(Table.BBwidth).';
% Max(3)=9999999999999999; %sum(PlaqueData.BBwidth(:,3));
% %     Vector=[1;Max(1);Max(1)*Max(2)];
Table.Sort1=Table.BBwidth(:,3);
Table.Sort2=Table.BBwidth(:,1);
Table=sortrows(Table,{'Sort1','Sort2'},{'descend','descend'});
Table = removevars(Table, {'Sort1','Sort2'});
Origin=[1;1;1];
Width=Table.BBwidth(1,:).';
for Pl=1:size(Table,1)
    if Origin(2)+Table.BBwidth(Pl,2)-1>Max(2)
        if Origin(1)+Width(1)+Table.BBwidth(Pl,1)-1>Max(1) % choose new Z-layer
            Origin=[1;1;Origin(3)+Width(3)];
            Width=Table.BBwidth(Pl,:).';
        else % choose new X-row
            Origin=[Origin(1)+Width(1);1;Origin(3)];
            Width(1:2)=Table.BBwidth(Pl,1:2).';
        end
    end
    Table.BBvector(Pl,1:3)=Origin.'-Table.BBstart(Pl,1:3);
    Origin(2)=Origin(2)+Table.BBwidth(Pl,2);
%     Table.BBvector=1-Table.BBstart;
%     Wave1=[1;cumsum(Table.BBwidth(1:end-1,3))+1];
%     Table.BBvector(:,3)=Wave1-Table.BBstart(:,3);
%     Wave1=Table.PixelList{Pl,1}+repmat(Table.BBvector(Pl,1:3),[Table.NumPix(Pl),1]);
%     Table.PixelList2{Pl,1}=Wave1;
%     Table.PixelIdxList2{Pl,1}=sub2ind(Max,Wave1(:,1),Wave1(:,2),Wave1(:,3));
end
Max(3)=Origin(3)+Width(3);
% Table.BBstart2=Table.BBstart+Table.BBvector;
for Pl=1:size(Table,1)
    Wave1=Table.PixelList{Pl,1};
    Table.PixelIdxList2{Pl,1}=sub2ind(Max,Wave1(:,1)+Table.BBvector(Pl,1),Wave1(:,2)+Table.BBvector(Pl,2),Wave1(:,3)+Table.BBvector(Pl,3));
end
% keyboard;
DataOut=zeros(Max.',class(DataIn));
DataOut(cell2mat(Table.PixelIdxList2))=DataIn(cell2mat(Table.PixelIdxList));