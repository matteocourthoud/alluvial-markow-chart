% Example file

%% Example 1: without options

% Set parameters
rng(1);
Q = rand(5);
Q = Q ./ sum(Q,2);
x = [1, 2, 3, 99, 100];

% Plot transitions without options
figure();
set(gca, 'OuterPosition', [-0.1,-0.16,1.17,1.1])
alluvial.plot_transitions(Q, x);
saveas(gcf,'figures/example1.png');

%% Example 2: with options

% Options
w0 = [1, 2, 4, 5, 1];
ylabels = ["Idea", "New", "Used", "Old", "Broken"];
xlabels = ["0", "1", "2", "\infty", "\infty"];
palette = "inferno";
title = "Product Life Cycle";

% Plot transitions with options
figure();
set(gca, 'OuterPosition', [-0.1,-0.16,1.17,1.1])
alluvial.plot_transitions(Q, x, "w0", w0, "palette", palette, "ylabels", ylabels, "xlabels", xlabels,  "title", title);
saveas(gcf,'figures/example2.png');