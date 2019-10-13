%read_output_annotation_tool.m

filename_out='output/Moas_arbete/generatedsweeps_4_20180406-142608.csv';

skip = 0
if ~skip
%filename='output/Moas_arbete/generatedsweeps_4_20180406-142608.csv';
%function out= read_output_annotation_tool(filename)



trID2=fopen(filename_out,'r');
scantemp=textscan(trID2,'%s');
fclose(trID2);


len = length(scantemp{1,1});
out = [];
j=0;

substring='""';
newstring='';
scantemp{1,1} = struct_string_replace(scantemp{1,1},substring,newstring); %third party code
columns =5;
for i = 2:columns:len
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

end

filename_in='~/Documents/generatedsweeps_5.csv';


trID2=fopen(filename_in,'r');
scantemp2=textscan(trID2,'%s','delimiter',',');
fclose(trID2);

len2=length(scantemp2{1,1});

input=[];
j=0;
k=0
for i=1:len2/300:len2
        %i
        j=j+1;
        input.path{j,1}=scantemp2{1,1}{i,1}(1:88);
        input.UTC_START_TIME{j,1}=scantemp2{1,1}{i,1}(89:end);
        input.curr(j,1)=str2double(scantemp2{1,1}{i+2,1});
        input.curr(j,2)=str2double(scantemp2{1,1}{i+3,1});
        input.curr(j,3)=str2double(scantemp2{1,1}{i+4,1});
        input.curr(j,4)=str2double(scantemp2{1,1}{i+5,1});
        input.curr(j,5)=str2double(scantemp2{1,1}{i+6,1});
        input.curr(j,6)=str2double(scantemp2{1,1}{i+7,1});
        
        %input.curr(j,(input.curr(j,:)==-1000))=nan;
        nanind=find(input.curr(j,:)~=-1000);

        ind_1=find(ismember(cell_listoffiles{1,1}(:),input.path(j)),1,'first');
        input.ind_1(j)=ind_1;
        
        ind_2=find(ismember(dataraw(ind_1).sweeps(:,1:6),input.curr(j,1:6),'rows'),1,'first');
        %ind_2=find(ismember(dataraw2(ind_1).sweeps(:,1:6),input.curr(j,1:6),1,'first'));
        
        if isempty(ind_2)
            temp=[];
            for ii=1:length(dataraw(ind_1).sweeps(:,1))
                if any(ismember(dataraw(ind_1).sweeps(ii,:),input.curr(j,nanind(1))))
                    ind_2=ii;
                end
            end
            
            if isempty(ind_2)
                'oh no'
                
            else
                input.ind_2(j)=ind_2;                
            end
            
            k=k+1;
            %input.curr(j,1:6);
        else
            input.ind_2(j)=ind_2;
        end

        input.UTC_START_TIME{j,1}=dataraw(ind_1).START_TIME_UTC{ind_2,1};
        
        

end

filename_out(end-3:end)='.mat';

save generatedsweeps_4_out20180406-142608.mat input out
    