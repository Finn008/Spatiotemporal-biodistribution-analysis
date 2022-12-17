function includeAllImarisStatistics(Application,Object)
global W;
% % % % %Remove Similarity Statistics
% % % % %vImarisObject.RemoveStatistics(['Similarity' ' ' vSimilarityStatisticsName]);
for m1=1:10
% % %     mouseMoveController(1);
    
    if exist('Application')==0
        ImarisVersion={'7.7.2','7.6.0'};
        for m=ImarisVersion
            Path=['cd(''C:\Program Files\Bitplane\Imaris x64 ',m{1},'\XT\matlab'');'];
            eval(Path);
            Path=['! ../../Imaris.exe id489745&'];
            eval(Path); pause(5);
            [Control]=subfctSetStatistics();
            pause(2);
            inputemu('key_ctrl','q'); pause(5);
        end
    else
        if exist('Object')==1
            selectObject(Application,Object);
        end
        if Application.GetVisible==0;
            SetInvisible=1;
        else
            Application.SetVisible(0);
            SetInvisible=0;
        end
        inputemu(transpose({'key_down','\WINDOWS';'key_normal','d';'key_up','\WINDOWS'}),1);
        Application.SetVisible(1); pause(0.5); % 1
        Application.SetVisible(0); pause(0.5); % 1
        Application.SetVisible(1); pause(1);
        inputemu('normal',[900,900]); pause(0.5); % 1
        pause(1);
        [Report]=subfctSetStatistics();
        if SetInvisible==1
            Application.SetVisible(0);
        end
    end
% % %     mouseMoveController(0);
    if Report==1
        break;
    end
    pause(m1*10);
end

if Report==0
    keyboard;
end

% keyboard; % show all Statistic values

% if exist('Properties')==0
%     Vobject.AddStatistics(All);
% else
%     Vobject.RemoveStatistics('Acceleration');
%     Vobject.AddStatistics(Properties);
% end
% vImarisObject.AddStatistics(vSimilarityNames, vCentroidSimilarity, vSimilarityUnits, vSimilarityFactors, vSimilarityFactorNames, vSimilarityIds);
% vImarisObject.RemoveStatistics(['Similarity' ' ' vSimilarityStatisticsName]);
% keyboard;
