function medSubTrans(filename_in, filename_out)
%%medSubTrans Opens the given image stack file, performs a median
%%subtraction, and writes the resulting images stack as a TIFF stack file.
%
%   inputs :
%       filename_in : A string variable that specifies the image stack to
%       open and perform the median subtraction on.
%
%       filename_out : A string variable that specifies the name of the
%       othe median subtracted image TIFF stack.

%% Open the filename_in with readTiffStack
stack = readTiffStack(filename_in);
%% Perform the median subtractions step
med_image = median(double(stack), 3);
for n = 1:size(stack,3)
    sub_plane = double(stack(:,:,n)) - med_image;
    %% Convert from double to uint16
    % subtract to eliminate negative values from subtraction
    conv_plane = uint16(sub_plane - min(sub_plane(:)));
    if n == 1
        imwrite(conv_plane, filename_out, 'tiff');
    else
        imwrite(conv_plane, filename_out, 'tiff', 'WriteMode', 'append');
    end
end
