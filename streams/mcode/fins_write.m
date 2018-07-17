%===============================================================================
% Company:     Geon Technologies, LLC
% Author:      Josh Schindehette
% Copyright:   (c) 2018 Geon Technologies, LLC. All rights reserved.
%              Dissemination of this information or reproduction of this
%              material is strictly prohibited unless prior written
%              permission is obtained from Geon Technologies, LLC
% Description: This function writes the values of a FinStreams structure in hex
%              format to a series of files. If the values are complex, the data
%              is written to the file with the imaginary component first.
%              Example: 1F455AB2 where 1F45 is imaginary and 5AB2 is real
% Inputs:      fins - FinStreams structure
%                * Each field within structure requires the following fields:
%                    .values
%                    .bit_width
%                    .is_signed
%                    .is_complex
%              file_prefix - string (optional)
%                * 'sim_in_' (default)
% Outputs:     (none - this function does not modify the FinStreams structure)
% Usage:       fins_write(FinStreams fins,<string file_prefix>)
%===============================================================================
function [] = fins_write( varargin )

  %-----------------------------------------------------------------------------
  % Get Variable Inputs
  %-----------------------------------------------------------------------------
  % Check for valid inputs
  if ((nargin == 1) && isstruct(varargin{1}))
    % Set inputs
    fins        = varargin{1};
    file_prefix = 'sim_in_';
  elseif ((nargin == 2) && isstruct(varargin{1}) && ischar(varargin{2}))
    % Set inputs
    fins        = varargin{1};
    file_prefix = varargin{2};
  else
    error('Incorrect usage. Correct syntax: fins_write(FinStreams fins,<string file_prefix>)');
  end

  %-----------------------------------------------------------------------------
  % Get FinStreams
  %-----------------------------------------------------------------------------
  % Retrieve the stream names
  stream_names = fieldnames(fins);

  % Check that there are streams
  if (length(stream_names) == 0)
    error('There are no streams in the FinStreams structure.')
  end

  %-----------------------------------------------------------------------------
  % Iterate through streams
  %-----------------------------------------------------------------------------
  for n=1:length(stream_names)
    %****************************************
    % Get the stream
    %****************************************
    stream_name = stream_names{n};
    stream = fins.(stream_name);

    %****************************************
    % Convert to hex
    %****************************************
    filename = [file_prefix,stream_name,'.txt'];
    write_hex_file(stream.values,filename,stream.bit_width,stream.is_complex,...
                    stream.is_signed);
  end
end
