function [DataOut,Table]=dataNesting_3(DataIn,Type,ConnComp,Res)
if exist('ConnComp','Var')~=1
    ConnComp='LogicalData';
end
if strcmp(ConnComp,'LogicalData')
    BW=bwconncomp(DataIn,6);
elseif strcmp(ConnComp,'BW')
    BW=DataIn;
else
    keyboard;
end
Table=table(cellfun(@numel,BW.PixelIdxList).',BW.PixelIdxList.','VariableNames',{'NumPix','PixelIdxList'});
% DataIn=labelmatrix(BW);
    
Wave1=struct2table(regionprops(BW,'BoundingBox','PixelList'));
Table.BBstart=Wave1.BoundingBox(:,1:3)+0.5;
Table.BBwidth=Wave1.BoundingBox(:,4:6);
Table.PixelList=Wave1.PixelList;
% Max=[NaN;512;33]; %[33344;512;33]; % 2048;2048;33
if strcmp(Type,'Compact') % plaques are stacked below each other
    Gap=ceil([5;5;5]./Res);
    PixDataOut=max(Table.BBwidth).'+Gap;
    PixDataOut(3)=NaN;
    Table.Sort1=Table.BBwidth(:,3);
    Table.Sort2=Table.BBwidth(:,1);
elseif strcmp(Type,'SortVolumeInPlane')
    PixDataOut=[NaN;512;max(Table.BBwidth(:,3))];
    Table.Sort1=Table.NumPix;
    Table.Sort2=Table.BBwidth(:,1);
else
    keyboard;
end
Table=sortrows(Table,{'Sort1','Sort2'},{'descend','descend'});
Table = removevars(Table, {'Sort1','Sort2'});
Origin=[1;1;1];
Width=Table.BBwidth(1,:).';
for Pl=1:size(Table,1)
    if Pl/1000==round(Pl/1000); disp(['First loop Pl: ',num2str(Pl)]); end;
    if Origin(2)+Table.BBwidth(Pl,2)+Gap(2)-1>PixDataOut(2)
        if Origin(1)+Width(1)+Table.BBwidth(Pl,1)+Gap(1)-1>PixDataOut(1) % choose new Z-layer
            Origin=[1;1;Origin(3)+Width(3)+Gap(3)];
            Width=Table.BBwidth(Pl,:).';
        else % choose new X-row
            Origin=[Origin(1)+Width(1)+Gap(1);1;Origin(3)];
%             Width(1:2)=Table.BBwidth(Pl,1:2).';
        end
    elseif Origin(1)+Table.BBwidth(Pl,1)+Gap(1)-1>PixDataOut(1) % choose new Z-layer
        Origin=[1;1;Origin(3)+Width(3)];
        Width=Table.BBwidth(Pl,:).';
    end
    Width=max([Width,Table.BBwidth(Pl,:).'],[],2);
    Table.BBvector(Pl,1:3)=Origin.'-Table.BBstart(Pl,1:3);
    Origin(2)=Origin(2)+Table.BBwidth(Pl,2)+Gap(2);
end
Wave1=find(isnan(PixDataOut));
PixDataOut(Wave1)=Origin(Wave1)+Width(Wave1);
% PixDataOut(3)=Origin(3)+Width(3);
for Pl=1:size(Table,1)
    if Pl/1000==round(Pl/1000); disp(['Second loop Pl: ',num2str(Pl)]); end;
    Wave1=Table.PixelList{Pl,1};
    Wave1=Wave1+repmat(Table.BBvector(Pl,:),[size(Wave1,1),1]);
    Table.PixelIdxList2{Pl,1}=sub2ind(PixDataOut,Wave1(:,1),Wave1(:,2),Wave1(:,3));
%     Table.PixelIdxList2{Pl,1}=sub2ind(PixDataOut,Wave1(:,1)+Table.BBvector(Pl,1),Wave1(:,2)+Table.BBvector(Pl,2),Wave1(:,3)+Table.BBvector(Pl,3));
end
BW.ImageSize=PixDataOut.';
BW.PixelIdxList=Table.PixelIdxList2.';
DataOut=labelmatrix(BW);

% DataOut=zeros(PixDataOut.',class(DataIn));
% DataOut(cell2mat(Table.PixelIdxList2))=DataIn(cell2mat(Table.PixelIdxList));