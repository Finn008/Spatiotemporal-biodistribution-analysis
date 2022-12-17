function heapSizeMemory()
keyboard;
% get heap size memory
oldMaxHeapSize = com.mathworks.services.Prefs.getIntegerPref('JavaMemHeapMax')

% set heap size Memory
com.mathworks.services.Prefs.setIntegerPref('JavaMemHeapMax', 16000)