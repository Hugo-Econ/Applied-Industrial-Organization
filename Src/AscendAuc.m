function [sumtab,wb] = AscendAuc(r,x,Draws)
%calculate the winning bids, r is the reserve price
%value: its log is normal w mean theta(1) and std theta(2)^2 (must be pos)
values = x(1) + (x(2)^2)*Draws;
L = size(Draws,1);
wb = zeros(L,1);
for ell = 1:L
    v_ell = values(ell,:); %row vec 
    v_up = v_ell(v_ell>=r); %list values >=r
    if length(v_up)>=2 %at least two active bidders 
        B = sort(v_up,'descend');
        wb(ell) = B(2); 
    elseif length(v_up)==1 %one acitive, win at reserve
        wb(ell) = r;
    else %no active bidders, auction fails
        wb(ell) =0;
    end
end 
sumtab = [mean(wb);std(wb)];
end