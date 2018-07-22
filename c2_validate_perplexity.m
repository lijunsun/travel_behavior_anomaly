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
s = 25;
t = 10;
load(strcat('res_2d_s',num2str(s),'_t',num2str(t),'.mat'));
mciter = 5;
[theta,phis,phit] = update_2d_holdout(test_three_week,mciter,zs,zt,naz,nzws,nzwt);

p1 = perplexity_2d(test_three_week,theta,phis,phit);
% test whether the perplexity makes sense
% p2 = perplexity_2d(test_three_week,theta,phis(:,randperm(size(phis,2)),:),phit);
% hist(p1);
% choose the best model in terms held-out sample prediction
disp(mean(p1));
% disp(mean(p2));


%%

% %%
% temp = test_three_week(test_three_week(:,1)==1,:);
% phis = zeros(1,461,461);
% phis(1,:,:) = eye(461)+eps;
% phit = zeros(1,24,24);
% phit(1,:,:) = eye(24)+eps;
% theta = zeros(1,461,24,1);
% for i = 1:size(temp,1)
%     theta(1,temp(i,3),temp(i,4),1) = theta(1,temp(i,3),temp(i,4),1)+1;
% end
% theta(:) = 1/sum(theta(:));
% perplexity_2d(temp,theta,phis,phit)

%%
subplot(1,3,1);
imagesc(squeeze(phis(2,:,:)));
subplot(1,3,2);
plot(squeeze(phis(:,1:8,1)));
subplot(1,3,3);
plot(squeeze(phis(:,1,1:426)));
figure;
plot(squeeze(phit(1,:,:))');


%%
clc;
%parpool(4);
permat = zeros(length(sp)*length(tp),1);
for i = 1:size(cases,1)
    s = cases(i,1);
    t = cases(i,2);
    w = load(strcat('res_2d_s',num2str(s),'_t',num2str(t),'.mat'));
    mciter = 5;
    [theta,phis,phit] = update_2d_holdout(test_three_week,mciter,w.zs,w.zt,w.naz,w.nzws,w.nzwt);
    p1 = perplexity_2d(test_three_week,theta,phis,phit);
    % hist(p1);
    disp([s,t,mean(p1)]);
    permat(i) = mean(p1);
end

%%
perp = reshape(permat,[length(sp),length(tp)]);
imagesc(perp);