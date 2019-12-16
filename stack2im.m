function stack2im(filename, directory)
%%stack2im Save each image in an image stack as a single-plane TIFF within
%%a specified directory
%
%   inputs:
%       filename : A string variable indicating a TIFF stack to parse
%
%       directory : A string variable indicating a directory to save the
%       TIFF images to

%% Read in the images in the stack
stk = uint16(readTiffStack(filename));
%% Write each image to TIFF file
for n = 1:size(stk, 3)
    %% Specify leading zeros
    if n < 10
        lead_string = '000';
    elseif n < 100
        lead_string = '00';
    elseif n < 1000
        lead_string = '0';
    end
    imwrite(stk(:,:,n), sprintf('%s%stile_%s%d.tif', directory, filesep, lead_string, n), 'tiff');
end