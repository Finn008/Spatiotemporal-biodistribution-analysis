function finalEvaluation_VolumeDistribution_2(MouseInfo,MouseInfoTime)
global W;

Groups={[314;336;341;353;375],{'Vehicle'},[0.5;0.5;0.5];...
    [318;331;346;347;371],{'NB-360_5Sel'},[0;0;0];...
    [275;331;346;347;371],{'NB-360_5Sel2'},[0;0;0];...
    [275;279;280;318;331;346;347;349;351;371],{'NB-360_All'},[0;0;0];...
    };
Groups=array2table(Groups,'VariableNames',{'MouseIds';'Description';'Color'});
Path2file=[W.G.PathOut,'\SurfacePlots\VolumeDistribution\'];

Zaxis=(0:20:100).';
finalEvaluation_VolumeDistribution_Diagram('Vehicle_Vs_NB360sel2',MouseInfoTime,MouseInfo,Groups([1;3],:),1,[-20;200],7,[-28;77],Zaxis,Path2file);

