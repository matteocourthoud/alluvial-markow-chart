%% Function to plot alluvial graphs for Markow Processes
% Author:  Matteo Courhoud
% Website: https://matteocourthoud.github.io/
% Github:  https://github.com/matteocourthoud

    
function alluvial_plot(Q, x, varargin)
    %   Plot transitions of matrix Q over time periods x
    %
    %   Parameters
    %   ----------
    %   Q: mat
    %       Square transition matrix
    % 
    %   x: array
    %       Time periods at which to evaluate the flows
    % 
    %   w0: array, optional 
    %       Initial weights
    %
    %	ylabels: str, optional 
    %       Labels of y axis
    %
    %	xlabels: str, optional 
    %       Labels of x axis
    %
    %	title: str, optional 
    %       Plot title
    %
    %	palette: str, optional 
    %       Color palette (viridis, magma, inferno, cividis)
   

    % Assign default values
    [ylabels, xlabels, title, w0, palette] = get_params(Q, x, varargin);

    % Generate distribution
    I = length(Q);
    J = length(x);
    mc = dtmc(Q);
    distr = redistribute(mc, max(x), 'X0', w0);
    y = distr(x, :)';
    [ybars_bottom, ybars_top] = get_ybars(y, I, J);

    % Init graph
    axis ij
    axis off
    hold on

    % Plot flows
    plot_flows(Q, x, y, ybars_bottom, I, J, palette)

    % Plot bars
    plot_bars(ybars_bottom, ybars_top, I, J, palette)

    % Prettify
    ymeans = (ybars_bottom + ybars_top) / 2;
    prettify(title, y, ylabels, xlabels, ymeans, I, J)

end



% Assign default values for comparative statics
function [ylabels, xlabels, title, w0, palette] = get_params(Q, x, vars)

    % Set default values
    ylabels = repmat("", 1, size(Q,1));
    for i=1:size(Q,1)
        ylabels(i) = sprintf("State %1.0f", i);
    end
    xlabels = string(x);
    title = "State to State Transitions";
    w0 = ones(1, size(Q,1))/size(Q,1);
    palette = get_colors("viridis", size(Q,1));

    % Assign default values
    for k=2:2:size(vars,2)
        switch vars{k-1}
            case "xlabels"
                xlabels = vars{k};
            case  "ylabels"
                ylabels = vars{k};
            case "title"
                title = vars{k};
            case "w0"
                w0 = vars{k};
            case "palette"
                palette = get_colors(vars{k}, size(Q,1));
            otherwise
                error('Invalid argument')
        end
    end
end



function plot_flows(Q, x, y, ybars_bottom, I, J, palette)
    % Plot flows

    % Loop over rows and columns
    for j=1:J-1
        bottoms = ybars_bottom(:,j+1)';
        for i = 1:I

            % Compute transition probabilities
            Qx = Q^(x(j+1)-x(j));

            % Get corners
            top_lefts = (cumsum(Qx(i,:)) - Qx(i,:)) * y(i,j)*0.9 + ybars_bottom(i,j);
            bottom_lefts = cumsum(Qx(i,:)) * y(i,j)*0.9 + ybars_bottom(i,j);
            top_rights = bottoms;
            bottom_rights = top_rights + bottom_lefts - top_lefts;
            bottoms = bottoms + bottom_lefts - top_lefts;

            % Get coordinates
            [X, Y] = get_coordinates(j, J, top_lefts, bottom_lefts, top_rights, bottom_rights);

            % Plot
            patch('XData', X, 'YData', Y, 'FaceAlpha', .3, 'Facecolor', palette(i,:), 'EdgeColor', 'none');
        end
    end

end



function [X, Y] = get_coordinates(j, J, top_lefts, bottom_lefts, top_rights, bottom_rights)
    % Get shape coordinates

    % Get curves
    w = J/40;
    [bottom_x, bottom_y] = get_curves(j+w, bottom_lefts, j+1-w, bottom_rights);
    [top_x, top_y] = get_curves(j+1-w, top_rights, j+w, top_lefts);

    % Get all oordinates
    X = [bottom_x; top_x];
    Y = [bottom_y; top_y];
end



function [x, y] = get_curves(x1, y1, x2, y2)
    % Makes curve between two points
    
    t = linspace(0, pi, 15);
    c = (1-cos(t))./2; 
    Ncurves = numel(y1);
    y = repmat(y1, 15, 1) + repmat(y2 - y1, 15,1) .* repmat(c', 1, Ncurves);
    x = repmat(linspace(x1, x2, 15)', 1, Ncurves);
end 



function [ybars_bottom, ybars_top] = get_ybars(y, I, J)
    % Compute bars

    % Init
    ybars_bottom = zeros(size(y));
    ybars_top = zeros(size(y));

    % Fill
    for j=1:J
        ybars_bottom(:,j) = cumsum(y(:,j)*0.9 + 0.1/(I-1)) - 0.1/(I-1) - y(:,j)*0.9;
        ybars_top(:,j) = cumsum(y(:,j)*0.9 + 0.1/(I-1)) - 0.1/(I-1);
    end
end




function plot_bars(ybars_bottom, ybars_top, I, J, palette)
    % Plot bars

    % Bar width (half)
    w = J/40;            

    % Plot bars
    for j=1:J
        set(gca,'ColorOrderIndex',1)
        for i=1:I
            y_corners = [ybars_bottom(i,j), ybars_bottom(i,j), ybars_top(i,j), ybars_top(i,j)];
            x_corners = [j-w, j+w, j+w, j-w];
            patch('X', x_corners, 'Y', y_corners, 'FaceAlpha', .8, 'Facecolor', palette(i,:), 'EdgeColor', 'none');
        end
        hold on
    end
end



function prettify(title, y, ylabels, xlabels, ymeans, I, J)
    % Make graph look pretty

    % Y labels
    for i=1:I
        if y(i,1)>0.05
            text(1-0.2, ymeans(i,1)-0.02, ylabels(i), 'HorizontalAlignment', 'right','Fontweight', 'Bold', 'Color', [.4 .4 .4])
            text(1-0.2, ymeans(i,1)+0.02, sprintf("%.2f",y(i,1)), 'HorizontalAlignment', 'right', 'Color', [.4 .4 .4])
        end
        if y(i,end)>0.05
            text(J+0.2, ymeans(i,end)-0.02, ylabels(i),'Fontweight', 'Bold', 'Color', [.4 .4 .4])
            text(J+0.2, ymeans(i,end)+0.02, sprintf("%.2f",y(i,end)), 'Color', [.4 .4 .4])
        end
    end

    % X labels
    for j=1:J
        text(j, 1.03, xlabels(j), 'HorizontalAlignment', 'center', 'Color', [.4 .4 .4])
    end
    text((J+1)/2, 1.07, "Periods", 'HorizontalAlignment', 'center', 'Fontsize', 12,'Fontweight', 'Bold', 'Color', [.4 .4 .4])

    % Title
    text((J+1)/2, -0.12, title, 'HorizontalAlignment', 'center', 'Fontsize', 20)

    % Font
    set(gca, 'FontName', 'SansSerif')

end
        
        
        

function colors = get_colors(palette_name, I)
    % Get colors
    %
    %   Returns
    %   -------
    %   colors: array
    %       Colormap

    % Load original paltte
    palette = palettes.(palette_name);

    % Transform
    k = 10;
    colors = interp1(linspace(0,1,size(palette,1)),palette,linspace(0,1,3+(I-1)*k));
    colors = colors(2:k:end-1,:);
end
