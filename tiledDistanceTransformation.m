function Distance=tiledDistanceTransformation(Data3D,Res,ResLevels)
ResLevels=table;


ResLevels={  'Res','Tiling','Overlap';...
    1.5,10^9,10;...
    5,0,0;...
    };
ResLevels=array2table(ResLevels(2:end,:),'VariableNames',ResLevels(1,:));



% for 

DistanceFromCore=distanceMat_4(PlaqueCore,{'DistInOut'},Res,1,1,0,0,'uint16',max([min(Res);0.8]));