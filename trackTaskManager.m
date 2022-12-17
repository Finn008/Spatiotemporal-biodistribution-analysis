function [Out]=trackTaskManager()

[Wave1,Wave2]=memory;

Out=fuseStruct(Wave1,Wave2);
Out.AvailableRAM=Wave2.PhysicalMemory.Available;
Out.JavaHeapMemory=java.lang.Runtime.getRuntime.maxMemory;
[~,String]=system('tasklist /v /fo csv');
Out.TaskManager=readCommaDelimitedString(String);
