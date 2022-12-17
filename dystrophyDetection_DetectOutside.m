function [Output]=dystrophyDetection_DetectOutside(FilenameTotal,Specimen,DataBrainArea,FilenameTotalOrig,ChannelListOrig)

timeTable('DetectOutside_Start');
global ShowIntermediateSteps;
if exist('ShowIntermediateSteps','Var') && ShowIntermediateSteps==1
    Application=FilenameTotal;
% else
%     ShowIntermediateSteps=0;
end

Fileinfo=getFileinfo_2(FilenameTotal);
Res=Fileinfo.Res{1};
Pix=Fileinfo.Pix{1};

if strcmp(Specimen,'Chunk')
    [Outside,Output]=dystrophyDetection_Outside_6(FilenameTotal,DataBrainArea,FilenameTotalOrig,ChannelListOrig);
    ex2Imaris_2(Outside,FilenameTotal,'Outside');
    % calculate thickness of brain slice
    MaxProjection=double(permute(sum(sum(Outside,1),2),[3,2,1]));
    MaxProjection=1-(MaxProjection/max(MaxProjection(:)));
    
    Output.SliceThickness=mean(MaxProjection(:))*Pix(3)*Res(3);
    Output.TotalVolume=sum(Outside(:))*prod(Res(1:3));

elseif strcmp(Specimen,'WholeSlice')
    
elseif strcmp(Specimen,'InToto')
%     [Fileinfo]=getFileinfo_2(FilenameTotal);
    

%     global Data3D;
    Data3D=im2Matlab_3(FilenameTotal,'CongoRed'); % takes roughly 20min
    Res2=[5;5;5];
    Data3D2=interpolate3D(Data3D,Res,Res2);
    
    
    Threshold=prctile(Data3D2(:),10)*4;
       
    BW=bwconncomp(Data3D2>Threshold,6);
    Table=table(cellfun(@numel,BW.PixelIdxList).',BW.PixelIdxList.','VariableNames',{'NumPix','IdxList'});
    Table.Volume=Table.NumPix*prod(Res2(1:3));
    Table=Table(Table.Volume>2000^3,:);
    Outside(:)=1;
    Outside(cell2mat(Table.IdxList))=0;
    clear BW;
%     Outside(cell2mat(Table.PixelIdxList))=0;
    
    FilenameTotal_Outside=regexprep(FilenameTotal,'.ims','_Outside.ims');
    dataInspector3D(Outside,Res2,'Outside',1,FilenameTotal_Outside,0);
%     [Application]=dataInspector3D(Data,Res,ChannelNames,Large,FilenameTotal,Visibility)
    if ShowIntermediateSteps==1; ex2Imaris_2(Data3D2,FilenameTotal_Outside,'CongoRed'); end;
%     if ShowIntermediateSteps==1; ex2Imaris_2(Outside,FilenameTotal_Outside,'Outside'); end;
%     global Data3D;
%     toc
end
