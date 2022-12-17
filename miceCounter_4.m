function miceCounter_4()
Path2file='\\fs-mu.dzne.de\ag-herms\Finn Peters\aktuelle Dokumente\AnimalBreeding.xlsx';
[Excel,Workbook,Sheets,SheetNumber]=connect2Excel(Path2file);

%% ZNP import
ZNP=xlsActxGet(Workbook,'ZNP');
ZNP(1,:)=regexprep(ZNP(1,:),'Animal ID','MouseId');
ZNP(1,:)=regexprep(ZNP(1,:),'Animal Num.','MouseIdStrain');
% ZNP(1,:)=regexprep(ZNP(1,:),'Strain','MouseLine');
ZNP(1,strfind1(ZNP(1,:).','Strain',1))={'MouseLine'};
ZNP(1,:)=regexprep(ZNP(1,:),'Cage tag','CageId');

ZNP(1,:)=regexprep(ZNP(1,:),'Breed unit','BreedUnit');
ZNP(1,:)=regexprep(ZNP(1,:),'Litter_no.','LitterNumber');
ZNP(1,:)=regexprep(ZNP(1,:),'Health_Status','HealthStatus');
ZNP(1,:)=regexprep(ZNP(1,:),'Death_date','DeathDate');
ZNP(1,:)=regexprep(ZNP(1,:),'Gen_Num','GenNum');
ZNP(1,:)=regexprep(ZNP(1,:),'Ethics project','EthicsProject');
ZNP=array2table(ZNP(2:end,:),'VariableNames',ZNP(1,:));
ZNP=ZNP(:,{'Sex';'MouseId';'Birthdate';'MouseLine';'Genotype';'Father';'Mother';'CageId';'MouseIdStrain';'Comments'});

% ZNP.Number=cell2mat(ZNP.Number);
ZNP.CageId=cell2mat(ZNP.CageId);
ZNP.MouseIdStrain=cell2mat(ZNP.MouseIdStrain);
ZNP.MouseId=cell2mat(ZNP.MouseId);
ZNP.Birthdate=regexprep(ZNP.Birthdate,'-MAR-','.03.');
ZNP.Birthdate=regexprep(ZNP.Birthdate,'-OCT-','.10.');
ZNP.Birthdate=regexprep(ZNP.Birthdate,'-DEC-','.12.');
[ZNP.Sex]=replaceMixedCell(ZNP.Sex,'nan',{['']});
% Genotype
ZNP.VGLUT1(strfind1(ZNP.Genotype,{'d/d'},[],1),1)={'dd'};
ZNP.VGLUT1(strfind1(ZNP.Genotype,{'+/d'},[],1),1)={'d+'};
ZNP.TauKO(strfind1(ZNP.Genotype,{'wt/ko'},[],1),1)={'K+'};
ZNP.TauKO(strfind1(ZNP.Genotype,{'ko/ko'},[],1),1)={'KK'};
ZNP.APPPS1(strfind1(ZNP.Genotype,{'+/T'},[],1),1)={'T+'};
ZNP.APPPS1(strfind1(ZNP.Genotype,{'+/+'},[],1),1)={' ++'};



ZNP.Location(:,1)={'ZNP'};

%% CSD import
CSD=xlsActxGet(Workbook,'CSD');
CSD(1,:)=regexprep(CSD(1,:),'Tier-ID','MouseIdFull');
CSD(1,strfind1(CSD(1,:).','G',1))={'Sex'};
CSD(1,:)=regexprep(CSD(1,:),'Geb.','Birthdate');
CSD(1,:)=regexprep(CSD(1,:),'Anzahl','Number');
CSD(1,:)=regexprep(CSD(1,:),'Zuchtlinie','MouseLine');
CSD(1,:)=regexprep(CSD(1,:),'F-Gen.','FGen');
CSD(1,:)=regexprep(CSD(1,:),'ParticipatesInActiveMating','Mating');
CSD(1,:)=regexprep(CSD(1,:),'Genotyp','Genotype');
CSD(1,:)=regexprep(CSD(1,:),'Vater','Father');
CSD(1,:)=regexprep(CSD(1,:),'Mutter','Mother');
CSD(1,:)=regexprep(CSD(1,:),'N/F','NF');
CSD(1,:)=regexprep(CSD(1,:),'Käfig-ID','CageId');
CSD(1,:)=regexprep(CSD(1,:),'Käfig-Name','CageName');
CSD(1,:)=regexprep(CSD(1,:),'Standort Käfig','StandortKaefig');
CSD(1,:)=regexprep(CSD(1,:),'Verantwortliche Person','VerantwortlichePerson');

CSD=array2table(CSD(2:end,:),'VariableNames',CSD(1,:));
CSD=CSD(:,{'Mating';'Sex';'MouseIdFull';'Birthdate';'Number';'MouseLine';'Genotype';'Father';'Mother';'CageId';'CageName';'Status'});

CSD.Number=cell2mat(CSD.Number);

Wave1=zeros(size(CSD,1),1);
Wave1(find(cellfun(@isempty,CSD.CageId)==0),1)=str2num(char(CSD.CageId));
CSD.CageId=Wave1;
% CSD.CageId=cell2mat(CSD.CageId);
% CSD.CageId=str2num(CSD.CageId);
CSD.Mating=uint8(cell2mat(CSD.Mating));

Wave1=strcat(cellstr(num2str(cell2mat(CSD.MouseIdFull(strcmp(CSD.Sex,'u'))))),'//0');
% Wave1=CSD.MouseIdFull{strcmp(CSD.Sex,'u')};
% Wave1=strcat(CSD.MouseIdFull(strcmp(CSD.Sex,'u')),'//0');
% CSD.MouseIdFull(strcmp(CSD.Sex,'u'))=strcat(CSD.MouseIdFull(strcmp(CSD.Sex,'u')),'//0');
CSD.MouseIdFull(strcmp(CSD.Sex,'u'))=Wave1;
Wave1=split(CSD.MouseIdFull,'//');
% A1=Wave1{1}
% A1=cell2mat(Wave1(:,1));
% CSD.MouseId=str2num(cell2mat(Wave1(:,1)));
CSD.MouseId=str2num(char(Wave1(:,1)));
CSD.MouseIdStrain=str2num(char(Wave1(:,2)));

CSD.TauKO(strfind1(CSD.Genotype,{'Tau (MAPT): wt/ko';'Tau KO: wt/ko';'TAU: wt/ko'}),1)={'K+'};
CSD.TauKO(strfind1(CSD.Genotype,{'Tau KO: ko/ko';'TAU: ko/ko';'Tau (MAPT): ko/ko'}),1)={'KK'};
CSD.TauKO(strfind1(CSD.Genotype,{'Tau KO: wt/wt'}),1)={' ++'};
CSD.APPPS1(strfind1(CSD.Genotype,{'APP-PS1: tg(het)';'APPPS1 : tg(het)';'APPPS1: tg(het)'}),1)={'T+'};
CSD.APPPS1(strfind1(CSD.Genotype,{'APPPS1 : wt';'APPPS1: wt';'APP-PS1: wt/wt'}),1)={' ++'};
CSD.VGLUT1(strfind1(CSD.Genotype,{'VKIN: ki/ki';'VGLUT1Venus knock-in, chromosome 7: ki/ki'}),1)={'dd'};
CSD.VGLUT1(strfind1(CSD.Genotype,{'VKIN: wt/ki'}),1)={'d+'};
CSD.VGLUT1(strfind1(CSD.Genotype,{'VKIN: wt/wt'}),1)={' ++'};
CSD.Location(:,1)={'CSD'};

%% CSDexperimental import
CSDexp=xlsActxGet(Workbook,'CSDexp');
% CSDexp(:,strfind1(CSDexp(1,:).','DEAD',1))=[];
CSDexp(1,strfind1(CSDexp(1,:).','Verantw. Person',1))={'VerantwPerson'};
CSDexp(1,strfind1(CSDexp(1,:).','Lieferantenbez.',1))={'Lieferantenbez'};
CSDexp(1,strfind1(CSDexp(1,:).','Geb. Datum',1))={'Birthdate'};
CSDexp(1,strfind1(CSDexp(1,:).','Käfig-ID',1))={'CageId'};
CSDexp(1,strfind1(CSDexp(1,:).','Voraus. Versuchsende',1))={'VorausVersuchsende'};
CSDexp(1,strfind1(CSDexp(1,:).','Kennzeichnungen',1))={'MouseIdFull'};
CSDexp=array2table(CSDexp(2:end,:),'VariableNames',CSDexp(1,:));

Wave1=ismember(CSD.MouseIdFull,CSDexp.MouseIdFull);
CSD.Location(Wave1)={'CSDexp'};

CSDexp=CSDexp(ismember(CSDexp.MouseIdFull,CSD.MouseIdFull),:);

% CSDexp.CageId=regexprep(CSDexp.CageId,'','NaN');
CSDexp.CageId(isempty_2(CSDexp.CageId),1)={'NaN'};
CSDexp.CageId=str2num(char(CSDexp.CageId));

% CSDexp.CageId=cell2mat(CSDexp.CageId);

% A1=str2num(char(CSDexp.CageId));
% CSDexp.CageId=str2num(CSDexp.CageId);
% [Ind]=ismember2(Array1,Array2)
CSD.CageId(Wave1)=CSDexp.CageId(ismember2(CSD.MouseIdFull(Wave1),CSDexp.MouseIdFull));


AllGenotypes={'TauKO';'APPPS1';'VGLUT1'};
for Mouse=1:size(CSD,1)
    Wave2=cell(0,2);
    Wave1=strfind1(CSD.MouseIdFull,CSD.Mother{Mouse});
    try
       Wave2=[Wave2;[AllGenotypes,CSD{Wave1,AllGenotypes}.']];
    end
    Wave1=strfind1(CSD.MouseIdFull,CSD.Father{Mouse});
    try
       Wave2=[Wave2;[AllGenotypes,CSD{Wave1,AllGenotypes}.']];
    end
    for m=1:size(Wave2,1)
        Remove(m,1)=isnumeric(Wave2{m,2});
    end
    try
        Wave2(Remove,:)=[];
        Wave2=[Wave2(:,1),repmat({': '},[size(Wave2,1),1]),Wave2(:,2)];
        Wave2=Wave2.'; Wave2=Wave2(:).';
        Wave3=strjoin(Wave2);
        CSD.GenotypeParents(Mouse,1)={Wave3};
    end
end

CSD(strcmp(CSD.Location,'CSD')&strcmp(CSD.Status,'Bereit')==0,:)=[];


%% ListNew
ListNew=CSD;
for Col=ZNP.Properties.VariableNames
    ListNew(size(CSD,1)+1:size(CSD,1)+size(ZNP,1),Col)=ZNP(:,Col);
end
% ListNew(end+1:end+size(ZNP,1),ZNP.Properties.VariableNames)=ZNP.Properties.VariableNames;

ListNew.MouseLine(strfind1(ListNew.MouseLine,{'PS1AswxVKIN/G'}),1)={'APPPS1 x VKIN'};
ListNew.MouseLine(strfind1(ListNew.MouseLine,{'PS1APPxVKINxTau-KO';'APPPS1 x Tau KO x VKIN'}),1)={'APPPS1 x TauKO x VKIN'};
ListNew.MouseLine(strfind1(ListNew.MouseLine,{'Tau KO'}),1)={'TauKO'};
ListNew.Sex(strfind1(ListNew.Sex,{'M'}),1)={'m'};
ListNew.Sex(strfind1(ListNew.Sex,{'F'}),1)={'f'};

%% export

ListOld=xlsActxGet(Workbook,'Current',1);
ListOld.Sex=cellstr(ListOld.Sex);
% % % ListOld.MouseId=str2num(char(ListOld.MouseId));

ListOld.Present(:,1)=0;
for Mouse=1:size(ListNew,1)
%     MouseId=ListNew.MouseId{Mouse};
%     Ind=strfind1(ListOld.MouseId,MouseId,1);
    MouseId=ListNew.MouseId(Mouse);
    Ind=find(ListOld.MouseId==MouseId);
    if size(Ind,1)>1;keyboard; end;
    if isempty(Ind)
        Ind=size(ListOld,1)+1;
    end
    ListOld.Present(Ind,1)=1;
    
%     ListOld(Ind,ListNew.Properties.VariableNames)=ListNew(Mouse,ListNew.Properties.VariableNames);
    
    for Col=ListNew.Properties.VariableNames
        ListOld(Ind,Col)=ListNew(Mouse,Col);
    end
    
end
% CageRang
ListOld.CageId(isnan(ListOld.CageId))=0;
[Wave1,Wave2,Wave3]=unique(ListOld.CageId);

Wave4=rand(size(Wave1,1),1);
Wave3=Wave4(Wave3);

ListOld.CageRang=Wave3;
ListOld.CageRang(ListOld.CageId==0)=NaN;
ListOld.CageId(ListOld.CageId==0)=NaN;




% excelWriteSparse(VocList(:,{'Update'}),W.Workbook,'Vocs','WholeColumns');
VariableNames={'Mating';'Sex';'MouseId';'Birthdate';'Number';'MouseLine';'Genotype';'Father';'Mother';'CageId';'Present';'Location';'APPPS1';'TauKO';'VGLUT1';'Comments';'MouseIdStrain';'GenotypeParents';'CageRang'};
excelWriteSparse(ListOld(:,VariableNames),Workbook,'Current','WholeColumns');
% excelWriteSparse(ListOld(:,{'Mating';'Sex';'MouseId';'Birthdate';'Number';'MouseLine';'Genotype';'Father';'Mother';'CageId';'CageName'}),Workbook,1);
% keyboard;

