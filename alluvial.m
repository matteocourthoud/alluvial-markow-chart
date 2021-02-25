%% Class to plot alluvial graphs for Markow Processes
% Author:  Matteo Courhoud
% Website: https://matteocourthoud.github.io/
% Github:  https://github.com/matteocourthoud



classdef alluvial
    
    % Properties
    properties (Constant)
        
        c =[0.0000    0.4470    0.7410
            0.8500    0.3250    0.0980
            0.9290    0.6940    0.1250
            0.4940    0.1840    0.5560
            0.4660    0.6740    0.1880
            0.3010    0.7450    0.9330
            0.6350    0.0780    0.1840];
        n = 15;
        
    end
    
    
    
    % Methods
    methods (Static)
    
        function plot_transitions(Q, x, ylabels, xlabels, title)
            
            % Generate distribution
            I = length(Q);
            J = length(x);
            mc = dtmc(Q);
            distr = redistribute(mc, max(x));
            y = distr(x, :)';
            [ybars_bottom, ybars_top] = alluvial.get_ybars(y, I, J);
            
            % Init graph
            set(gca, 'OuterPosition', [0,-0.07,0.95,1])
            axis ij
            axis off
            hold on
            
            % Plot flows
            alluvial.plot_flows(Q, x, y, ybars_bottom, I, J)
            
            % Plot bars
            alluvial.plot_bars(ybars_bottom, ybars_top, I, J)
            
            % Prettify
            ymeans = (ybars_bottom + ybars_top) / 2;
            alluvial.prettify(title, y, ylabels, xlabels, ymeans, I, J)
            
        end
        
        
        
        % Plot flows
        function plot_flows(Q, x, y, ybars_bottom, I, J)
            
            % Init colors
            c = get(gca,'ColorOrder');
            
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
                    [X, Y] = alluvial.get_coordinates(j, J, top_lefts, bottom_lefts, top_rights, bottom_rights);

                    % Plot
                    patch('XData', X, 'YData', Y, 'FaceAlpha', .3, 'Facecolor', c(i,:), 'EdgeColor', 'none');
                end
            end
            
        end
        
        
        
        % Get shape coordinates
        function [X, Y] = get_coordinates(j, J, top_lefts, bottom_lefts, top_rights, bottom_rights)
            
            % Get curves
            w = J/40;
            [bottom_x, bottom_y] = alluvial.get_curves(j+w, bottom_lefts, j+1-w, bottom_rights);
            [top_x, top_y] = alluvial.get_curves(j+1-w, top_rights, j+w, top_lefts);

            % Get all oordinates
            X = [bottom_x; top_x];
            Y = [bottom_y; top_y];
        end
        
        
        
        % Makes curve between two points
        function [x, y] = get_curves(x1, y1, x2, y2)
            t = linspace(0, pi, alluvial.n);
            c = (1-cos(t))./2; 
            Ncurves = numel(y1);
            y = repmat(y1, alluvial.n, 1) + repmat(y2 - y1, alluvial.n,1) .* repmat(c', 1, Ncurves);
            x = repmat(linspace(x1, x2, alluvial.n)', 1, Ncurves);
        end 
        
        
        
        % Compute bars
        function [ybars_bottom, ybars_top] = get_ybars(y, I, J)
            
            % Init
            ybars_bottom = zeros(size(y));
            ybars_top = zeros(size(y));
            
            % Fill
            for j=1:J
                ybars_bottom(:,j) = cumsum(y(:,j)*0.9 + 0.1/(I-1)) - 0.1/(I-1) - y(:,j)*0.9;
                ybars_top(:,j) = cumsum(y(:,j)*0.9 + 0.1/(I-1)) - 0.1/(I-1);
            end
        end
        
        
        
        % Plot bars
        function plot_bars(ybars_bottom, ybars_top, I, J)
            
            % Bar width (half)
            w = J/40;            
            
            % Plot bars
            for j=1:J
                set(gca,'ColorOrderIndex',1)
                for i=1:I
                    y_corners = [ybars_bottom(i,j), ybars_bottom(i,j), ybars_top(i,j), ybars_top(i,j)];
                    x_corners = [j-w, j+w, j+w, j-w];
                    patch('X', x_corners, 'Y', y_corners, 'FaceAlpha', .8, 'Facecolor', alluvial.c(i,:), 'EdgeColor', 'none');
                end
                hold on
            end
        end
    
        
        
        % Make graph look pretty
        function prettify(title, y, ylabels, xlabels, ymeans, I, J)
            
            % Y labels
            for i=1:I
                if y(i,1)>0.1
                text(1-0.2, ymeans(i,1), ylabels(i), 'HorizontalAlignment', 'right','Fontweight', 'Bold', 'Color', [.4 .4 .4])
                end
                if y(i,end)>0.1
                    text(J+0.2, ymeans(i,end), ylabels(i),'Fontweight', 'Bold', 'Color', [.4 .4 .4])
                end
            end
            
            % X labels
            for j=1:J
                text(j, 1.03, xlabels(j), 'HorizontalAlignment', 'center', 'Color', [.4 .4 .4])
            end
            text((J+1)/2, 1.1, "Periods", 'HorizontalAlignment', 'center', 'Fontsize', 12,'Fontweight', 'Bold', 'Color', [.4 .4 .4])
            
            % Title
            text((J+1)/2, -0.13, title, 'HorizontalAlignment', 'center', 'Fontsize', 18)
            
            % Font
            set(gca, 'FontName', 'SansSerif')

        end
        
    end
    
end