%===============================================================================
% Company:     Geon Technologies, LLC
% Author:      Josh Schindehette
% Copyright:   (c) 2018 Geon Technologies, LLC. All rights reserved.
%              Dissemination of this information or reproduction of this
%              material is strictly prohibited unless prior written
%              permission is obtained from Geon Technologies, LLC
% Description: This function reads the values of a FinStreams structure in hex
%              format from a series of files. If the values are complex, the
%              data is read from the files with the imaginary component first.
%              Example: 1F455AB2 where 1F45 is imaginary and 5AB2 is real
% Inputs:      fins - FinStreams structure
%                * Each field within structure requires the following fields:
%                    .values
%                    .bit_width
%                    .is_signed
%                    .is_complex
%              file_prefix - string (optional)
%                * 'sim_out_' (default)
% Outputs:     This function modifies each field within the FinStreams structure
%              by modifying the following field:
%                .values
% Usage:       fins_read(FinStreams fins,<string file_prefix>)
%===============================================================================
function [ fins ] = fins_read( varargin )

  %-----------------------------------------------------------------------------
  % Get Variable Inputs
  %-----------------------------------------------------------------------------
  % Defaults
  file_prefix = 'sim_out_';

  % Check for valid inputs
  if ((nargin == 1) && isstruct(varargin{1}))
    % Set inputs
    fins        = varargin{1};
  elseif ((nargin == 2) && isstruct(varargin{1}) && ischar(varargin{2}))
    % Set inputs
    fins        = varargin{1};
    file_prefix = varargin{2};
  else
    error('Incorrect usage. Correct syntax: fins_read(FinStreams fins,<string file_prefix>)');
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
    % Open/Read the File
    %****************************************
    % Construct filename
    filename = [file_prefix,stream_name,'.txt'];

    % Open and read values
    stream.values = read_hex_file(filename,stream.bit_width,...
                                  stream.is_complex,stream.is_signed);

    %****************************************
    % Put the stream back in FinStreams
    %****************************************
    fins.(stream_name) = stream;
  end
end
