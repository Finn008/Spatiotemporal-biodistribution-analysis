function mouseAdder()
global w; global l;dbstop if error;
t=l.t(w.task,:);
f=l.t.f{w.task}(w.file,:);
xls_check_if_open(t.targetFile{1},'close'); % close Excel file if it is open

% load input excel file
path=[l.g.pathRaw{1},'\',f.filename{1},'.xlsx'];
[iNum,iTxt,iRaw] = xlsread(path,1);
iColumnNames={'ianimalID';'imouse';'ibreedUnit';'istrain';'isex';'icharacter';'iearmark';'icage4F';'ilitterNo';'iBdate';'imother';'ifather';'igenotype';'icomments';'iuse';'ihealthStatus';'iDead';'iDdate';'igenNum';'ireserved';'iethicsProject'};
for m=1:size(iColumnNames,1);
    path=[iColumnNames{m},'=iRaw(3:end-1,m);'];
    eval(path);
end

% convert iBdate
iBdate = regexprep(iBdate, '-MAR-', '.03.');
iBdate = regexprep(iBdate, '-MAY-', '.05.');
iBdate = regexprep(iBdate, '-OCT-', '.10.');
iBdate = regexprep(iBdate, '-DEC-', '.12.');
iAge=now-datenum(iBdate,'dd.mm.yyyy'); iAge=iAge/365*12; iAge=num2cell(iAge);
% convert iGenotype
igenotype = regexprep(igenotype, ' ', '');
igenotype = regexprep(igenotype, '/', '');
igenotype = regexprep(igenotype, 'wt', '+');
igenotype = regexprep(igenotype, 'ko', 'K');

% load target Excel sheet
% % MyExcel    = actxserver('Excel.Application');
% % MyExcel.Visible = 1;
% % Workbook = MyExcel.Workbooks.Open(a.targetFile);

[num,txt,raw] = xlsread(t.targetFile{1},1);

columnNames={'mouse';'mouseLine';'genotype';'sex';'Bdate';'location';'cage4F';'mother';'father';'reserved';'comments'};
allColumnNames=raw(1,:).';
for m=1:size(columnNames,1);
%     disp(m);
    columnNames{m,2}=find(ismember(allColumnNames,columnNames(m)));
    columnNames{m,3}=num2abc(columnNames{m,2});
end
for m=1:size(columnNames,1);
    path=[columnNames{m,1},'=raw(2:end,columnNames{m,2});'];
    eval(path);
    % replace nan with empty
    path=[columnNames{m,1},'(cellfun(@(',columnNames{m,1},') any(isnan(',columnNames{m,1},')),',columnNames{m,1},')) = {''''};'];
    eval(path);
    % generate output stuff
    path=['o',columnNames{m,1},'=',columnNames{m,1},';'];
    eval(path);
end

mouseList=mouse;
for m=1:size(mouseList,1);
    % remove mice that are not in 4th floor or not of the correct genotype
    if strcmp(mouseLine{m},f.filename{1})==0;
        mouseList{m}=-1;
    else % for all mice of correct genotype set all floor4 to floor4dead
        olocation(m) = regexprep(olocation(m), 'present4F', 'dead4F');
    end
end

for m=1:size(imouse,1);
    ind=find([mouseList{:}]==imouse{m});
    if isempty(ind); % not yet in the list
        ind=size(omouse,1)+1;
    % skip mice not marked as dead4F
    elseif strcmp(olocation{ind},'dead4F')==0; 
        continue
    end
    
    for n=1:size(columnNames,1);
        if strcmp(columnNames{n,1},'mouseLine');
            value={f.filename{1}};
        elseif strcmp(columnNames{n,1},'location');
            value={'present4F'};
        else
            value = eval(['i',columnNames{n,1},'(m);']);
        end
        path=['o',columnNames{n,1},'(ind)=value;']; eval(path);
    end
end

MyExcel    = actxserver('Excel.Application');
MyExcel.Visible = 1;
Workbook = MyExcel.Workbooks.Open(t.targetFile{1});
MySheet  = MyExcel.ActiveWorkBook.Sheets.Item(1);
for m=1:size(omouse,1);
    for n=1:size(columnNames,1);
        try
            path=['value=',columnNames{n,1},'(m);']; eval(path);
        catch; end;
        path=['ovalue=o',columnNames{n,1},'(m);']; eval(path);
        equality = cellfun(@strcmp, value, ovalue);
        equality = isequaln(value,ovalue);
        if equality~=1;
            xlRange = [columnNames{n,3},num2str(m+1),':',columnNames{n,3},num2str(m+1)];
            set( get(MySheet,'Range',xlRange), 'Value', ovalue);
        end
    end
end
invoke(Workbook, 'Save');
pause(5);
invoke(MyExcel, 'Quit');
delete(MyExcel);


variableSetter('l.t.f{w.task}.mouseAdder{w.file}',{'lll','done'});
w.DoReport='success';