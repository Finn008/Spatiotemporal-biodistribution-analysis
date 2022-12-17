function PlaqueListSingle=finalEvaluation_PlaqueClosestDistance_2(PlaqueListSingle)




for Pl=1:size(PlaqueListSingle,1)
    UmCenter=PlaqueListSingle.UmCenter{Pl};
    if isempty(UmCenter) || PlaqueListSingle.RadiusFit1(Pl)==0 || isnan(PlaqueListSingle.RadiusFit1(Pl))
        MinDistance=NaN;
    else
        Time=PlaqueListSingle.Time(Pl);
        MouseId=PlaqueListSingle.MouseId(Pl);
        PlId=PlaqueListSingle.PlId(Pl);
        RoiId=PlaqueListSingle.RoiId(Pl);
        
        Selection=PlaqueListSingle(PlaqueListSingle.Time==Time & PlaqueListSingle.MouseId==MouseId & PlaqueListSingle.RoiId==RoiId & PlaqueListSingle.RadiusFit1>3 & isempty_2(PlaqueListSingle.UmCenter)==0,:);
        Selection(Selection.PlId==PlId,:)=[];
        
        if isempty(Selection)
            MinDistance=NaN;
        else
            [Distance]=xyzDistance(UmCenter,Selection.UmCenter);
            Distance=Distance-PlaqueListSingle.RadiusFit1(Pl)/2-Selection.RadiusFit1/2;
            [MinDistance,ClosestPlaque]=min(Distance);
        end
        %     if MinDistance<=0;keyboard;end;
    end
    PlaqueListSingle.Distance2ClosestPlaque(Pl,1)=MinDistance;
    
    
end