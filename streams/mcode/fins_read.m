%===============================================================================
% Company:     Geon Technologies, LLC
% File:        fins_read.m
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
%
% Revision History:
% Date        Author             Revision
% ----------  -----------------  -----------------------------------------------
% 2017-08-11  Josh Schindehette  Initial Version
%
%===============================================================================
function [ fins ] = fins_read( varargin )

  %-----------------------------------------------------------------------------
  % Get Variable Inputs
  %-----------------------------------------------------------------------------
  % Defaults
  input_error = true;
  file_prefix = 'sim_out_';

  % Check for valid inputs
  if ((nargin == 1) && isstruct(varargin{1}))
    % Set inputs
    fins        = varargin{1};
    % Turn off error
    input_error = false;
  elseif ((nargin == 2) && isstruct(varargin{1}) && ischar(varargin{2}))
    % Set inputs
    fins        = varargin{1};
    file_prefix = varargin{2};
    % Turn off error
    input_error = false;
  end

  % Report input error
  if (input_error)
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
    % Check if file exists
    %****************************************
    % Construct filename
    filename = [file_prefix,stream_name,'.txt'];
    % Check if file exists
    if (~exist(filename))
      error(['File: ',filename,' cannot be read because it does not exist. Did you run the simulation?']);
    end
    %****************************************
    % Read the file
    %****************************************
    % Read in hex values
    values_hex = char(textread(filename,'%s'));
    % Convert to numeric
    if (stream.is_complex)
      % Check to make sure number of hex characters can be split evenly for the
      % complex data
      half_num_hex = size(values_hex,2) / 2;
      if (mod(half_num_hex,1) ~= 0)
        error(['Complex data cannot be read from file: ',filename,' because it does not have an even number of hex characters.']);
      end
      % Convert to integers
      if (stream.is_signed)
        stream.values = complex(hex2signed(values_hex(:, half_num_hex+1:end), stream.bit_width/2), ...
                                hex2signed(values_hex(:, 1:half_num_hex),     stream.bit_width/2));
      else
        stream.values = complex(hex2dec(values_hex(:, half_num_hex+1:end)), ...
                                hex2dec(values_hex(:, 1:half_num_hex    )));
      end
    else
      % Convert to integers
      if (stream.is_signed)
        stream.values = hex2signed(values_hex, stream.bit_width);
      else
        stream.values = hex2dec(values_hex);
      end
    end
    %****************************************
    % Put the stream back in FinStreams
    %****************************************
    fins.(stream_name) = stream;
  end
end
