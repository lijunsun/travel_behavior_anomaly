clc;
load('all_data.mat');
train_data = temp_data(temp_data(:,1)>=1 & temp_data(:,1) <= 2000,:);
test_data = temp_data(temp_data(:,1)>=2001 & temp_data(:,1) <= 2500,:);
test_data(:,1) = test_data(:,1)-2000;
hist(temp_data(:,1),15000);


train_three_week = train_data(train_data(:,2)>=1 & train_data(:,2) <= 21,:);
train_last_week = train_data(train_data(:,2)>=22 & train_data(:,2) <= 28,:);
test_three_week = test_data(test_data(:,2)>=1 & test_data(:,2) <= 21,:);


%%
s = 8;
t = 4;
%load(strcat('test_2d_s',num2str(s),'_t',num2str(t),'.mat'));
iter = 100;
[theta,phis,phit] = update_2d_holdout(train_last_week(1:200000,:),iter,zs,zt,naz,nzws,nzwt);

%%
theta2 = squeeze(mean(theta,1));
theta2 = theta2./sum(sum(theta2,1),2);
phis2 = squeeze(mean(phis,1));
phis2 = phis2./sum(phis2,2);
phit2 = squeeze(mean(phit,1));
phit2 = phit2./sum(phit2,2);
p1 = perplexity_2d(temp,theta2,phis2,phit2);

% test whether the perplexity makes sense
% p2 = perplexity_2d(temp,theta2,phis2(randperm(size(phis2,1)),:),phit2);
% p3 = perplexity_2d(temp,theta2,phis2(randperm(size(phis2,1)),:),phit2(randperm(size(phit2,1)),:));
perplexity = p1;

%%
% user ranking with perplexity
