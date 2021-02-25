%% Working example

Q = rand(3);
Q = Q ./ sum(Q,2);
x = [1,2,3,99,100];
ylabels = ["Duopoly", "Mixed", "Monopoly"];
xlabels = ["1", "2", "3", "\infty", "\infty"];
title = "State to State Transitions";

% Plot transitions
alluvial.plot_transitions(Q, x, ylabels, xlabels, title);
