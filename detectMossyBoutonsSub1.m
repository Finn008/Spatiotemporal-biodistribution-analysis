function detectMossyBoutonsSub1(FctSpec)
global W;

FA=W.G.T.F{W.Task}(:,{'Filename','Type','Treatment','Mouse'});
FA.FilenameTotal=strcat(FA.Filename,FA.Type);
% FA.Treatment(strfind1(FA.Filename,'BACE1-KO'),1)=1;
% FA.Treatment(strfind1(FA.Filename,'GFP-M'),1)=2;
if FctSpec.Type==1
    FA(FA.Treatment~=3&FA.Treatment~=4,:)=[];
    FA.Treatment=FA.Treatment-2;
    
%     SphericityThreshold=0.82;
%     DiameterThreshold=0.7;
%     VglutThreshold=100;
    SphericityThreshold=0.7;
    DiameterThreshold=0.7;
    VglutThreshold=15000;
else
    SphericityThreshold=0.82;
    DiameterThreshold=1.3;
end

FA(isnan(FA.Treatment),:)=[];


%% gather all the data from available files
for m=1:size(FA,1)
    FA.Fileinfo(m,1)={getFileinfo_2(FA.FilenameTotal{m,1})};
    Path=[FA.FilenameTotal{m,1},'_Results.mat'];
    [Path,Report]=getPathRaw(Path);
    if Report==1
        Wave1=load(Path);
        Wave1=Wave1.Results;
        FA.Results(m,1)={Wave1};
    else
        FA.Treatment(m,1)=0;
    end
end
FA(FA.Treatment==0,:)=[];

Table=table({0},{0},{0},{0},{0},'VariableNames',{'Diameter';'Sphericity';'DistInMax';'MeanGFPMcorr';'MeanVglutCorr'},'RowNames',{'Raw'});
for m=1:size(FA,1)
    Statistics=FA.Results{m,1}.Statistics1;
    ObjInfo=Statistics.ObjInfo;
    ChannelList=varName2Col(Statistics.ChannelNames);
    Diameter=(ObjInfo.Volume*3/pi/4).^(1/3)*2;
    Table.Diameter{'Raw',1}(1:size(ObjInfo,1),m)=Diameter;
    Table.Sphericity{'Raw',1}(1:size(ObjInfo,1),m)=ObjInfo.Sphericity;
    Table.MeanGFPMcorr{'Raw',1}(1:size(ObjInfo,1),m)=ObjInfo.IntensityMean(:,ChannelList.GFPMcorr);
    Table.MeanVglutCorr{'Raw',1}(1:size(ObjInfo,1),m)=ObjInfo.IntensityMean(:,ChannelList.VglutCorr);
%     for m2=1:size(Statistics.ChannelNames,1)
%         Table.MeanInt{'Raw',1}.(Statistics.ChannelNames{m2})(1:size(ObjInfo,1),m)=ObjInfo.IntensityMean(:,m2);
%     end
    Table.DistInMax{'Raw',1}(1:size(ObjInfo,1),m)=ObjInfo.IntensityMax(:,ChannelList.DistInOut)/10;
end

%% subselect Terminals
Sphericity=Table{'Raw','Sphericity'}{1};
Diameter=Table{'Raw','Diameter'}{1};
Vglut=Table{'Raw','MeanVglutCorr'}{1};
% Vglut=Table{'Raw','MeanInt'}{1}.VglutCorr;
for Calc={'Diameter','MeanVglutCorr','DistInMax'} % threshold sphericity
    Data=Table{'Raw',Calc{1}}{1};
    Data(Data==0)=NaN;
    Data(Sphericity<SphericityThreshold)=NaN;
    Data(Diameter<DiameterThreshold)=NaN;
    Data(Vglut<VglutThreshold)=NaN;
    clear Data2;
    for File=1:size(Data,2) % readout mean for each file
        Wave1=Data(:,File);
        Wave1(isnan(Wave1),:)=[];
        Data2(1:size(Wave1,1),File)=Wave1(:);
        FA(File,Calc{1})={nanmean(Data(:,File))};
    end
    Data2(Data2==0)=NaN;
    Table{'Selection',Calc{1}}={Data2};
end

Wave1=Table{'Selection','Diameter'}{1};
Wave1=Wave1./Wave1;
FA.Number=nansum(Wave1,1).';

Mouse=table;
Mouse.Tag=unique(FA.Mouse);
for Calc={'Diameter','MeanVglutCorr','DistInMax'}
    for m=1:size(Mouse,1)
        MouseTag=Mouse.Tag(m);
        Wave1=find(FA.Mouse==MouseTag);
        Mouse.Treatment(m,1)=FA.Treatment(Wave1(1));
        Mouse{m,Calc{1}}=mean(FA{Wave1,Calc{1}});
    end
end

Treatment=table;
Treatment.Treatment=(1:2).';
for Calc={'Diameter','MeanVglutCorr','DistInMax'}
    for m=1:2
        Treatment{m,Calc{1}}=mean(Mouse{Mouse.Treatment==m,Calc{1}});
    end
end


% generate binned distribution
for Calc={'Diameter','MeanVglutCorr','DistInMax'} % threshold sphericity
    if strcmp(Calc{1},'Diameter')
        Resolution=0.2;
    elseif strcmp(Calc{1},'MeanVglutCorr')
        Resolution=100;
    elseif strcmp(Calc{1},'DistInMax')
        Resolution=0.05;
    end
    Data=Table{'Selection',Calc{1}}{1};
    Data=round(Data/Resolution);
    Xaxis=(min(Data(:)):max(Data(:))).';
    
    Data2=table;
    Data2.Xaxis=Xaxis*Resolution;
    
    % for each file
    for File=1:size(Data,2)
        Wave1=histc(Data(:,File),Xaxis.');
        Wave1=Wave1/sum(Wave1(:))*100;
        Data2.File(:,File)=Wave1;
    end
    % for each mouse
    for m=1:size(Mouse,1)
        MouseTag=Mouse.Tag(m);
        Wave1=find(FA.Mouse==MouseTag);
        Data2.Mouse(:,m)=mean(Data2.File(:,Wave1),2);
    end
    % for each treatment type
    for m=1:2
        Data2.Treatment(:,m)=mean(Data2.Mouse(:,Mouse.Treatment==m),2);
        Data2.TreatmentStDev(:,m)=std(Data2.Mouse(:,Mouse.Treatment==m),0,2);
    end
    Data2.Ratio=Data2.Treatment(:,1)./Data2.Treatment(:,2);
       
%     A1=sum(Data2.Mouse);
    Table{'Binned',Calc{1}}={Data2};
end

% export as graphic
SavePath=[W.PathExp,'\output\DetectMossyBoutons\'];
for Calc={'Diameter'}
    
    Xaxis=Table.Diameter{'Binned'}.Xaxis;
        
    ColorArray(Mouse.Treatment==1,1)={'w-'};
    ColorArray(Mouse.Treatment==2,1)={'r-'};
    % all spectra in one
    Data=Table.Diameter{'Binned'}.Mouse;
    J=struct;
    J.X=Xaxis;
    J.Y=Data;
    J.Sp=ColorArray;
    J.Xlab='Diameter [µm]';
    J.Ylab='Share [%]';
%     J.Yrange=[0;103];
    J.Style=1;
    J.Path2file=[SavePath,Calc{1},'_Mice.jpg'];
    movieBuilder_4(J);
    
    % Mean and its StdDev
%     Wave1=ObjInfo2.NormMean{'Mean'}{:,:};
%     Data2=[Wave1(:,1),Wave1(:,1)-Wave1(:,2),Wave1(:,1)+Wave1(:,2)];
    Mean=Table{'Binned',Calc{1}}{1}.Treatment;
    StDev1=Mean+Table{'Binned',Calc{1}}{1}.TreatmentStDev;
    StDev2=Mean-Table{'Binned',Calc{1}}{1}.TreatmentStDev;
    J.OrigYaxis=[...
        {Mean(:,1)},{'w-'};...
        {StDev1(:,1)},{'w--'};...
        {StDev2(:,1)},{'w--'};...
        {Mean(:,2)},{'r-'};...
        {StDev1(:,2)},{'r--'};...
        {StDev2(:,2)},{'r--'}];
    try; J=rmfield(J,'Sp'); end;
    J.Path2file=[SavePath,Calc{1},'_Treatment.jpg'];
    movieBuilder_4(J);
    

    J.Y=Table{'Binned',Calc{1}}{1}.Ratio;
    J.Y(:,2)=1;
    try; J=rmfield(J,'OrigYaxis'); end;
	J.Sp=[{'w-'};{'w--'}];
    J.Ylab='Ratio';
    J.Path2file=[SavePath,Calc{1},'_Ratio.jpg'];
    movieBuilder_4(J);
    
    
% % %     % spectra one after the other
% % %     %     J.Tit=strcat({'Emission spectrum: '},num2strArray((1:size(Data,2)).'));
% % %     J.OrigYaxis={Data};
% % %     J.OrigType=3;
% % %     J.Frequency=0.25;
% % %     J.Path2file=[SavePath,ObjectInfo.Name{Obj},'_NormMean.avi'];
% % %     movieBuilder_4(J);
% % %     
% % %     % all spectra cumulative
% % %     J.Path2file=[SavePath,ObjectInfo.Name{Obj},'_NormMeanCum.avi'];
% % %     J.Cumulative=1;
% % %     movieBuilder_4(J);
end

%% export to excel
OutputPath=[SavePath,W.G.T.TaskName{W.Task},'_Results.xlsx'];
[Excel,Workbook,Sheets,SheetNumber]=connect2Excel(OutputPath);

Wave1=num2cell(Table.Diameter{'Selection'});
Wave1=[FA.FilenameTotal.';Wave1];
xlsActxWrite(Wave1,Workbook,'RawDiameter',[],'Delete');

Wave1=FA(:,{'FilenameTotal';'Treatment';'Mouse';'Diameter';'MeanVglutCorr';'DistInMax';'Number'});
xlsActxWrite(Wave1,Workbook,'FileMean',[],'Delete');
xlsActxWrite(Mouse,Workbook,'MouseMean',[],'Delete');
xlsActxWrite(Treatment,Workbook,'TreatmentMean',[],'Delete');


xlsActxWrite(Table.Diameter{'Binned'},Workbook,'Distribution',[],'Delete',1);

A1=1;


% A1=1;






