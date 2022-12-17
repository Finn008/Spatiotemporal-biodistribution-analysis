function [data]=unpack(spotInfo,property,classes,pix)
global l; global w; dbstop if error;

TotalNumberOfSpots=size(spotInfo,1);
if isempty(property);
    spotValues=spotInfo.Volume; spotValues(:)=1;
    digNumber=1;
elseif ischar(property);
    if strcmp(property,'Volume')
        if ischar(classes);
            if strcmp(classes,'round')
                spotValues=round(spotInfo.Volume);
                digNumber=max(spotValues);
            end
            if strcmp(classes,'ceil')
                spotValues=ceil(spotInfo.Volume);
                digNumber=max(spotValues);
            end
            if strcmp(classes,'spotID')
                spotValues=(1:TotalNumberOfSpots).';
                digNumber=TotalNumberOfSpots;
            end
        elseif isnumeric(classes);
            spotValues=spotInfo.Volume;
            for m=1:size(classes,1);
                spotValues(spotValues<=classes(m))=classes(m);
            end
            if max(spotValues(:))>classes(end);
                disp('unclassified spots');
                return;
            end
            digNumber=size(classes,1);
        end
    end
end

if digNumber==1;
    data=false(pix(1),pix(2),pix(3));
elseif digNumber < 256;
    data=zeros(pix(1),pix(2),pix(3),'int8');
elseif digNumber < 65536;
    data=zeros(pix(1),pix(2),pix(3),'int16');
end

for m=1:TotalNumberOfSpots;
    data(spotInfo.pixPos{m}(1),spotInfo.pixPos{m}(2),spotInfo.pixPos{m}(3))=spotValues(m);
end
a1=1;