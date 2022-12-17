% check function generateTimelineStacks_AllPlaquesPerTimepoint_2(Mouse,MouseInfo,PlaqueListSingle)
% previously: dystrophyDetection_visualizeIndividualPlaques_2(MouseInfo,PlaqueListSingle,Version,DataType,Selection)
function dystrophyDetection_visualizeIndividualPlaques_4(MouseInfo,PlaqueListSingle,Struct)
global W;
v2struct(Struct);
if exist('ImageGeneration','Var')~=1
    ImageGeneration='EachPlaque';
end
PlaqueListSingle=fuseTable_MatchingColums_4(PlaqueListSingle,MouseInfo,{'MouseId'},{'TreatmentType'});
PlaqueListSingle(ismember(PlaqueListSingle.TreatmentType,{'NB360';'TauKD'}),:)=[];
PlaqueListSingle.TreatmentType(strcmp(PlaqueListSingle.TreatmentType,'NB360Vehicle'),1)={'Control'};

%% data selection
% % % % Wave1=strfind1(PlaqueListSingle.Filename,{'ExHazal_TrControl_IhcBace1_Ihd160416_M266_HemRight_Roi6';'ExHazal_TrControl_IhcBace1_Ihd160416_M259_HemRight_Roi9';'ExHazalS_IhcIba1_M266_PLQ5_HemRight_Roi10';'ExHazalS_IhcIba1_M266_PLQ5_HemLeft_Roi09';'ExHazal_IhcAPPY188_M341_Roi6';'ExHazal_TrVehicle_IhcBace1_Ihd160416_M341_HemLeft_Roi1'});
% % % % Wave1=strfind1(PlaqueListSingle.Filename,{'ExHazal_TrTauKO_IhcBace1_Ihd160703_M396_HemLeft_Roi4';'ExHazal_TrTauKO_IhcBace1_Ihd160703_M381_HemLeft_Roi4';'ExHazal_TrTauKO_IhcBace1_Ihd160703_M381_HemRight_Roi10'});
% % % % Wave1=strfind1(PlaqueListSingle.Filename,{'ExHazal_TrControl_IhcBace1_Ihd160416_M266_HemRight_Roi6'});
% % % % Wave1=strfind1(PlaqueListSingle.Filename,{'ExHazalS_IhcLamp1_M353_PLQ8_HemLeft_Roi17';'ExHazal_TrTauKO_IhcBace1_Ihd170403_M429_HemRight_Roi9'});
% % % % PlaqueListSingle=PlaqueListSingle(Wave1,:);


if strfind1(PlaqueListSingle.Properties.VariableNames,'Filenames',1)
    PlaqueListSingle.Properties.VariableNames('Filenames')={'Filename'};
end

if exist('Selection','Var')==1 && Selection==1
    [Path2file,Report]=getPathRaw('VisualizeIndividualPlaques.xlsx');
    [Excel,Workbook,Sheets,SheetNumber]=connect2Excel(Path2file);
    PlaqueList=xlsActxGet(Workbook,'Selection',1);
    clear Wave1;
    for Pl=1:size(PlaqueList,1)
        Wave1(Pl,1)=find(strncmp(PlaqueListSingle.Filename,PlaqueList.Filename{Pl},size(PlaqueList.Filename{Pl},2)) & PlaqueListSingle.PlId==PlaqueList.Pl(Pl));
    end
    PlaqueListSingle=PlaqueListSingle(Wave1,:);
end
% SquareUm=[100;100;0.4]; % µm % SquareUm=[100;100;1]; % µm
ChannelInfo=table;
if find(Version==1)
    ChannelInfo(1,{'Channel','Colormap','ColorMinMax'})={'MetBlue',{[0;1;1]},{[0;40000]}};
    ChannelInfo(2,{'Channel','Colormap','ColorMinMax'})={DataType,{[1;0;1]},{[0;30000]}}; % Iba1
    ChannelInfo(3,{'Channel','Colormap','ColorMinMax','ImageAdjustment'})={'DistInOut',{[1;1;1]},{[0;1]},'PlaqueBorder'};
end
if Version==2
    ChannelInfo(1,{'Channel','Colormap','ColorMinMax'})={'MetBlue',{[0;1;1]},{[0;30000]}};
    ChannelInfo(2,{'Channel','Colormap','ColorMinMax'})={DataType,{[1;0;1]},{[0;20000]}}; % Iba1: 30000
end
if Version==3 % BACE1 stainings for TauKO paper
    ChannelInfo(1,{'Channel','Colormap','ColorMinMax'})={'MetBlue',{'Black2Blue2White'},{'Norm100'}};
    ChannelInfo(2,{'Channel','Colormap','ColorMinMax'})={DataType,{[1;0;1]},{[0;15000]}}; % Iba1: 30000
end

% if find(Version==4) % InVivo: Vglut1 colorcoded
%      Wave1={'Version',4;'Channel','VglutGreen';'D2D','D2DRatioA';'Colormap','Spectrum1';'IntensityMinMax','Norm99.5';'ColorChannel','Dystrophies2Radius';'ColorMinMax',[0;30];'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
% end
% if find(Version==5) % InVivo: Vglut1
%     Wave1={'Version',5;'Channel','VglutGreen';'D2D','D2DRatioA';'Colormap',[0.5;1;0];'IntensityMinMax','Norm99.5';'Res',[0.1;0.1;0.4]};
%     ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
% end
if find(Version==5) % InVivo: VglutGreen
    Wave1={'Version',5.0;'Channel','VglutGreen';'D2D','D2DRatioA';'Colormap',[0.5;1;0];'IntensityMinMax','Norm96';'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
end
if find(Version==5.1) % InVivo: MetBlue
    Wave1={'Version',5.1;'Channel','MetBlue';'D2D','D2DRatioB';'Colormap','Black2Blue2White';'IntensityMinMax','Norm100Center60';'IntensityGamma',1;'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
end
if find(Version==5.2) % VglutGreen&Methoxy
    Wave1={'Version',5.2;'Channel','MetBlue';'D2D','D2DRatioB';'Colormap','Black2Blue2White';'IntensityMinMax','Norm100';'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
    Wave1={'Version',5.2;'Channel','VglutGreen';'D2D','D2DRatioA';'Colormap',[0.5;1;0];'IntensityMinMax','Norm96';'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
end
if find(Version==5.3) % InVivo: VglutGreen colorcoded
    Wave1={'Version',5.3;'Channel','VglutGreen';'D2D','D2DRatioA';'Colormap','Spectrum1';'IntensityMinMax','Norm96';'ColorChannel','Dystrophies2Radius';'ColorMinMax',[0;30];'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
end
if find(Version==5.4) % InVivo: VglutGreen colorcoded and Methoxy
    Wave1={'Version',5.4;'Channel','MetBlue';'D2D','D2DRatioB';'Colormap','Black2Blue2White';'IntensityMinMax','Norm100Center60';'IntensityGamma',1;'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
    Wave1={'Version',5.4;'Channel','VglutGreen';'D2D','D2DRatioA';'Colormap','Spectrum1';'IntensityMinMax','Norm96';'ColorChannel','Dystrophies2Radius';'ColorMinMax',[0;30];'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
end
if find(Version==5.5) % InVivo: MetBlue
    Wave1={'Version',5.5;'Channel','MetBlue';'D2D','D2DRatioB';'Colormap','Black2Blue2White';'IntensityMinMax','Norm100Center60';'IntensityGamma',0.5;'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
end
if find(Version==5.6) % InVivo: Distance
    Wave1={'Version',5.6;'Channel','DistInOut';'D2D','D2DTrace';'Colormap','Distance_5umBins';'IntensityMinMax',[0;255];'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
end
if find(Version==5.7) % ExVivo VglutGreen&Methoxy
    Wave1={'Version',5.7;'Channel','MetBlue';'D2D','D2DRatioB';'Colormap','Black2Blue2LightBlue';'IntensityMinMax','Norm100';'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
    Wave1={'Version',5.7;'Channel','VglutGreen';'D2D','D2DRatioA';'Colormap',[0.5;1;0];'IntensityMinMax','Norm96';'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
%     ChannelInfo.Res(:,1)={[0.1;0.1;0.4]};
end
if find(Version==7) % ExVivo Vglut1&Methoxy
    Wave1={'Version',7;'Channel','Vglut1';'Colormap',[0.5;1;0];'IntensityMinMax','Norm96';'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).'; % previously Norm99
    Wave1={'Version',7;'Channel','MetBlue';'Colormap','Black2Blue2White';'IntensityMinMax','Norm100';'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
end
if find(Version==7.1) % ExVivo Vglut1-Diameter&Methoxy
    Wave1={'Version',7.1;'Channel','MetBlue';'Colormap','Black2Blue2White';'IntensityMinMax','Norm100';'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
    Wave1={'Version',7.1;'Channel','Vglut1';'Colormap','Spectrum1';'IntensityMinMax','Norm96';'ColorChannel','Vglut1DystrophiesDiameter';'ColorMinMax',[0;60];'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
end
if find(Version==7.2) % ExVivo Vglut1-Diameter
    Wave1={'Version',7.2;'Channel','Vglut1';'Colormap','Spectrum1';'IntensityMinMax','Norm96';'ColorChannel','Vglut1DystrophiesDiameter';'ColorMinMax',[0;60];'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
end
if find(Version==8) % ExVivo APPY188&Methoxy
    Wave1={'Version',8;'Channel','APP';'Colormap',[1;0;1];'IntensityMinMax',[0;30000];'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
    Wave1={'Version',8;'Channel','MetBlue';'Colormap','Black2Blue2White';'IntensityMinMax','Norm100';'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
end
if find(Version==9) % ExVivo Methoxy
%     Wave1={'Version',9;'Channel','MetBlue';'Colormap','Black2Blue2White';'IntensityMinMax','Norm99.9';'IntensityGamma',0.333;'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
    Wave1={'Version',9;'Channel','MetBlue';'Colormap','Black2Blue2White';'IntensityMinMax','Norm100';'IntensityGamma',0.333;'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
end
if find(Version==10) % DistanceBins of 5µm
%     Wave1={'Version',10;'Channel','DistInOut';'Colormap','Distance_5umBinsPlus1';'IntensityMinMax',[0;255];'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
%     Wave1={'Version',10;'Channel','DistInOut';'Colormap','Distance_5umBinsMinus1';'IntensityMinMax',[0;255];'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
    Wave1={'Version',10;'Channel','DistInOut';'Colormap','Distance_5umBins';'IntensityMinMax',[0;255];'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
end
if find(Version==11) % ExVivo Vglut1-Diameter&Methoxy
    Wave1={'Version',11;'Channel','MetBlue';'Colormap','Black2Blue2White';'IntensityMinMax','Norm100';'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
    Wave1={'Version',11;'Channel','Iba1';'Colormap',[1;0;1];'IntensityMinMax','Norm99.5';'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
% % %     Wave1={'Version',11;'Channel','Iba1';'Colormap','WhiteOrMagenta';'IntensityMinMax','Norm96';'ColorChannel','Microglia';'ColorMinMax',[0;1];'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
end
if find(Version==12) % Imaris
%     Wave1={'Version',12;'Channel','MetBlue';'D2D','D2DRatioB'}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
    Wave1={'Version',12;'ChannelName','MetBlue';'Channel',{2};'D2D','FilenameDeFinB'}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
    Wave1={'Version',12;'ChannelName','MetRed';'Channel',{1};'D2D','FilenameDeFinB'}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
%     Wave1={'Version',12;'Channel','MetRed';'D2D','D2DRatioB'}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
    Wave1={'Version',12;'Channel','VglutGreen';'D2D','FilenameRel2'}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
    Wave1={'Version',12;'Channel','VglutRed';'D2D','FilenameRel2'}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
    Wave1={'Version',12;'Channel','Membership';'D2D','FilenameTrace'}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
    Wave1={'Version',12;'Channel','DistInOut';'D2D','FilenameTrace'}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
%     Wave1={'Version',5.0;'Channel','VglutGreen';'D2D','D2DRatioA';'Colormap',[0.5;1;0];'IntensityMinMax','Norm96';'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
    ChannelInfo.Res(:,1)={[0.15;0.15;0.4]};
    ChannelInfo.SizeUm(:,1)={[350;350;60]};
end

if strfind1(ChannelInfo.Properties.VariableNames.','ChannelName',1)==0
    ChannelInfo.ChannelName=ChannelInfo.Channel;
else
    Wave1=find(isempty_2(ChannelInfo.ChannelName));
    ChannelInfo.ChannelName(Wave1,:)=ChannelInfo.Channel(Wave1);
end

Version=unique(ChannelInfo.Version);
if strfind1(PlaqueListSingle.Properties.VariableNames.','Time',1)==0
    PlaqueListSingle.Time(:,1)=1;
end

if strfind1(ChannelInfo.Properties.VariableNames.','SizeUm',1)==0
    ChannelInfo.SizeUm(:,1)={[100;100;0.4]};
end
if strfind1(ChannelInfo.Properties.VariableNames.','Res',1)==0
    ChannelInfo.Res(:,1)={[]};
end
MouseIds=unique(PlaqueListSingle.MouseId);
% MouseIds=384;
for Mouse=1:size(MouseIds,1)
    MouseId=MouseIds(Mouse);
    PlaqueListSingle2=PlaqueListSingle(PlaqueListSingle.MouseId==MouseId & isempty_2(PlaqueListSingle.UmCenter)==0,:);
    if max(PlaqueListSingle2.Time)==1
        [~,~,PlaqueListSingle2.RoiId]=unique(PlaqueListSingle2.Filename);
    end
    RoiIds=unique(PlaqueListSingle2.RoiId);
    for Roi=1:size(RoiIds,1)
        RoiId=RoiIds(Roi);
        Timepoints=unique(PlaqueListSingle2.Time(PlaqueListSingle2.RoiId==floor(RoiId)));
        
        for Time=1:size(Timepoints,1)
% Time=2;
            TimeId=Timepoints(Time);
            PlaqueListSingle3=PlaqueListSingle2(find(PlaqueListSingle2.Time==TimeId & PlaqueListSingle2.RoiId==floor(RoiId)),:);
            
%             Data3D=ChannelInfo(:,{'ChannelName';'Channel';'Res'});
            Data3D=ChannelInfo;
            Data3D.Time(:,1)=1;
            try; Data3D(end+1:end+size(ChannelInfo,1),Data3D.Properties.VariableNames)=ChannelInfo(:,{'ColorChannel';'Res'}); end;
            
            if strfind1(ChannelInfo.Properties.VariableNames.','D2D')~=0
                if Time==1
                    [FileList,TimeList,Output]=spatialRelation_2(PlaqueListSingle2.Filename{1,1});
                end
                keyboard; % already here readout the individual SumCoef
                for m=1:size(Data3D,1)
                    Data3D.FilenameTotal(m,1)=TimeList{Time,Data3D.D2D{m}};
                end
                
                Data3D.Time(strfind1(Data3D.D2D,'FilenameTrace'),1)=Time;
            else
                Data3D.FilenameTotal(:,1)={regexprep(PlaqueListSingle3.Filename{1},{'.lsm';'.czi'},{'.ims'})};
            end
            
            
            Data3D(isempty_2(Data3D.ChannelName)|isempty_2(Data3D.FilenameTotal),:)=[];
            [~,Wave1]=unique(Data3D.ChannelName);
            Data3D=Data3D(Wave1,:);
            for m=1:size(Data3D,1)
                FilenameTotal=Data3D.FilenameTotal{m};
                [~,Report]=getPathRaw(FilenameTotal);
                [Fileinfo]=getFileinfo_2(FilenameTotal);
%                 if min(ismember(ChannelInfo.Channel,Fileinfo.ChannelList{1}))==0
%                     continue;
%                 end
                if Report==0; continue; end;
                Wave1=im2Matlab_3(FilenameTotal,Data3D.Channel{m},Data3D.Time(m));
                Data3D.Data(m,1)={Wave1};
                Data3D.Fileinfo(m,1)={Fileinfo};
            end
            % %                 Filename=PlaqueListSingle3.Filename{1,2};
            % %                 if isempty(Filename); continue; end;
            % %                 [D2DDeFinB,D2DDeFinAgreen,D2DDeFinAred,D2DRatioA,D2DRatioB,D2DTrace,FitCoefTrace2B,FitCoefB2A,Res,UmMinMax,FileinfoRatioA,FileinfoRatioB]=getRotationDrift_2(Filename,TimeId);

%             Data3D=ChannelInfo(:,{'ChannelName';'Channel';'D2D';'Res'});
%             try; Data3D(end+1:end+size(ChannelInfo,1),Data3D.Properties.VariableNames)=ChannelInfo(:,{'ColorChannel';'D2D';'Res'}); end;
%             Data3D(isempty_2(Data3D.ChannelName),:)=[];
%             [~,Wave1]=unique(Data3D.ChannelName);
%             Data3D=Data3D(Wave1,:);
%             for m=1:size(Data3D,1)
%                 Wave1=eval(Data3D.D2D{m});
%                 Wave1.Tres=Data3D.Res{m};
%                 Wave1=rmfield(Wave1,'Tpix');
%                 Data3D.Data(m,1)={applyDrift2Data_4(Wave1,Data3D.Channel{m,1})};
%             end
            
            % ex vivo
            for Pl=1:size(PlaqueListSingle3,1)
                
% Pl=2;
                PlId=PlaqueListSingle3.PlId(Pl);
                if strfind1(ChannelInfo.Properties.VariableNames.','D2D')~=0
                    PlXYZtrace=PlaqueListSingle3.UmCenter{Pl}; % Center in Trace file
                    [Wave1]=YofBinFnc(repmat(PlXYZtrace(3),[3,1]),FitCoefTrace2B(:,1),FitCoefTrace2B(:,2),FitCoefTrace2B(:,3));
                    PlXYZb=PlXYZtrace+Wave1; % Center in RatioB
                    [Wave1]=YofBinFnc(repmat(PlXYZb(3),[3,1]),FitCoefB2A(:,1),FitCoefB2A(:,2),FitCoefB2A(:,3));
                    PlXYZa=PlXYZb+Wave1; % Center in RatioA
                    
%                     PlXYZb=PlXYZb-FileinfoRatioB.UmStart{1}(:,1);
                    PlXYZa=PlXYZa-FileinfoRatioA.UmStart{1}(:,1);
                end
                for Ver=1:size(Version,1)
% Ver=3;
                    VerId=Version(Ver);
                    ChannelInfo2=ChannelInfo(find(ChannelInfo.Version==VerId),:);
                    for Ch=1:size(ChannelInfo2,1)
                        Ind=find(strcmp(ChannelInfo2.ChannelName{Ch,1},Data3D.ChannelName)); % Ind=find(strcmp(ChannelInfo2.Channel,Data3D.Channel)&strcmp(ChannelInfo2.D2D,Data3D.D2D));
                        Pix=size(Data3D.Data{Ind,1}).';
                        SizeUm=ChannelInfo2.SizeUm{Ch,1};
                        Res=ChannelInfo.Res{Ch,1};
                        if strfind1(ChannelInfo2.Properties.VariableNames.','D2D')==0
                            CenterPix=round(PlaqueListSingle3.PixCenter{Pl}.*Fileinfo.Res{1}./Res);
                        elseif strfind1(ChannelInfo2.Properties.VariableNames.',{'D2DRatioA';'D2DRatioB';'D2DTrace';'D2DDeFinB'})==0
                            CenterPix=round((PlXYZa./Res));
                        else
                            keyboard;
                        end
                        
                        SquarePix=round2odd(SizeUm./Res);
                        CenterPixPaste=(SquarePix+1)/2;
                        [Cut,Paste]=pixelOverhang(CenterPix,SquarePix,CenterPixPaste,Pix);
                        
                        Wave1=zeros(SquarePix.','uint16');
                        Wave1(Paste(1,1):Paste(1,2),Paste(2,1):Paste(2,2),Paste(3,1):Paste(3,2))=Data3D.Data{Ind}(Cut(1,1):Cut(1,2),Cut(2,1):Cut(2,2),Cut(3,1):Cut(3,2));
                        
                        if strfind1(ImageGeneration,'ImarisStack')
                            Data3D.Data(Ind)={Wave1};
                        else
                            ChannelInfo2.IntensityData{Ch,1}=max(Wave1,[],3);
                            if strfind1(ChannelInfo2.Properties.VariableNames.','ColorChannel')~=0 && isempty(ChannelInfo2.ColorChannel{Ch})==0
                                Ind=strfind1(Data3D.Channel,ChannelInfo2.ColorChannel{Ch,1},1);
                                Wave1=zeros(SquarePix.','uint16');
                                Wave1(Paste(1,1):Paste(1,2),Paste(2,1):Paste(2,2),Paste(3,1):Paste(3,2))=Data3D.Data{Ind}(Cut(1,1):Cut(1,2),Cut(2,1):Cut(2,2),Cut(3,1):Cut(3,2));
                                ChannelInfo2.ColorData{Ch,1}=max(Wave1,[],3);
                            end
                        end
                    end
                    if strfind1(ImageGeneration,'ImarisStack')
                        FilenameTotal=['TimeLine','_M',num2str(MouseId),'_Version',num2str(VerId),'.ims'];
                        Res=Data3D.Res{1};
                        Pix=size(Data3D.Data{1}).';
                        [PathRaw,Report]=getPathRaw(FilenameTotal);
                        if Report==0
                            J=struct;J.PixMax=[Pix(1);Pix(2);Pix(3);0;2]; J.Resolution=Res; J.Path2file=W.PathImarisSample;
                            Application=openImaris_2(J); Application.SetVisible(1);
                            Application.FileSave(PathRaw,'writer="Imaris5"');
                            quitImaris(Application);
                            clear Application;
                        end
                        Wave1=Data3D.Data{strcmp(Data3D.ChannelName,'Membership'),1};
                        Wave2=Data3D.Data{strcmp(Data3D.ChannelName,'DistInOut'),1};
                        Wave1(Wave2>50)=0;
                        Data3D(end+1,{'ChannelName';'Data'})={{'PlaqueID'},Wave1};
                        Data3D(strfind1(Data3D.Channel,{'Membership';'DistInOut'}),:)=[];
                        for m=1:size(Data3D,1)
                            ex2Imaris_2(Data3D.Data{m,1},FilenameTotal,Data3D.ChannelName{m,1},Time);
% %                             imarisSaveHDFlock(FilenameTotal);
                        end
                    end
                    if strfind1(ImageGeneration,'EachPlaque')
                        FilenameTotal=[PlaqueListSingle3.TreatmentType{Pl,1},'_M',num2str(MouseId),'_Pl',num2str(Pl),'_Time',num2str(TimeId),'_',PlaqueListSingle3.Filename{Pl,1},'_Version',num2str(VerId)];
                        Path2file=[W.G.PathOut,'\ImageGenerator\',TargetFolder,'\'];
                        if strfind1(ImageGeneration,'RadiusBin')
                            Wave1=str2num(ImageGeneration{1}(strfind(ImageGeneration{1},'RadiusBin')+9));
                            Wave2=ceil(PlaqueListSingle3.PlaqueRadius(Pl)/Wave1)*Wave1;
                            Path2file=[Path2file,num2str(Wave2),'um\'];
                        end
                        mkdir(Path2file);
                        Path2file=[Path2file,FilenameTotal,'.jpg'];
                        imageGenerator_2(ChannelInfo2,Path2file,[],struct('Rotate',-90));
                    end
                    Wave1=find(PlaqueListSingle.MouseId==MouseId&strcmp(PlaqueListSingle.Filename,PlaqueListSingle3.Filename{Pl,1})&PlaqueListSingle.PlId==PlId&PlaqueListSingle.Time==TimeId);
                    PlaqueListSingle.ImageGenerator(Wave1,Ver)={ChannelInfo2};
                    
                end
            end
        end
        if strfind1(ImageGeneration,'PlaqueTimeLine') && strfind1(PlaqueListSingle.Properties.VariableNames.','ImageGenerator')
            for Pl=1:size(PlaqueListSingle3,1)
                PlId=PlaqueListSingle3.PlId(Pl);
                Wave1=find(PlaqueListSingle.MouseId==MouseId&PlaqueListSingle.RoiId==RoiId&PlaqueListSingle.PlId==PlId&isempty_2(PlaqueListSingle.ImageGenerator(:,1))~=1);
                PlaqueListSingle4=PlaqueListSingle(Wave1,:);
                if size(PlaqueListSingle4,1)==0;break;end;
                for Ver=1:size(Version,1)
                    VerId=Version(Ver);
                    ChannelInfo2=PlaqueListSingle4.ImageGenerator{1,Ver};
                    for m=2:size(PlaqueListSingle4,1)
                        for n=1:size(ChannelInfo2,1)
                            ChannelInfo2.IntensityData(n,1)={[ChannelInfo2.IntensityData{n,1};PlaqueListSingle4.ImageGenerator{m,Ver}.IntensityData{n,1}]};
                            try; ChannelInfo2.ColorData(n,1)={[ChannelInfo2.ColorData{n,1};PlaqueListSingle4.ImageGenerator{m,Ver}.ColorData{n,1}]}; end;
                        end
                    end
                    FilenameTotal=['M',num2str(MouseId),'_Pl',num2str(Pl),'_',PlaqueListSingle3.Filename{Pl,1},'_Version',num2str(VerId)];
                    Path2file=[W.G.PathOut,'\ImageGenerator\',TargetFolder,'\PlaqueTimeLine\'];
                    mkdir(Path2file);
                    Path2file=[Path2file,FilenameTotal,'.jpg'];
                    imageGenerator_2(ChannelInfo2,Path2file,[],struct('Rotate',-90));
                end
            end
        end
    end
end
% keyboard;
% show all plaques sorted by size in each mouse printable as DinA4
ShowAllPlaqueDinA4=0
if ShowAllPlaqueDinA4==1
    dystrophyDetection_visualizeIndividualPlaques_AllPlaqueDinA4(PlaqueListSingle,MouseIds,MouseInfo,TargetFolder,Version);
end