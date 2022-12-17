function [out]=addEmptyVar2Table(in,value,title);

rowNumber=size(in,1);
varNumber=size(value,1);
out=in;
for m=1:varNumber
    wave1=value(m,1);
    for n =1:rowNumber
        wave1(n,1)=value(m,1);
    end
%     wave1=value{m,1};
%     wave1(rowNumber,1)=wave1(1,1);
    
    path=['out.',title{m,1},'=wave1;'];
    eval(path);
end
a1=1;