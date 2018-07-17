function z = mnrnd_old(prob_vec)

cump = cumsum(prob_vec);
uf = rand;
z = 1;
for f = 1:length(prob_vec)-1
    if uf > cump(f)
        z = f+1;
    else
        break
    end
end

