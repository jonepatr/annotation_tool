for i = 1:2100
    
    
    
i
    shit= moa_input.sweepraw(i,moa_input.sweepraw(i,:)~=-1000);
    
    
    
    mid=floor(length(shit)/2+0.5); %sort of mid point
    
    indz= find(moa_input.sweepraw(i,1:floor(mid*1.2))==-1000);
    if ~isempty(indz)
        moa_input.sweepraw(i,indz)=nan;
    end
    
        
    
    %moa_input.sweepraw(i,moa_input.sweepraw(i,1:mid)==-1000)=nan; %replace all current -1000 values with nan

    shit= moa_input.sweepraw(i,moa_input.sweepraw(i,:)~=-1000); %find the rest of the -1000 values, excluding those that previously misidentified)
    mid=floor(length(shit)/2+0.5);

    moa_input.I(i,1:mid)=shit(1:mid);
    moa_input.V(i,1:mid)=shit(mid+1:end);
    
    
    
    for i=1:2100
        %moa_input.I(i,moa_input.I(i,:)==0)=nan;
        
%        for j=1:length(moa_input.I(i,:))
                
 %       end
        
    end
    
    
end