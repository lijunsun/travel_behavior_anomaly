function z = mnrnd_new(prob_vec)

uf = rand;
z = 1;
for f = 1:length(prob_vec)-1
    uf = uf - prob_vec(f);
    if uf > 0
        z = z+1;
    else
        break;
    end
end

