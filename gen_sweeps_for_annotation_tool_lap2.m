%gen_sweeps_for_annotation_tool
%LAP2

load=0;
if load
    command = 'ls /mnt/squid/RO-C-RPCLAP-5-1*V0.7/*/*/*/*I2S.TAB';
    
    [status,command_output] = system(command);
    cell_listoffiles=textscan(command_output,'%s');
    %dataraw=  readAxS_prelim(cell_listoffiles{1,1});
    
    len_f=length(cell_listoffiles{1,1});
    
    
    
    k=0;
    sweepmatrix=nan(1,2);
    for i = 1:len_f
        
        if ~isempty(dataraw(i).sweeps)
            
            for j = 1:length(dataraw(i).sweeps(:,1))
                k=k+1;
                sweepmatrix(k,1:2)=[i;j];
                
            end
        end
        i
        
    end


end



nrofsweeps=300;
fname='../generatedsweeps_21.csv';

max_sweep=0;
% for i =1:nrofsweeps %bump up to 1000 soon
%     
%     ind_1(i)=1+floor(rand()*(len_f-1)+0.5);
%    
%     while isempty(dataraw(ind_1(i)).sweeps) %oh noes, its empty
%         ind_1(i)=1+floor(rand()*(len_f-1)+0.5); %try again
%     end
%     
%     lenS(i)=length(dataraw(ind_1(i)).sweeps(:,1));
%     ind_2(i)=1+floor(rand*(lenS(i)-1)+0.5);
%     
%     lenmax=length(dataraw(ind_1(i)).sweeps(1,:));
%     if lenmax>max_sweep
%         max_sweep = lenmax
%     end
%     
%     
% 
%     
% end

for i =1:nrofsweeps %bump up to 1000 soon
    
    
    
    k=1+floor(rand()*(length(sweepmatrix)-1)+0.5);
    
    ind_1(i)=sweepmatrix(k,1);
    ind_2(i)=sweepmatrix(k,2);
    ind_3(i)=k;   
    
    lenmax=length(dataraw(ind_1(i)).sweeps(1,:));
    if lenmax>max_sweep
        max_sweep = lenmax
    end
    
    

    
end




test = 1;
if test    
    sweep=[];
    figure(1)
    hold on;
    for i = 1:10        
        I=dataraw(ind_1(i)).sweeps(ind_2(i),:);
        Vb= dataraw(ind_1(i)).bias_potentials;
        plot(Vb,I)
        grid on;
    end
    hold off;
end

%ind_1
%lenS
%ind_2
twID = fopen(fname,'w');

Dataarray=nan(nrofsweeps,max_sweep);
for i = 1:nrofsweeps
    leennnngth=length(dataraw(ind_1(i)).sweeps(ind_2(i),:));
    Dataarray(i,1:leennnngth*2)=[dataraw(ind_1(i)).sweeps(ind_2(i),:) dataraw(ind_1(i)).bias_potentials.'];
end
    Dataarray(Dataarray==0)=-1000;
    Dataarray(isnan(Dataarray))=-1000;

for i = 1:nrofsweeps
    i
    b1 = fprintf(twID,'%s%s, %d',cell_listoffiles{1,1}{ind_1(i),1},dataraw(ind_1(i)).START_TIME_UTC{1,1},dataraw(ind_1(i)).qf(ind_2(i)));
    b2 = fprintf(twID,', %14.7e',Dataarray(i,:));
    %b2 = fprintf(twID,', %14.7e',dataraw(ind_1(i)).sweeps(ind_2(i),:).'); %
    %b3 = fprintf(twID,', %14.7e',dataraw(ind_1(i)).bias_potentials.'); %some steps could be "NaN" values if LDL macro
    b4 = fprintf(twID, '\r\n');
    
end

fclose(twID);




function dataraw = readAxS_prelim(list_of_ixsfiles)
%dataraw takes a filepath to a file with paths to A1S or A2S files, outputs
%it to a horrible massive struct called dataraw, to be polished later. It
%also starts some stuff needed for iph0 calculations later.
% dataraw massive struct ? la dataraw(:).t1 = many structs with arrays of
% t1 from each A1S or A2S file specified in file filename
% trID = fopen(filename);
% scantemp=textscan(trID,'%s');
% fclose(trID);
% file1=scantemp{1,1};

%dataraw=struct

perc=0;
for i = 1:length(list_of_ixsfiles)
    

    if mod(i,floor(length(list_of_ixsfiles)/10))==0
        %    if mod(10,floor(100*i/length(list_of_axsfiles)))==0
        
%    if mod(i,floor(length(file1)/100)) == 1 %% Output counter routine for monitoring
        fprintf(1,'%i percent of LAP axS list done\n',perc);
        perc=perc+10;

    end
    

    
    
    rfile =list_of_ixsfiles{i,1};
    rfile3=rfile;
    rfile3(end-6)='B';
    
    if exist(rfile,'file') && ~ismember(str2double(rfile(end-10:end-8)),[304;305;306;307;916;917;922;411]) %if file exists, and is not 304/307 fine sweeps
        %macro 411 only gives problems for LAP2
        
        temp=lap_import(rfile);
        %        %formatin = 'YYYY-mm-ddTHH:MM:SS'; temp.t1 = datenum(cspice_et2utc(cspice_str2et(temp.START_TIME_UTC),'ISOC',0),formatin);
        %temp.t1 = irf_time(cell2mat(temp.START_TIME_UTC(:,1)),'utc>epoch');
        temp.macroId(1:length(temp.qf),1)=str2double(rfile(end-10:end-8));
        %temp.strID=strcat(rfile(end-51:end-48),'LAP',rfile2(end-5));
        temp.data=[];
        temp.STOP_TIME_UTC=[];
        
        %---- comment out this for now
        

        
        temp3=lap_import(rfile3);
        %temp.t1 = datenum(cspice_et2utc(cspice_str2et(temp.START_TIME_UTC),'ISOC',0),formatin);
        temp.bias_potentials=temp3.bias_potentials;
        %temp2.sample_times=temp3.sample_times;
        
%         if (temp.macroId(1) == 204 ||temp.macroId(1) == 926)
%             
%             %double some arrays, it's annoying, but whatevs.
%             temp.curr(1:length(temp.t1),1)=nan; %% length(temp.t1)!!!
%             temp.B(1:length(temp.t1),1)=nan;
%             shit=temp.ion_slope;
%             shit(1:length(shit)/2)=shit(1:2:end);% map every second value from start:0.5len.
%             shit(length(shit)/2:end)=nan;%fill with nans. I don't really care anymore
%             temp.ion_slope=shit;
%             
%             % special case, I'm ignoring the second part of the 204 sweep for now.
%             %I wan't to isolate the first value close to -17, as that's the one that the AxS file is referring to
%             % macro 204 has 208 steps, and 926 has 240 steps, so the first
%             % 1:104 values should contain the "first part" of the sweep
%             [checkthis,ind1] = sort(abs(temp2.bias_potentials(1:104)-V_query)); % find and sort values closest to -17.0V
%                         
%         else
%             [checkthis,ind1] = sort(abs(temp2.bias_potentials-V_query)); % find and sort values closest to -17.0V
%             
%         end
%         
        %ind1=find( abs(temp2.bias_potentials+17.0) < epsilon) ; %Find potential near -17, within 1.0V
        
%         if checkthis(1) < epsilon %max 1V away from  17
%             %        ind1=find(temp2.bias_potentials > -17.5 & temp2.bias_potentials < -16) ; %Find current from the sweeps at a specific bias voltage
%             %if ~isempty(ind1)
%             temp.curr(1:length(temp2.qf),1)=temp2.sweeps(:,ind1(1)); %length(temp2.qf)!!!
%             temp.B(1:length(temp2.qf),1)=temp2.bias_potentials(ind1(1));
%             
%         else
%             temp.curr(1:length(temp2.qf),1)=nan;
%             temp.B(1:length(temp2.qf),1)=nan;
%         end
        dataraw(i) = temp; %Here's the write file  
    else
        fprintf(1,'skipping %s, i=%d\n',rfile,i);
        %        rfile
    end
end



end % function
