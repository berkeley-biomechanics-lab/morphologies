%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Grace O'Connell Biomechanics Lab, UC Berkeley Department of Mechanical
% Engineering - Etchverry 2162
%
% Given the (centered) coordinates of a vertebra, this program uses the ICP
% (Iterative Closest Point) algorithm to determine the rigid transformation 
% (rotation matrix, R and translation vector, T) that best aligns the input
% and target point clouds.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% determining reference model using the following rule:
%       reference: 658_T4 – for T1, T2, T3, T4, T5, T6, T7
%       reference: 658_T11 – for T8, T9, T10, T11, T12, T13, T14
%       reference: 658_L3 – for T15, L1, L2, L3, L4, L5, L6

% script variables:
varsbefore = who;

%% Making transformations

% reference model groupings:
group1 = {'T1', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'};
group2 = {'T8', 'T9', 'T10', 'T11', 'T12', 'T13', 'T14'};
group3 = {'T15', 'L1', 'L2', 'L3', 'L4', 'L5', 'L6'};

% finding and loading reference model, given the vertebral level:
if any(strcmp(group1, lvl))
    reference = references{1};
    load(reference);
elseif any(strcmp(group2, lvl))
    reference = references{2};
    load(reference);
elseif any(strcmp(group3, lvl))
    reference = references{3};
    load(reference);
else
    disp('subject level does not have an associated reference level!')
end

% extracting (centered) reference model:
Mc = nodes_final;

% runnning ICP:
np = length(Pc);
[Ricp, Ticp, ~, ~] = icp(Mc', Pc', nk, 'Matching','kDtree');
Pt = (Ricp * Pc' + repmat(Ticp, 1, np))'; % transformed geometry

% re-centering geometry
c = mean(Pt);
Pt = Pt - c;
model.vertices = Pt; % updating 'model' object

% defining c2 translation vector:
c2 = c;

%% Visualizing transformations

% plotting pre- and post-alignment geometry:
makeplot = false;
if makeplot
    figure
    hold on
    scatter3(Pc(:,1), Pc(:,2), Pc(:,3))
    scatter3(Pt(:,1), Pt(:,2), Pt(:,3))
    xlabel('X [mm]')
    ylabel('Y [mm]')
    zlabel('Z [mm]')
    legend('pre', 'post')
    title('Pre- and post-alignment geometry: ' + string(subj) + ', ' + string(lvl))
    view(90, 0) % YZ plane
    drawnow
end

%% MATLAB cleanup

% deleting everything except Pt:
varsafter = who; % get names of all variables in 'varsbefore' plus variables
varsremove = setdiff(varsafter, varsbefore); % variables  defined in the script
varskeep = {'Pt', 'Ricp', 'Ticp', 'c2'};
varsremove(ismember(varsremove, varskeep)) = {''};
clear(varsremove{:})
