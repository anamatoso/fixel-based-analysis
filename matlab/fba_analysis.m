%% Clean
clearvars
close all
clc

%% Load data
 
% Define variables
atlases = ["JHUtracts" "JHUlabels" "AAL116"];
groups = ["controls" "ictals"];

% Iterate through csvs to load matrices
for i_a=1:length(atlases)
    for i_g=1:length(groups)
        data.(atlases(i_a)).(groups(i_g))=load("matrices/con_matrix_" + groups(i_g) + "_" + atlases(i_a) + ".csv"); % struct with the matrix of each group of each atlas
    end
end

clear i_a i_g

%% Plot connectivity matrices

% Iterate through fields and plot the matrices
for atlas=1:length(atlases)
    figure('color','w','Position',[26,197,1168,444]);
    sgtitle(atlases(atlas), 'FontSize', 20)
    for group=1:length(groups)
        subplot(1, length(groups), group)
        imagesc(data.(atlases(atlas)).(groups(group))); colormap jet; colorbar;
        title(groups(group))
        set(gca,'FontSize',15)
    end
end

clear atlas group

%% Calculate the connectivity metrics

version = 2;

% Iterate through fields to get matrices to calculate metrics
for atlas = 1 : length(atlases)
    for group = 1 : length(groups)
        matrix = data.(atlases(atlas)).(groups(group));
        metrics = calculate_metrics_v2(matrix,version);
        data_metrics.(atlases(atlas)).(groups(group))=metrics; % struct with the metrics of each matrix in each group in each atlas
    end
end

clear atlas group matrix metrics

%% Compare values

results=cell(1,length(atlases)); % table with the comparitive results

for atlas = 1 : length(atlases)
    metrics_labels=get_label_metrics(version,get_label_nodes("AAL116"+"_labels.txt"));
    for group = 1 : length(groups)
        results{atlas}=table(metrics_labels', data_metrics.(atlases(atlas)).(groups(1)),data_metrics.(atlases(atlas)).(groups(2)),'VariableNames', ["Metric","Controls", "Patients"]);
    end
end

clear group atlas 










