function [PlaqueData]=finalEvaluationSub8(PlaqueData,SibInfo)

PathTotalResults=[SibInfo.FamilyName,'_RatioResults.mat'];
[PathTotalResults,Report]=getPathRaw(PathTotalResults);
TotalResults=load(PathTotalResults);
TotalResults=TotalResults.TotalResults;

for Pl=1:size(PlaqueData,1)
    PlaqueData.Single(Pl,1)=TotalResults.TracePlaqueData.Data(Pl,1);
end