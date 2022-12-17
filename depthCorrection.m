function [data4D,container]=depthCorrection(data4D,percentile,savePath,Zres)

chunkNumber=size(data4D,4);
pix=[size(data4D,1);size(data4D,2);size(data4D,3)];

pixTotal=prod(size(data4D(:,:,:,1)));
for m=1:chunkNumber
    [container]=getHistograms(data4D(:,:,:,m),0,savePath,{num2str(m)},Zres,Zres);
%     % normalize whole stack such that 20 percentile has same intensity in all depths
    selectedPercProfile=container.fittedPercentileProfile(percentile,:).';
    normSelectedPercProfile=selectedPercProfile(:)./selectedPercProfile(1);
    
    % set intensity at percentile 20 equal to intensity 100
    selectedPercProfile=container.fittedPercentileProfile(percentile,:).';
    normSelectedPercProfile=rdivide(100,selectedPercProfile(:));
    
    
    
    for n=1:pix(3)
        data4D(:,:,n,m)=data4D(:,:,n,m).*normSelectedPercProfile(n);
    end
end