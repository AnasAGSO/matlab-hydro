input = rand(1000,1);
save("inputData.mat","input");
evalc('sim(''simTest'')');
