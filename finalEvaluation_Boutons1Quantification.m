function [MouseInfo,PlaqueListBoutons1]=finalEvaluation_Boutons1Quantification(TimeDistTable,MouseInfo)

PlaqueList=table;

Loop=struct('Ind',0,'Selection',[]);
while Loop.Ind>=0
    Loop=struct('Type','TimeDistTable','TimeDistTable',TimeDistTable,'MouseInfo',MouseInfo,'Ind',Loop.Ind,'Selection',Loop.Selection,'Restriction',{{'Mod','Boutons1Number';'Sub',1}}); % switch Sub back to 1
    [Loop]=looper(Loop);
    if Loop.Ind<0; break; end
    % calculate density between 0 and 10µm from plaque border compared to 20-40
    BoutonDensityFar=nanmean(Loop.Data(71:91,:));
    BoutonDensityClose=nanmean(Loop.Data(51:61,:));
    Factor=BoutonDensityClose./BoutonDensityFar;
    
    Wave1=table(BoutonDensityClose.',BoutonDensityFar.',Factor.','VariableNames',{'BoutonDensityClose','BoutonDensityFar','BoutonFactor'});
    Loop.PlaqueData(Loop.NanCols,{'BoutonDensityClose','BoutonDensityFar','BoutonFactor'})=Wave1(Loop.NanCols,:);
    Loop.PlaqueData.Radius(cellfun(@isempty,Loop.PlaqueData.XYZCenter))=NaN;
    MouseInfo.RoiInfo{Loop.Mouse,1}.TraceData{Loop.RoiData,1}.Data{Loop.Pl,1}=Loop.PlaqueData;
% % %     keyboard; % normalize  with BoutonDensityFar
    [PlaqueList]=generatePlaqueList(PlaqueList,Loop.PlaqueData,Loop,MouseInfo,{'BoutonDensityClose';'BoutonDensityFar';'BoutonFactor'});
    
end

keyboard;
OrigPlaqueList=PlaqueList;

PlaqueList(PlaqueList.BorderTouch==1 |...
    isnan(PlaqueList.Radius) |...
    isnan(PlaqueList.BoutonFactor)|...
    PlaqueList.BoutonFactor==0,:)=[];
PlaqueList.BoutonFactor(PlaqueList.BoutonFactor==inf)=NaN;

Wave1=find(isnan(PlaqueList.DistRel(:,2))==0);
if isempty(Wave1)==0
    PlaqueList(Wave1,:)=[];
end

processTraceGroups(PlaqueList,'Boutons1');


PlaqueListBoutons1=PlaqueList;