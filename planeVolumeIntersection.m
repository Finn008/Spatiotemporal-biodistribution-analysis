function Volume=planeVolumeIntersection(Fit,UmMinMax,Distance,ResCalc,Layer)


Xaxis=(UmMinMax(1,1):ResCalc:UmMinMax(1,2));
Yaxis=(UmMinMax(2,1):ResCalc:UmMinMax(2,2)).';
AreaSize=[size(Xaxis,2);size(Yaxis,1)];
Xaxis=repmat(Xaxis,[AreaSize(2),1]);
Yaxis=repmat(Yaxis,[AreaSize(1),1]);
Xaxis=reshape(Xaxis,[prod(size(Xaxis)),1]);

Zaxis=zeros(AreaSize(1),AreaSize(2));
Zaxis(:)=feval(Fit,Xaxis,Yaxis);

for m=1:size(Distance,1)
    ZaxisTop=Zaxis+Distance(m,2);
    ZaxisDown=Zaxis+Distance(m,1);
    ZaxisTop(ZaxisTop>UmMinMax(3,2))=UmMinMax(3,2);
    ZaxisDown(ZaxisDown<UmMinMax(3,1))=UmMinMax(3,1);
    ZaxisSum=ZaxisTop-ZaxisDown;
    ZaxisSum(ZaxisSum<0)=0;
    Volume(m,1)=sum(ZaxisSum(:)*ResCalc^2);
end

if exist('Layer')==1
    Volume=Volume-[0;Volume(1:end-1)];
end


% keyboard;