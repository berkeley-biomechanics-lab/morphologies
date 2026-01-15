function plotBeforeAfter(subjectData)
% Visualizing subject geometric alignment properties

    figure; % initializing figure

    n = subjectData.numSubjects; % number of subjects

    showVert = true;
    showDisc = false;

    % Looping through each subject:
    for i = 1:n

        subj = subjectData.subject(i); % ith subject
        sgtitle("Subject " + subj.vertebrae.subjName + " Visualization");

        if showVert
            if showVert && showDisc
                axVert = subplot(1,2,1); axVert.SortMethod = 'childorder';
            else
                axVert = subplot(1,1,1); axVert.SortMethod = 'childorder';
            end
            
            hold on;
            xlabel('X'); ylabel('Y'); zlabel('Z');
        
            % Setting the view to the YZ plane:
            %       YZ plane: view(90, 0)
            %       XZ plane: view(0, 0)
            %       XY plane: view(0, 90)
            view(90, 0);
            axis equal;

            for v = 1:subj.vertebrae.numLevels
                cla; % Clear the plot from the current axis
    
                % --- Original vertebra mesh ---
                TR  = subj.vertebrae.mesh(v).TR;
                V   = TR.Points;
                F   = TR.ConnectivityList;
        
                name  = subj.vertebrae.mesh(v).levelName;
                title("Pre- and post-alignment mesh of vertebral level " + name, ...
                            "Interpreter","none", ...
                            'Parent', axVert);
        
                % --- Rigid-body transform ---
                t = subj.alignment.vertebrae(v).translation; % translation vector (1×3)
        
                % Apply translation transformation:
                V0  = V + t; % translate
                TR0 = triangulation(F, V0); % intermediate geometric body
        
                % Before alignment:
                trisurf(TR0, ...
                        'FaceColor', [1 0 0], ...
                        'EdgeColor', 'none', ...
                        'FaceAlpha', 0.3, ...
                        'DisplayName', "pre-alignment", ...
                        'Parent', axVert);
        
                % After alignment:
                trisurf(subj.vertebrae.mesh(v).alignedProperties.TR, ...
                        'FaceColor', [0 0 1], ...
                        'EdgeColor', 'none', ...
                        'FaceAlpha', 0.3, ...
                        'DisplayName', "post-alignment", ...
                        'Parent', axVert);

                % Get the current axes handle
                ax = gca;
                
                % Retrieve the current x and y limits
                current_xlim = xlim(ax); current_ylim = ylim(ax);
                
                % Calculate the range of current limits
                x_range = current_xlim(2) - current_xlim(1); y_range = current_ylim(2) - current_ylim(1);
                
                % Calculate the amount to expand (5% of the range, so 2.5% on each side)
                expand_amount_x = x_range * 0.025; expand_amount_y = y_range * 0.025;
                
                % Calculate the new limits
                new_xlim = [current_xlim(1) - expand_amount_x, current_xlim(2) + expand_amount_x];
                new_ylim = [current_ylim(1) - expand_amount_y, current_ylim(2) + expand_amount_y];
                
                % Set the new limits to zoom out by 1%
                xlim(ax, new_xlim); ylim(ax, new_ylim);
                
                legend;
                drawnow;
            end
        end

        if showDisc
            if showVert && showDisc
                axDisc = subplot(1,2,1); axDisc.SortMethod = 'childorder';
            else
                axDisc = subplot(1,1,1); axDisc.SortMethod = 'childorder';
            end
            
            hold on;
            xlabel('X'); ylabel('Y'); zlabel('Z');
        
            % Setting the view to the YZ plane:
            %       YZ plane: view(90, 0)
            %       XZ plane: view(0, 0)
            %       XY plane: view(0, 90)
            view(90, 0);
            axis equal;

            for v = 1:subj.discs.numLevels
                cla; % Clear the plot from the current axis
    
                % --- Original vertebra mesh ---
                TR  = subj.discs.mesh(v).TR;
                V   = TR.Points;
                F   = TR.ConnectivityList;
        
                name  = subj.discs.mesh(v).levelName;
                title("Pre- and post-alignment mesh of disc level " + name, ...
                            "Interpreter","none", ...
                            'Parent', axDisc);
        
                % --- Rigid-body transform ---
                t = subj.alignment.discs(v).translation; % translation vector (1×3)
        
                % Apply translation transformation:
                V0  = V + t; % translate
                TR0 = triangulation(F, V0); % intermediate geometric body
        
                % Before alignment:
                trisurf(TR0, ...
                        'FaceColor', [1 0 0], ...
                        'EdgeColor', 'none', ...
                        'FaceAlpha', 0.3, ...
                        'DisplayName', "pre-alignment", ...
                        'Parent', axDisc);
        
                % After alignment:
                trisurf(subj.discs.mesh(v).alignedProperties.TR, ...
                        'FaceColor', [0 0 1], ...
                        'EdgeColor', 'none', ...
                        'FaceAlpha', 0.3, ...
                        'DisplayName', "post-alignment", ...
                        'Parent', axDisc);

                % Get the current axes handle
                ax = gca;
                
                % Retrieve the current x and y limits
                current_xlim = xlim(ax); current_ylim = ylim(ax);
                
                % Calculate the range of current limits
                x_range = current_xlim(2) - current_xlim(1); y_range = current_ylim(2) - current_ylim(1);
                
                % Calculate the amount to expand (5% of the range, so 2.5% on each side)
                expand_amount_x = x_range * 0.025; expand_amount_y = y_range * 0.025;
                
                % Calculate the new limits
                new_xlim = [current_xlim(1) - expand_amount_x, current_xlim(2) + expand_amount_x];
                new_ylim = [current_ylim(1) - expand_amount_y, current_ylim(2) + expand_amount_y];
                
                % Set the new limits to zoom out by 1%
                xlim(ax, new_xlim); ylim(ax, new_ylim);
                
                legend;
                drawnow;
            end
        end
    end
end

