function [out]=replaceMixedCell(in,this,that)

out=in;

if strcmp(this,'nan')
    out(cellfun(@(x) any(isnan(x)),out)) = that;
elseif isempty(this)
    out(cellfun(@(x) any(isempty(x)),out)) = that;
end