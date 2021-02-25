% Example file

Q = [0.6 0.1 0.3
     0.2 0.7 0.1
     0.3 0.3 0.4];
x = [1, 2, 3, 99, 100];
ylabels = ["Duopoly", "Mixed", "Monopoly"];
xlabels = ["1", "2", "3", "\infty", "\infty"];
title = "State to State Transitions";

% Plot transitions
alluvial.plot_transitions(Q, x, ylabels, xlabels, title);
saveas(gcf,'example.png');
close();