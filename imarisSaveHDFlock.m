function imarisSaveHDFlock(Application,Path2file,SavePrevious)
global W;

if ischar(Application)
    if exist('Path2file')~=1
        [Path2file,Report]=getPathRaw(Application);
    end
    Application=openImaris_4(Path2file);
end
if isempty(strfind(Path2file,'\'))
    [Path2file,Report]=getPathRaw(Path2file);
end

Wave1=strfind(Path2file,'\');
Wave1=max(Wave1(:));
FilenameTotal=Path2file(Wave1+1:end);

IntermediatePath2file=strrep(Path2file,'.ims','_HDFlocked.ims');
% end

Application.FileSave(IntermediatePath2file,'writer="Imaris5"');
pause(30);
Application.SetVisible(1);

% Application.Quit();% % % 
quitImaris(Application);
if exist('SavePrevious')==1
    FilenameTotalPrevious=strrep(FilenameTotal,'.ims',[SavePrevious,'.ims']);
    Path=['rename "',Path2file,'" "',FilenameTotalPrevious,'"'];
else
    Path=['del "',Path2file,'"'];
end

for m=1:15
    [Status,Cmdout]=dos(Path);
    if isempty(Cmdout)
        break;
    end
    pause(120);
end
if isempty(Cmdout)==0
    killImaris;
    [Status,Cmdout]=dos(Path);
    disp('killImaris');
%     keyboard;
%     W.ErrorMessage='HDFlocked could not replace original file';
end
Path=['rename "',IntermediatePath2file,'" "',FilenameTotal,'"'];

[Status,Cmdout]=dos(Path);
if isempty(Cmdout)==0
    keyboard;
end



