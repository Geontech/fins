%===============================================================================
% Company:     Geon Technologies, LLC
% File:        fins_write.m
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
%
% Revision History:
% Date        Author             Revision
% ----------  -----------------  -----------------------------------------------
% 2017-08-11  Josh Schindehette  Initial Version
%
%===============================================================================
function [] = fins_write( varargin )

  %-----------------------------------------------------------------------------
  % Get Variable Inputs
  %-----------------------------------------------------------------------------
  % Default error to be true
  input_error = true;

  % Check for valid inputs
  if ((nargin == 1) && isstruct(varargin{1}))
    % Set inputs
    fins        = varargin{1};
    file_prefix = 'sim_in_';
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
    % Check if complex
    if (stream.is_complex)
      % Check that the bit width is even
      if (mod(stream.bit_width,2) > 0)
        error(['The complex values for ',stream_name,' cannot be converted to hex because the bit width (',stream.bit_width,') is odd.']);
      end
      % Round data if not integers
      int_values = stream.values(:);
      if (any((rem(real(stream.values),1) > 0) || (rem(imag(stream.values),1) > 0)))
        fprintf('WARNING: Values for %s are not purely integers. Rounding data...\n', stream_name);
        int_values = complex(round(real(int_values)), round(imag(int_values)));
      end
      % Convert to hex
      num_hex_digits = ceil((stream.bit_width / 2) / 4); % /2 for complex, /4 for bits in hex character
      if (stream.is_signed)
        hex_values = [signed2hex(imag(int_values), num_hex_digits), signed2hex(real(int_values), num_hex_digits)];
      else
        hex_values = [dec2hex(imag(int_values), num_hex_digits), dec2hex(real(int_values), num_hex_digits)];
      end
    else
      % Round data if not integers
      int_values = stream.values(:);
      if (any(rem(stream.values,1) > 0))
        fprintf('WARNING: Values for %s are not purely integers. Rounding data...\n', stream_name);
        int_values = round(int_values);
      end
      % Convert to hex
      num_hex_digits = ceil(stream.bit_width / 4); % /4 for bits in hex character
      if (stream.is_signed)
        hex_values = signed2hex(int_values, num_hex_digits);
      else
        hex_values = dec2hex(int_values, num_hex_digits);
      end
    end
    %****************************************
    % Write to file
    %****************************************
    % Open file
    fileID = fopen([file_prefix,stream_name,'.txt'],'w');
    % Write hexadecimal values to file
    for n=1:length(stream.values)
      fprintf(fileID, '%s\n', hex_values(n,:));
    end
    % Close file
    fclose(fileID);
  end
end
