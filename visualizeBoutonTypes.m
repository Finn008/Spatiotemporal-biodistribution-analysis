function visualizeBoutonTypes(SingleStacks,Mouse,Roi,Pl,Tp)

Ind=find(SingleStacks.Mouse==Mouse&SingleStacks.Roi==Roi&SingleStacks.TargetTimepoint==Tp);
Ind=Ind(end);
Statistics=SingleStacks.Statistics{Ind,1}.Boutons1;
ObjInfo=Statistics.ObjInfo;

VolumeData=SingleStacks.DistRelation{Ind,1}.Density;
VolumeData=SingleStacks.DistRelation{Ind,1}{num2str(Pl),'Density'}{1}.Volume;

ObjInfo=ObjInfo(ObjInfo.Membership==Pl&ObjInfo.Relationship<=2,:);

% everything
Selection=ObjInfo;
Out=Summer_3({[]},{Selection.DistInOut-50},{[-50],[0],[0]});