% pixIn,umMinMaxIn,filename
function [out]=resAdjust(in)
dbstop if error; global w; global l;
out=struct;
[fileinfo,a2,a3]=GetFileInfo(in.filename);
out.res=fileinfo.res{1};
% umMinMaxFile=[fileinfo.umStart{1},fileinfo.umEnd{1}];

if exist('in.pixIn','var')==0; in.pixIn=[]; end;

if isempty(in.pixIn) % calculate from um
   out.pixMinMax(:,1)=floor(in.umMinMax(:,1)./out.res);
   out.pixMinMax(:,2)=ceil(in.umMinMax(:,2)./out.res);
   out.umMinMax=out.pixMinMax.*[out.res,out.res];
   out.um=out.umMinMax(:,2)-out.umMinMax(:,1);
   out.pix=out.um./out.res;
elseif isempty(in.umMinMax)
    
end
