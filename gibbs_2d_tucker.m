function [zs,zt,naz,nzws,nzwt] = gibbs_2d_tucker(data,num_spatial_topics,num_temporal_topics,maxiter,everyiter,plotf)

if nargin<6
    plotf = 0;
end

num_car = max(data(:,1));
num_location = max(data(:,3));
num_time = max(data(:,4));

beta = 0.01;
alpha = 0.1;

% initialize

% note that put car on last dimension to improve performance
naz = zeros(num_spatial_topics,num_temporal_topics,num_car);

nzws = zeros(num_spatial_topics,num_location);
nzwt = zeros(num_temporal_topics,num_time);
na = zeros(num_car,1);
nzs = zeros(num_spatial_topics,1);
nzt = zeros(num_temporal_topics,1);

[siz,~] = size(data);

zs = randi(num_spatial_topics,[siz,1]);
zt = randi(num_temporal_topics,[siz,1]);
for idx = 1:siz
    car = data(idx,1);
    location = data(idx,3);
    time = data(idx,4);
    tzs = zs(idx);
    tzt = zt(idx);
    naz(tzs,tzt,car) = naz(tzs,tzt,car)+1;
    nzws(tzs,location) = nzws(tzs,location)+1;
    nzwt(tzt,time) = nzwt(tzt,time)+1;
    na(car) = na(car)+1;
    nzs(tzs) = nzs(tzs)+1;
    nzt(tzt) = nzt(tzt)+1;
end


% gibbs
bl = beta * num_location;
bt = beta * num_time;
ast = alpha*num_spatial_topics*num_temporal_topics;

st = tic;
for iter = 1:maxiter
    for idx = 1:siz
        car = data(idx,1);
        location = data(idx,3);
        time = data(idx,4);
        
        tzs = zs(idx);
        tzt = zt(idx);
        naz(tzs,tzt,car) = naz(tzs,tzt,car)-1;
        nzws(tzs,location) = nzws(tzs,location)-1;
        nzwt(tzt,time) = nzwt(tzt,time)-1;
        nzs(tzs) = nzs(tzs)-1;
        nzt(tzt) = nzt(tzt)-1;
        
        left1 = (nzws(:,location) + beta) ./ (nzs + bl);
        left2 = (nzwt(:,time) + beta) ./ (nzt + bt);
        %right = (naz(:,:,car) + alpha) ./ (na(car) -1 + ast);
        right = (naz(:,:,car) + alpha);
        p_z = left1.*left2'.*right;
        p_z = p_z(:);
        %p_z = p_z./sum(p_z);
        tz = mnrnd_mex_noscale(p_z);
        
        tzs = mod(tz-1,num_spatial_topics)+1;
        tzt = (tz-tzs)/num_spatial_topics+1;
        naz(tzs,tzt,car) = naz(tzs,tzt,car)+1;
        nzws(tzs,location) = nzws(tzs,location)+1;
        nzwt(tzt,time) = nzwt(tzt,time)+1;
        nzs(tzs) = nzs(tzs)+1;
        nzt(tzt) = nzt(tzt)+1;
        zs(idx) = tzs;
        zt(idx) = tzt;
    end
    
    if mod(iter,everyiter)==0
        t = toc(st);
        fprintf('Iter %i. Average time: %0.3f s\n',iter,t/everyiter);
        if plotf
            subplot(1,2,1);
            plot(nzwt');
            subplot(1,2,2);
            imagesc(naz(:,:,1));
            drawnow;
        end
        st = tic;
    end
end

