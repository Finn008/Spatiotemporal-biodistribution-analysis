function [Out]=extractStringPart(String,Version)

if strfind(Version,'Date_')
    DateStr=Version(6:end);
    for m=1:size(String,2)
        String2=String(m:m+size(DateStr,2)-1);
        if isequal(strfind(String2,'.'),[5,8]) && str2num(String2(1:4))>2000 && str2num(String2(6:7)) < 13 && str2num(String2(9:10))<32
            Out=String2;
            break;
        end
    end
elseif strcmp(Version,'FileFamilyName')
    Out=table;
    % find_
    UnderlinePos=strfind(String,'_').';
    UnderlinePos=UnderlinePos(end);
    % find numeric after :
    [Wave1]=extractStringPart(String,'InterspersedNumbers');
    Wave1=Wave1(Wave1.Type==1,:);
    
    Wave2=find(Wave1.StartPos>UnderlinePos);
    Out=Wave1.Content{Wave2,1};
    
elseif strcmp(Version,'Separate_')
    UnderlinePos=strfind(String,'_').';
    UnderlinePos=[0;UnderlinePos;size(String,2)+1];
    
    for m=1:size(UnderlinePos,1)-1
        Out(m,1)={String(UnderlinePos(m)+1:UnderlinePos(m+1)-1)};
    end
    
elseif strcmp(Version,'MasterGain')
    Out=table;
    if isempty(str2num(String))==0
        Out.MasterGain=[str2num(String);str2num(String)];
    end
    % find :
    DoubleDotPos=strfind(String,':').';
    % find numeric after :
    [Wave1]=extractStringPart(String,'InterspersedNumbers');
    Wave1=Wave1(Wave1.Type==1,:);
    for m=1:size(DoubleDotPos,1)
        Wave2=find(Wave1.StartPos>DoubleDotPos(m,1));
        Out.MasterGain(m,1)=Wave1.Numeric(Wave2(1),1);
    end
elseif strcmp(Version,'Lasers')
    Out=struct;
    % find %
    PercPos=strfind(String,'%').';
    % find numeric after :
    [Wave1]=extractStringPart(String,'InterspersedNumbers');
    Wave1=Wave1(Wave1.Type==1,:);
    Out.Wavelength=Wave1.Numeric(1,1);
    Out.Transmission=Wave1.Numeric(2:end,1);
elseif strcmp(Version,'InterspersedNumbers')
    J=table;
    J.Letters=String.';
    for m=1:size(J,1)
        J.IsChar(m,1)=isempty(str2num(J.Letters(m,1))) || strcmp(J.Letters(m,1),'i');
        J.IsDot(m,1)=strcmp(J.Letters(m,1),'.').';
    end
    % replace dots surrounded with numeric with numeric
    for m=find(J.IsDot==1).'
        if sum(J.IsChar(m-1:m+1),1)==1
            J.IsChar(m,1)=0;
        end
    end
    
    % detect numeric startpoints
    J.PartChange=logical(J.IsChar-[2;J.IsChar(1:end-1,1)]);
    Parts=table;
    Parts.StartPos=find(J.PartChange==1);
    Parts.EndPos=[Parts.StartPos(2:end)-1;size(J,1)];
    for m=1:size(Parts,1)
        Parts.Content{m,1}=String(1,Parts.StartPos(m,1):Parts.EndPos(m,1));
        Wave1=str2num(Parts.Content{m,1});
        if isempty(Wave1)
            Parts.Type(m,1)=0;
        else
            Parts.Type(m,1)=1;
%             Parts.Content{m,1}=Wave1;
            Parts.Numeric(m,1)=Wave1;
        end
    end
    Out=Parts;
end


