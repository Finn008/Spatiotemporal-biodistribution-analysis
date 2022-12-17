function [FilenameTrace,FilenameDrift,TargetTimepoint]=dystrophyDetection_Chronic(FctSpec)
global W;
F=W.G.T.F{W.Task}(W.File,:);

FilenameTrace=[W.G.T.TaskName{W.Task},'_M',num2str(F.MouseId(1)),'_Roi',num2str(F.Roi(1)),'_TyTrace.ims'];
FilenameDrift=[W.G.T.TaskName{W.Task},'_M',num2str(F.MouseId(1)),'_Roi',num2str(F.Roi(1)),'_TyDrift.ims'];
TargetTimepoint=F.TargetTimepoint;
FileList=W.G.T.F{W.Task};
FileList=FileList(FileList.MouseId==F.MouseId & FileList.Roi==F.Roi,:);

[PathRaw,Report]=getPathRaw(FilenameDrift);
if Report==0 || Report~=0
       
    FA=table;
    FA.FilenameTotal=FileList.Filename;
    FA.SourceTimepoint(:,1)=1;
    FA.TargetTimepoint=FileList.TargetTimepoint;
    try; FA.Rotate=strcat(FileList.Rotate); end;
    for File=1:size(FA,1)
        Wave1=variableExtract(FileList.DriftCorrection{File}); Wave1.ChannelNames=strsplit(Wave1.ChannelNames,',').';
        FA.Type{File,1}=Wave1.Type;
        if strfind1(FileList.Properties.VariableNames,'ChannelNames')==0
            ChannelListOrig=variableExtract(FileList.DystrophyDetection{File});
            ChannelListOrig=ChannelListOrig.ChannelNames;
        else
            ChannelListOrig=FileList.ChannelNames{File};
        end
        ChannelListOrig=strsplit(ChannelListOrig,',').';
        
        FA.SourceChannel{File,1}=num2cell(ismember2(Wave1.ChannelNames,ChannelListOrig));
        FA.TargetChannel{File,1}=Wave1.ChannelNames;
    end
    [FA,Volume]=calcSummedFitCoef_2(FA);
    
    merge3D_6(FilenameDrift,FA,Volume.Resolution,Volume.TotalVolumeUm);
    [FileinfoDrift]=getFileinfo_2(FilenameDrift);
    Res=FileinfoDrift.Res{1};
    for Channel=FileinfoDrift.ChannelList{1}.'
        Settings={  'Name','SpFiPrctile','SpFiSubtrBackgr';...
            'Autofluo750',70,10;...
            'Autofluo880',70,10;...
            'MetBlue',70,400;...
            };
        Settings=array2table(Settings(2:end,:),'VariableNames',Settings(1,:),'RowNames',Settings(2:end,1));
        if strfind1(Settings.Name,Channel,1)==0; continue; end;
        for Time=1:FileinfoDrift.GetSizeT
            [Data3D]=im2Matlab_3(FilenameDrift,Channel,Time);
            [~,Data3D]=percentileFilter3D_3(Data3D,Settings{Channel,'SpFiPrctile'}{1},Res,[10;10;Res(3)],[],Settings{Channel,'SpFiSubtrBackgr'}{1},[200;200;1]);
%             [~,A1]=percentileFilter3D_3(Data3D,Settings{Channel,'SpFiPrctile'}{1},Res,[10;10;Res(3)],[],Settings{Channel,'SpFiSubtrBackgr'}{1},[200;200;1]);
            ex2Imaris_2(Data3D,FilenameDrift,Channel,Time); 
        end
    end
%     Application=openImaris_2(FilenameDrift,1,1);
    imarisSaveHDFlock(FilenameDrift);
    keyboard;
    
    % detect large Plaques
    J=struct; J.Application=Application;
    J.SurfaceName='Plaques';
    J.Channel='Plaque';
    J.Smooth=1;
    J.Background=10;
    J.LowerManual=1.5;
    J.SurfaceFilter='"Volume" above 3.0 um^3';
    [PlaqueSurface,PlaqueSurfaceInfo]=generateSurface3(J);
    imarisSaveHDFlock(Application,Path2fileDriftCorr);
    FA.Selection=regexprep(FA.Selection,'Do#Go','Do#Fin');
    FA.Selection=regexprep(FA.Selection,'Step#1','Step#2');
end

if Report==0
    
    
    if FctSpec.Step==0
    end
    
    
    
    Application=openImaris_2(FilenameTotalOrig);
    %     Fileinfo=extractFileinfo(FilenameTotalOrig,Application);
    % % %     if ischar(FctSpec.ChannelNames) % rename channels
    
    if size(ChannelListOrig,1)~=size(FileinfoOrig.ChannelList{1},1)
        quitImaris(Application);
        A1=asdf; % make error if more channels present than names
    end
    for m=1:size(ChannelListOrig,1)
        Application.GetDataSet.SetChannelName(m-1,ChannelListOrig{m});
    end
    % % %     end
    Application.FileSave(PathRaw,'writer="Imaris5"');
    quitImaris(Application);
    [Fileinfo,Ind,PathRaw]=getFileinfo_2(FilenameTotal);
    try; iFileChanger('W.G.Fileinfo.Results{Q1,1}.ZenInfo',FileinfoOrig.Results{1}.ZenInfo,{'Q1',Ind}); end;
    timeTable('LoadData');
end