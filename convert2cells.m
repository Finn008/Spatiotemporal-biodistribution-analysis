function [output]=convert2cells(input)
global w; global l; dbstop if error;
output=input; % keep copy of initial array
structs2convert={output,'output'};
structNumber=1;
while structNumber<=size(structs2convert,1);
    s=whos('output');
    disp([num2str(structNumber),' ',num2str(s.bytes/1000000)]);
    
    proxy=structs2convert{structNumber};
    %     output=input;
    
    if istable(proxy);
        columnNames=proxy.Properties.VariableNames.';
        for m=1:size(proxy,2) % go through columns
            wave1=proxy{:,m};
            
            if iscell(wave1(1,1))==0
                wave1=num2cell(wave1);
            end
            
            for n=1:numel(wave1)
                if istable(wave1{n}) || isstruct(wave1{n})
                    ind=size(structs2convert,1)+1;
                    structs2convert{ind,1}=wave1{n};
                    structs2convert{ind,2}=[structs2convert{structNumber,2},'.',columnNames{m},'{',num2str(n),'}'];
                    
                end
            end
            path=[structs2convert{structNumber,2},'.',columnNames{m},'=wave1;'];
            eval(path);
        end
        
    end
    
    if isstruct(proxy);
        fields=fieldnames(proxy);
        fieldNumber=size(fields,1);
        for f=1:fieldNumber;
            path=['rowNumber=size({proxy.',fields{f},'},2);'];
            eval(path);
            
            for r=1:rowNumber;
                
                path=['wave1=proxy(r).',fields{f},';'];
                eval(path);
                if ischar(wave1);
                    wave2={wave1};
                    wave1=wave2;
                elseif isnumeric(wave1);
                    wave1=num2cell(wave1);
                elseif isstruct(wave1) || istable(wave1)
                    ind=size(structs2convert,1)+1;
                    structs2convert{ind,1}=wave1;
                    structs2convert{ind,2}=[structs2convert{structNumber,2},'(',num2str(r),').',fields{f}];
                end
                path=[structs2convert{structNumber,2},'.',fields{f},'=wave1;'];
                eval(path);
            end
        end
    end
    %     path=[structs2convert{structNumber,2},'=output'];
    %     eval(path);
    structNumber=structNumber+1;
end
a1=1;