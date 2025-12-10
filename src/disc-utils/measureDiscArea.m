%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Grace O'Connell Biomechanics Lab, UC Berkeley Department of Mechanical
% Engineering - Etchverry 2162
%
% Given the (transformed) coordinates of a disc, this program  slices 
% through the discal goemetry through the height (z-)axis and measures 
% the cross-sectional area
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc

% script variables:
varsbefore = who;

%% Slicing geometry

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
makegif = false;
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

    makeplot = false;
    makenewfig = false;
    if makeplot
        if makenewfig
            figure;
        elseif ~exist('polyfig','var') || ~ishandle(polyfig)
            polyfig = figure;
            figure(polyfig);
        else
            set(0, 'CurrentFigure', polyfig)
            figure(polyfig);
        end

        splsz = {2, 1};
        updatetime = 0.25;
        if sl == 1
		    ec = 'k';
            % display the object and slice plane
		    clf
		    subplot(splsz{:},1)
            title("3D Polyshape for layer: " + sl)
		    hp{1} = patch(model,'facecolor','w','edgecolor',ec); hold on
		    hp{2} = patch(plane,'facecolor','m','edgecolor',ec,'facealpha',0.5);
		    view(3)
		    followerlight(hp{1});
		    axis equal
		    grid on
		    
		    % draw the intersection line
		    npgons = numel(ipgons);
		    hp{3} = gobjects(npgons,1);
		    for p = 1:npgons
			    hp{3}(p) = plot3(ipgons{p}(:,1),ipgons{p}(:,2),ipgons{p}(:,3),'y','linewidth',2);
		    end
		    drawnow
               
		    % plot the polyshape
		    subplot(splsz{:},2)
		    drawnow
		    hp{5} = plot(ps(1));
		    xlim(xl)
		    ylim(yl)
		    axis equal
		    grid on
            title("2D Polyshape for layer: " + sl)

            pause(updatetime)
	    else
		    % update the slice plane
		    subplot(splsz{:},1)
            title("3D Polyshape for layer: " + sl)
		    hp{2}.Vertices = plane.vertices;
		    
		    % update the intersection line
		    delete(hp{3}); % the array won't be the same size, so just nuke everything
		    npgons = numel(ipgons);
		    hp{3} = gobjects(npgons,1);
		    for p = 1:npgons
			    hp{3}(p) = plot3(ipgons{p}(:,1),ipgons{p}(:,2),ipgons{p}(:,3),'y','linewidth',2);
		    end
		    drawnow
		    
		    % plot the polyshape
		    subplot(splsz{:},2)
		    drawnow
		    delete(hp{5});
		    hp{5} = plot(ps(sl));
		    xlim(xl)
		    ylim(yl)
		    axis equal
		    grid on
            title("2D Polyshape for layer: " + sl)

            pause(updatetime)
        end
        if makegif
            giffilename = 'area_measurement.gif';
            frame = getframe(gcf);
            img = frame2im(frame);
            [imind, cm] = rgb2ind(img, 256);
        
            % Write to GIF
            if sl == 1
                imwrite(imind, cm, giffilename, 'gif', 'Loopcount', inf, 'DelayTime', 0.05);
            else
                imwrite(imind, cm, giffilename, 'gif', 'WriteMode', 'append', 'DelayTime', 0.05);
            end
        end
    end
end

%% Calculating cross sectional area at slice positions

adjustmentFactor = 1 / ((1 - compressPer/100)^2);
areaZ = area(ps) * adjustmentFactor; % area with respect to slice position Z
Z = zlevels - zlevels(1); % slice positions, defined to start at 0

%% Area analysis

% mean area:
meanArea = mean(areaZ); % adjusted by compression factor

% derivative of area wrt slice position:
dcsadh = diff(areaZ)./diff(Z); % starts from the bottom up

%% Plotting cross sectional areas with respect to slice position

makeplot = true;
makenewfig = false;
if makeplot
    figtitle = string(subj) + ', ' + string(lvl);
    if makenewfig
        figure;
    elseif ~exist('afig','var') || ~ishandle(afig)
        afig = figure;
        figure(afig);
    else
        set(0, 'CurrentFigure', afig)
        figure(afig);
        clf
    end
    sgtitle('Cross Sectional Area Measurements')

    % raw cross sectional area VS slice position
    subplot(2,2,1);
    plot(areaZ, Z)
    xline(meanArea, '--r');
    xlabel('csa [mm^{2}]')
    ylabel('height [mm]')
    title('Raw area for ' + figtitle)
    ylim([min(Z) max(Z)])
    drawnow

    % dcsa/dh VS slice position
    subplot(2,2,2);
    plot(dcsadh, Z(1:end-1))
    xlabel('dCSA/dh')
    ylabel('height [mm]')
    title('Area gradient for ' + figtitle)
    ylim([min(Z) max(Z)])
    drawnow

    % inferior and superior surfaces:
    subplot(2,2,[3 4]);
    xlabel('X')
    ylabel('Y')
    zlabel('Z')
    hold on
    surface_inds = [floor(0.25*ns), floor(0.75*ns)];
    for sl = 1:2
        z = zlevels(surface_inds(sl));
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
        if makeplot
            ec = 'k';
            % display the object and slice plane
            title("Inferior index = " + string(surface_inds(1)) + "/" + ns + ", superior index = " + string(surface_inds(2)) + "/" + ns)
            hp{1} = patch(model,'facecolor','w','edgecolor',ec); hold on
            hp{2} = patch(plane,'facecolor','m','edgecolor',ec,'facealpha',0.5);
            followerlight(hp{1});
            axis equal
            grid on
            
            % draw the intersection line
            npgons = numel(ipgons);
            hp{3} = gobjects(npgons,1);
            for p = 1:npgons
	            hp{3}(p) = plot3(ipgons{p}(:,1),ipgons{p}(:,2),ipgons{p}(:,3),'y','linewidth',2);
            end
        end
    end
    view(90, 0) % YZ plane

    pause(3)
end

%% MATLAB cleanup

% deleting everything except areas and Z:
varsafter = who; % get names of all variables in 'varsbefore' plus variables
varsremove = setdiff(varsafter, varsbefore); % variables  defined in the script
varskeep = {'areaZ', 'Z', 'afig', 'polyfig'};
varsremove(ismember(varsremove, varskeep)) = {''};
clear(varsremove{:})
