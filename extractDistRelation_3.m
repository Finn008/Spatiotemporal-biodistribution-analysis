% Relationship: 1-everything else, 2-besides plaque, 3-above plaque, 4-below Plaque, 5-Blood
function [Co]=extractDistRelation_3(ReadOuts,Res,FilenameTotalFusedStack)
global W;

if exist('FilenameTotalFusedStack')==1; GenerateFusedStack=1; else; GenerateFusedStack=0; end;
cprintf('text','extractDistRelation: ');

MaskInfo=ReadOuts(strfind1(ReadOuts.CalcType,'Mask',1),:);
ReadOuts=ReadOuts(strfind1(ReadOuts.CalcType,'Data'),:);
Pix=size(MaskInfo.ApplyD2D{1}).';
ReadOuts(size(ReadOuts,1)+1,{'Name','Identity','CalcType','ChannelName','ApplyD2D'})={{'Volume'},{'Channel'},{'Data'},{'Volume'},{ones(Pix.','uint8')}};

% load masks
for m=1:size(MaskInfo,1)
    Wave1=MaskInfo.ApplyD2D{m};
    if isstruct(Wave1)==1
        MaskData{m,1}=applyDrift2Data_4(Wave1,MaskInfo.ChannelName{m,1});
    elseif ischar(Wave1)
        MaskData{m,1}=im2Matlab_3(Wave1,MaskInfo.ChannelName{m,1});
    elseif isnumeric(Wave1)
        MaskData{m,1}=Wave1;
    end
    clear Wave1;
    if GenerateFusedStack==1
        if m==1
            J=struct;
            J.PixMax=size(MaskData{m,1}).';
            J.UmMinMax=[-J.PixMax.*Res/2,J.PixMax.*Res/2];
            J.Path2file=W.PathImarisSample;
            Application=openImaris_2(J);
            Application.FileSave(getPathRaw(FilenameTotalFusedStack),'writer="Imaris5"');
            quitImaris(Application); clear Application;
        end
        
        ex2Imaris_2(MaskData{m,1},FilenameTotalFusedStack,MaskInfo.Name{m,1});
    end
end

Pix=size(MaskData{1,1}).';
if istable(ReadOuts)==0
    Wave1=ReadOuts;
    ReadOuts=table;
    ReadOuts.Name=Wave1(:,1);
    ReadOuts.Identity=cell2mat(Wave1(:,2));
end

Co=struct;
DistRelation=table; % plaques in rows
Co.PlaqueIDs=unique(MaskData{strfind1(MaskInfo.Name,'Membership'),1}(:));
Co.PlaqueIDs(Co.PlaqueIDs==0)=[];
Co.Res3D=prod(Res);

for iRead=1:size(ReadOuts,1)
    cprintf('text',[ReadOuts.Name{iRead,1},',']);
    if strcmp(ReadOuts.Identity(iRead,1),'Channel')
        Wave1=ReadOuts.ApplyD2D{iRead};
        if isstruct(Wave1)==1
            Wave1.Tpix=Pix;
            Data=applyDrift2Data_4(Wave1,ReadOuts.ChannelName{iRead,1});
        elseif ischar(Wave1)
            Data=im2Matlab_3(Wave1,ReadOuts.ChannelName{iRead,1});
        elseif isnumeric(Wave1) || islogical(Wave1)
            Data=Wave1;
        end
        clear Wave1;
        if GenerateFusedStack==1
            ex2Imaris_2(Data,FilenameTotalFusedStack,ReadOuts.Name{iRead,1});
        end
    end
    
    if strcmp(ReadOuts.Identity(iRead,1),'StatisticsStorage')
        FilenameTotal=ReadOuts.ApplyD2D{iRead}.FilenameTotal;
        Fileinfo=getFileinfo_2(FilenameTotal);
        Path=[FilenameTotal,'_Statistics',ReadOuts.ChannelName{iRead,1},'.mat'];
        Path=getPathRaw(Path);
        Statistics=load(Path);
        Statistics=Statistics.Statistics;
        if isstruct(Statistics)==0
            Statistics=struct('ObjInfo',Statistics);
        end
        
        if strfind1(Statistics.ObjInfo.Properties.VariableNames.','PixXYZ') % if Spots
            try; Rotate=ReadOuts.ApplyD2D{iRead,1}.Rotate; catch; Rotate=[]; end;
            [~,Statistics.ObjInfo.PixXYZ,Statistics.ObjInfo.Ind]=umXYZ2pixXYZ(Statistics.ObjInfo{:,{'PositionX','PositionY','PositionZ'}},Fileinfo.UmStart{1}.',Fileinfo.UmEnd{1}.',Pix.',Rotate);
            Statistics.ObjInfo.DistInOut=MaskData{1}(Statistics.ObjInfo.Ind);
            Statistics.ObjInfo.Membership=MaskData{2}(Statistics.ObjInfo.Ind);
            Statistics.ObjInfo.Relationship=MaskData{3}(Statistics.ObjInfo.Ind);
        end
        
        Path=['Co.Statistics.',ReadOuts.Name{iRead,1},'=Statistics;'];
        eval(Path);
        if GenerateFusedStack==1
            Wave1=zeros(Pix.','uint8');
            Wave1(Statistics.ObjInfo.Ind)=Statistics.ObjInfo.RadiusX*200; % Diameter µm/100
            ex2Imaris_2(Wave1,FilenameTotalFusedStack,ReadOuts.Name{iRead,1});
            clear Wave1;
        end
        continue;
    end
    
    if max(Data(:))<=255 && strcmp(class(Data),'uint16')
        Data=uint8(Data);
    end
    if strcmp(ReadOuts.CalcType{iRead,1},'Data')
        Out=accumarray_9(MaskData,Data,@sum);
        Out.Properties.VariableNames={'DistInOut';'Membership';'Relationship';ReadOuts.Name{iRead,1}}.';
    elseif strcmp(ReadOuts.CalcType{iRead,1},'Data2')
        Out=accumarray_9([MaskData;{Data}],[],@sum);
        Out.Properties.VariableNames={'DistInOut';'Membership';'Relationship';['Num',ReadOuts.Name{iRead,1}];ReadOuts.Name{iRead,1}}.';
    end
    
    RowList=[];
    for m=1:size(Out,2)-1
        RowList=strcat(RowList,num2strArray_3(Out{:,m}),',');
    end
    DistRelation{RowList,Out.Properties.VariableNames}=Out{:,Out.Properties.VariableNames};
end

if exist('Application')==1
    quitImaris(Application);
    clear Application;
end
Co.DistRelation=DistRelation;
cprintf('text','\n');