function satellitePlaqueImage(MouseInfo,NewBornPlaqueList,PlaqueList,PlaqueListSingle)
global W;

Mouse=3;
MouseId=MouseInfo.MouseId(Mouse);
% if strcmp(MouseInfo.TreatmentType(Mouse),'Control'); continue; end;
RoiInfo=MouseInfo.RoiInfo{Mouse,1};

Filename=MouseInfo.RoiInfo{Mouse,1}.Files{1,1}.Filenames{1};
[NameTable,SibInfo]=fileSiblings_3(Filename);
Application=openImaris_2('SatellitePlaques_M336.ims');

FilenameTotalTrace=NameTable.FilenameTotal{'Trace'};
FileinfoTrace=getFileinfo_2(FilenameTotalTrace);
Res=FileinfoTrace.Res{1};
Membership=im2Matlab_3(FilenameTotalTrace,'Membership',FileinfoTrace.GetSizeT(1));
DistInOut=im2Matlab_3(FilenameTotalTrace,'DistInOut',FileinfoTrace.GetSizeT(1));
PlaqueMap=Membership; PlaqueMap(DistInOut>50)=0;


ex2Imaris_2(Membership,Application,'Membership');

%% make distance transformation only for plaques that touch slice 361 (144µm)

Wave1=PlaqueMap(:,:,361);
PlaqueIds=unique(Wave1(:)); PlaqueIds=PlaqueIds(2:end);
PlaqueMap(ismember(PlaqueMap,PlaqueIds)==0)=0;

[Distance,Membership]=distanceMat_4(PlaqueMap,{'DistInOut';'Membership'},Res,1,1,1,50);
ex2Imaris_2(Distance,Application,'DistInOutSlice');
ex2Imaris_2(Membership,Application,'MembershipSlice');
%     ex2Imaris_2(Distance,'SatellitePlaques_M336.ims','DistInOut');

%% further
Make3DImage=0;
if Make3DImage==1
    
    Pix=size(Membership).';
    Array=uint16(logical(Membership));
    NewBornPlaqueList2=NewBornPlaqueList(NewBornPlaqueList.MouseId==MouseId,:);
    for Pl=1:size(NewBornPlaqueList2,1)
        PlId=NewBornPlaqueList2.PlId(Pl);
        PlBirth=NewBornPlaqueList2.PlBirth(Pl);
        PlaqueListSingle2=PlaqueListSingle(PlaqueListSingle.MouseId==MouseId & PlaqueListSingle.PlId==PlId & PlaqueListSingle.Age==PlBirth,:);
        if size(PlaqueListSingle2,1)>1; keyboard; end;
        Distance2ClosestPlaque=PlaqueListSingle2.Distance2ClosestPlaque(1);
        ClosestPlaque=PlaqueListSingle2.ClosestPlaque(1);
        %             ConnectingLine=[];
        Array(Membership==PlId)=round(Distance2ClosestPlaque);
    end
    
    
    %         Projection=Membership;
    [Application]=dataInspector3D(Array,Res);
    %         ClosestDistance=Array;
    %         ClosestDistance(ClosestDistance==1)=0;
    ex2Imaris_2(Array,Application,'ClosestDistance');
    PreExistingPlaques=Array;
    PreExistingPlaques(Array>1)=0;
    ex2Imaris_2(PreExistingPlaques,Application,'PreExistingPlaques');
    NewPlaques=logical(Array);
    NewPlaques(Array==1)=0;
    ex2Imaris_2(NewPlaques,Application,'NewPlaques');
    
end
Projection=max(Membership,[],3);
Pix=size(Projection).';
Array=uint16(logical(Projection));
NewBornPlaqueList2=NewBornPlaqueList(NewBornPlaqueList.MouseId==MouseId,:);
for Pl=1:size(NewBornPlaqueList2,1)
    PlId=NewBornPlaqueList2.PlId(Pl);
    PlBirth=NewBornPlaqueList2.PlBirth(Pl);
    PlaqueListSingle2=PlaqueListSingle(PlaqueListSingle.MouseId==MouseId & PlaqueListSingle.PlId==PlId & PlaqueListSingle.Age==PlBirth,:);
    if size(PlaqueListSingle2,1)>1; keyboard; end;
    Distance2ClosestPlaque=PlaqueListSingle2.Distance2ClosestPlaque(1);
    ClosestPlaque=PlaqueListSingle2.ClosestPlaque(1);
    Array(Projection==PlId)=round(Distance2ClosestPlaque);
end
%     if Make3DImage==1

%     else
Max=150;
Colormap=jet(Max);
Colormap(1,:)=[0,0,0];
Colormap(2,:)=[1,1,1];
Image=gray2rgb_2(Array,Colormap);
%     imshow(Image);

Path2file=[W.G.PathOut,'\SatellitePlaques\'];

Path=[Path2file,MouseInfo.TreatmentType{Mouse},'_M',num2str(MouseInfo.MouseId(Mouse)),'.tif'];
imwrite(Image,Path);
%     end
