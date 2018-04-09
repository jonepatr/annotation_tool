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

