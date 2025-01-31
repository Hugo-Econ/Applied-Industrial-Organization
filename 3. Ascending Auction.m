% Ascending Auctions  
% This script estimates bidders' private value distribution using moment matching.  
% It then simulates optimal reserve prices and their effect on seller revenue.  

clear; clc;
Startup % Calls useful functions from the Src directory concisely.  

rng(888); % Set seed for reproducibility  

%% **1. Data Generation: Simulating Bidders' Private Values**  
L = 50000; % Number of simulated auctions  
I = 4; % Number of bidders per auction  

theta0 = [0; 1]; % True parameters: [shift, scale]  
values0 = theta0(1) + theta0(2) * rand(L, I); % Private values ~ U(theta0(1), theta0(1) + theta0(2))  

B = sort(values0, 2, 'descend'); % Sort bids in descending order  
winbids0 = B(:,2); % Winning bid = 2nd highest bid  
sumtab0 = [mean(winbids0); std(winbids0)]; % Record empirical moments  

%% **2. Estimation: Recovering Parameters via Moment Matching**  
Draws = rand(L, I); % Fixed random draws to ensure smooth objective function  
yy = @(x) sum((AscendAuc(0, x, Draws) - sumtab0).^2); % Objective function: minimize moment differences  

% Reparameterize theta as [x1, x2^2] to ensure a positive scaling parameter  
x_hat = fminunc(yy, [1; 1], optimset('display', 'iter'));  

% Estimated parameters:  
theta_hat = x_hat;  
theta_hat(2) = x_hat(2)^2; % Ensure positive scaling parameter  

%% **3. Counterfactual Experiments: Reserve Prices and Seller Revenue**  
% Simulate seller’s expected revenue for different reserve prices  
r_vec = linspace(0.25, 0.75, 200); % Range of reserve prices to test  
sumtab_vec = zeros(length(r_vec), 2); % Store expected revenues  

for i = 1:length(r_vec)  
    sumtab_vec(i, :) = (AscendAuc(r_vec(i), x_hat, Draws))'; % Compute revenue at each reserve price  
end  

% Plot seller’s expected revenue as a function of reserve price  
figure;  
plot(r_vec, sumtab_vec(:, 1), 'LineWidth', 2);  
xlabel('Reserve Price (r)');  
ylabel('Expected Revenue');  
title('Optimal Reserve Price and Expected Seller Revenue');  
grid on;  

%% **4. Optimal Reserve Price Search**  
% Numerically search for the optimal reserve price that maximizes revenue  
r_opt = fminsearch(@(r) rfun(r, x_hat, Draws), 0.25, optimset('display', 'iter'));  

% Display results  
fprintf('Estimated Parameters: Theta_hat = [%f, %f]\n', theta_hat(1), theta_hat(2));  
fprintf('Optimal Reserve Price: r_opt = %f\n', r_opt);  


% Alternative: Find the maximum from the simulated values  
[value, i] = max(sumtab_vec(:,1));  
r_vec(i) % Optimal reserve price from simulation  
r_opt % Optimal reserve price from numerical optimization  
