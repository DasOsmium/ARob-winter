function e = rmse(y, yhat)
%RMSE Root-mean-squared error between a measured and an estimated signal.
%   e = rmse(y, yhat), both column vectors of the same length.
e = sqrt(mean((y - yhat) .^ 2));
end
