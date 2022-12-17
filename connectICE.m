function connectICE()
cd(['C:\Program Files\Bitplane\Imaris x64 7.7.2\XT\matlab']);
javaaddpath ImarisLib.jar;
vImarisLib=ImarisLib();
Server=vImarisLib.GetServer();
Id=Server.GetObjectID(0);
Conn=IceImarisConnector();
