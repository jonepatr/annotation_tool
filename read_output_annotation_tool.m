%read_output_annotation_tool.m


%command = strcat({'ls '}, '/Users/frejon/Documents/annotation_tool/output/Moas_arbete/*.csv',{'| grep -v "copy"'}); %I don't like this copy files. have to handle them later...
command = strcat({'ls -tr '}, '/Users/frejon/Documents/annotation_tool/output/Moas_arbete/*.csv'); %I don't like this copy files. have to handle them later...

[status,command_output] = system(command{1,1});
cell_listofsweepfiles=textscan(command_output,'%s');

for i = 1:length(cell_listofsweepfiles{1,1})
    
    fname= cell_listofsweepfiles{1,1}{i,1}
    
    
%out=  read_output_annotation_tool_part(cell_listofsweepfiles{1,1});

    stuff(i)=  read_output_annotation(fname);

end


indz=1;
Moaoutput=[];
for i = 1:length(stuff)
    delind=strcmp(stuff(i).path(:,1),'')|stuff(i).empty.';
    %delind=isempty(stuff(i).path(:,1));
    len=sum(~delind);
    indz=max(indz):(max(indz)+len-1);
    Moaoutput.path(indz)            =stuff(i).path(~delind);
    Moaoutput.UTC_START_TIME(1,indz)=stuff(i).UTC_START_TIME(~delind);
    Moaoutput.Vph(indz)             =stuff(i).Vph(~delind);
    Moaoutput.Vbar(indz)            =stuff(i).Vbar(~delind);
    Moaoutput.check_disturb(indz)   =stuff(i).check_disturb(~delind);
    Moaoutput.check_calib(indz)     =stuff(i).check_calib(~delind);
    Moaoutput.Vsc(indz)             =stuff(i).Vsc(~delind);
    Moaoutput.outputfile(indz)             =stuff(i).filename(~delind);
    %588 unique sweeps out of 714... hmmm
    %i
end



%unique handling
[~,~,idx]=unique(Moaoutput.UTC_START_TIME);
idy=1:length(Moaoutput.UTC_START_TIME);
Z= accumarray(idx(:),idy(:),[],@(n){n});

%I'm not sure how to deal with duplicates, so I'm hoping the last saved
%analysis is the most correct one. I don't think I gain anything by averaging or otherwise
Moa_last=[];
[~,idz,~] =unique(Moaoutput.UTC_START_TIME,'last');

Moa_last.path              =Moaoutput.path(idz) ;
Moa_last.UTC_START_TIME    =Moaoutput.UTC_START_TIME(1,idz);
Moa_last.Vph               =Moaoutput.Vph(idz);
Moa_last.Vbar              =Moaoutput.Vbar(idz);
Moa_last.check_disturb     =Moaoutput.check_disturb(idz) ;
Moa_last.check_calib       =Moaoutput.check_calib(idz) ;
Moa_last.Vsc               =Moaoutput.Vsc(idz);
Moa_last.outputfile        =Moaoutput.outputfile(idz);



for i=1:length(Moa_last.Vph)

    indz= find(strcmp(Moa_last.UTC_START_TIME{1,i},moa_input.utc),1,'first');

    i
    len = length(moa_input.I(indz,:));
    Moa_last.I(i,1:len)  = moa_input.I(indz,:);
    Moa_last.V(i,1:len)  = moa_input.V(indz,:);
    Moa_last.qf(i) = moa_input.qflag(indz);

    

    
    
end




% A = [9,9,9,3,3,3,3];
% [~,~,idx] = unique(A);
%  idy = 1:numel(A);
%  Z = accumarray(idx(:),idy(:),[],@(n){n});
% Z{:}


%input_stuff= read_input_annotation('/Users/frejon/Documents/annotation_tool/moas_input/cat_generatedsweeps.csv');







%filename_out='output/Moas_arbete/generatedsweeps_4_20180406-142608.csv';
% 
% skip = 0;
% if ~skip
%filename='output/Moas_arbete/generatedsweeps_4_20180406-142608.csv';



skip=1;
if ~skip
    
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

end
%save generatedsweeps_4_out20180406-142608.mat input out

function out= read_output_annotation(filename)



trID2=fopen(filename,'r');
scantemp=textscan(trID2,'%s');
fclose(trID2);


len = length(scantemp{1,1});
out = [];
j=0;

substring='""';
newstring='';
scantemp{1,1} = struct_string_replace(scantemp{1,1},substring,newstring); %third party code
columns =6;

col5list={'/Users/frejon/Documents/annotation_tool/output/Moas_arbete/generatedsweeps_5_20180409-120304.csv','/Users/frejon/Documents/annotation_tool/output/Moas_arbete/generatedsweeps_5_20180410-110623.csv','/Users/frejon/Documents/annotation_tool/output/Moas_arbete/generatedsweeps_4_20180406-142608.csv','/Users/frejon/Documents/annotation_tool/output/Moas_arbete/generatedsweeps_22_20180411-110217.csv'};

%if any(strcmp('/Users/frejon/Documents/annotation_tool/output/Moas_arbete/generatedsweeps_4_20180406-142608.csv',col5list))
if any(strcmp(filename,col5list))

    %if strcmp(filename,'/Users/frejon/Documents/annotation_tool/output/Moas_arbete/generatedsweeps_22_20180411-110217.csv')
    columns =5;
    
    
end

    

for i = 2:columns:len
    %i
    j=j+1;
    if ~isempty(scantemp{1,1}{i,1})
        out.path{j,1}=scantemp{1,1}{i,1}(1:88);
        out.UTC_START_TIME{j,1}=scantemp{1,1}{i,1}(89:end);
        out.Vph(j)=str2double(scantemp{1,1}{i+1,1});
        out.Vbar(j)=str2double(scantemp{1,1}{i+2,1});
        out.check_disturb{j,1}= scantemp{1,1}{i+3,1};
        out.check_calib{j,1}= scantemp{1,1}{i+4,1};
        out.Vsc(j)= str2double(scantemp{1,1}{min([i+5;len]),1});
        out.filename{j,1}= filename;
        
        
        %messy:
        if columns == 5
            if all(strcmp(scantemp{1,1}{i+1,1},{scantemp{1,1}{i+2,1},scantemp{1,1}{i+3,1},scantemp{1,1}{i+4,1}}))
                out.empty(j)=1;
            else
                out.empty(j)=0;                
            end
            

        else
            
            if all(strcmp(scantemp{1,1}{i+1,1},{scantemp{1,1}{i+2,1},scantemp{1,1}{i+3,1},scantemp{1,1}{i+4,1},scantemp{1,1}{i+5,1}}))
                out.empty(j)=1;
            else
                out.empty(j)=0;                
            end
            
        end
        
            
            

    else
        out.path{j,1}='';
        out.UTC_START_TIME{j,1}='';
        out.Vph(j)=nan;
        out.Vbar(j)=nan;
        out.check_disturb{j,1}='';
        out.check_calib{j,1}='';
        out.Vsc(j)=nan;
        out.filename{j,1}= '';
        out.empty(j)=1;                



    end
        
end




if any(strcmp(filename,col5list))
%if strcmp(filename,'/Users/frejon/Documents/annotation_tool/output/Moas_arbete/generatedsweeps_22_20180411-110217.csv')
    out.Vsc(:)=nan;    
end



end


function out= read_input_annotation(filename)



trID2=fopen(filename,'r');
scantemp=textscan(trID2,'%s');
fclose(trID2);


len = length(scantemp{1,1});
out = [];
j=0;

substring='""';
newstring='';
scantemp{1,1} = struct_string_replace(scantemp{1,1},substring,newstring); %third party code
columns =6;
for i = 2:columns:len

    j=j+1;
    if ~isempty(scantemp{1,1}{i,1})
        out.path{j,1}=scantemp{1,1}{i,1}(1:88);
        out.UTC_START_TIME{j,1}=scantemp{1,1}{i,1}(89:end);
        out.Vph(j)=str2double(scantemp{1,1}{i+1,1});
        out.Vbar(j)=str2double(scantemp{1,1}{i+2,1});
        out.check_disturb{j,1}= scantemp{1,1}{i+3,1};
        out.check_calib{j,1}= scantemp{1,1}{i+4,1};
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

function shitvoid()

for i = 1:2100
catpath{i,1}=catgeneratedsweeps_strings{i,1}{1,1}(1:88);
catutc{i,1}=catgeneratedsweeps_strings{i,1}{1,1}(89:end);
end

moa_input.utc = catutc;
moa_input.path = catpath;
moa_input.sweepraw=[];
save moa_input_catraw.mat moa_input

for i = 1:2100
    
    shit= moa_input.sweepraw(i,moa_input.sweepraw(i~=-1000));
    mid=floor(length(shit)/2+1);
    moa_input.I(i)=shit(1:mid);
    moa_input.V(i)=shit(mid+1:end);
    
    
    
end

for i = 1:2100
    
    
    
i
    shit= moa_input.sweepraw(i,moa_input.sweepraw(i,:)~=-1000);
    
    
    
    mid=floor(length(shit)/2+0.5); %sort of mid point
    
    indz= find(moa_input.sweepraw(i,1:floor(mid*1.5))==-1000);
    if ~isempty(indz)
        moa_input.sweepraw(i,indz)=nan;
    end
    
        
    
    %moa_input.sweepraw(i,moa_input.sweepraw(i,1:mid)==-1000)=nan; %replace all current -1000 values with nan

    shit= moa_input.sweepraw(i,moa_input.sweepraw(i,:)~=-1000); %find the rest of the -1000 values, excluding those that previously misidentified)
    mid=floor(length(shit)/2+0.5);

    moa_input.I(i,1:mid)=shit(1:mid);
    moa_input.V(i,1:mid)=shit(mid+1:end);
    
    
    
    for i=1:2100
        moa_input.I(i,moa_input.I(i,:)==0)=nan;
        

        
    end
    
    
end

end


    