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
% the best model
s = 25;
t = 10;
load(strcat('res_2d_s',num2str(s),'_t',num2str(t),'.mat'));
iter = 10;
[theta,phis,phit] = update_2d_tucker(train_three_week,iter,zs,zt,naz,nzws,nzwt);

%%
w = squeeze(mean(theta,1));
w = reshape(permute(w,[2,1,3]),[s*t,2000]);
csvwrite('theta.csv',w');
save('train.mat','train_data');

% tsne mapping
w = csvread('theta.csv');
Y = tsne(w,'Algorithm','barneshut','NumPCAComponents',50);
gscatter(Y(:,1),Y(:,2),L);

%%
% user ranking with perplexity
clc;
per_predict = perplexity_2d(train_last_week,theta,phis,phit);
per_predict(:,2) = 1:size(per_predict,1);
per_predict = sortrows(per_predict,1);
csvwrite(strcat('perplexity_2d_s',num2str(s),'_t',num2str(t),'.csv'),per_predict);

%%
% data: user_id, day, location, time
w = train_data(train_data(:,1)==1517,:);
w = hist3(w(:,[2,3]),{1:31,1:461});
imagesc(w)
