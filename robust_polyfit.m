function para = robust_polyfit(x,y,n)
%%function para = robust_polyfit(x,y,n)
% function same as polyfit but remove high error data points
%


para0 = polyfit(x,y,n);

err = y-polyval(para0,x);
