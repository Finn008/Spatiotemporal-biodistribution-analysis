function visualizeBoutonTypes_2(ObjInfo,Surf,Pl)

% try
%     ObjInfo=ObjInfo(ObjInfo.IntensityMean(:,VariableNames.GRratio)>20,:);
% end

Container=table;
Container.Name(1,1)={[Surf{1},'Number']};
Container.ObjInfo(1,1)={ObjInfo};

Container.Name(2,1)={[Surf{1},'Small']};
Container.ObjInfo(2,1)={ObjInfo(ObjInfo.RadiusX<=0.5,:)};

Container.Name(3,1)={[Surf{1},'Large']};
Container.ObjInfo(3,1)={ObjInfo(ObjInfo.RadiusX>0.5,:)};


for Con=1:size(Container,1)
    ObjInfo=Container.ObjInfo{Con,1};
    Out=Summer_3({[]},{ObjInfo.Distance,ObjInfo.Membership,ObjInfo.Relationship},{[-50],[0],[0]});
    SubRegionNumber=size(Out.SumRes,3);
    for Pl=1:size(Out.RoiIds{2,1},1)
        PlId=num2str(Out.RoiIds{2,1}(Pl,1));
        for Sub=1:SubRegionNumber
            if isempty(DistRelation.Data{PlId,1}.Properties.RowNames)
                DistRelation.Data{PlId,1}.Properties.RowNames=num2strArray_2(DistRelation.Data{PlId,1}.Distance); % remove for newer version
            end
            Distance=(Out.MinMax(1,1):Out.MinMax(1,2)).';
            DistRelation.Data{PlId,Sub}{num2strArray_2(Distance),'Distance'}=Distance;
            Data=Out.SumRes(:,Pl,Sub);
            DistRelation.Data{PlId,Sub}{num2strArray_2(Distance),Container.Name{Con,1}}=Data;
            DistRelation.Data{PlId,Sub}=sortrows(DistRelation.Data{PlId,Sub},'Distance');
        end
    end
end


% Ind=find(SingleStacks.Mouse==Mouse&SingleStacks.Roi==Roi&SingleStacks.TargetTimepoint==Tp);
% Ind=Ind(end);
% Statistics=SingleStacks.Statistics{Ind,1}.Boutons1;
% ObjInfo=Statistics.ObjInfo;
%
% VolumeData=SingleStacks.DistRelation{Ind,1}.Density;
% VolumeData=SingleStacks.DistRelation{Ind,1}{num2str(Pl),'Density'}{1}.Volume;
%
% ObjInfo=ObjInfo(ObjInfo.Membership==Pl&ObjInfo.Relationship<=2,:);
%
% % everything
% Selection=ObjInfo;
% Out=Summer_3({[]},{Selection.DistInOut-50},{[-50],[0],[0]});