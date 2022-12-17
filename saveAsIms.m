function saveAsIms(data5D,pathSaveAs,UmMinMax)
global w;
croplimitsmax(1,1:5)=[size(data5D,1),size(data5D,2),size(data5D,3),size(data5D,4),size(data5D,5)];
[application]=P0237_2(w.pathImarisSample,[],croplimitsmax,[],'7.6.0');
if strcmp(w.DoReport,'success')==0; return; end;
% if strcmp(report,'file loaded')==0; w.DoReport=report; return; end;
vDataSetIn=application.GetDataSet;
vDataSetIn.SetExtendMaxX(UmMinMax(1,2)); vDataSetIn.SetExtendMaxY(UmMinMax(2,2)); vDataSetIn.SetExtendMaxZ(UmMinMax(3,2));
vDataSetIn.SetExtendMinX(UmMinMax(1,1)); vDataSetIn.SetExtendMinY(UmMinMax(2,1)); vDataSetIn.SetExtendMinZ(UmMinMax(3,1));

for indT=1:size(data5D,5);
    disp('indT '); disp(indT);
    for indC=1:size(data5D,4);
        Ex2Imaris(application,data5D(:,:,:,indC,indT),indC,indT)
    end
end

% application.SetVisible(1);


application.FileSave(pathSaveAs,'writer="Imaris5"');
% application.Quit;
quitImaris(application);
clear application;