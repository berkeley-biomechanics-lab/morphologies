function validateConfig(cfg)
% Preventing silent errors in the configuration settings

    arguments
        cfg struct
    end

    assert(cfg.disc.alpha > 0 && cfg.disc.alpha < 0.5, ...
        'Endplate % of vertebral height must be between 0 and 50!');

    assert(cfg.measurements.slicerIgnorance >= 0 && cfg.disc.alpha < 0.5, ...
        'Slicer measurement ignorance ratio must be between 0 and 0.5!');

    assert(cfg.measurements.APrl <= cfg.measurements.APru, ...
        'Height ratio measurement bonudaries must be configured properly!');
end

