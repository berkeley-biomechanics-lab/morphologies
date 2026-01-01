function Y = buildGroupArray(T, levelLabels)

    subjects = unique(T.SubjectID);
    N = numel(subjects);
    Q = numel(levelLabels);

    Y = nan(N,Q);

    for i = 1:N
        sid = subjects(i);
        Ti  = T(T.SubjectID == sid,:);

        for q = 1:Q
            lvl = levelLabels(q);
            idx = (Ti.LevelName == lvl);

            if any(idx)
                Y(i,q) = Ti.Volume(idx);
            end
        end
    end
end

