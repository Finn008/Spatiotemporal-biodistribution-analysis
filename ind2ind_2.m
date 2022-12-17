function LinInd2=ind2ind_2(LinInd1,Pix1,Pix2)

Factor=Pix1./Pix2;
[XYZ(:,1),XYZ(:,2),XYZ(:,3)]=ind2sub(Pix1,LinInd1);
XYZ=round(XYZ./repmat(Factor.',[size(XYZ,1),1]));
XYZ(XYZ==0)=1;
LinInd2=sub2ind(Pix2,XYZ(:,1),XYZ(:,2),XYZ(:,3));