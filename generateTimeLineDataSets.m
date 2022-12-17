function generateTimeLineDataSets(MouseInfo,PlaqueListSingle)
global W;

%% generate satellite plaque image via imaris
for MouseId=341 % [312;348;369;370;372;374;377;381;384;9347;314;336;341;353;375].'
    Mouse=find(MouseInfo.MouseId==MouseId);
    RoiInfo=MouseInfo.RoiInfo{Mouse,1};
    Filename=MouseInfo.RoiInfo{Mouse,1}.Files{1,1}.Filenames{1,1};
    [FileList,Output]=spatialRelation(Filename);
    FileList=table;
    FileList.Filenames=MouseInfo.RoiInfo{Mouse,1}.Files{1,1}.Filenames;
    FileList.RoiId(:,1)=1;
    FileList.MouseId(:,1)=MouseId;
    FileList.PlId(:,1)=1;
    FileList.Time(:,1)=(1:size(FileList,1)).';
    FileList.UmCenter(:,1)={[0;0;0]};
    dystrophyDetection_visualizeIndividualPlaques_4(MouseInfo,FileList,struct('Version',[12],'ImageGeneration',{{'ImarisStack'}},'TargetFolder','TimeLineStacks'));
    keyboard;
    
    
    
    
    
    
    
    
    
    FilenameTotal=[W.G.T.TaskName{W.Task},'_M',num2str(MouseId),'_',FileList.Family{1},'_Version1.ims'];
    FileList.FilenameTotal=strcat(FileList.Filename,'.ims');
    FileList2=FileList(:,{'FilenameTotal';'Time';'Rotate';'SumCoef'});
    % FileList: filename, type, SourceChannel, SourceTimepoint, sumCoef, coefRange, TargetChannel, TargetTimepoint
    Wave1=FileList2(1:17,:);
    
    merge3D_6(FilenameTotal,FileList,[1;1;1],Output.UmMinMaxTotal);
%     applyDrift2Data_5(FilenameTrace,FileList,Res,UmMinMax)
    
end