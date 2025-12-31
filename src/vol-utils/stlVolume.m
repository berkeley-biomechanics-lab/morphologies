% You have to first read the stl file. I am attaching a file that you can use (this is from MATLAB central). 
% Then the following commands can be used
% >> [F,V] = stlBinaryRead('01DWB.stl');
% >> [totalVolume,totalArea,cg] = stlVolume(V',F')
% totalVolume =
%    2.8390e+06
% totalArea =
%    1.0035e+05
% cg =
%     4.3410    3.6762  117.2932
% You can use this alternative statement in your implementation:
% V(any(isnan(V), 2), :) = [];
% This line correctly identifies any row in V that contains at least one NaN value and removes those rows.
% You can refer to this example as follows:
% Preparing a demo Vertices Matrix with NaN values %
% V = [0 0 0; NaN 0 NaN; 1 1 0; 0 1 0; 0.5 0.5 1]
% Removing Rows containing NaN Values %
% V(any(isnan(V), 2), :) = [];
% Displaying 
%V( :, all( isnan( V ), 1 ) ) = [];


function [totalVolume,totalArea,cg] = stlVolume(p,t)
% Given a surface triangulation, compute the volume enclosed using
% divergence theorem.
% Assumption:Triangle nodes are ordered correctly, i.e.,computed normal is outwards
% Input: p: (3xnPoints), t: (3xnTriangles)
% Output: total volue enclosed, and total area of surface  

% Compute the vectors d13 and d12
d13= [(p(1,t(2,:))-p(1,t(3,:))); (p(2,t(2,:))-p(2,t(3,:)));  (p(3,t(2,:))-p(3,t(3,:)))];
d12= [(p(1,t(1,:))-p(1,t(2,:))); (p(2,t(1,:))-p(2,t(2,:))); (p(3,t(1,:))-p(3,t(2,:)))];
cr = cross(d13,d12,1);%cross-product (vectorized)
area = 0.5*sqrt(cr(1,:).^2+cr(2,:).^2+cr(3,:).^2);% Area of each triangle
totalArea = sum(area);

% degenerate faces will result in a zero-magnitude cross product
crNorm = sqrt(cr(1,:).^2+cr(2,:).^2+cr(3,:).^2);

zMean = (p(3,t(1,:))+p(3,t(2,:))+p(3,t(3,:)))/3;

% this division will result in NaN
nz = -cr(3,:)./crNorm;% z component of normal for each triangle
volume = area.*zMean.*nz; % contribution of each triangle

% we can just ignore the NaNs created by degenerate faces
% that doesn't necessarily mean our result is useful
totalVolume = sum(volume,'omitnan'); % divergence theorem



















