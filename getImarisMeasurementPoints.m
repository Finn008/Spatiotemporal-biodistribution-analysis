function [Data]=getImarisMeasurementPoints(Application,Object)

[MeasurementPoints,Ind,ObjectList]=selectObject(Application,Object);

MeasurementPoints=Application.GetFactory.ToMeasurementPoints(Application.GetSurpassSelection);
Values=MeasurementPoints.Get;
Positions = Values.mPositionsXYZ;
IndicesT = Values.mIndicesT;
Names = Values.mNames;

Data=table;
Data.XYZ=Positions;
Data.Time=IndicesT;
