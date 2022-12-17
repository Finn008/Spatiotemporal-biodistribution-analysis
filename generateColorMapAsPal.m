function generateColorMapAsPal()


OutputPath=[W.G.PathFinn,'\Raw data\Imaris color tables\New\'];

ColorMap=zeros(256,3);
ColorMap=repmat((0:255).',[1,3]);

% darkBlue,lightBlue until 50 with 5µm bins, then black gray until 255
MapName='Distance1';
[Excel,Workbook,Sheets,SheetNumber]=connect2Excel([W.G.PathFinn,'\Raw data\ColorMaps.xlsx']);
Data=xlsActxGet(Workbook,MapName,1);
ColorMap=Data{:,{'R';'G';'B'}};


dlmwrite([OutputPath,MapName,'.pal'],ColorMap,'precision','%.3f');




dlmwrite([OutputPath,MapName,'.pal'],ColorMap.');
dlmwrite([OutputPath,MapName,'.pal'],ColorMap,' ','precision',4);

dlmwrite([OutputPath,MapName,'.pal'],ColorMap,'delimiter','\t','precision',3,'roffset',1);

dlmwrite('myFile.txt',M,'delimiter','\t','precision',3)
% dlmwrite([OutputPath,MapName,'.pal'],ColorMap,' ',size(ColorMap,1));
% dlmwrite([OutputPath,MapName,'.pal'],ColorMap,' ',size(ColorMap,2));
% ColorMap=ColorMap/255;

cmap2pal(ColorMap);
% cmap2pal(ColorMap,'Path',[OutputPath,MapName,'.pal']);

M = magic(5);
dlmwrite([OutputPath,MapName,'.txt'],M,'delimiter',' ');
