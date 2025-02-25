% Optimize firm profit given other prices 

% This implies we are NOT solving for equilibrium prices. Instead, we assume  
% a given price vector for firm -j and then maximize j's profit accordingly.  

%% Definition:
% Vertical differentiation:
% A product characteristic that is objectively better, such as  
% GPU performance. Horizontal differentiation, in contrast,  
% represents variations in preferences (e.g., some people prefer  
% sports cars, while others prefer economy cars).  

%% Setting up
clear; clc;

Startup % Calls useful functions from the Src directory concisely.  

J = 2; % Number of products  
P = cumsum(ones(J,1)); % Prices  
C = zeros(J,1); % Costs  

delta = ones(J,1); % Vertical differentiation except price. "Ones" implies no differentiation.  

alpha = 0.1; % Price coefficient. We assume it, but normally it is estimated.  


%% Profit given price

% Profit function. Vector-based representation.  
pi = (P - C) .* (exp(delta - alpha .* P) ./ (1 + sum(exp(delta - alpha .* P))));  

% Visualize profit as a function of p_j  
% Since the real world is discrete, we construct a price vector  
% from 0.01 to 50 with 1000 steps.  

p_vec = linspace(0.01, 50, 1000)';  
profit = p_vec; % Placeholder for profit values.  
share = p_vec; % Placeholder for market shares.  

for i = 1:length(p_vec)  
    [profit(i), s] = pi_j(1, p_vec(i), P, C, delta, alpha);  
    share(i) = s(1); % Market share of product j  
end  

subplot(1,2,1);  
plot(p_vec, profit);  
xlabel('Price'); ylabel('Profit');  
title('Profit Function');  

subplot(1,2,2);  
plot(p_vec, share);  
xlabel('Price'); ylabel('Market Share');  
title('Market Share Function');  

% From the graph, we observe a well-behaved function with a maximum.  
% Now, let's numerically find the maximum using fminunc.  

% We call function pi_j (found in Src). This function takes the characteristics  
% of J=j (i.e., delta(J=j), price=p_j, and cost=c_j), then computes  
% the profit and market share for good J=j, given other prices.
% Explaination are provided below. 

% Numerically optimize profit given other prices  
p_j_opt = fminunc(@(x) -pi_j(1, x, P, C, delta, alpha), 1);  

%% Explanation:  
% pi_j is not immediately obvious, so we detail its function here.  
j = 1;  
pi_j(j, P(j), P, C, delta, alpha);  
% j=1 refers to good "1".  
% With price P(j=1) = 1, so p_1 = 1.  
% Given the price vector P = [1;2].  
% Given the cost vector C = [0;0].  
% And parameter delta (product differentiation), where here the good is homogeneous.  
% Alpha represents price sensitivity.  

% Since we define pi_j this way, it returns profit as output.  
% To maximize it, we minimize -profit using fminunc.  

%% Compare firm profit, and social welfare.  

%Firm j's profit.
P(1)=p_j_opt
profit_1 = pi_j(1, p_j_opt, P, C, delta, alpha)  

%Firm i's profit.
profit_2 = pi_j(2, P(2), P, C, delta, alpha)  

%Lets show i's behaviour is irrational. That is: if J=1 plays P=p_j_opt.
% Then p_i != 2

p_i_opt = fminunc(@(x) -pi_j(2, x, P, C, delta, alpha), 1);  
P(2)=p_i_opt
profit_2_prime = pi_j(2, P(2), P, C, delta, alpha);
profit_2_prime>profit_2

%So clearly one will respond. How should one reach the equilibirum ? See
%the next one!
%% Homework: Compare consumer surplus, firm profit, and social welfare. 