function [Table]=xyzDistanceAmorph_2(Data3D,Res,UmStart)
% PlaqueIDs=unique(Data3D(:));
% PlaqueIDs(PlaqueIDs==0,:)=[];
Pix=size(Data3D).';
% Um=Pix.*Res;
Table=regionprops('table',Data3D,'centroid');
Table.Centroid(:,1:3)=Table.Centroid(:,[2,1,3]);
Table.XYZum(:,1:3)=Table.Centroid.*repmat(Res.',[size(Table,1),1]);
if exist('UmStart')==1
    Table.XYZum=Table.XYZum+repmat(UmStart.',[size(Table,1),1]);
end

for Pl=1:size(Table,1)
    Table2=table;
    Table2.Distance=xyzDistance(Table.XYZum(Pl,:).',Table.XYZum.');
    
    Points=round(sum(Pix.^2)^0.5);
%     Points=100;
    Startpoints=repmat(permute(Table.Centroid(Pl,:),[1,3,2]),[size(Table,1),Points,1]);
    Endpoints=repmat(permute(Table.Centroid,[1,3,2]),[1,Points,1]);
    
    Subscripts=repmat(linspace(0,1,Points),[size(Table,1),1,3]);
%     Subscripts(:,100,:)
    Subscripts=Startpoints+(Endpoints-Startpoints).*Subscripts;
    Subscripts=round(Subscripts);
%     A1=Subscripts(:,:,1);
    
    Wave1=sub2ind(Pix.',Subscripts(:,:,1),Subscripts(:,:,2),Subscripts(:,:,3));
    NanInd=find(isnan(Wave1));
    Wave1(NanInd)=1;
    Wave2=Data3D(Wave1);
    Wave2(NanInd(:))=0;
    for SubPl=1:size(Table2,1)
        Table2.OutsidePlaque(SubPl,1)=sum(ismember(Wave2(SubPl,:).',[Pl;SubPl])==0);
    end
    Table2.OutsidePlaque=Table2.OutsidePlaque/Points;
    Table2.RealDistance=Table2.Distance.*Table2.OutsidePlaque;
    Table2.RealDistance(Pl,1)=NaN;
%     Data3D(Wave1(isnan(Wave1)==0))=1;
    Table.MinDistance(Pl,1)=min(Table2.RealDistance);
    Table.Distances(Pl,1)={Table2(:,{'Distance';'RealDistance'})};
%     [Application]=dataInspector3D(Data3D,Res);
%     keyboard;
end


% A1=Wave2(20,:).';
% A2=size(find(A1(:)==20),1);
% A3=size(find(A1(:)==1),1);
% A4=1475-A2-A3