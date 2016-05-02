clear;

center_la = 39;
center_lo = -96;
invest_range = 1000; % km
ip = 4;

CSfiles = dir('CSmeasure/2011*.mat');

for ics = 1:10
	disp(ics);
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

	x = dists(sta_inds);
	y = localdata.dts(sta_inds);

	para_dt = polyfit(x(:),y(:),1);
	app_v(ics) = 1./para_dt(1);

	y = localdata.amps(sta_inds);
	para_A = polyfit(x(:),y(:),1);
	del_A(ics) = para_A(1);


	figure(38)
	clf
	subplot(1,2,2);
	hold on
	plot(dists(sta_inds),localdata.dts(sta_inds),'x');
	plot(x,polyval(para_dt,x),'r');
	title(['Station Phase Delay (s):',eventcs.id]);
	subplot(1,2,1);
	hold on
	plot(dists(sta_inds),localdata.amps(sta_inds),'x');
	plot(x,polyval(para_A,x),'r');
	title(['Station Amplitude:',eventcs.id]);
	ginput(1);
end
