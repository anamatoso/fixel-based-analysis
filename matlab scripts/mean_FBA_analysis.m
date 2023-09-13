%% Clean
clearvars
close all
clc
cd '/Users/ana/Documents/Ana/IST/LaSEEB/FBA/matlab scripts'
%% Load data
 
% Define variables
atlases = ["JHUtracts" "JHUlabels" "AAL116"];
metrics = ["fd" "log_fc" "fdc"];
groups = ["-midcycle" "-premenstrual" "-interictal" "-preictal" "-ictal" "-postictal"];

for i_a = 1:length(atlases)
    for i_m = 1:length(metrics)
        input_folder = "./results_mean_metrics/"+metrics(i_m)+"_"+atlases(i_a);
        for i_g = 1:length(groups)
            group_name = groups(i_g);
            files = dir(fullfile(input_folder, "*"+group_name+"*.txt"));
            file_paths = fullfile({files.folder}, {files.name});
            n_files = length(file_paths);
            c = cell(1,n_files);
            for file = 1:n_files
                c{file} = load(file_paths{file});
            end
            matrix = cell2mat(c);
            group_name = split(group_name,"-"); group_name = group_name(2);
            data.(atlases(i_a)).(metrics(i_m)).(group_name) = matrix; 
        end
    end
end

clear i_a i_m i_g input_folder group_name files file_paths n_files c matrix file

%% Analyse data

comparisons = ["midcycle" "interictal";"premenstrual" "ictal"; "premenstrual" "postictal";"premenstrual" "preictal";...
    "midcycle" "premenstrual"; ...
    "interictal" "preictal"; "preictal" "ictal";"ictal" "postictal";"postictal" "interictal";...
    "interictal" "ictal";"preictal" "postictal"];


for i_a = 1:length(atlases)
    labels=importdata(atlases(i_a)+"_labels.txt");
    for i_m = 1:length(metrics)
        for comp = 1:length(comparisons)
            g1 = comparisons(comp,1);
            g2 = comparisons(comp,2);
            x1 = data.(atlases(i_a)).(metrics(i_m)).(g1);
            x2 = data.(atlases(i_a)).(metrics(i_m)).(g2);
            n_nodes = size(x1,1);
            p_thresh = 0.05/length(metrics);

            for node = 1:n_nodes
                p = ranksum(x1(node,:),x2(node,:));
                if p<p_thresh
                    disp(atlases(i_a)+", "+metrics(i_m)+", "+g1+"-"+g2+", "+labels{node}+": "+p)
                end
            end
        end
    end
    disp("----------------")
end

clear i_a i_m comp g1 g2 x1 x2 n_nodes p_thresh node p







