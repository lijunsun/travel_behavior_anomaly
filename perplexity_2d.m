function per = perplexity_2d(data,theta_chain,phis_chain,phit_chain)

% input data: [user, day, location, time]
mciter = size(theta_chain,1);
per = zeros(mciter,size(data,1));

for iter = 1:mciter
    theta = squeeze(theta_chain(iter,:,:,:));
    phis = squeeze(phis_chain(iter,:,:));
    phit = squeeze(phit_chain(iter,:,:));
    w = permute(log(phis(:,data(:,3))+eps),[1,3,2]) + ...
        permute(log(phit(:,data(:,4))+eps),[3,1,2]) + ...
        log(theta(:,:,data(:,1))+eps);
    w = reshape(w,[size(phis,1)*size(phit,1),size(data,1)]);
    per(iter,:) = logsumexp(w,1);
end
ttt = sum_eik(per',data(:,1),max(data(:,1)));

[y,~] = hist(data(:,1),1:max(data(:,1)));
perplexity = logsumexp(ttt-log(mciter),2);
per = exp(-perplexity./y');
