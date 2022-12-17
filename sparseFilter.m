function [Data,OrigData]=sparseFilter(Data,Exclude,Res,VoxelNumber,FilterRadius,ResCalc,Percentile,SubtractBackground)
% % % tic;
OrigData=Data;
Pix=size(Data).';
Um=Pix.*Res;
PixRadius=round(FilterRadius./Res);

IndX=round(linspace(1,Pix(1),Um(1)/ResCalc(1))).';
IndY=round(linspace(1,Pix(2),Um(2)/ResCalc(2))).';
IndZ=round(linspace(1,Pix(3),Um(3)/ResCalc(3))).';
if isempty(IndZ)
    IndZ=round(Pix(3)/2);
end
PixCalc=[size(IndX,1);size(IndY,1);size(IndZ,1)];
Counter=0;

Data2=zeros(PixCalc(1),PixCalc(2),PixCalc(3),'single');
NanVoxels=zeros(0,1);
tic
for Zi=1:size(IndZ,1)
% %     disp([num2str(Zi),' ',num2str(round(toc)),'s']);
    tic;
    Z=IndZ(Zi);
    for Xi=1:size(IndX,1)
        X=IndX(Xi);
        for Yi=1:size(IndY,1)
            Y=IndY(Yi);
            Start=[X;Y;Z]-PixRadius;
            End=[X;Y;Z]+PixRadius;
            Start(Start<1)=1;
            End(End>Pix)=Pix(End>Pix);
            Range=End-Start+1;
            Ind=round(linspace(1,prod(Range),VoxelNumber));
            
            [Wave1,Wave1(2,:),Wave1(3,:)]=ind2sub(Range.',Ind);
            Wave1=[Wave1(1,:)+Start(1);Wave1(2,:)+Start(2);Wave1(3,:)+Start(3)]-1;
            Ind=sub2ind(Pix.',Wave1(1,:),Wave1(2,:),Wave1(3,:));
            if isempty(Exclude)==0
                Ind(:,Exclude(Ind)==1)=[];
            end
            if exist('Percentile')==1
                try
                    Data2(Xi,Yi,Zi)=prctile(Data(Ind),Percentile);
                catch
                    Data2(Xi,Yi,Zi)=NaN;
                end
            else
                Data2(Xi,Yi,Zi)=mean(Data(Ind));
            end
        end
        
    end
% % %     if Counter>=0
% % %         disp(prod(PixCalc).*toc/60);
% % %         Counter=Counter+1;
% % %     end
end

Xt=round(linspace(1,PixCalc(1),Pix(1))).';
Yt=round(linspace(1,PixCalc(2),Pix(2))).';
Zt=round(linspace(1,PixCalc(3),Pix(3))).';
Data=single(Data);
Data(:,:,:)=Data2(Xt,Yt,Zt);
% % % % toc;
if exist('SubtractBackground')~=1
    SubtractBackground='None';
end

if strcmp(SubtractBackground,'Subtract')
    keyboard; % how to treat NaN values?
    MinMax=[min(Data(:));max(Data(:))];
    OrigData=uint16(single(OrigData)-single(Data)+single(MinMax(2)));
elseif strfind(SubtractBackground,'Multiply')
    Factor=str2num(regexprep(SubtractBackground,'Multiply',''));
    OrigData=single(OrigData)./Data*Factor;
    OrigData=uint16(OrigData); % NaN become zero
end


