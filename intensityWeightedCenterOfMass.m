function [Table]=intensityWeightedCenterOfMass(RegionMap,IntensityData)
global OrigTable;
Pix=size(RegionMap).';
Table=table;
Table.Region=unique(RegionMap(:));
Table(Table.Region==0,:)=[];

Table2=table;
Table2.Indices=find(RegionMap~=0);
Table2.Intensities=double(IntensityData(Table2.Indices));
Table2.Intensities(Table2.Intensities==0)=0.5;
Table2.RegionId=RegionMap(Table2.Indices);
[Table2.Coordinates,Table2.Coordinates(:,2),Table2.Coordinates(:,3)]=ind2sub(Pix.',Table2.Indices);


for Region=1:size(Table,1)
    Wave1=Table2(Table2.RegionId==Table.Region(Region),:);
    Table.CenterOfIntensityMass(Region,1:3)=sum(Wave1.Coordinates.*repmat(Wave1.Intensities,[1,3]),1)./sum(Wave1.Intensities,1);
end


% for Region=1:size(Table,1)
%     Indices=find(RegionMap==Table.Region(Region));
%     [Coordinates,Coordinates(:,2),Coordinates(:,3)]=ind2sub(Pix.',Indices);
%     Intensities=IntensityData(Indices);
%     
%     for XYZ=1:3
%         Table.CenterOfIntensityMass(Region,XYZ)=sum(Coordinates(:,XYZ).*double(Intensities))/sum(Intensities,1);
%     end
%     
%     
% end
