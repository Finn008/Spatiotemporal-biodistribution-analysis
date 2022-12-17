function deleteFile(Path2file)

Path=['del "',Path2file,'"'];
for m=1:15
    [Status,Cmdout]=dos(Path);
    if isempty(Cmdout)
        break;
    end
    pause(60);
end