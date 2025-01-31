
%Given charactheristic of J=j (so delta(J=j), Price=p_j adn C=c_j), what is
%the profit and market share for the good J=j, given other prices. 
function [profit, share] = pi_j(j, p_j, P, C, delta, alpha)
%calculate profit j after changing j's price to p_j, given other prices
P(j) = p_j;
profit = (p_j - C(j)) .* (exp(delta(j) - alpha .* p_j) ./ (1 + sum(exp(delta - alpha .* P))));
share = exp(delta - alpha .* P) ./ (1 + sum(exp(delta - alpha .* P)));
end
