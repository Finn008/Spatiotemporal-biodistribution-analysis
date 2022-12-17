function [MetBlue]=wholeSliceQuantification_Tilting(MetBlue,Pix,Res,Inside)


[Range]=gridding3D(Pix,Res,[100;100]);

Table=table;
for X=Range{1}.'
    for Y=Range{2}.'
        Ind=size(Table,1)+1;
        XYpix=[round(mean(X));round(mean(Y))];
        Table.XYZpix(Ind,1:2)=XYpix.';
        Table.XYZum(Ind,1:2)=XYpix.*Res(1:2);
        Table.Inside(Ind,1)=Inside(XYpix(1),XYpix(2));
        if Table.Inside(Ind,1)==0
            continue;
        end
        Wave1=MetBlue(X(1):X(2),Y(1):Y(2),:);
        Wave1=median(median(Wave1,1),2);
        Wave1=permute(Wave1,[3,2,1]);
        [~,StartEnd]=max(diff(Wave1));
        [~,StartEnd(2,1)]=max(diff(flip(Wave1)));
        Table.StartEnd(Ind,1:2)=StartEnd.';
    end
end
Table(Table.Inside==0,:)=[];
Table.XYZpix(:,3)=Table.StartEnd(:,2);

[MetBlue]=brainSliceTilting(MetBlue,Table.XYZpix,Res,'Loess');
