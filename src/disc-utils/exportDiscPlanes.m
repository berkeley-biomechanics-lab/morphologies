%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Grace O'Connell Biomechanics Lab, UC Berkeley Department of Mechanical
% Engineering - Etchverry 2162
%
% Given the coordinates of the inferior and superior surfaces of the disc
% a vertebra, this program constructs and exports disc geometries
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc

% script variables:
varsbefore = who;

%% Determining equation of inferior/superior bonudary planes for the disc
% choosing three vertices and calculate two vectors, where there are two
% coordinate systems: 1.) the superior surface of the disc (the inferior
% surface of the top vertebra) and 2.) the inferior surface of the disc
% (the superior surface of the bottom vertebra). infv1 + infv2 represent
% the superior coordinate vectors on the inferior vertebral geometry that 
% will determine (2) and supv1 + supv2 represent the inferior coordinate 
% vectors on the superior vertebral geometry that will determine (1).
% PVInfVertSupPlane represents the vertices that describe superior surface 
% boundary plane of vertebra Iinf and supPV represents the vertices that 
% describe inferior surface boundary plane of vertebra Isup:
v1InfVertSupPlane = PVInfVertSupPlane(2,:) - PVInfVertSupPlane(1,:);
v2InfVertSupPlane = PVInfVertSupPlane(3,:) - PVInfVertSupPlane(1,:);
v1SupVertInfPlane = PVSupVertInfPlane(2,:) - PVSupVertInfPlane(1,:);
v2SupVertInfPlane = PVSupVertInfPlane(3,:) - PVSupVertInfPlane(1,:);

% calculating normal vector, for each vertebral plane:
v3InfVertSupPlane = cross(v1InfVertSupPlane, v2InfVertSupPlane);
v3SupVertInfPlane = cross(v1SupVertInfPlane, v2SupVertInfPlane);

% choosing vertex and finding equation, for each vertebral plane:
DInfVertSupPlane = -v3InfVertSupPlane * PVInfVertSupPlane(1,:)';
DSupVertInfPlane = -v3SupVertInfPlane * PVSupVertInfPlane(1,:)';
pInfVertSupPlane = [v3InfVertSupPlane, DInfVertSupPlane]';
pSupVertInfPlane = [v3SupVertInfPlane, DSupVertInfPlane]';

%% Determining inferior/superior vertebral surfaces

% calculating z-coordinates on inferior/superior planes:
zOnInfVertSupPlane = (-pInfVertSupPlane(1)*infPt(:,1) ...
                        - pInfVertSupPlane(2)*infPt(:,2) ...
                        - pInfVertSupPlane(4)) ./ pInfVertSupPlane(3);
zOnSupVertInfPlane = (-pSupVertInfPlane(1)*supPt(:,1) ...
                        - pSupVertInfPlane(2)*supPt(:,2) ...
                        - pSupVertInfPlane(4)) ./ pSupVertInfPlane(3);

% comparing z-coordinates to boundary planes:
aboveInfVertSupPlane = infPt(:,3) >= zOnInfVertSupPlane;
belowSupVertInfPlane = supPt(:,3) <= zOnSupVertInfPlane;

% partitioning inferior/superior surfaces:
supDiscPoints = supPt(belowSupVertInfPlane,:);
infDiscPoints = infPt(aboveInfVertSupPlane,:);

% converting inferior + superior coordinates to original coordinates:
RicpSup_invT = inv(RicpSup');
RicpInf_invT = inv(RicpInf');
supDiscPointso = (supDiscPoints - TicpSup' + c2Sup) * RicpSup_invT + c1Sup;
infDiscPointso = (infDiscPoints - TicpInf' + c2Inf) * RicpInf_invT + c1Inf;

%% MATLAB cleanup

% deleting everything except areas and Z:
varsafter = who; % get names of all variables in 'varsbefore' plus variables
varsremove = setdiff(varsafter, varsbefore); % variables  defined in the script
varskeep = {'supDiscPointso', 'infDiscPointso'};
varsremove(ismember(varsremove, varskeep)) = {''};
clear(varsremove{:})
