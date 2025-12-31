function volumeProgressUpdate(job, name)
    
    pctJob   = 100 * job.count / job.total;
    
    fprintf(['Volume measurements progress: ' ...
                'Subject %d/%d | Level %s | %.1f%% total\n'], ...
                job.subjectIdx, job.numSubjects, name, pctJob);
end

