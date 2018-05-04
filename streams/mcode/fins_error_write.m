%===============================================================================
% Company:     Geon Technologies, LLC
% Author:      Josh Schindehette
% Copyright:   (c) 2018 Geon Technologies, LLC. All rights reserved.
%              Dissemination of this information or reproduction of this 
%              material is strictly prohibited unless prior written
%              permission is obtained from Geon Technologies, LLC
% Description: This function writes the error metrics of a FinStreamsError
%              structure to a "results" file or the screen.
% Inputs:      fins_error - FinStreamsError structure
%                * Each field within structure requires the following fields:
%                    .error_max_absolute
%                    .error_avg_absolute
%                    .error_max_relative
%                    .error_avg_relative
%              filename - string (optional)
%                * Filename to print results to
%                * Default prints to screen
% Outputs:     (none - this function writes to file or screen)
% Usage:       fins_error_write(FinStreamsError fins_error, <string filename>)
%===============================================================================
function [] = fins_error_write( varargin )

  %-----------------------------------------------------------------------------
  % Get Variable Inputs
  %-----------------------------------------------------------------------------
  % Defaults
  fileID      = 1;     % Print to screen
  file_opened = false; % No file was opened

  % Check for valid inputs
  if ((nargin == 1) && isstruct(varargin{1}))
    % Set inputs
    fins_error  = varargin{1};
  elseif ((nargin == 2) && isstruct(varargin{1}) && ischar(varargin{2}))
    % Set inputs
    fins_error   = varargin{1};
    fileID      = fopen(varargin{2},'w');
    file_opened = true;
  else
    error('Incorrect usage. Correct syntax: fins_error_write(FinStreamsError fins_error, <string filename>)');
  end

  %-----------------------------------------------------------------------------
  % Get FinStreamsError
  %-----------------------------------------------------------------------------
  % Retrieve the stream names
  stream_names = fieldnames(fins_error);

  % Check that there are streams
  if (length(stream_names) == 0)
    error('There are no streams in the FinStreamsError structure.')
  end

  % Print the date and time to the results
  fprintf(fileID, '%s\n', datestr(now,31));

  %-----------------------------------------------------------------------------
  % Iterate through streams
  %-----------------------------------------------------------------------------
  for n=1:length(stream_names)
    %****************************************
    % Get the stream
    %****************************************
    stream_name = stream_names{n};
    stream = fins_error.(stream_name);
    %****************************************
    % Write to file (or screen if fileID=1)
    %****************************************
    fprintf(fileID, '--- %s ---\n', stream_name);
    fprintf(fileID, 'Max Absolute Error: %f\n', stream.error_max_absolute);
    fprintf(fileID, 'Avg Absolute Error: %f\n', stream.error_avg_absolute);
    fprintf(fileID, 'Max Relative Error: %f\n', stream.error_max_relative);
    fprintf(fileID, 'Avg Relative Error: %f\n', stream.error_avg_relative);
  end

  % Close the file if it was opened
  if (file_opened)
    fclose(fileID);
  end
end
