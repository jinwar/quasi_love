function [ampsurf xi yi] = smooth_amp_surf(stlas,stlos,amps,xnode,ynode)

[surf xi yi] = gridfit(stlas,stlos,amps,xnode,ynode,'smooth',100);

fitamps = interp2(xi,yi,surf,stlas,stlos);

errs = fitamps - amps;
stderr = std(errs);

goodind = find(abs(errs)<stderr*3);

[ampsurf xi yi] = gridfit(stlas(goodind),stlos(goodind),amps(goodind),xnode,ynode,'smooth',10);


