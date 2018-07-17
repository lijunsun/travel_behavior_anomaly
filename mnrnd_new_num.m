function z = mnrnd_new_num(prob_vec,num)


cump = cumsum(prob_vec);
z = sum(cump < rand(1,num)*cump(end),1) + 1;
