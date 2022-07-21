function imStack = loadEpoch(videoFolder, epochID, useTiffStack)
% LOADEPOCH
%
% Description:
%   Loads epoch video from analysis folder
%
% Inputs:
%   videoFolder                 full path to your video folder
%   epochID                     videoID number
% Optional inputs:
%   useTiffStack                whether to use TIFFStack (default = false)
% Outputs:
%   imStack                     video 
% -------------------------------------------------------------------------
    
    assert(isfolder(videoFolder), 'Analysis folder not recognized!');
    if nargin < 3
        try
            useTiffStack = getpref('ao-tools', 'use_tiffstack');
        catch
            useTiffStack = false;
        end
    end

    imStack = [];
    for i = 1:numel(epochID)
        epochFileName = ['vis_', int2fixedwidthstr(epochID(i), 4), '.tif'];
        epochFile = fullfile(videoFolder, epochFileName);
    
        fprintf('Loading epoch %u\n', epochID(i));
        if useTiffStack
            warning('off', 'MATLAB:imagesci:tiffmexutils:libtiffWarning');
            warning('off', 'imageio:tiffmexutils:libtiffWarning');
            ts = TIFFStack(epochFile);
            imStack = cat(4, imStack, ts(:, :, :));
        else
            imStack = cat(4, imStack, readTiffStack(epochFile));
        end
    end
    imStack = squeeze(imStack);
