function dystrophyDetection_visualizeIndividualPlaques(MouseInfo,PlaqueListSingle,Version,DataType,Selection)
global W;

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

SquareUm=[100;100;1]; % µm
ChannelInfo=table;
if Version==1
    ChannelInfo(1,{'Channel','Colormap','ColorMinMax'})={'MetBlue',{[0;1;1]},{[0;40000]}};
    ChannelInfo(2,{'Channel','Colormap','ColorMinMax'})={DataType,{[1;0;1]},{[0;30000]}}; % Iba1
    ChannelInfo(3,{'Channel','Colormap','ColorMinMax','ImageAdjustment'})={'DistInOut',{[1;1;1]},{[0;1]},'PlaqueBorder'};
elseif Version==2
%     ChannelInfo(1,{'Channel','Colormap','ColorMinMax'})={'MetBlue',{'Black2Blue2White'},{[0;30000]}};
    ChannelInfo(1,{'Channel','Colormap','ColorMinMax'})={'MetBlue',{[0;1;1]},{[0;30000]}};
    ChannelInfo(2,{'Channel','Colormap','ColorMinMax'})={DataType,{[1;0;1]},{[0;20000]}}; % Iba1: 30000
%     ChannelInfo(2,{'Channel','Colormap','ColorMinMax'})={DataType,{[1;0;1]},{[0;30000]}}; % Iba1
elseif Version==3 % BACE1 stainings for TauKO paper
    SquareUm=[100;100;0.4]; % µm
    ChannelInfo(1,{'Channel','Colormap','ColorMinMax'})={'MetBlue',{'Black2Blue2White'},{'Norm100'}};
    ChannelInfo(2,{'Channel','Colormap','ColorMinMax'})={DataType,{[1;0;1]},{[0;15000]}}; % Iba1: 30000
end


MouseIds=unique(PlaqueListSingle.MouseId);
for MouseId=MouseIds.'
    PlaqueListSingle2=PlaqueListSingle(PlaqueListSingle.MouseId==MouseId,:);
    Rois=unique(PlaqueListSingle2.RoiId);
    for Roi=Rois.'
        PlaqueListSingle3=PlaqueListSingle2(PlaqueListSingle2.RoiId==Roi,:);
        FilenameTotal=regexprep(PlaqueListSingle3.Filename{1},{'.lsm';'.czi'},{'.ims'});
        [Fileinfo]=getFileinfo_2(FilenameTotal);
        Res=Fileinfo.Res{1};
        Pix=Fileinfo.Pix{1};
        if min(ismember(ChannelInfo.Channel,Fileinfo.ChannelList{1}))==0; continue; end;
        for Ch=1:size(ChannelInfo,1)
            ChannelData(Ch,1)={im2Matlab_3(FilenameTotal,ChannelInfo.Channel{Ch})};
        end
        
        for Pl=1:size(PlaqueListSingle3,1)
            PlId=PlaqueListSingle3.PlId(Pl);
            CenterPix=PlaqueListSingle3.PixCenter{Pl};
            SquarePix=round2odd(SquareUm./Res);
                        
            CenterPixPaste=(SquarePix+1)/2;
            [Cut,Paste]=pixelOverhang(CenterPix,SquarePix,CenterPixPaste,Pix);
            for Ch=1:size(ChannelInfo,1)
                Wave1=zeros(SquarePix.','uint16');
                Wave1(Paste(1,1):Paste(1,2),Paste(2,1):Paste(2,2),Paste(3,1):Paste(3,2))=ChannelData{Ch,1}(Cut(1,1):Cut(1,2),Cut(2,1):Cut(2,2),Cut(3,1):Cut(3,2));
                ChannelInfo.Data{Ch,1}=max(Wave1,[],3);
            end
            
            Path2file=[W.G.PathOut,'\DystrophieDetection\',regexprep(FilenameTotal,'.ims',''),'_Pl',num2str(PlaqueListSingle3.PlId(Pl)),'_Rad',num2str(round(PlaqueListSingle3.PlaqueRadius(Pl),1)),'.jpg'];
            imageGenerator(ChannelInfo,Path2file);
        end
    end
end
