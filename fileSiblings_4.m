% original:     2014.04.08_38b.lsm
% for deconvolution:       2014.04.08_38b_4decon.ims or .ids
% after deconvolution:       2014.04.08_38b_DeFin.ids
% for deconvolution calibration:        2014.04.08_38b_4deCal.ims
% after deconvolution calibration:        2014.04.08_38b_CalFin.ids
% after putting series together:        38_DriftCorr.ims
% after refining drift in series:        38_Trace.ims
function [NameTable,ChannelTable]=fileSiblings_4(Filename)
global W;
F=W.G.T.F{W.Task}(W.File,:);
% F.Family{1}='Type#Chronic|';
% F.Family{1}='Type#Standard|Tiff3DtoImaris#1|';
if strfind1(F.Properties.VariableNames.','Family',1) && strfind(F.Family{1},'Type#')% || isnan(F.Family{1})
    [Family]=variableExtract(F.Family{1});
else
    Family=struct('Type','Standard');
end

% Family=struct('Type','Tiff3D');
% SibInfo=struct;
global NameTable; NameTable=table;
global ChannelTable; ChannelTable=table;
if strcmp(Family.Type,'Chronic')
    FileList=W.G.T.F{W.Task};
    FileList=FileList(strfind1(FileList.Family,['SuperF#',num2str(Family.SuperF),'|']),:);
    
    NameTable('FilenameTotal','Filename')={{[F.Filename{1},'.ims']}};
    NameTable('FilenameTotalOrig','Filename')={{[F.Filename{1},'_DeFin.ids']}};
    
    NameTable('Trace','Filename')={{[W.G.T.TaskName{W.Task},'_M',num2str(F.MouseId(1)),'_SF',num2str(Family.SuperF),'_Trace.ims']}};
    NameTable.Filename{'DriftCorr'}=regexprep(NameTable.Filename{'Trace'},'Trace.ims','DriftCorr.ims');
        
    ChannelTable(ChannelListOrig,'ChannelName')=ChannelListOrig;
end

if strcmp(Family.Type,'Standard')
    if isfield(Family,'Tiff3DtoImaris')==1
%         NameTable('FilenameImarisLoadTif','Filename')={{regexprep(F.Filename{1},'.tif','_T001_Z001_C01.tif')}};
        NameTable('FilenameImarisLoadTif','Filename')={{regexprep(F.Filename{1},'.tif','')}};
        NameTable('FilenameTotal','Filename')={{regexprep(F.Filename{1},'.tif','.ims')}};
        NameTable('FilenameTotalOrig','Filename')={{regexprep(F.Filename{1},'.tif','_Tiff3D.ims')}};
    else
        NameTable('FilenameTotal','Filename')={{regexprep(F.Filename{1},{'.lsm';'.czi'},'.ims')}};
        NameTable('FilenameTotalOrig','Filename')=F.Filename(1);
    end

    if strfind1(F.Properties.VariableNames,'ChannelNames')==0
        Wave1=variableExtract(F.DystrophyDetection{1});
        ChannelListOrig=strsplit(Wave1.ChannelNames,',').';
    else
        ChannelListOrig=strsplit(F.ChannelNames{1},',').';
    end

    ChannelTable(ChannelListOrig,'ChannelName')=ChannelListOrig;
    ChannelTable(ChannelListOrig,'SourceFilename')=NameTable('FilenameTotalOrig','Filename');
    ChannelTable(ChannelListOrig,'TargetFilename')=NameTable('FilenameTotal','Filename');
    % ChannelTable{ChannelListOrig,'TargetFilename'}=(1:size(ChannelListOrig,1)).';
    for m=1:size(ChannelListOrig,1)
        ChannelTable(ChannelListOrig{m},'SourceChannelName')={{m}};
    end
    ChannelTable('Outside',{'ChannelName';'TargetFilename';'SourceChannelName'})={'Outside',NameTable{'FilenameTotal','Filename'},'Outside'};
%     ChannelTable('Outside',{'ChannelName';'SourceFilename';'TargetFilename';'SourceChannelName'})={'Outside',[],regexprep(NameTable{'FilenameTotal','Filename'}{1},'.ims','_Outside.ims'),'Outside'};
    % ChannelTable{ChannelListOrig,'SourceChannelName'}=num2cell((1:size(ChannelListOrig,1)).');
    %
    if isfield(Family,'Tiff3DtoImaris')==1
        ChannelTable('Outside',{'ChannelName';'SourceFilename';'TargetFilename';'SourceChannelName'})={'Outside',[],regexprep(NameTable{'FilenameTotal','Filename'}{1},'.ims','_Outside.ims'),'Outside'};
        ChannelTable('Unspecified',{'ChannelName';'SourceFilename';'TargetFilename'})={'Outside',[],NameTable{'FilenameTotal','Filename'}{1}};
        ResIntermediate=[5;5;5];
    else
        Fileinfo=getFileinfo_2(NameTable.Filename{'FilenameTotalOrig'});
        ResIntermediate=Fileinfo.Res{1};
    end
end
% NameTable('Results','Filename')={{regexprep(NameTable{'FilenameTotal','Filename'},'.ims','_Results.mat')}};
NameTable.Filename('Results')={[NameTable.Filename{'FilenameTotal'},'_Results.mat']};
% keyboard; % Intermediate placed as cell
ChannelTable{'ShowIntermediate',{'TargetFilename','Res'}}={regexprep(NameTable.Filename{'FilenameTotal'},'.ims','_Intermediate.ims'),ResIntermediate};

