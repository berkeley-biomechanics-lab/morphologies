%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Grace O'Connell Biomechanics Lab, UC Berkeley Department of Mechanical
% Engineering - Etchverry 2162
%
% Given the (centered) coordinates of a disc, this program uses the ICP
% (Iterative Closest Point) algorithm to determine the rigid transformation 
% (rotation matrix, R and translation vector, T) that best aligns the input
% and target point clouds.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% script variables:
varsbefore = who;

%% Making transformations

% vector point positions:
infPointPlot = [0, 0 , min(Pc(:,3))];
supPointPlot = [0, 0 , max(Pc(:,3))];
axisPointPlot = [0, 0, mean([min(Pc(:,3)), max(Pc(:,3))])];

% Pc is n x 3, already centered
C = cov(Pc);              % 3x3 covariance matrix
[V, D] = eig(C);          % eigen decomposition

% sort eigenvalues (descending)
[evals, idx] = sort(diag(D), 'descend');
R = V(:, idx);            % principal axes (unit vectors)

% transformed coordinates:
Pt = Pc * R;
newaxis = [0 0 1] * R;

model.vertices = Pt; % updating 'model' object

%% Exporting transformations

% exporting post-alignment geometry into a new .stl file:
makeexport = false;
if makeexport
    % exporting specific vertebra levels:
    if ((i-1)*length(levels) + j == 12) || ((i-1)*length(levels) + j == 22) || ((i-1)*length(levels) + j == 39)
        folderpath = "C:\Users\16233\Desktop\grad\projects\scoliosis\subject measurements\matlabSOPs\spineSOP\discExportValidation";
        stlpath = append(folderpath, "Segmentation_", subj, "_", lvl, "_transformed.stl");
        TR = triangulation(model.faces, model.vertices);
        stlwrite(TR, stlpath, 'text')
    end
end

%% Visualizing transformations

% plotting pre- and post-alignment geometry:
makeplot = true;
makenewfig = false;
if makeplot
    if makenewfig 
        figure; 
    elseif ~exist('alignfig','var') || ~ishandle(alignfig)
        alignfig = figure; 
    else 
        set(0, 'CurrentFigure', alignfig) 
        figure(alignfig) 
        clf('reset') 
    end
    
    hold on
    scatter3(Pc(:,1), Pc(:,2), Pc(:,3), 'bo')
    scatter3(Pt(:,1), Pt(:,2), Pt(:,3), 'ro')
    scatter3(axisPointPlot(:,1), axisPointPlot(:,2), axisPointPlot(:,3), 'k*')
    %qAxis = quiver3(axisPointPlot(:,1), axisPointPlot(:,2), axisPointPlot(:,3), ...
    %                    newaxis(:,1), newaxis(:,2), newaxis(:,3), 3, 'k', 'LineWidth', 3);
    %qAxis.MaxHeadSize = 3;
    xlabel('X [mm]'); ylabel('Y [mm]'); zlabel('Z [mm]');

    title('Pre- and post-alignment geometry: ' + string(subj) + ', ' + string(lvl))
    legend('pre', 'post')
    view(90, 0) % YZ plane
    drawnow
end

%% MATLAB cleanup

% deleting everything except Pt:
varsafter = who; % get names of all variables in 'varsbefore' plus variables
varsremove = setdiff(varsafter, varsbefore); % variables  defined in the script
varskeep = {'Pt', 'R', 'alignfig'};
varsremove(ismember(varsremove, varskeep)) = {''};
clear(varsremove{:})
