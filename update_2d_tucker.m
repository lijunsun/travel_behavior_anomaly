function [theta,phis,phit] = update_2d_tucker(data,maxiter,zs,zt,naz,nzws,nzwt)

beta = 0.01;
alpha = 0.1;


[num_spatial_topics,num_temporal_topics,num_car] = size(naz);
[~,num_location]  = size(nzws);
[~,num_time] = size(nzwt);
[siz,~] = size(data);
na = squeeze(sum(sum(naz,1),2));

% gibbs
bl = beta * num_location;
bt = beta * num_time;
ast = alpha*num_spatial_topics*num_temporal_topics;

theta = zeros(maxiter,num_spatial_topics,num_temporal_topics,num_car);
phis = zeros(maxiter,num_spatial_topics,num_location);
phit = zeros(maxiter,num_temporal_topics,num_time);


nzs = zeros(num_spatial_topics,1);
nzt = zeros(num_temporal_topics,1);


for idx = 1:siz
    tzs = zs(idx);
    tzt = zt(idx);
    nzs(tzs) = nzs(tzs)+1;
    nzt(tzt) = nzt(tzt)+1;
end


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
        
        left1 = (nzws(:,location) +  beta) ./ (nzs + bl);
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
    
    w = reshape(permute(naz,[3,1,2]),[car,num_spatial_topics*num_temporal_topics]);
    imagesc(w);
    drawnow;
    disp(iter);
    
    theta(iter,:,:,:) = bsxfun(@rdivide,(naz + alpha),reshape((na + ast),[1,1,size(naz,3)]));
    phis(iter,:,:) = bsxfun(@rdivide,nzws + beta,nzs + bl);
    phit(iter,:,:) = bsxfun(@rdivide,nzwt + beta,nzt + bt);
end
    
    