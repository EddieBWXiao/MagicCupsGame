function test_gen_asym2arm

seq = [100,0.7,0.3;100,0.6,0.6;repmat([20,0.1,0.9;20,0.9,0.1],2,1);[10,0.1,0.9]];
task = gen_asym2arm_task(seq,'auto_sym');
gen_asym2arm_task_visual(task);

figure;
seq = [100,0.7,0.3;100,0.6,0.6;repmat([20,0.1,0.9;20,0.9,0.1],2,1);[10,0.1,0.9]];
task = gen_asym2arm_task(seq,'never_sym');
gen_asym2arm_task_visual(task);

end
