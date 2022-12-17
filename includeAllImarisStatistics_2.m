function includeAllImarisStatistics_2(Application,Object)
% % % % %Remove Similarity Statistics
keyboard; %does not work yet
Object.RemoveStatistics(['Area']);
Object.RemoveStatistics(['Similarity' ' ' vSimilarityStatisticsName]);






[Vobject,Ind,ObjectList]=selectObject(Application,Object);


return;
pause(1);
if exist('Application')==0
    ImarisVersion={'7.7.2','7.6.0'};
    for m=ImarisVersion
        Path=['cd(''C:\Program Files\Bitplane\Imaris x64 ',m{1},'\XT\matlab'');'];
        eval(Path);
        Path=['! ../../Imaris.exe id489745&'];
        eval(Path); pause(5);
        subfctSetStatistics(); pause(2);
        inputemu('key_ctrl','q'); pause(5);
    end
else
    if exist('Object')==1
        selectObject(Application,Object);
    end
    if Application.GetVisible==0;
        Application.SetVisible(1); pause(3);
        SetInvisible=1;
    else
        SetInvisible=0;
    end
    subfctSetStatistics()
    if SetInvisible==1
        Application.SetVisible(0);
    end
end

function subfctSetStatistics()
inputemu('key_ctrl','p'); pause(3);
inputemu(repmat({'key_normal';'\DOWN'},[1,10]),1); pause(1);
inputemu('key_normal','\TAB'); pause(1);
inputemu('key_normal',' '); pause(2); % uncheck or check all Cells statistics
inputemu('key_normal','\RIGHT'); pause(1);
inputemu('key_normal','\DOWN'); pause(1); % opposite check for one Cells statistics value
inputemu('key_normal',' '); pause(1); % check all
inputemu('key_normal','\TAB'); pause(1);
inputemu('key_normal',' '); pause(1); % check all
inputemu('key_normal','\ENTER'); pause(1);