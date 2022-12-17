function generateKochplan()
dbstop if error; global w; global Excel;
return;

% get list of chosen recipies
raw=Excel.sheets.Item(w.sheetNames.chooser).UsedRange.value;
recipyList=cell2table(raw(2:end,:));
recipyList.Properties.VariableNames=raw(1,:);

% put chosen recepies in right order and with correct amount into Kochliste
chosenRecipies=find(recipyList.number>0);

Kochliste=cell(size(w.allRecipies,1),0);
for m=1:size(chosenRecipies,1)
    Kochliste(:,m*2-1:m*2)=w.allRecipies(:,chosenRecipies(m)*2-1:chosenRecipies(m)*2);
    Kochliste{3:end,m*2}=str2num(Kochliste{3:end,m*2}.*recipyList.number(chosenRecipies(m));
end
Kochliste(2,:)=[];
% multiply amount with number


% insert unity into name





xlsActxWrite(Kochliste,Excel,w.sheetNames.Kochliste);

% from chosen recipies generate list of all required ingredients






% from allRecipies extract all ingredients and replace each with a number

for m = 1:size(raw,1)
    
end
a1=1;