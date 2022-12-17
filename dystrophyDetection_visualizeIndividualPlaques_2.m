% check function generateTimelineStacks_AllPlaquesPerTimepoint_2(Mouse,MouseInfo,PlaqueListSingle)
% previously: dystrophyDetection_visualizeIndividualPlaques_2(MouseInfo,PlaqueListSingle,Version,DataType,Selection)
function dystrophyDetection_visualizeIndividualPlaques_2(MouseInfo,PlaqueListSingle,Struct)
global W;
v2struct(Struct);
if exist('ImageGeneration','Var')~=1
    ImageGeneration='EachPlaque';
end
PlaqueListSingle(ismember(PlaqueListSingle.TreatmentType,{'NB360';'TauKD'}),:)=[];

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
if find(Version==4)
    Wave1={'Version',4;'Channel','VglutGreen';'D2D','D2DRatioA';'Colormap','Spectrum1';'IntensityMinMax',[0;15000];'ColorChannel','Dystrophies2Radius';'ColorMinMax',[0;30];'Res',[0.1;0.1;0.4]};
    ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
end
if find(Version==5)
    Wave1={'Version',5;'Channel','VglutGreen';'D2D','D2DRatioA';'Colormap',[0.5;1;0];'IntensityMinMax',[0;15000];'Res',[0.1;0.1;0.4]};
    ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
end
if find(Version==6)
    Wave1={'Version',6;'Channel','MetBlue';'D2D','D2DRatioB';'Colormap',[0;0.5;1];'IntensityMinMax',[0;30];'IntensityGamma',1;'Res',[0.2;0.2;0.4]};
    ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
end
if strfind1(ChannelInfo.Properties.VariableNames.','SizeUm',1)==0
    ChannelInfo.SizeUm(:,1)={[100;100;0.4]};
end
if strfind1(ChannelInfo.Properties.VariableNames.','Res',1)==0
    ChannelInfo.Res(:,1)={[]};
end

MouseIds=unique(PlaqueListSingle.MouseId);
for Mouse=3:size(MouseIds,1)
    MouseId=MouseIds(Mouse);
    PlaqueListSingle2=PlaqueListSingle(PlaqueListSingle.MouseId==MouseId & isempty_2(PlaqueListSingle.UmCenter)==0,:);
    RoiIds=unique(PlaqueListSingle2.RoiId);
    for Roi=1:size(RoiIds,1)
%         Roi=3;
        RoiId=RoiIds(Roi);
        Timepoints=unique(PlaqueListSingle2.Time(PlaqueListSingle2.RoiId==floor(RoiId)));
        for Time=1:size(Timepoints,1)
%             Time=15;
            TimeId=Timepoints(Time);
            PlaqueListSingle3=PlaqueListSingle2(find(PlaqueListSingle2.Time==TimeId & PlaqueListSingle2.RoiId==floor(RoiId)),:);
            % load the intensity data
            % in vivo
            if strfind1(ChannelInfo.Properties.VariableNames.','D2D')~=0
                Filename=PlaqueListSingle3.Filenames{1,2};
                if isempty(Filename); continue; end;
                [D2DDeFinAgreen,D2DDeFinAred,D2DRatioA,D2DRatioB,D2DTrace,FitCoefTrace2B,FitCoefB2A,Res,UmMinMax]=getRotationDrift(Filename,TimeId);
                if isempty(D2DDeFinAgreen);continue; end;
                Data3D=ChannelInfo(:,{'Channel';'D2D';'Res'});
                Data3D(end+1:end+size(ChannelInfo,1),Data3D.Properties.VariableNames)=ChannelInfo(:,{'ColorChannel';'D2D';'Res'});
                Data3D(isempty_2(Data3D.Channel),:)=[];
                [~,Wave1]=unique(Data3D.Channel);
                Data3D=Data3D(Wave1,:);
%                 if strfind1(ChannelInfo.Properties.VariableNames.','Res',1) && isempty(ChannelInfo.Res{})==0
%                     Res=ChannelInfo.Res{};
%                 else
%                     Res=[];
%                 end
                for m=1:size(Data3D,1)
                    Wave1=eval(Data3D.D2D{m});
                    Wave1.Tres=Data3D.Res{m};
                    Data3D.Data(m,1)={applyDrift2Data_4(Wave1,Data3D.Channel{m,1})};
                end
%                 Pix=size(Data3D{1,3}).';
            else
                % ex vivo
                keyboard; %check if works
                FilenameTotal=regexprep(PlaqueListSingle3.Filename{1},{'.lsm';'.czi'},{'.ims'});
                [Fileinfo]=getFileinfo_2(FilenameTotal);
                Res=Fileinfo.Res{1};
                Pix=Fileinfo.Pix{1};
                if min(ismember(ChannelInfo.Channel,Fileinfo.ChannelList{1}))==0; continue; end;
                for Ch=1:size(ChannelInfo,1)
                    IntensityData3D(Ch,1)={im2Matlab_3(FilenameTotal,ChannelInfo.Channel{Ch})};
                    if strfind1(ChannelInfo.Properties.VariableNames.','ColorChannel')~=0 && isempty(ChannelInfo.ColorChannel{Ch})==0
                        ColorData3D(Ch,1)={im2Matlab_3(FilenameTotal,ChannelInfo.ColorChannel{Ch})};
                    end
                end
            end
            
            for Pl=1:size(PlaqueListSingle3,1)
                %                 Pl=3;
                PlId=PlaqueListSingle3.PlId(Pl);
                
                if strfind1(ChannelInfo.Properties.VariableNames.','D2D')~=0
                    UmCenter=PlaqueListSingle3.UmCenter{Pl};
                    [Wave1]=YofBinFnc(repmat(UmCenter(3),[3,1]),FitCoefTrace2B(:,1),FitCoefTrace2B(:,2),FitCoefTrace2B(:,3));
                    PlXYZb=UmCenter+Wave1;
                    [Wave1]=YofBinFnc(repmat(PlXYZb(3),[3,1]),FitCoefB2A(:,1),FitCoefB2A(:,2),FitCoefB2A(:,3));
                    PlXYZa=PlXYZb+Wave1;
                end
                for Ver=1:size(Version,1)
                    VerId=Version(Ver);
                    ChannelInfo2=ChannelInfo(find(ChannelInfo.Version==VerId),:);
                    for Ch=1:size(ChannelInfo2,1)
                        Ind=find(strcmp(ChannelInfo2.Channel,Data3D.Channel)&strcmp(ChannelInfo2.D2D,Data3D.D2D));
                        Pix=size(Data3D.Data{Ind,1}).';
                        SizeUm=ChannelInfo2.SizeUm{Ch,1};
%                         if strfind1(ChannelInfo.Properties.VariableNames,'Res',1) && isempty(ChannelInfo.Res{Ch,1})==0
                        Res=ChannelInfo.Res{Ch,1};
%                         end
                        if strfind1(ChannelInfo2.Properties.VariableNames.','D2D')==0
                            CenterPix=PlaqueListSingle3.PixCenter{Pl};
                        elseif strcmp(ChannelInfo2.D2D{Ch},'D2DRatioA')
                            CenterPix=round((PlXYZa-UmMinMax(:,1))./Res);
                        elseif strcmp(ChannelInfo2.D2D{Ch},'D2DRatioB')
                            CenterPix=round((PlXYZb-UmMinMax(:,1))./Res);
                        else
                            keyboard;
                        end
                        
                        SquarePix=round2odd(SizeUm./Res);
                        CenterPixPaste=(SquarePix+1)/2;
                        [Cut,Paste]=pixelOverhang(CenterPix,SquarePix,CenterPixPaste,Pix);
                        
                        
                        Wave1=zeros(SquarePix.','uint16');
                        Wave1(Paste(1,1):Paste(1,2),Paste(2,1):Paste(2,2),Paste(3,1):Paste(3,2))=Data3D.Data{Ind}(Cut(1,1):Cut(1,2),Cut(2,1):Cut(2,2),Cut(3,1):Cut(3,2));
                        ChannelInfo2.IntensityData{Ch,1}=max(Wave1,[],3);
                        if strfind1(ChannelInfo2.Properties.VariableNames.','ColorChannel')~=0 && isempty(ChannelInfo2.ColorChannel{Ch})==0
                            Ind=find(strcmp(ChannelInfo2.ColorChannel,Data3D.Channel(:))&strcmp(ChannelInfo2.D2D,Data3D.D2D(:)));
                            Wave1=zeros(SquarePix.','uint16');
                            Wave1(Paste(1,1):Paste(1,2),Paste(2,1):Paste(2,2),Paste(3,1):Paste(3,2))=Data3D.Data{Ind}(Cut(1,1):Cut(1,2),Cut(2,1):Cut(2,2),Cut(3,1):Cut(3,2));
                            ChannelInfo2.ColorData{Ch,1}=max(Wave1,[],3);
                        end
                        if strfind1(ImageGeneration,'EachPlaque')
                            FilenameTotal=['M',num2str(MouseId),'_Roi',num2str(RoiId),'_Pl',num2str(Pl),'_Time',num2str(TimeId),'_',PlaqueListSingle3.Filenames{Pl,1},'_Version',num2str(VerId)];
                            Path2file=[W.G.PathOut,'\ImageGenerator\EachPlaque\',FilenameTotal,'.jpg'];
                            imageGenerator_2(ChannelInfo2,Path2file,[],struct('Rotate',-90));
                        end
                        Wave1=find(PlaqueListSingle.MouseId==MouseId&PlaqueListSingle.RoiId==RoiId&PlaqueListSingle.PlId==PlId&PlaqueListSingle.Time==TimeId);
                        PlaqueListSingle.ImageGenerator(Wave1,Ver)={ChannelInfo2};
                    end
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
                    FilenameTotal=['M',num2str(MouseId),'_Roi',num2str(RoiId),'_Pl',num2str(Pl),'_',PlaqueListSingle3.Filenames{Pl,1},'_Version',num2str(VerId)];
                    Path2file=[W.G.PathOut,'\ImageGenerator\PlaqueTimeLine\',FilenameTotal,'.jpg'];
                    imageGenerator_2(ChannelInfo2,Path2file,[],struct('Rotate',-90));
                end
            end
        end
% % %         PlaqueListSingle(:,'ImageGenerator')=[];
    end
end

keyboard;