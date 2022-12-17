% show for each plaque the radius as an excel table
function finalEvaluation_ShowPlaqueGrowth(PlaqueList)
Table=PlaqueList;


for m=1:size(Table,1)
    Wave1=Table.PlaqueListSingle{m}.Radius;
    Radius=nan(25,1);
    Radius(1:size(Wave1,1),1)=Wave1;
    Table.Radius(m,1:size(Radius,1))=Radius.';
end

Table=Table(:,{'MouseId','RoiId','Pl','TreatmentType','PlRadPerWeek','StartTreatmentNum','PlBirth','Timepoints','Radius'});

ex2ex_2(Table);
return;
MouseIds=unique(PlaqueList.MouseId);
for Mouse=1:size(MouseIds)
    MouseId=MouseIds(Mouse);
    
    Selection1=PlaqueList(PlaqueList.MouseId==MouseId,:);
    
    
    IndAdd=size(Table,1)+1;
    Table.MouseId(IndAdd,1)=MouseId;
    Table.RoiId(IndAdd,1)=RoiId;
    Table.Pl(IndAdd,1)=PlId;
    Radius=nan(25,1);
    Radius(1:size(Selection3,1),1)=Selection3.Radius;
    Table.Radius(IndAdd,1:size(Radius,1))=Radius.';
    
    
    Rois=unique(Selection1.RoiId);
    for Roi=1:size(Rois,1)
        RoiId=Rois(Roi);
        Selection2=Selection1(Selection1.RoiId==RoiId,:);
        Plaques=unique(Selection2.Pl);
        for Pl=1:size(Plaques,1)
            PlId=Plaques(Pl);
            Selection3=Selection2(Selection2.Pl==PlId,:);
            
            IndAdd=size(Table,1)+1;
            Table.MouseId(IndAdd,1)=MouseId;
            Table.RoiId(IndAdd,1)=RoiId;
            Table.Pl(IndAdd,1)=PlId;
            Radius=nan(25,1);
            Radius(1:size(Selection3,1),1)=Selection3.Radius;
            Table.Radius(IndAdd,1:size(Radius,1))=Radius.';
            
            
            
            
        end
    end
end


