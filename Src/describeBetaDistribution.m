function describeBetaDistribution(alpha, beta)
    % Calculate mean and variance
    meanValue = alpha / (alpha + beta);
    variance = (alpha * beta) / ((alpha + beta)^2 * (alpha + beta + 1));

    % Determine the type of distribution
    if alpha > 1 && beta > 1
        if alpha == beta
            distributionType = 'Symmetric bell-shaped';
        else
            distributionType = 'Bell-shaped and skewed';
        end
    elseif alpha < 1 && beta < 1
        distributionType = 'U-shaped';
    elseif (alpha > 1 && beta < 1) 
        distributionType = 'Right-skewed';
    elseif (alpha < 1 && beta > 1)
        distributionType = 'Left-skewed';

    else
        distributionType = 'Special case';
    end

    % Print the results
    fprintf('Distribution type: %s\n', distributionType);
    fprintf('Mean value: %f\n', meanValue);
    fprintf('Variance: %f\n', variance);
end
