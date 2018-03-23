%===============================================================================
% Company:     Geon Technologies, LLC
% Author:      Josh Schindehette
% Copyright:   (c) 2018 Geon Technologies, LLC. All rights reserved.
%              Dissemination of this information or reproduction of this 
%              material is strictly prohibited unless prior written
%              permission is obtained from Geon Technologies, LLC
% Description: This function checks the fields of a FinStreams structure to make
%              sure the user has provided valid values.
% Inputs:      fins - FinStreams structure
%                * Each field within structure requires the following fields:
%                    .values
%                    .bit_width
%                    .is_signed
%                    .is_complex
%                    .frame_size
%                * Each field within the structure can optionally have the
%                  following fields
%                    .xlabel
%                    .ylabel
%                    .title
%                    .scale_factor
%              verbose - boolean
%                * Default is true
%                * When verbose is true, "Notes" are printed along with "Errors"
%                  and "Warnings"
% Outputs:     result - boolean
%                * True if all checks pass, otherwise false
% Usage:       fins_check(FinStreams fins, <boolean verbose>)
%===============================================================================
function [ result ] = fins_check( varargin )

  %-----------------------------------------------------------------------------
  % Get Variable Inputs
  %-----------------------------------------------------------------------------
  % Check for valid inputs
  if ((nargin == 1) && isstruct(varargin{1}))
    % Set inputs
    fins        = varargin{1};
    verbose     = true;
  elseif ((nargin == 2) && isstruct(varargin{1}) && islogical(varargin{2}))
    % Set inputs
    fins        = varargin{1};
    verbose     = varargin{2};
  else
    error('Incorrect usage. Correct syntax: fins_check(FinStreams fins, <boolean verbose>)');
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

  % Print the header
  fprintf('****** START: FinStreams Structure Check\n');

  % Initialize the result
  result = true;

  %-----------------------------------------------------------------------------
  % Iterate through streams
  %-----------------------------------------------------------------------------
  for n=1:length(stream_names)
    %****************************************
    % Get the stream
    %****************************************
    stream_name = stream_names{n};
    stream = fins.(stream_name);
    fprintf('--- Stream: %s\n', stream_name);
    %****************************************
    % Perform data type checks
    %****************************************
    if (isnumeric(stream.values))
      if (verbose)
        fprintf('Note: The data type for %s is correct.\n', '.values');
      end
    else
      fprintf('Error: The data type for %s is incorrect.\n', '.values');
      result = false;
    end
    if (isnumeric(stream.bit_width))
      if (verbose)
        fprintf('Note: The data type for %s is correct.\n', '.bit_width');
      end
    else
      fprintf('Error: The data type for %s is incorrect.\n', '.bit_width');
      result = false;
    end
    if (islogical(stream.is_signed))
      if (verbose)
        fprintf('Note: The data type for %s is correct.\n', '.is_signed');
      end
    else
      fprintf('Error: The data type for %s is incorrect.\n', '.is_signed');
      result = false;
    end
    if (islogical(stream.is_complex))
      if (verbose)
        fprintf('Note: The data type for %s is correct.\n', '.is_complex');
      end
    else
      fprintf('Error: The data type for %s is incorrect.\n', '.is_complex');
      result = false;
    end
    if (isnumeric(stream.frame_size))
      if (verbose)
        fprintf('Note: The data type for %s is correct.\n', '.frame_size');
      end
    else
      fprintf('Error: The data type for %s is incorrect.\n', '.frame_size');
      result = false;
    end
    if (isfield(stream, 'xlabel'))
      if (ischar(stream.xlabel))
        if (verbose)
          fprintf('Note: The data type for %s is correct.\n', '.xlabel');
        end
      else
        fprintf('Error: The data type for %s is incorrect.\n', '.xlabel');
        result = false;
      end
    end
    if (isfield(stream, 'ylabel'))
      if (ischar(stream.ylabel))
        if (verbose)
          fprintf('Note: The data type for %s is correct.\n', '.ylabel');
        end
      else
        fprintf('Error: The data type for %s is incorrect.\n', '.ylabel');
        result = false;
      end
    end
    if (isfield(stream, 'title'))
      if (ischar(stream.title))
        if (verbose)
          fprintf('Note: The data type for %s is correct.\n', '.title');
        end
      else
        fprintf('Error: The data type for %s is incorrect.\n', '.title');
        result = false;
      end
    end
    if (isfield(stream, 'scale_factor'))
      if (isnumeric(stream.scale_factor))
        if (verbose)
          fprintf('Note: The data type for %s is correct.\n', '.scale_factor');
        end
      else
        fprintf('Error: The data type for %s is incorrect.\n', '.scale_factor');
        result = false;
      end
    end
    %****************************************
    % Perform functional checks
    %****************************************
    % Check "is_complex" field
    if (stream.is_complex)
      if (~isreal(stream.values))
        if (verbose)
          fprintf('Note: The data is correctly designated as complex.\n');
        end
      else
        fprintf('Error: The .is_complex field is TRUE but the data in the .values field is not complex.\n');
        result = false;
      end
    else
      if (~isreal(stream.values))
        fprintf('Error: The .is_complex field is FALSE but the data in the .values field is complex.\n');
        result = false;
      else
        if (verbose)
          fprintf('Note: The data is correctly designated as real.\n');
        end
      end
    end
    % Check "frame_size" field
    if (mod(length(stream.values),stream.frame_size) > 0)
      fprintf('Error: The length of the .values field is not divisible by the .frame_size field.\n');
      result = false;
    else
      if (verbose)
        fprintf('Note: The data correctly has frames with size %d.\n', stream.frame_size);
      end
    end
    % Check "is_signed" field
    if (stream.is_signed)
      if (any(stream.values < 0))
        if (verbose)
          fprintf('Note: The data is correctly designated as signed.\n');
        end
      else
        fprintf('Warning: The .is_signed field is TRUE but the data in the .values field has no negative elements.\n');
      end
    else
      if (any(stream.values < 0))
        fprintf('Error: The .is_signed field is FALSE but the data in the .values field has negative elements.\n');
        result = false;
      else
        if (verbose)
          fprintf('Note: The data is correctly designated as unsigned.\n');
        end
      end
    end
    % Check "bit_width" field
    if (stream.is_complex)
      % Check that the bit width is even
      if (mod(stream.bit_width,2) > 0)
        fprintf('Error: The .bit_width field cannot be ODD when the .is_complex field is TRUE since the bit width is representing both real and imaginary.\n');
        result = false;
      else
        % Print note
        if (verbose)
          fprintf('Note: The .bit_width field is correctly even for the complex data.\n');
        end
        % Calculate the full scale value for this bit width
        if (stream.is_signed)
          max_fs = 2^(stream.bit_width/2-1) - 1;
          min_fs = -2^(stream.bit_width/2-1);
        else
          max_fs = 2^(stream.bit_width/2) - 1;
          min_fs = -2^(stream.bit_width/2);
        end
        % Calculate the min/max of the values
        max_value = max(max(real(stream.values)), max(imag(stream.values)));
        min_value = min(min(real(stream.values)), min(imag(stream.values)));
        % Check that the amplitude of the values fit in the bit width
        if ((max_value > max_fs) || (min_value < min_fs))
          fprintf('Error: The complex data in the .values field does not fit within fixed point format specified by .bit_width and .is_signed.\n');
          result = false;
        else
          if (verbose)
            fprintf('Note: The complex data in the .values field correctly fits within fixed point format specified by .bit_width and .is_signed.\n');
          end
        end
      end
    else
      % Calculate the full scale value for this bit width
      if (stream.is_signed)
        max_fs = 2^(stream.bit_width-1) - 1;
        min_fs = -2^(stream.bit_width-1);
      else
        max_fs = 2^(stream.bit_width) - 1;
        min_fs = -2^(stream.bit_width);
      end
      % Calculate the min/max of the values
      max_value = max(stream.values);
      min_value = min(stream.values);
      % Check that the amplitude of the values fit in the bit width
      if ((max_value > max_fs) || (min_value < min_fs))
        fprintf('Error: The data in the .values field does not fit within fixed point format specified by .bit_width and .is_signed.\n');
        result = false;
      else
        if (verbose)
          fprintf('Note: The data in the .values field correctly fits within fixed point format specified by .bit_width and .is_signed.\n');
        end
      end
    end
  end

  % Print a footer
  fprintf('****** END:   FinStreams Structure Check\n');
end
