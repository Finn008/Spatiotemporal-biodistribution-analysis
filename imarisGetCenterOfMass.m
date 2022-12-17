function Statistics=imarisGetCenterOfMass(Application,Object)
Statistics=table;
Vobject=selectObject(Application,Object);
Number=Vobject.GetNumberOfSurfaces;
for m=1:Number
    Statistics.CenterOfMass(m,1:3)=Vobject.GetCenterOfMass(m-1);
end
% Statistics=array2table([Wave1,Wave2],'VariableNames',{'PositionX';'PositionY';'PositionZ';'RadiusX';'RadiusY';'RadiusZ'});

