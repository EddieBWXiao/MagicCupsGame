function debug_gen_IBLT

% ensure gen_IBLT is functioning by visually inspecting all six possible
% task structure graphs

%for the task applied to participants
tsk1 = gen_IBLT_task('both volatile');
tsk2 = gen_IBLT_task('win volatile');
tsk3 = gen_IBLT_task('loss volatile');

%visual:
gen_IBLT_task_visual(tsk1)
gen_IBLT_task_visual(tsk2)
gen_IBLT_task_visual(tsk3)

%for simulating task with randomised trial order
tsk1 = gen_IBLT_task('both volatile','random');
tsk2 = gen_IBLT_task('win volatile','random');
tsk3 = gen_IBLT_task('loss volatile','random');

%visual:
gen_IBLT_task_visual(tsk1)
gen_IBLT_task_visual(tsk2)
gen_IBLT_task_visual(tsk3)

end