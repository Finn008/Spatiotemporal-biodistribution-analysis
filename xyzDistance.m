function [Distance]=xyzDistance(XYZ1,XYZ2)

XYZ1=XYZ1.';
if iscell(XYZ2)
    for m=1:size(XYZ2,1)
        Wave1(m,1:3)=XYZ2{m};
    end
    XYZ2=Wave1;
else
    XYZ2=XYZ2.';
end

Distance=XYZ2-repmat(XYZ1,[size(XYZ2,1),1]);
Distance=(Distance(:,1).^2+Distance(:,2).^2+Distance(:,3).^2).^0.5;