function outdata = gather_data(eventcs,center_la,center_lo,invest_range,ip)

	isfigure = 1;
	% find the station in the range
	dists = distance(eventcs.stlas,eventcs.stlos,center_la,center_lo);
	dists = deg2km(dists);
	sta_inds = find(dists<invest_range);
	sta_amps = arrayfun(@(x) eventcs.autocor(x).amp(ip),sta_inds);
	sta_amps = sta_amps.^0.5;
	stlas = eventcs.stlas(sta_inds);
	stlos = eventcs.stlos(sta_inds);
	
	% get the relative travel time for all stations in the range
	% select the in zone CSs
	CS = eventcs.CS;
	CSind = [];
	for ics = 1:length(CS)
		if CS(ics).isgood(ip) < 1
			continue;
		end
		if ismember(CS(ics).sta1,sta_inds) && ismember(CS(ics).sta2,sta_inds)
			CSind(end+1) = ics;
		end
	end
	if length(CSind)<length(sta_inds)*2
		outdata = [];
		return;
	end
	% for the matrix for LSQ inversion
	A = zeros(length(CSind)+1,length(sta_inds));
	d = zeros(length(CSind)+1,1);
	CS = CS(CSind);
	for ics = 1:length(CS)
		sta1ind = find(CS(ics).sta1==sta_inds);
		sta2ind = find(CS(ics).sta2==sta_inds);
		A(ics,sta1ind) = 1;
		A(ics,sta2ind) = -1;
		d(ics) = CS(ics).dtp(ip);
	end
	[temp centersta_ind] = max(diag(A'*A));
	A(end,centersta_ind) = 1;
	d(end) = 0;
	sta_dts = (A'*A+eye(length(sta_inds))*1e-6)\(A'*d);
	
	outdata.stlas = stlas;
	outdata.stlos = stlos;
	outdata.amps = sta_amps;
	outdata.dts = sta_dts;
	outdata.evla = eventcs.evla;
	outdata.evlo = eventcs.evlo;
	outdata.id = eventcs.id;
	outdata.center_la = center_la;
	outdata.center_lo = center_lo;

	% make some plots
	if isfigure
	cmap = colormap('jet');
	figure(340)
	clf
	subplot(1,2,1)
	hold on
	crange = nanmedian(sta_amps)*[0.5 1.5];
	cx = linspace(crange(1),crange(2),size(cmap,1));
	for ista=1:length(stlas)
		stacolor = interp1(cx,cmap,sta_amps(ista),'nearest','extrap');
		plot(stlas(ista),stlos(ista),'o','markerfacecolor',stacolor);
	end
	plot(center_la,center_lo,'rv');
	caxis(crange);
	colorbar
	subplot(1,2,2)
	hold on
	crange = [min(sta_dts) max(sta_dts)];
	cx = linspace(crange(1),crange(2),size(cmap,1));
	for ista=1:length(stlas)
		if (isnan(sta_dts(ista)))
			continue;
		end
		stacolor = interp1(cx,cmap,sta_dts(ista),'nearest','extrap');
		plot(stlas(ista),stlos(ista),'o','markerfacecolor',stacolor);
	end
	plot(center_la,center_lo,'rv');
	caxis(crange);
	colorbar
	end

