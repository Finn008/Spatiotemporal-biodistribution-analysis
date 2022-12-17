function initializeKochplan()
warning('off','all');
dbstop if error;

%% initialization
path2Kochplan='C:\Users\Admins\Desktop\Finns\Computer\Matlab\Kochplan\Kochplan.xlsm';
try % Check if an Excel server is running
    Excel = actxGetRunningServer('Excel.Application');
    for m = 1:Excel.Workbooks.Count % get the names of all open Excel files
        if strcmp(path2Kochplan,Excel.Workbooks.Item(m).FullName)
            %Workbooks.Item(m).Save % save changes
            %Workbooks.Item(ii).SaveAs(filename) % save changes with a different file name
            %W5orkbooks.Item(ii).Saved = 1; % if you don't want to save
            %Workbooks.Item(m).Close; % close the Excel file
            break
        end
    end
catch % If Excel is not running, "actxGetRunningServer" will result in error
    Excel = actxserver('Excel.Application');
    Excel.Visible = 1;
    invoke(Excel.Workbooks, 'open', path2Kochplan);
end

sheetNumber = Excel.sheets.count;
sheetNames2=cell(sheetNumber,1);
for m =1:sheetNumber;
    sheetNames2{m,1}=Excel.sheets.Item(m).name;
end

% get sheetnumber of each sheetname as struct
for m = 1:size(sheetNames2,1)
    path=['sheetNames.',sheetNames2{m,1},'=m;'];
    eval(path);
end
%% extract all relevant excel sheets
[allRecipies]=xlsActxGet(Excel,sheetNames.allRecipies,1,[]);
[chooser]=xlsActxGet(Excel,sheetNames.chooser,1,[]);
[ingredients]=xlsActxGet(Excel,sheetNames.ingredients,1,[]);
[location]=xlsActxGet(Excel,sheetNames.location,1,[]);
[additionally]=xlsActxGet(Excel,sheetNames.additionally,1,[]);


%% extract all recipy titles into recipyList
recipyTitles=unique(allRecipies.recipy);
allRecipiesNumber=size(recipyTitles,1);
[meals,price,number,pricePerMeal]=deal(cell(allRecipiesNumber,1));
recipyList=table(recipyTitles,meals,number,price,pricePerMeal);
recipyList = sortrows(recipyList,1);
[recipyList]=findStrValue2(chooser,'titles',recipyTitles); % enter correct number

% put chosen recipies in right order and with correct amount into Kochliste
chosenRecipies=recipyList(recipyList.number>0,:);
chosenRecipyNumber=size(chosenRecipies,1);
cookingList=cell(0,0);
purchaseList=cell(0,0);
for m=1:chosenRecipyNumber
    ingr2add=allRecipies(strcmp(allRecipies.recipy,chosenRecipies.titles{m}),:);
    % if present then cut out the Anleitung
%     ind=findInd(ingr2add.ingredients,'Anleitung');
%     if isnan(ind)==0
%         Anleitung(m,1:3)=ingr2add(ind,:);
%         ingr2add(ind,:)=[];
%     end
        
    ingr2add.recipy=[];
    ingr2add.amount=ingr2add.amount.*chosenRecipies.number(m); % multiply amount with number
    wave1=findStrValue2(ingredients,'item',ingr2add.ingredients);
    wave2=[ingr2add.ingredients,wave1.unity,num2cell(ingr2add.amount)];
    cookingList(1:size(wave2,1),size(cookingList,2)+1:size(cookingList,2)+size(wave2,2))=wave2(:,:);
    cookingListTitles{1,size(cookingList,2)}=chosenRecipies.titles{m};
    purchaseList=[purchaseList;wave2];
    
        
end
%% get Anleitung
GetAnleitung=0;
if GetAnleitung==1
    [Out1]=getXlsCell(sheetNames.Anleitung,'All',Excel);
    Anleitung=table;
    Anleitung.Title=Out1.Text(:,1);
    Anleitung.Description=Out1.Text(:,2);
    Anleitung.TextColour=Out1.TextColour(:,2);
    [AnleitungList,Ind]=findStrValue2(Anleitung,'Title',chosenRecipies.titles);
    AnleitungList(isnan(Ind),:)=[];
    
    WordTable=table;
    for m=0:size(AnleitungList,1)-1
        WordTable.Text(m*2+1,1)=AnleitungList.Title(m+1);
        WordTable.TextColour(m*2+1,1)={13107};
        WordTable.TextSize(m*2+1,1)={14};
        WordTable.Text(m*2+2,1)=AnleitungList.Description(m+1);
        WordTable.TextColour(m*2+2,1)=AnleitungList.TextColour(m+1);
        WordTable.TextSize(m*2+2,1)={11};
    end
    In.WordTable=WordTable;
    In.Filename='Anleitung.docx';
    In.Path2File='C:\Users\Admins\Desktop\Finns\Computer\Matlab\Kochplan';
    In.Filename='Anleitung.docx';
    In.Overwrite='replace';
    WriteToWordFromMatlab(In);
end

% add recipy titles to cookingList
if isempty(cookingList)==0 % if nothing selected in chooser
    purchaseList=cell2table(purchaseList,'VariableNames',{'item','unity','amount'});
    cookingList=[cookingListTitles;cookingList];
    xlsActxWrite(cookingList,Excel,sheetNames.cookingList);
    
end
purchaseList=[additionally;purchaseList];

% pool unique items
uniquePurchaseList=unique(purchaseList.item);
itemNumber=size(uniquePurchaseList,1);
amount=zeros(itemNumber,1);
for m=1:itemNumber
    amount(m,1)=sum(purchaseList.amount(strcmp(purchaseList.item,uniquePurchaseList{m})));
end
purchaseList=findStrValue2(ingredients,'item',uniquePurchaseList); % enter correct number
purchaseList.amount=amount;

% find shop and position of each item
[purchaseList]=priceAndOrder(purchaseList,location);
% remove 'meals' from purchaseList
ind=findInd(purchaseList.item,'meals');
if isnan(ind)==0
    purchaseList(ind,:)=[];
end
col=findInd((purchaseList.Properties.VariableNames.'),'order');
purchaseList = sortrows(purchaseList,col);
wave1=[purchaseList.item,num2cell(purchaseList.amount),num2cell(purchaseList.unity),purchaseList.shop,num2cell(purchaseList.price),num2cell(purchaseList.storage)];
purchaseList=cell2table(wave1,'VariableNames',{'item','amount','unity','shop','price','storage'});
%% insert Einheit into additionally
wave1=findStrValue2(ingredients,'item',additionally.item);
additionally.unity=wave1.unity;

%% export everything to excel

xlsActxWrite(recipyList,Excel,sheetNames.chooser);
xlsActxWrite(additionally,Excel,sheetNames.additionally);
xlsActxWrite(purchaseList,Excel,sheetNames.purchaseList);

release(Excel.Workbooks);
delete(Excel);

a1=1;