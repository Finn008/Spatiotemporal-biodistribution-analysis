function [Co]=getVariableSize(Input,Name)
global W;
SizeLimit=0.1;
if exist('Input')~=1
    Input=W.G;
    Name='WG';
end

Special='None'; % Special='InitialUpperCase';
% keyboard;
Path2ProxyMat=getPathRaw('Proxy1.mat');
% Path2ProxyMat=[W.G.ComputerInfo.Path2RawData{strcmp(W.G.ComputerInfo.Name,W.ComputerName)},'\Proxy.mat'];
PathExcelExport=getPathRaw('VariableSize.xlsx');
[~,Workbook]=connect2Excel(PathExcelExport);


% Path2ProxyMat='D:\Finn\Proxy.mat';
Path=[Name,'=Input;'];
eval(Path);
Path={Name};
Co=table(Path);

Co.ParentMB=9999999999999999999;

Ind=1;
DisplayTimer=datenum(now);
DisplayExcel=datenum(now);
while Ind~=0
    
    [MaxValue,Ind]=max(Co.ParentMB);
    if MaxValue<SizeLimit
        break;
    end
    if DisplayTimer<datenum(now)-(1/24/60/60*30) % display MaxValue every 30s
        disp(MaxValue);
        DisplayTimer=datenum(now);
    end
    if DisplayExcel<datenum(now)-(1/24/60*5) % export Excel table every 10min
%         keyboard;
        Wave1=Co(find(Co.RealMB~=0),:);
        xlsActxWrite(Wave1,Workbook,Name,[],'Delete');
        Workbook.Save;
        
        DisplayExcel=datenum(now);
        clear Wave1;
    end
    Path=['Proxy=',Co.Path{Ind},';'];
    eval(Path);
    S=whos('Proxy');
    Co.MB(Ind,1)=S.bytes/1000000;
    Co.ParentMB(Ind,1)=0;
    Co.Class{Ind,1}=S.class;
    if S.bytes/1000000<SizeLimit % everything smaller than 1kB not chunked further
%         keyboard;
        continue;
    end
    
    save(Path2ProxyMat,'Proxy');
    Wave1=dir(Path2ProxyMat);
    Co.RealMB(Ind,1)=Wave1.bytes/1000000;
    
    Co2Add=table;
    if iscell(Proxy);
        RowNumber=size(Proxy,1);
        ColumnNumber=size(Proxy,2);
        LayerNumber=size(Proxy,3);
        for n=1:RowNumber
            for o=1:ColumnNumber
                for p=1:LayerNumber
                    if isempty(Proxy{n,o,p})
                    elseif iscell(Proxy{n,o,p}) || istable(Proxy{n,o,p}) || isstruct(Proxy{n,o,p})
                        Co2Add.Path{size(Co2Add,1)+1,1}=[Co.Path{Ind,1},'{',num2str(n),',',num2str(o),',',num2str(p),'}'];
                    end
                end
            end
        end
    end
    if istable(Proxy);
        if strcmp(Special,'InitialUpperCase');
            [Proxy]=renameFields(Proxy);
            Path=[Co.Path{Ind},'=Proxy;'];
            eval(Path);
        end
        Fields=Proxy.Properties.VariableNames.';
        FieldNumber=size(Proxy,2);
        for f=1:FieldNumber % go through columns
            Co2Add.Path{size(Co2Add,1)+1,1}=[Co.Path{Ind,1},'.',Fields{f,1}];
        end
        
    end
    if isstruct(Proxy);
        if strcmp(Special,'InitialUpperCase');
            [Proxy]=renameFields(Proxy);
            Path=[Co.Path{Ind},'=Proxy;'];
            eval(Path);
        end
        Fields=fieldnames(Proxy);
        FieldNumber=size(Fields,1);
        RowNumber=size(Proxy,1);
        for n=1:RowNumber
            for f=1:FieldNumber;
                Co2Add.Path{size(Co2Add,1)+1,1}=[Co.Path{Ind,1},'(',num2str(n),',1)','.',Fields{f,1}];
            end
        end
        
    end
    if isempty(Co2Add)==0
        Co2Add.ParentMB(1)=Co.MB(Ind,1);
        Co2Add.ParentMB(:)=Co2Add.ParentMB(1);
        [Co]=fuseTable_2(Co,Co2Add);
    end    
end
Wave1=Co(find(Co.RealMB~=0),:);
xlsActxWrite(Wave1,Workbook,Name,[],'Delete');
Workbook.Save;

keyboard; % save W.G.SizeG under W

iFileChanger('W.G.SizeG',Co);
