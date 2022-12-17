function [DataOut,Changes]=getMouseInfo_TierbaseFormat(Data,MouseLine,CurrentData)
LineFound=0;

DataOut=table;
DataOut.Number(1)=Data.AnimalNum;

DataOut.Birthdate(1)={datestr(datenum(Data.Birthdate{1}),'dd.mm.yyyy')};
DataOut.Sex(1)=Data.Sex{1};

DataOut.MouseLine(1)={MouseLine};

Genotype=Data.Genotype{1};
%% APP23-GFPM
if strcmp(MouseLine,'APP23-GFPM')
    
    if strcmp(Genotype,'+/T      +/T      ')
        DataOut.APP23(1)={'+T'};
        DataOut.GFPM(1)={'+T'};
        DataOut.Genotype(1)={'+23+T'};
    elseif strcmp(Genotype,'+/T      +/+      ')
        DataOut.APP23(1)={'+T'};
        DataOut.GFPM(1)={'++'};
        DataOut.Genotype(1)={'+23++'};
    elseif strcmp(Genotype,'+/+      +/T      ')
        DataOut.APP23(1)={'++'};
        DataOut.GFPM(1)={'+T'};
        DataOut.Genotype(1)={'+++T'};
    elseif strcmp(Genotype,'+/+      +/+      ')
        DataOut.APP23(1)={'++'};
        DataOut.GFPM(1)={'++'};
        DataOut.Genotype(1)={'++++'};
    elseif strcmp(Genotype,'')
    else
        keyboard;
    end
    LineFound=1;
end
%% APP23-VKIN
if strcmp(MouseLine,'APP23-VKIN')
    if strcmp(Genotype,'+/d      +/T      ')
        DataOut.VKIN(1)={'+T'};
        DataOut.APP23(1)={'+T'};
        DataOut.Genotype(1)={'+d+23'};
    elseif strcmp(Genotype,'d/d      +/T      ')
        DataOut.VKIN(1)={'TT'};
        DataOut.APP23(1)={'+T'};
        DataOut.Genotype(1)={'dd+23'};
    elseif strcmp(Genotype,'+/T      ')
        DataOut.VKIN(1)={'TT'};
        DataOut.APP23(1)={'+T'};
        DataOut.Genotype(1)={'dd+23'};
    elseif strcmp(Genotype,'+/+      ')
        DataOut.VKIN(1)={'TT'};
        DataOut.APP23(1)={'++'};
        DataOut.Genotype(1)={'dd++'};
    elseif strcmp(Genotype,'d/d      +/+      ')
        DataOut.VKIN(1)={'TT'};
        DataOut.APP23(1)={'++'};
        DataOut.Genotype(1)={'dd++'};
    else
        keyboard;
    end
    LineFound=1;
end
%% GFPM
if strcmp(MouseLine,'GFPM')
    if strcmp(Genotype,'+/+      ')
        DataOut.GFPM(1)={'++'};
        DataOut.Genotype(1)={'++'};
    elseif strcmp(Genotype,'+/T      ')
        DataOut.GFPM(1)={'+T'};
        DataOut.Genotype(1)={'+T'};
    elseif strcmp(Genotype,'')
        
    else
        keyboard;
    end
    LineFound=1;
end
%% PS1
if strcmp(MouseLine,'PS1')
    if strcmp(Genotype,'+/+      ')
        DataOut.APPPS1(1)={'++'};
        DataOut.Genotype(1)={'++'};
    elseif strcmp(Genotype,'+/T      ')
        DataOut.APPPS1(1)={'+T'};
        DataOut.Genotype(1)={'+T'};
    elseif strcmp(Genotype,'')
    else
        keyboard;
    end
    LineFound=1;
end
%% PS1-VKIN
if strcmp(MouseLine,'PS1-VKIN')
    if strcmp(Genotype,'+/d      +/+      ')
        DataOut.VKIN(1)={'+T'};
        DataOut.APPPS1(1)={'+T'};
        DataOut.Genotype(1)={'dd+T'};
    elseif strcmp(Genotype,'d/d      +/T      ')
        DataOut.VKIN(1)={'TT'};
        DataOut.APPPS1(1)={'+T'};
        DataOut.Genotype(1)={'dd+T'};
    elseif strcmp(Genotype,'+/+      +/+      ')
        DataOut.VKIN(1)={'++'};
        DataOut.APPPS1(1)={'++'};
        DataOut.Genotype(1)={'++++'};
    elseif strcmp(Genotype,'d/d      +/+      ')
        DataOut.VKIN(1)={'TT'};
        DataOut.APPPS1(1)={'++'};
        DataOut.Genotype(1)={'dd++'};
    elseif strcmp(Genotype,'')
    elseif strcmp(Genotype,'+/d      +/T      ')
        DataOut.VKIN(1)={'+T'};
        DataOut.APPPS1(1)={'+T'};
        DataOut.Genotype(1)={'+d+T'};
    elseif strcmp(Genotype,'?/?      +/T      ')
        DataOut.VKIN(1)={'??'};
        DataOut.APPPS1(1)={'+T'};
        DataOut.Genotype(1)={'??+T'};
    elseif strcmp(Genotype,'d/d      ?/?      ')
        DataOut.VKIN(1)={'TT'};
        DataOut.Genotype(1)={'dd??'};
    elseif strcmp(Genotype,'+/+      +/T      ')
        DataOut.VKIN(1)={'++'};
        DataOut.APPPS1(1)={'+T'};
        DataOut.Genotype(1)={'+++T'};
    elseif strcmp(Genotype,'?/?      +/+      ')
        DataOut.VKIN(1)={'??'};
        DataOut.APPPS1(1)={'++'};
        DataOut.Genotype(1)={'??++'};
    elseif strcmp(Genotype,'+/+      ')
        DataOut.VKIN(1)={'??'};
        DataOut.APPPS1(1)={'++'};
        DataOut.Genotype(1)={'??++'};
    elseif strcmp(Genotype,'+/T      ')
        DataOut.VKIN(1)={'??'};
        DataOut.APPPS1(1)={'+T'};
        DataOut.Genotype(1)={'??+T'};
    else
        keyboard;
    end
    LineFound=1;
end

%% PS1-VKIN-tauKO
if strcmp(MouseLine,'PS1-VKIN-tauKO')
    if strcmp(Genotype,'wt/ko    +/T      +/+      ')
        DataOut.TauKO(1)={'+K'};
        DataOut.APPPS1(1)={'+T'};
        DataOut.VKIN(1)={'++'};
        DataOut.Genotype(1)={'+K+T++'};
    elseif strcmp(Genotype,'wt/ko    +/+      +/+      ')
        DataOut.TauKO(1)={'+K'};
        DataOut.APPPS1(1)={'++'};
        DataOut.VKIN(1)={'++'};
        DataOut.Genotype(1)={'+K++++'};
    elseif strcmp(Genotype,'wt/wt    +/T      +/d      ')
        DataOut.TauKO(1)={'++'};
        DataOut.APPPS1(1)={'+T'};
        DataOut.VKIN(1)={'+T'};
        DataOut.Genotype(1)={'+++T+d'};
    elseif strcmp(Genotype,'ko/ko    +/+      +/+      ')
        DataOut.TauKO(1)={'KK'};
        DataOut.APPPS1(1)={'++'};
        DataOut.VKIN(1)={'++'};
        DataOut.Genotype(1)={'KK++++'};
    elseif strcmp(Genotype,'ko/ko    +/T      +/+      ')
        DataOut.TauKO(1)={'KK'};
        DataOut.APPPS1(1)={'+T'};
        DataOut.VKIN(1)={'++'};
        DataOut.Genotype(1)={'KK+T++'};
    elseif strcmp(Genotype,'ko/ko    +/T      ?/?      ')
        DataOut.TauKO(1)={'KK'};
        DataOut.APPPS1(1)={'+T'};
        DataOut.VKIN(1)={'??'};
        DataOut.Genotype(1)={'KK+T??'};
    elseif strcmp(Genotype,'ko/ko    +/+      +/d      ')
        DataOut.TauKO(1)={'KK'};
        DataOut.APPPS1(1)={'++'};
        DataOut.VKIN(1)={'+T'};
        DataOut.Genotype(1)={'KK+++d'};
    elseif strcmp(Genotype,'ko/ko    +/T      +/d      ')
        DataOut.TauKO(1)={'KK'};
        DataOut.APPPS1(1)={'+T'};
        DataOut.VKIN(1)={'+T'};
        DataOut.Genotype(1)={'KK+T+d'};
    elseif strcmp(Genotype,'wt/ko    +/T      +/d      ')
        DataOut.TauKO(1)={'+K'};
        DataOut.APPPS1(1)={'+T'};
        DataOut.VKIN(1)={'+T'};
        DataOut.Genotype(1)={'+K+T+d'};
    elseif strcmp(Genotype,'wt/ko    +/+      +/d      ')
        DataOut.TauKO(1)={'+K'};
        DataOut.APPPS1(1)={'++'};
        DataOut.VKIN(1)={'+T'};
        DataOut.Genotype(1)={'+K+++d'};
    elseif strcmp(Genotype,'wt/ko    +/+      d/d      ')
        DataOut.TauKO(1)={'+K'};
        DataOut.APPPS1(1)={'++'};
        DataOut.VKIN(1)={'TT'};
        DataOut.Genotype(1)={'+K++dd'};
    elseif strcmp(Genotype,'ko/ko    +/+      d/d      ')
        DataOut.TauKO(1)={'KK'};
        DataOut.APPPS1(1)={'++'};
        DataOut.VKIN(1)={'TT'};
        DataOut.Genotype(1)={'KK++dd'};
    elseif strcmp(Genotype,'ko/ko    +/T      d/d      ')
        DataOut.TauKO(1)={'KK'};
        DataOut.APPPS1(1)={'+T'};
        DataOut.VKIN(1)={'TT'};
        DataOut.Genotype(1)={'KK+Tdd'};
    elseif strcmp(Genotype,'+/T               ')
        DataOut.TauKO(1)={'??'};
        DataOut.APPPS1(1)={'+T'};
        DataOut.VKIN(1)={'??'};
        DataOut.Genotype(1)={'??+T??'};
    elseif strcmp(Genotype,'+/+               ')
        DataOut.TauKO(1)={'??'};
        DataOut.APPPS1(1)={'++'};
        DataOut.VKIN(1)={'??'};
        DataOut.Genotype(1)={'??++??'};
    elseif strcmp(Genotype,'?/?      ')
        DataOut.TauKO(1)={'??'};
        DataOut.APPPS1(1)={'??'};
        DataOut.VKIN(1)={'??'};
        DataOut.Genotype(1)={'??????'};
    elseif strcmp(Genotype,'wt/ko    +/T      d/d      ')
        DataOut.TauKO(1)={'+K'};
        DataOut.APPPS1(1)={'+T'};
        DataOut.VKIN(1)={'TT'};
        DataOut.Genotype(1)={'+K+Tdd'};
    elseif strcmp(Genotype,'')
    else
        keyboard;
    end
    LineFound=1;
end

%% VKIN
if strcmp(MouseLine,'VKIN')
    
    if strcmp(Genotype,'d/d      ')
        DataOut.VKIN(1)={'TT'};
        DataOut.Genotype(1)={'dd'};
    elseif strcmp(Genotype,'')
    else
        keyboard;
    end
    LineFound=1;
end
%% dE9-GFPM
if strcmp(MouseLine,'dE9-GFPM')
    
    if strcmp(Genotype,'+/T      +/T      ')
        DataOut.GFPM(1)={'+T'};
        DataOut.dE9(1)={'+T'};
        DataOut.Genotype(1)={'+G+dE9'};
    elseif strcmp(Genotype,'+/+      +/T      ')
        DataOut.GFPM(1)={'++'};
        DataOut.dE9(1)={'+T'};
        DataOut.Genotype(1)={'+++dE9'};
        elseif strcmp(Genotype,'+/+      +/+      ')
        DataOut.GFPM(1)={'++'};
        DataOut.dE9(1)={'++'};
        DataOut.Genotype(1)={'++++'};
        elseif strcmp(Genotype,'+/T      +/+      ')
        DataOut.GFPM(1)={'+T'};
        DataOut.dE9(1)={'++'};
        DataOut.Genotype(1)={'+G++'};
    elseif strcmp(Genotype,'')
    else
        keyboard;
    end
    LineFound=1;
end

%% APP23-Bace1KO
if strcmp(MouseLine,'APP23-Bace1KO')
    if strcmp(Genotype,'+/T      wt/ko    ')
        DataOut.APP23(1)={'+T'};
        DataOut.Bace1KO(1)={'+K'};
        DataOut.Genotype(1)={'+23+K'};
    elseif strcmp(Genotype,'+/+      wt/ko    ')
        DataOut.APP23(1)={'++'};
        DataOut.Bace1KO(1)={'+K'};
        DataOut.Genotype(1)={'+23+K'};
    elseif strcmp(Genotype,'')
    else
        keyboard;
    end
    LineFound=1;
end
%%
if LineFound==0
    keyboard;
    %     elseif strcmp(MouseLine,'GFPM')
    %     if strcmp(Genotype,'')
    %         DataOut.GFPM(1)={'++'};
    %         DataOut.Genotype(1)={'++'};
    %     else
    %         keyboard;
    %     end
end

if exist('CurrentData')
    Changes=table;
    VariableNames=DataOut.Properties.VariableNames.';
    for m=1:size(VariableNames,1)
        try
            Before=CurrentData{1,VariableNames{m}};
        catch
            Before='';
        end
        After=DataOut{1,VariableNames{m}};
        Wave1=isequal(Before,After);
        if Wave1==0
            Changes(end+1,{'VariableName','Before','After'})={{VariableNames{m}},{Before},{After}};
        end
    end
end
Changes.Number(:,1)=Data.AnimalNum;
Changes.MouseLine(:,1)={MouseLine};

% keyboard;