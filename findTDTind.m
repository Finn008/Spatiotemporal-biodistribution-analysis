function [Ind,Present]=findTDTind(TimeDistTable,MouseId,RoiId,Sub,Mod,PlId,Calc)

if isempty(TimeDistTable)
    Ind=1;
    return;
end
if isstruct(MouseId)
    Calc=MouseId.Calc;
    PlId=MouseId.Pl;
    Mod=MouseId.Mod;
    Sub=MouseId.Sub;
    RoiId=MouseId.Roi;
    MouseId=MouseId.Mouse;
end

Ind=find(TimeDistTable.MouseId==MouseId...
    & TimeDistTable.RoiId==RoiId...
    & TimeDistTable.SubPool==Sub...
    & TimeDistTable.PlId==PlId...
    & strcmp(TimeDistTable.Mod,Mod)...
    & strcmp(TimeDistTable.Calc,Calc)...
    );
if isempty(Ind)
    Ind=size(TimeDistTable,1)+1;
    Present=0;
else
    Present=1;
end


