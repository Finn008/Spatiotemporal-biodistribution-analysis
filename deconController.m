function deconController(FilenameTotal)
global W;
% keyboard;
if exist('FilenameTotal')==0
    FilenameTotal=W.G.Fileinfo.FilenameTotal{W.Row,1};
end
if iscell(FilenameTotal); FilenameTotal=FilenameTotal{1}; end;

[Fileinfo,FileInd,Path2file]=getFileinfo_2(FilenameTotal);
% [Speci]=variableExtract(Fileinfo.Decon{1},{'Do'});

[Sibling,NameTable,ImageGroup]=fileSiblings(FilenameTotal);
% [NameTable,Wave1]=fileSiblings_3();
% ImageGroup=Wave1.ImageGroup;
% if strcmp(Sibling,'Original')==0; A1=asdf; end;

%% put ForDecon
if NameTable.Report('Original')==1 && NameTable.Report('ForDecon')==0 % ((NameTable.Report('ForDecon')==0 || NameTable.Datenum('ForDecon') < datenum('2015.05.13 10:07','yyyy.mm.dd HH:MM')))
    [Fileinfo]=getFileinfo_2(FilenameTotal);
    PathSource=NameTable.Path2file{'Original'};
    PathTarget=NameTable.Path2file{'ForDecon'};
    J=struct; J.Path2file=PathSource;
    [Application]=openImaris_2(J);
    Application.FileSave(PathTarget,'writer="ICS"');
    quitImaris(Application); 
    clear Application;
    [Sibling,NameTable,ImageGroup]=fileSiblings(FilenameTotal); % update because new file was placed
end
%% calculate depth correction for deconvoluted file
if NameTable.Report('DeFin')==1
    
    [Fileinfo,IndFileinfo,~]=getFileinfo_2(NameTable{'DeFin','FilenameTotal'});
    try
        Wave1=Fileinfo.Results{1}.ZenInfo.Lasers;
    catch % transfer ZenInfo to DeFin file
        LsmFileinfo=getFileinfo_2(NameTable{'Original','FilenameTotal'});
        iFileChanger('W.G.Fileinfo.Results{Q1,1}.ZenInfo',LsmFileinfo.Results{1}.ZenInfo,{'Q1',IndFileinfo});
    end
    if strcmp(ImageGroup,'a')
       Exponent=[0.004;0.005];
    elseif strcmp(ImageGroup,'b')
%         Exponent=[0.005;0.003];
        Exponent=[0.005;0.0025];
    end
    
    J=struct;
    J.CorrType='InVivoFixed';
    J.FilenameTotal=NameTable.FilenameTotal{'DeFin'};
    J.TargetChannel=1;
    J.Exponent=Exponent(1,1);
    depthCorrection_6(J);
    
    J.TargetChannel=2;
    J.Exponent=Exponent(2,1);
    depthCorrection_6(J);
end
%% generate calibration file
if strcmp(ImageGroup,'b') && NameTable.Report('ForDeCal')==0 && datenum(now)==0
    PathTarget=NameTable.Path2file{'ForDeCal'};
    PathSource=NameTable.Path2file{'ForDecon'};
    J=struct;
    J.Resolution=[1.2;1.2;0];
    J.Path2file=PathSource;
    J.Fileinfo=Fileinfo;
    Application=openImaris_2(J);
    
    Application.FileSave(PathTarget,'writer="ICS"');
    quitImaris(Application);
    clear Application;
end
%% generate entry to deconvolute with different settings
if strcmp(ImageGroup,'b')
    %         FinFiles=NameTable.Properties.RowNames; FinFiles=strfind1(FinFiles,{'DeFin';'CalFin'});
    FinFiles=strfind1(NameTable.Properties.RowNames,{'DeFin';'CalFin'});
elseif strcmp(ImageGroup,'a')
    FinFiles=strfind1(NameTable.Properties.RowNames,'DeFin');
end
FinFiles=NameTable.Report(FinFiles);
if min(FinFiles)==0
    FileList=table;
    FileList.FilenameTotal{1}=NameTable.FilenameTotal{'ForDecon'};
    FileList.Filename{1}=NameTable.Filename{'ForDecon'};
    FileList.Type{1}=NameTable.Type{'ForDecon'};
    FileList.TargetFilename{1}=NameTable.Filename{'DeFin'};
    FileList.Modality{1}='Multi-Photon Fluorescence';
    FileList.Lens{1}='W Plan-Apochromat 20x/1.0 DIC M27 75mm';
    FileList.ImmMedium{1}='Water (1,333)';
    FileList.SampleMedium{1}='Water (1,333)';
    FileList.BitType{1}='16 bit unsigned integer';
    
    FileList.MB(1)=Fileinfo.MB;
    FileList.TrialDate=0;
    if strcmp(ImageGroup,'a')
        FileList.SA{1}='0,0';
        FileList.Ch1Wavelength{1}='620 nm';
        FileList.Ch2Wavelength{1}='530 nm';
    elseif strcmp(ImageGroup,'b')
        FileList.SA{1}='0,4';
        FileList.Ch1Wavelength{1}='450 nm';
        FileList.Ch2Wavelength{1}='620 nm';
        
        if datenum(now)==0
            Wave1=dir(NameTable.Path2file{'ForDeCal'}); MBForDeCal=Wave1.bytes/1000000;
            for m=2:10
                SA=m-2;
                FileList(m,:)=FileList(1,:);
                FileList.FilenameTotal{m,1}=NameTable.FilenameTotal{'ForDeCal'};
                FileList.Filename{m,1}=NameTable.Filename{'ForDeCal'};
                FileList.Type{m,1}='.ids';
                FileList.TargetFilename{m,1}=NameTable.Filename{['CalFin',num2str(SA)]};
                FileList.SA{m,1}=['0,',num2str(SA)];
                FileList.MB(m,1)=MBForDeCal;
                FileList.TrialDate(m,1)=0;
            end
        end
    end
    
    iFileChanger('W.G.Fileinfo.Results{Q1,1}.Decon.FileList',FileList,{'Q1',FileInd});
    [Wave1]=variableSetter_2(W.G.Fileinfo.Decon{FileInd,1},{'Autoquant','Go'});
    iFileChanger('W.G.Fileinfo.Decon{Q1,1}',Wave1,{'Q1',FileInd});
else
    [Wave1]=variableSetter_2(W.G.Fileinfo.Decon{FileInd,1},{'Autoquant','Fin'});
    iFileChanger('W.G.Fileinfo.Decon{Q1,1}',Wave1,{'Q1',FileInd});
end
%% make the decon calibration
%         CalFinFiles=NameTable.Properties.RowNames; CalFinFiles=strfind1(CalFinFiles,'CalFin');
%         if min(NameTable.Report(CalFinFiles))==1
%
%         end

%% all files were deconvoluted
if min(FinFiles)==1
    %         iFileChanger({['G.Fileinfo.Results{Q1,1}.Decon.FileList']},FileList,{'Q1',FileInd});
    [Wave1]=variableSetter_2(W.G.Fileinfo.Decon{FileInd,1},{'Decon','Fin'});
    iFileChanger('W.G.Fileinfo.Decon{Q1,1}',Wave1,{'Q1',FileInd});
end


%% Step 1: CalFin-files are available, load each, make depth correction, adjust 60th percentile to 1, determine surface with manual threshold set to 1, return ellipticity, fit curve to ellipticity, choose the one closest to 1
%% step 2: start decon of 4decon-file with the optimal settings


evalin('caller','global W;');