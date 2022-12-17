function [PlaqueList]=generatePlaqueList(PlaqueList,PlaqueData,Loop,MouseInfo,SpecialColNames)

Wave1=PlaqueData(:,[{'Radius';'BorderTouch'};SpecialColNames]);
Wave1.MouseId(:,1)=Loop.MouseId;
Wave1.Mouse(:,1)=Loop.Mouse;
Wave1.Roi(:,1)=Loop.Roi;
Wave1.Pl(:,1)=Loop.Pl;
Wave1.Tp(:,1)=(1:size(Wave1,1)).';
Wave1.TreatmentStart=Loop.Age(1:size(Wave1,1))-Loop.TimeSections(1,2);
Wave1.TreatmentStart(Wave1.TreatmentStart<0)=0;
Wave1.TreatmentType(:,1)=MouseInfo.TreatmentType(Loop.Mouse,1);
Wave1.DistRel=Loop.Data(:,1:size(Wave1,1)).';
Wave1.DistRelVolume=Loop.VolumeData(:,1:size(Wave1,1)).';
PlaqueList=[PlaqueList;Wave1];