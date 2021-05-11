function [xval,yhat,ylow,yupp,stats] = regressionError(y,x1)
% regressionError Calculate linear fit and confidence intervals for the mean
%
%   regressionError(y,x1) uses x1 as a linear predictor of y plus an
%   intercept
%
%   [xhat,yhat,ylow,yupp] = regressionError(y,x1) returns predicted values
%   yhat at x-values xval with lower and upper error ranges ylow and yupp

X = [ones(size(x1)) x1];
n = length(y);

% [b,bint,r,rint,stats]
[b,~,~,~,stats] = regress(y,X);
b0 = b(1);
b1 = b(2);

sse = sum((y-b0-b1*x1).^2);
mse = sse/(n-2);

tvalue = tinv(0.975,n-2);

xval = min(x1):0.01:max(x1);
yhat = b0+b1*xval;

se = sqrt(mse * (1/n + ((xval-mean(x1)).^2) ./ sum((x1-mean(x1)).^2)));

ylow = yhat - tvalue*se;
yupp = yhat + tvalue*se;

end