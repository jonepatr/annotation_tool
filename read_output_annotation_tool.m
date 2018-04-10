%read_output_annotation_tool.m
filename='output/Moas_arbete/generatedsweeps_4_20180406-142608.csv';
%function out= read_output_annotation_tool(filename)


trID2=fopen(filename,'r');
scantemp=textscan(trID2,'%s');
fclose(trID2);


len = length(scantemp{1,1});
out = [];
j=0;

substring='""';
newstring='';
scantemp{1,1} = struct_string_replace(scantemp{1,1},substring,newstring); %third party code

for i = 2:5:len
    i
    j=j+1;
    if ~isempty(scantemp{1,1}{i,1})
        out.path{j,1}=scantemp{1,1}{i,1}(1:88);
        out.UTC_START_TIME{j,1}=scantemp{1,1}{i,1}(89:end);
        out.Vph(j)=str2double(scantemp{1,1}{i+1,1});
        out.Vbar(j)=str2double(scantemp{1,1}{i+2,1});
        out.check_disturb{j,1}= scantemp{1,1}{i+3,1};
        out.check_calib{j,1}= scantemp{1,1}{i+3,1};
    else
        out.path{j,1}='';
        out.UTC_START_TIME{j,1}='';
        out.Vph(j)=nan;
        out.Vbar(j)=nan;
        out.check_disturb{j,1}='';
        out.check_calib{j,1}='';
    end
        
end

    