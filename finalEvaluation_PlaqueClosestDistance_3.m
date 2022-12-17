function PlaqueListSingle=finalEvaluation_PlaqueClosestDistance_3(PlaqueListSingle)

for Pl=1:size(PlaqueListSingle,1)
%     Pl=5266;
    MinDistance=NaN;
    ClosestPlaque=NaN;
    MinCenter2Center=NaN;
    if isnan(PlaqueListSingle.Radius(Pl))==0 && (PlaqueListSingle.Radius(Pl)~=0 & isnan(PlaqueListSingle.Radius(Pl))==0)
        
        Time=PlaqueListSingle.Time(Pl);
        MouseId=PlaqueListSingle.MouseId(Pl);
        PlId=PlaqueListSingle.PlId(Pl);
        RoiId=PlaqueListSingle.RoiId(Pl);
        
        Selection=PlaqueListSingle(PlaqueListSingle.Time==Time...
            & PlaqueListSingle.MouseId==MouseId...
            & PlaqueListSingle.RoiId==RoiId...
            & (PlaqueListSingle.RadiusFit1>3 & isnan(PlaqueListSingle.Radius)==0 | (isnan(PlaqueListSingle.RadiusFit1) & PlaqueListSingle.Radius>3))...
            & isempty_2(PlaqueListSingle.UmCenter)==0,:);
        Selection(Selection.PlId==PlId,:)=[];
        if size(Selection,1)>0
            Distance=PlaqueListSingle.Distances{Pl}.RealDistance(Selection.PlId);
            [MinDistance,Ind]=min(Distance);
            ClosestPlaque=Selection.PlId(Ind);
            Distance=PlaqueListSingle.Distances{Pl}.Distance(Selection.PlId);
            MinCenter2Center=min(Distance);
        end
%     else
%         keyboard;
    end
    PlaqueListSingle.ClosestPlaque(Pl,1)=ClosestPlaque;
    PlaqueListSingle.Distance2ClosestPlaque(Pl,1)=MinDistance;
    PlaqueListSingle.MinCenter2Center(Pl,1)=MinCenter2Center;
end
% keyboard;