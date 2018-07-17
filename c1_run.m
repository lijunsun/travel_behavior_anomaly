clearvars;
clc;
data = csvread('matlab.csv',1);
data = data+1;
maxiter = 3000;
data(:,2) = data(:,2)-1;

%%
% data: user_id, day, location, time
length(unique(data(:,3)*100+data(:,4)));
map_ind = zeros(max(data(:,1)),1);
map_ind(:,1) = 1:max(data(:,1));
map_ind(:,2) = randperm(max(data(:,1)));
temp_data = data;
temp_data(:,1) = map_ind(temp_data(:,1),2);
temp_data = sortrows(temp_data,[1,2]);

%%
save('all_data.mat','temp_data','map_ind','data');

%%
% starting from here
load('all_data.mat');
train_data = temp_data(temp_data(:,1)>=1 & temp_data(:,1) <= 2000,:);
test_data = temp_data(temp_data(:,1)>=2001 & temp_data(:,1) <= 4000,:);
test_data(:,1) = test_data(:,1)-2000;
hist(temp_data(:,1),15000);


train_three_week = train_data(train_data(:,2)>=1 & train_data(:,2) <= 21,:);
train_last_week = train_data(train_data(:,2)>=22 & train_data(:,2) <= 28,:);

%% test
profile on;
clc;
% gibbs_2d2(data,num_spatial_topics,num_temporal_topics,maxiter,everyiter,plotf)
% gibbs_2d : theta is defined on a 2-d panel, without any restriction
s = 8;
t = 4;
[zs,zt,naz,nzws,nzwt] = gibbs_2d_tucker(train_last_week(1:100000,:),s,t,100,5,1);
m = matfile(strcat('test_2d_s',num2str(s),'_t',num2str(t),'.mat'),'writable',true);
m.zs = zs;
m.zt = zt;
m.naz = naz;
m.nzws = nzws;
m.nzwt = nzwt;

profile viewer;

%% test
% setenv('MW_MINGW64_LOC','C:\TDM-GCC-64');
% mex mnrnd_mex.c;
iters = 100000;
z = zeros(iters,4);
x = [0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1,1.1,1.2,1.3,1.4,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1,1.1,1.2,1.3,1.4];
y = x;
x = x/sum(x);
profile on;
for i = 1:iters
    z(i,1) = mnrnd_new(x);
    z(i,2) = mnrnd_old(x);
    z(i,3) = mnrnd_mex(x);
    z(i,4) = mnrnd_mex_noscale(y);
end
profile viewer; 
% we found that mnrnd_mex is much faster
hist(z,1:length(x));


%% test
clc;
plotf = 0;

sp = [10,15,20,25,30,35,40];
tp = [6,8,10,12,14];

cases = [];
for i = 1:length(sp)
    for j = 1:length(tp)
        cases = [cases; sp(i),tp(j)];
    end
end

%%
% parpool(4);
clc;
parfor i = 1:size(cases,1)
    s = cases(i,1);
    t = cases(i,2);
    disp([s,t]);
    m = matfile(strcat('res_2d_s',num2str(s),'_t',num2str(t),'.mat'),'writable',true);
    [zs,zt,naz,nzws,nzwt] = gibbs_2d_tucker(train_three_week,s,t,2500,5,plotf);
    m.zs = zs;
    m.zt = zt;
    m.naz = naz;
    m.nzws = nzws;
    m.nzwt = nzwt;
end