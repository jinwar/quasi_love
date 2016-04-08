clear;

center_la = 39;
center_lo = -96;
invest_range = 1000; % km
ip = 4;

CSfiles = dir('CSmeasure/2011*.mat');

for ics = 1:10
	filename = ['CSmeasure/',CSfiles(ics).name];
	load(filename);
	localdata = gather_data(eventcs,center_la,center_lo,invest_range,ip);
	if isempty(localdata)
		continue;
	end
	dists = distance(localdata.evla,localdata.evlo,localdata.stlas,localdata.stlos);
	dists = deg2km(dists);
	localdata.dists = dists;
	evla = localdata.evla;
	evlo = localdata.evlo;
	stlas = localdata.stlas;
	stlos = localdata.stlos;
	[gclats gclons] = gcwaypts(evla,evlo,center_la,center_lo,1000);

	ind = find(gclats>min(stlas)&gclats<max(stlas));
	gclats = gclats(ind);
	gclons = gclons(ind);
	gc_max_dist = 100;
	sta_inds = [];
	for ista=1:length(stlas)
		gcdists = distance(stlas(ista),stlos(ista),gclats,gclons);
		gcdists = deg2km(gcdists);
		if min(gcdists)<gc_max_dist
			sta_inds(end+1) = ista;
		end
	end

	figure(38)
	clf
	subplot(1,2,1);
	plot(dists(sta_inds),localdata.dts(sta_inds),'x');
	subplot(1,2,2);
	plot(dists(sta_inds),localdata.amps(sta_inds),'x');
	ginput(1);
end
