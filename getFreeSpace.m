function [GBfree]=getFreeSpace(path)

cd(path);
[c,d] = dos('dir');
posVerzeichnisse=strfind(d,'Verzeichnis(se),')+16;
posBytesFrei=strfind(d,'Bytes frei')-1;
wave2=d(posVerzeichnisse:posBytesFrei);
wave2 = strrep(wave2, ' ', '');
wave2 = strrep(wave2, '.', '');
GBfree=str2num(wave2)/1000000000*0.9;
