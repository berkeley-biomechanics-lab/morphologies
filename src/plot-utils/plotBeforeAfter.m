function plotBeforeAfter(subjectData)
% Visualizing subject geometric alignment properties

    figure; % initializing figure

    n = subjectData.numSubjects; % number of subjects

    % Looping through each subject:
    for i = 1:n

        subj = subjectData.subject(i); % ith subject
        sgtitle("Subject " + subj.vertebrae.subjName + " Visualization");

        ax1 = subplot(1,2,1); ax1.SortMethod = 'childorder';
        hold on;
        xlabel('X'); ylabel('Y'); zlabel('Z');
    
        % Setting the view to the YZ plane:
        %       YZ plane: view(90, 0)
        %       XZ plane: view(0, 0)
        %       XY plane: view(0, 90)
        view(90, 0)

        for v = 1:subj.vertebrae.numLevels
            cla; % Clear the plot from the current axis

            % --- Original vertebra mesh ---
            TR  = subj.vertebrae.mesh(v).TR;
            V   = TR.Points;
            F   = TR.ConnectivityList;
    
            name  = subj.vertebrae.mesh(v).levelName;
            title("Pre- and post-alignment mesh of vertebral level " + name, ...
                        "Interpreter","none", ...
                        'Parent', ax1);
    
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
                    'Parent', ax1);
    
            % After alignment:
            trisurf(subj.vertebrae.mesh(v).alignedProperties.TR, ...
                    'FaceColor', [0 0 1], ...
                    'EdgeColor', 'none', ...
                    'FaceAlpha', 0.3, ...
                    'DisplayName', "post-alignment", ...
                    'Parent', ax1);
            
            legend;
            drawnow;
        end

        ax2 = subplot(1,2,2); ax2.SortMethod = 'childorder';
        hold on;
        xlabel('X'); ylabel('Y'); zlabel('Z');
    
        % Setting the view to the YZ plane:
        %       YZ plane: view(90, 0)
        %       XZ plane: view(0, 0)
        %       XY plane: view(0, 90)
        view(90, 0)

        for v = 1:subj.discs.numLevels
            cla; % Clear the plot from the current axis

            % --- Original vertebra mesh ---
            TR  = subj.discs.mesh(v).TR;
            V   = TR.Points;
            F   = TR.ConnectivityList;
    
            name  = subj.discs.mesh(v).levelName;
            title("Pre- and post-alignment mesh of disc level " + name, ...
                        "Interpreter","none", ...
                        'Parent', ax2);
    
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
                    'Parent', ax2);
    
            % After alignment:
            trisurf(subj.discs.mesh(v).alignedProperties.TR, ...
                    'FaceColor', [0 0 1], ...
                    'EdgeColor', 'none', ...
                    'FaceAlpha', 0.3, ...
                    'DisplayName', "post-alignment", ...
                    'Parent', ax2);
            
            legend;
            drawnow;
        end
    end
end

