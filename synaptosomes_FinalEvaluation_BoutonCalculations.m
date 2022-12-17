function [BoutonData]=synaptosomes_FinalEvaluation_BoutonCalculations(BoutonData)
for Bouton=1:size(BoutonData,1)
    StructureTypes={'Pre';'Post'};
    for StructureID=1:size(StructureTypes,1)
        StructureType=StructureTypes{StructureID};
        
        CalcTypes={'All';'Hwi'};
        for CalcId=1:size(CalcTypes,1)
            CalcType=CalcTypes{CalcId};
            if strcmp(StructureType,'Pre')
                VoxelTable=BoutonData.CenterPlaneVoxels{Bouton,1};
            elseif strcmp(StructureType,'Post')
                VoxelTable=BoutonData.CenterPlaneVoxelsImmuno{Bouton,1};
                if isempty(VoxelTable)
                    BoutonData(Bouton,[StructureType,'ImmunoMean',CalcType])=BoutonData(Bouton,[StructureTypes{1},'ImmunoMean',CalcType]);
                    BoutonData(Bouton,[StructureType,'ImmunoSum',CalcType])=BoutonData(Bouton,[StructureTypes{1},'ImmunoSum',CalcType]);
                    continue;
                end
            end
            
            if strcmp(CalcType,'Hwi')
                VglutGreenThreshold=prctile(VoxelTable.VglutGreen,98)/2; % previously 90th
                VoxelTable=VoxelTable(VoxelTable.VglutGreen>VglutGreenThreshold,:);
                BoutonData(Bouton,[StructureType,'Hwi'])={VglutGreenThreshold};
            end
            
            Wave1=size(VoxelTable,1)*prod(BoutonData.Res{Bouton}(1:2));
            BoutonData(Bouton,[StructureType,'Radius',CalcType])={(Wave1/3.1415)^0.5};
            BoutonData(Bouton,[StructureType,'VglutMean',CalcType])={mean(VoxelTable.VglutGreen)};
            BoutonData(Bouton,[StructureType,'VglutSum',CalcType])={sum(VoxelTable.VglutGreen)};
            BoutonData(Bouton,[StructureType,'VglutRedMean',CalcType])={mean(VoxelTable.VglutRed)};
            BoutonData(Bouton,[StructureType,'ImmunoMean',CalcType])={mean(VoxelTable.Immuno)};
            BoutonData(Bouton,[StructureType,'ImmunoSum',CalcType])={sum(VoxelTable.Immuno)};
        end
    end
end