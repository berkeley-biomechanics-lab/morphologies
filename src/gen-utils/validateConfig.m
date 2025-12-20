function validateConfig(cfg)
% Preventing silent errors in the configuration settings

    arguments
        cfg struct
    end

    assert(cfg.disc.alpha > 0 && cfg.disc.alpha < 50, ...
        'Endplate % of vertebral height must be between 0 and 50.');

end

