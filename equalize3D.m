function [Data3D2]=equalize3D(Data3D,Inclusion,Res,ChunkUm,Percentile)


Pix=size(Data3D).';
Um=Pix.*Res;

Data3D2=zeros(Pix(1),Pix(2),Pix(3),'uint8');


% PercentilePlane=zeros(0,0);
[Range]=gridding3D(Pix,Res,[ChunkUm;ChunkUm]);
for Xind=1:size(Range{1},1)
    X=Range{1}(Xind,:);
    for Yind=1:size(Range{2},1)
        Y=Range{2}(Yind,:);
        Chunk=Data3D(X(1):X(2),Y(1):Y(2),:);
        InMask=Inclusion(X(1):X(2),Y(1):Y(2),:);
        Wave1=Chunk(InMask==1);
        Perc=prctile(Wave1,Percentile);
%         [Out]=getHistograms_3([],Chunk,InMask);
%         Perc=Out.Percentiles.a(Percentile);
%         PercentilePlane(size(PercentilePlane,1)+1,1)=Perc;
        PercentilePlane(Xind,Yind)=Perc;
%         PercentilePlane(X(1):X(2),Y(1):Y(2),:)=Perc;
        Chunk2=Chunk>=Perc;
        Data3D2(X(1):X(2),Y(1):Y(2),:)=Chunk2;
    end
%     disp(Xind);
end

% PercentilePlane=reshape(PercentilePlane,[size(Range{1},1),size(Range{2},1)])
keyboard;
ex2ex_2(flip(PercentilePlane.'));
return;

% % SubPix=10;
% ChunkNumber=round(Um(1:2)/ChunkUm);
% % ChunkUm=Um(1:2)./Wave1;
% 
% Xrange=round(linspace(1,Pix(1)+1,ChunkNumber(1)).');
% Xrange(1:end-1,2)=Xrange(2:end,1)-1;
% Xrange(end,:)=[];
% 
% Yrange=round(linspace(1,Pix(1)+1,ChunkNumber(1)).');
% Yrange(1:end-1,2)=Yrange(2:end,1)-1;
% Yrange(end,:)=[];

for X=1:size(Xrange,1)
    for Y=1:size(Yrange,1)
%         X1=(X-1)*SubPix+1;
%         X2=X*SubPix;
%         Y1=(Y-1)*SubPix+1;
%         Y2=Y*SubPix;
        Chunk=Data3D(Xrange(X,1):Xrange(X,2),Yrange(Y,1):Yrange(Y,2),:);
        InMask=Inclusion(Xrange(X,1):Xrange(X,2),Yrange(Y,1):Yrange(Y,2),:);
        
%         Wave1=Chunk(InMask==1);
%         Wave1=sort(Wave1);
        [Out]=getHistograms_3([],Chunk,InMask);
        PercTable=table;
        PercTable.SourceValue=Out.Percentiles.a;
        for m=1:size(Out.Percentiles,1)
            PercTable.TargetValue(m,1)=str2num(Out.Percentiles.Properties.RowNames{m,1});
        end
        PercTable(100,:)=[];
        
        
        Wave1=str2num();
        Percentiles=Out.Percentiles.a;
        ChunkCopy=Chunk;
%         Wave1=Out.Percentiles.Properties.RowNames;
%         Wave2=num2cell((1:size(Wave1,1)).');
%         In=[Wave1,Wave2];
%         PercTable=array2table(In,'VariableNames',{'Percentile','TargetValue'});
%         PercTable.TargetValue=cell2mat(PercTable.TargetValue);
%         PercTable.Percentile=num2strArray_2(PercTable.Percentile);
                
        for m=1:size(Percentiles,1)
            Chunk(ChunkCopy<=Percentile.a(m) & ChunkCopy>PercTable.SourceValue(m-1))=PercTable.TargetValue(m);
        end
        
        if strcmp(DataOutput{m,1},'IntensityBinning2D')
            for m2=1:size(Data3Dcorr,3)
                [PercTable]=generatePercTable(DataOutput{m,2},DepthCorrectionInfo,TargetChannel,m2);
                Data2D=Data3Dcorr(:,:,m2);
                Data2Dcopy=Data2D;
                Data2D(Data2Dcopy<=PercTable.SourceValue(1))=PercTable.TargetValue(1);
                for m3=2:size(PercTable,1)
                    Data2D(Data2Dcopy<=PercTable.SourceValue(m3) & Data2Dcopy>PercTable.SourceValue(m3-1))=PercTable.TargetValue(m3);
                end
                Data3Dcorr(:,:,m2)=Data2D;
            end
        end
        
        
    end
end


