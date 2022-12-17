% to get as max Id not the first max but the median among all the max Ids
function [MaxData]=maxID(Data)

% in 4D
Pix=size(Data);
MaxValue=max(Data,[],4);
MaxValue=repmat(MaxValue,[1,1,1,Pix(4)]);
% Data(Data~=Wave2)=0;

clear Wave1;
Wave1(1,1,1,1:Pix(4))=(1:Pix(4));
Wave1=repmat(Wave1,[Pix(1),Pix(2),Pix(3),1]);

Wave1(Data~=MaxValue)=nan;
MaxData=nanmean(Wave1,4);

