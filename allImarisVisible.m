function allImarisVisible()
global W;

OrigW=W;
cd(['C:\Program Files\Bitplane\Imaris x64 7.7.2\XT\matlab']);
javaaddpath ImarisLib.jar;
ImarisLibrary=ImarisLib;
W=OrigW;
global W;
Server=ImarisLibrary.GetServer;
if isempty(Server)==0
    NumberOfObjects=Server.GetNumberOfObjects;
    for m=0:NumberOfObjects-1
        ObjectID=Server.GetObjectID(m);
        Application=ImarisLibrary.GetApplication(ObjectID);
        Application.SetVisible(1);
    end
end
evalin('caller','global W;');