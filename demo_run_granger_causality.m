% This is a demo script for running granger causality with simulated
% discrete data for course P657 P657 Machine learning in Cognitive Science
% Spring 2017
% Tian Linger Xu txu@indiana.edu

clear all;
addpath('granger_libs');

% This demo script will create two data streams, with onsets of stream2
% always precedes onsets of stream1
demo_str = 'stream2 leads stream1';
plot_args.var_text = {'stream1', 'stream2'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set parameters here for the leading relationship between stream1 and stream2
window_size = 30;
step_size = 200;
succ_rate = 0.7;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

data_length = 3000;
num_trials = 4;
num_channels = 2;
plot_args.colormap = {[0 0 0]};
plot_args.save_path = '.';
plot_args.ForceZero = 0;
plot_args.ref_column = 1;
plot_args.color_code = 'cevent_value';
plot_args.xlim_list = [0 data_length];
plot_args.ForceZero = 0;
plot_args.time_ref = 0;

data_mat = nan(num_channels, data_length, num_trials);
plot_data = [];

result_gcause.window_size = window_size;
result_gcause.onset_step_size = step_size;
result_gcause.succ_rate = succ_rate;
index_start = window_size+1;

for rgidx = 1:num_trials
    data_one = zeros(num_channels, data_length);

    main_index_list = randi([index_start step_size]):step_size:data_length;
    data_one(1, main_index_list) = 1;
    main_index = find(data_one(1, :));
    main_index = [1 main_index data_length];

    for lidx = 2:(length(main_index)-1)
        is_succ = randi([0 1000]) <= 1000 * succ_rate;

        if is_succ
            range_lead_start = max([main_index(lidx-1) main_index(lidx)-window_size]);
            index_lead = randi([range_lead_start main_index(lidx)-1]);
            data_one(2, index_lead) = 1;
        end
    end
    data_mat(:, :, rgidx) = data_one;
    plot_data = [plot_data; stream2intervals(data_one', 1)];
end

[gcausal_mat, gcausal_fdr] = calculate_granger_causality(data_mat);
result_gcause.data_mat = data_mat;
result_gcause.gcausal_mat = gcausal_mat;
result_gcause.gcausal_sig = gcausal_fdr;

plot_args.title = sprintf('Granger causality stream2->stream1 %.2f, stream1->stream2 %.2f', ...
    gcausal_mat(1, 2), gcausal_mat(2, 1));

plot_args.save_name = sprintf('Gcause_demo_%s_stepsize_%d_window_%d_rate_%.1f', demo_str, step_size, window_size, succ_rate);
visualize_time_series(plot_data, plot_args);

save_filename = 'Gcause_demo_simulated_data.mat';
save(save_filename, 'result_gcause');