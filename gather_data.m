clear;

center_la = 39;
center_lo = -96;

CSfiles = dir('CSmeasure/*_cs_LHT.mat');

for ievent = 1:1
	filename = ['CSmeasure/',CSfiles(ievent).name];
	clear eventcs
	load(filename);
end
