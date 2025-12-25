function [indInf, indSup] = findSurfaces(ns, Pt, plane, model, makeplot, showQuivers, searchfig, subj, lvl, meanArea)
    % Finds the index of the inferior + superior surface index location, 
    % indInf + indSup, by measuring concavity of the 3D surfaces

    % making 'searchfig' the current figure
    figure(searchfig);
    figtitle = string(subj) + ', ' + string(lvl);
    updatetime = 0.025;

    % copy of the plane object:
    planeCopy = plane;

    % direction tolerance (% representation of how much we're willing to
    % let the distribution of surface normal vectors point in the opposite 
    % direction of the inferior or superior surface normal):
    dirTol = 0; % preferably as close as possible to 0

    % poisson reconstruction octree depth:
    octreeDepth = 6;

    % mean area proximity factor:
    fInf = 1.025; % how much greater the selected inferior area should be, preferably as close as possible to 1
    fSup = 1.005; % how much greater the selected inferior area should be, preferably as close as possible to 1
   
    % min-max of each axis:
    xl = [min(Pt(:,1)), max(Pt(:,1))];
    yl = [min(Pt(:,2)), max(Pt(:,2))];
    zl = [min(Pt(:,3)), max(Pt(:,3))];
    
    % constructing the slice plane at placeholder z-level:
    [xx, yy] = meshgrid(xl, yl);
    plane.vertices = [xx(:), yy(:), zeros(4,1)];
    plane.faces = [1 3 4; 1 4 2]; % two triangles
    zlevels = (linspace(zl(1), zl(2), ns))';
    
    % initializing polyshape array:
    ps = polyshape();
    ps = repmat(ps, [ns, 1]);
    
    % measurement loop:
    for sl = 1:ns
	    z = zlevels(sl);
	    plane.vertices(:,3) = repmat(z, [4 1]); % update slice plane data
		    
        % updating current polyshape model paramaters:
        currmodel.vertices = model.vertices;
        currmodel.faces = model.faces;
    
	    % find the intersection
	    pgons = {};
	    [~, section] = SurfaceIntersection(currmodel, plane);
        % OUTPUT:
        % * section - a structure with following fields:
        %     section.vertices - N x 3 array of unique points
        %     section.edges    - N x 2 array of edge vertex ID's
        %     section.faces    - N x 3 array of face vertex ID's
	    
        % reorder the edge segments and identify unique polygons:
	    E = unique(section.edges, 'rows'); % only unique edges
	    E = E(diff(E,1,2) ~= 0,:); % get rid of degenerate edges (contain a pair of same vertices)
	    p = 1;
	    while ~isempty(E)
		    pgons{p} = E(1,:); % pick the first edge
		    E = E(2:end,:); % remove it from the pile
		    atend = false; % we're not at the end of this curve
		    v = 1;
		    while ~atend % run until there are no more connecting segments
			    nextv = pgons{p}(end,2); % look at the last vertex on this curve
			    idx = find(E(:,1) == nextv,1,'first'); % try to find an edge that starts at this vertex
			    
			    atend = isempty(idx); % we're at the end if there are no more connecting edges
			    if ~atend
				    v = v+1;
				    pgons{p}(end+1,:) = E(idx,:);
				    E(idx,:) = [];
			    end
		    end
		    p = p+1;
	    end
	    
	    % discard open curves
	    goodpgons = false(numel(pgons),1);
	    for p = 1:numel(pgons)
		    goodpgons(p) = pgons{p}(1,1) == pgons{p}(end,2);
	    end
	    pgons = pgons(goodpgons);
	    
	    % construct ordered vertex lists from ordered edge lists
	    for p = 1:numel(pgons)
		    thisE = pgons{p};
		    thisE = [thisE(:,1); thisE(end,2)];
		    pgons{p} = section.vertices(thisE,:);
	    end
	    ipgons = pgons.';
		    
	    % throw all the polygons into one polyshape() 
	    if isempty(ipgons)
		    iPS = polyshape();
        else
            for p = 1:numel(ipgons)
                thisP = ipgons{p};
                if p == 1
                    iPS = polyshape(thisP(:,1), thisP(:,2));
                else
                    iPS = addboundary(iPS, thisP(:,1), thisP(:,2));
                end
            end
	    end
	    
        ps(sl) = iPS;
        areaInf = area(iPS);
        
        % Determining surface points of pv:
        pv = plane.vertices; % vertices that describe surface boundary plane
    
        % choosing three vertices and calculate two vectors, for each plane:
        v1 = pv(2,:) - pv(1,:);
        v2 = pv(3,:) - pv(1,:);
        
        % calculating normal vector, for each plane:
        n = cross(v1, v2);
        
        % choosing vertex and finding equation, for each plane:
        D = -n * pv(1,:)';
        p = [n, D]';
        
        % calculating z-coordinates on inferior/superior planes:
        zPlane = (-p(1)*Pt(:,1) - p(2)*Pt(:,2) - p(4)) ./ p(3);
        
        % comparing z-coordinates to boundary planes:
        belowPlane = Pt(:,3) <= zPlane;
        
        % partitioning surface:
        pointsInf = Pt(belowPlane,:);
        numPointsInf = size(pointsInf, 1);
        
        % contructing point clouds if there are enough points:
        if numPointsInf > 1
            plotPoint = mean(pointsInf, 1);
            plotPoint(:,3) = min(pointsInf(:,3));
            zNorm = [0, 0, -1];

            % intializing point cloud:
            ptCloudInf = pointCloud(pointsInf);
            
            % reconstructing the surface mesh:
            [meshInf, ~] = pc2surfacemesh(ptCloudInf, "poisson", octreeDepth);

            % cleaning up surface mesh:
            removeDefects(meshInf, "duplicate-vertices")
            removeDefects(meshInf, "duplicate-faces")
            removeDefects(meshInf, "unreferenced-vertices")
            removeDefects(meshInf, "degenerate-faces")
            removeDefects(meshInf, "nonmanifold-edges")
            
            % computing normals of the surface meshes (creates VertexNormals + FaceNormals feature inside each mesh):
            computeNormals(meshInf);
            
            % flipping vertex normals of mesh if most of the normals are facing
            % inwards:
            if mean(meshInf.VertexNormals(:,3)) > 0
                meshInf.VertexNormals = -meshInf.VertexNormals;
            end
    
            % obtaining averaged normal vector for each surface mesh (using the
            % vertices as a reference):
            vertexNormals = meshInf.VertexNormals;
            vertices = meshInf.Vertices;
            dotProductInf = sum(meshInf.VertexNormals .* zNorm, 2);
        end
    
        if makeplot
            if sl == 1
		        ec = 'k';
                % display the object and slice plane
                title("(Inferior surface search) 3D polyshape for " + figtitle + " at layer: " + sl)
		        hp{1} = patch(model,'facecolor','w','edgecolor',ec);
		        hp{2} = patch(plane,'facecolor','m','edgecolor',ec,'facealpha',0.5);
                xlabel('X'); ylabel('Y'); zlabel('Z');
		        view([0 1 0]);
		        followerlight(hp{1});
		        axis equal
		        grid on
                hold on
		        
		        % draw the intersection line
		        npgonsInf = numel(ipgons);
		        hp{3} = gobjects(npgonsInf,1);
                for p = 1:npgonsInf
			        hp{3}(p) = plot3(ipgons{p}(:,1),ipgons{p}(:,2),ipgons{p}(:,3),'y','linewidth',2);
                end
		        drawnow
    
                pause(updatetime)
	        else
		        % update the slice plane
                title("(Inferior surface search) 3D polyshape for " + figtitle + " at layer: " + sl)
                xlabel('X'); ylabel('Y'); zlabel('Z');
		        hp{2}.Vertices = plane.vertices;
		        
		        % update the intersection line
		        delete(hp{3}); % the array won't be the same size, so just nuke everything
		        npgonsInf = numel(ipgons);
		        hp{3} = gobjects(npgonsInf,1);
                for p = 1:npgonsInf
			        hp{3}(p) = plot3(ipgons{p}(:,1),ipgons{p}(:,2),ipgons{p}(:,3),'y','linewidth',2);
                end
                if exist('hscatterInf', 'var')
                    delete(hscatterInf);
                end
                if exist('qNormInf', 'var')
                    delete(qNormInf);
                end
                if exist('qMeshInf', 'var')
                    delete(qMeshInf);
                end
                qNormInf = quiver3(plotPoint(:,1), plotPoint(:,2), plotPoint(:,3), ...
                                    zNorm(:,1), zNorm(:,2), zNorm(:,3), 3, 'k', 'LineWidth', 3);
                if showQuivers
                    qMeshInf = quiver3(vertices(:,1), vertices(:,2), vertices(:,3), ...
                                        vertexNormals(:,1), vertexNormals(:,2), vertexNormals(:,3), ...
                                        3, 'r', 'LineWidth', 3);
                end
                hscatterInf = scatter3(pointsInf(:,1), pointsInf(:,2), pointsInf(:,3), 'green');
		        drawnow
        		        
                pause(updatetime)
            end 

            % stopping criteria:
            isOneRegionInf = npgonsInf == 1;
            isValidPointsInf = numPointsInf > 1;
            isExistInf = exist('dotProductInf', 'var');
            isValidAreaInf = areaInf >= fInf * meanArea;
            if isExistInf
                isInvalidOrientationInf = any(dotProductInf <= dirTol);
            end
            if isExistInf && isInvalidOrientationInf && isOneRegionInf && isValidPointsInf && isValidAreaInf
                break;
            end
        end
    end

    indInf = sl;

    % measurement loop:
    for sl = ns:-1:1
	    z = zlevels(sl);
	    planeCopy.vertices(:,3) = repmat(z, [4 1]); % update slice plane data
		    
        % updating current polyshape model paramaters:
        currmodel.vertices = model.vertices;
        currmodel.faces = model.faces;
    
	    % find the intersection
	    pgons = {};
	    [~, section] = SurfaceIntersection(currmodel, planeCopy);
        % OUTPUT:
        % * section - a structure with following fields:
        %     section.vertices - N x 3 array of unique points
        %     section.edges    - N x 2 array of edge vertex ID's
        %     section.faces    - N x 3 array of face vertex ID's
	    
        % reorder the edge segments and identify unique polygons:
	    E = unique(section.edges, 'rows'); % only unique edges
	    E = E(diff(E,1,2) ~= 0,:); % get rid of degenerate edges (contain a pair of same vertices)
	    p = 1;
	    while ~isempty(E)
		    pgons{p} = E(1,:); % pick the first edge
		    E = E(2:end,:); % remove it from the pile
		    atend = false; % we're not at the end of this curve
		    v = 1;
		    while ~atend % run until there are no more connecting segments
			    nextv = pgons{p}(end,2); % look at the last vertex on this curve
			    idx = find(E(:,1) == nextv,1,'first'); % try to find an edge that starts at this vertex
			    
			    atend = isempty(idx); % we're at the end if there are no more connecting edges
			    if ~atend
				    v = v+1;
				    pgons{p}(end+1,:) = E(idx,:);
				    E(idx,:) = [];
			    end
		    end
		    p = p+1;
	    end
	    
	    % discard open curves
	    goodpgons = false(numel(pgons),1);
	    for p = 1:numel(pgons)
		    goodpgons(p) = pgons{p}(1,1) == pgons{p}(end,2);
	    end
	    pgons = pgons(goodpgons);
	    
	    % construct ordered vertex lists from ordered edge lists
	    for p = 1:numel(pgons)
		    thisE = pgons{p};
		    thisE = [thisE(:,1); thisE(end,2)];
		    pgons{p} = section.vertices(thisE,:);
	    end
	    ipgons = pgons.';
		    
	    % throw all the polygons into one polyshape() 
	    if isempty(ipgons)
		    iPS = polyshape();
        else
            for p = 1:numel(ipgons)
                thisP = ipgons{p};
                if p == 1
                    iPS = polyshape(thisP(:,1), thisP(:,2));
                else
                    iPS = addboundary(iPS, thisP(:,1), thisP(:,2));
                end
            end
	    end
	    
        ps(sl) = iPS;
        areaSup = area(iPS);
        
        % Determining surface points of pv:
        pv = planeCopy.vertices; % vertices that describe surface boundary plane
    
        % choosing three vertices and calculate two vectors, for each plane:
        v1 = pv(2,:) - pv(1,:);
        v2 = pv(3,:) - pv(1,:);
        
        % calculating normal vector, for each plane:
        n = cross(v1, v2);
        
        % choosing vertex and finding equation, for each plane:
        D = -n * pv(1,:)';
        p = [n, D]';
        
        % calculating z-coordinates on inferior/superior planes:
        zPlane = (-p(1)*Pt(:,1) - p(2)*Pt(:,2) - p(4)) ./ p(3);
        
        % comparing z-coordinates to boundary planes:
        abovePlane = Pt(:,3) >= zPlane;
        
        % partitioning surface:
        pointsSup = Pt(abovePlane,:);
        numPointsSup = size(pointsSup, 1);
        
        % contructing point clouds if there are enough points:
        if numPointsSup > 1
            plotPoint = mean(pointsSup, 1);
            plotPoint(:,3) = max(pointsSup(:,3));
            zNorm = [0, 0, 1];

            % intializing point cloud:
            ptCloudSup = pointCloud(pointsSup);
            
            % reconstructing the surface mesh:
            [meshSup, ~] = pc2surfacemesh(ptCloudSup, "poisson", octreeDepth);

            % cleaning up surface mesh:
            removeDefects(meshSup, "duplicate-vertices")
            removeDefects(meshSup, "duplicate-faces")
            removeDefects(meshSup, "unreferenced-vertices")
            removeDefects(meshSup, "degenerate-faces")
            removeDefects(meshSup, "nonmanifold-edges")
            
            % computing normals of the surface meshes (creates VertexNormals + FaceNormals feature inside each mesh):
            computeNormals(meshSup);
            
            % flipping vertex normals of mesh if most of the normals are facing
            % inwards:
            if mean(meshSup.VertexNormals(:,3)) < 0
                meshSup.VertexNormals = -meshSup.VertexNormals;
            end
    
            % obtaining averaged normal vector for each surface mesh (using the
            % vertices as a reference):
            vertexNormals = meshSup.VertexNormals;
            vertices = meshSup.Vertices;
            dotProductSup = sum(meshSup.VertexNormals .* zNorm, 2);
        end
    
        if makeplot
            if sl == ns
		        ec = 'k';
                % display the object and slice plane
                title("(Superior surface search) 3D polyshape for " + figtitle + " at layer: " + sl)
		        hp{1} = patch(model,'facecolor','w','edgecolor',ec);
		        hp{2} = patch(planeCopy,'facecolor','m','edgecolor',ec,'facealpha',0.5);
                xlabel('X'); ylabel('Y'); zlabel('Z');
		        view([0 1 0]);
		        followerlight(hp{1});
		        axis equal
		        grid on
                hold on
		        
		        % draw the intersection line
		        npgonsSup = numel(ipgons);
		        hp{3} = gobjects(npgonsSup,1);
                for p = 1:npgonsSup
                    intersectionLine = ipgons{p};
			        hp{3}(p) = plot3(intersectionLine(:,1), ...
                                        intersectionLine(:,2), ...
                                        intersectionLine(:,3), ...
                                        'y', 'linewidth', 2);
                end
		        drawnow
    
                pause(updatetime)
	        else
		        % update the slice plane
                title("(Superior surface search) 3D polyshape for " + figtitle + " at layer: " + sl)
                xlabel('X'); ylabel('Y'); zlabel('Z');
		        hp{2}.Vertices = planeCopy.vertices;
		        
		        % update the intersection line
		        delete(hp{3}); % the array won't be the same size, so just nuke everything
		        npgonsSup = numel(ipgons);
		        hp{3} = gobjects(npgonsSup,1);
                for p = 1:npgonsSup
                    intersectionLine = ipgons{p};
			        hp{3}(p) = plot3(intersectionLine(:,1), ...
                                        intersectionLine(:,2), ...
                                        intersectionLine(:,3), ...
                                        'y', 'linewidth', 2);
                end
                if exist('hscatterSup', 'var')
                    delete(hscatterSup);
                end
                if exist('qNormSup', 'var')
                    delete(qNormSup);
                end
                if exist('qMeshSup', 'var')
                    delete(qMeshSup);
                end
                qNormSup = quiver3(plotPoint(:,1), plotPoint(:,2), plotPoint(:,3), ...
                            zNorm(:,1), zNorm(:,2), zNorm(:,3), 3, 'k', 'LineWidth', 3);
                if showQuivers
                    qMeshSup = quiver3(vertices(:,1), vertices(:,2), vertices(:,3), ...
                                        vertexNormals(:,1), vertexNormals(:,2), vertexNormals(:,3), ...
                                        3, 'r', 'LineWidth', 3);
                end
                hscatterSup = scatter3(pointsSup(:,1), pointsSup(:,2), pointsSup(:,3), 'blue');
		        drawnow
        		        
                pause(updatetime)
            end 

            % stopping criteria:
            isOneRegionSup = npgonsSup == 1;
            isValidPointsSup = numPointsSup > 1;
            isExistSup = exist('dotProductSup', 'var');
            isValidAreaSup = areaSup >= fSup * meanArea;
            if isExistSup
                isInvalidOrientationSup = any(dotProductSup <= dirTol);
            end
            if isExistSup && isInvalidOrientationSup && isOneRegionSup && isValidPointsSup && isValidAreaSup
                break;
            end
        end
    end

    indSup = sl;
end
