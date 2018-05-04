%===============================================================================
% Company:     Geon Technologies, LLC
% Author:      Josh Schindehette
% Copyright:   (c) 2018 Geon Technologies, LLC. All rights reserved.
%              Dissemination of this information or reproduction of this 
%              material is strictly prohibited unless prior written
%              permission is obtained from Geon Technologies, LLC
% Description: This function scales the values of a FinStreams structure up by a
%              power of 2, calculated to keep the values within valid ranges
%              allowable by the .bit_width field of each stream. Scaling the
%              values of each stream prepares the values for conversion to
%              hexadecimal.
% Inputs:      fins - FinStreams structure
%                * Each field within structure requires the following fields:
%                    .values
%                    .bit_width
%                    .is_signed
%                    .is_complex
% Outputs:     This function modifies each field within the FinStreams structure
%              by adding the following field:
%                .scale_factor
%              and by modifying the following field:
%                .values
% Usage:       fins_scale(FinStreams fins)
%===============================================================================
function [ fins ] = fins_scale( varargin )

  %-----------------------------------------------------------------------------
  % Get Variable Inputs
  %-----------------------------------------------------------------------------
  % Check for valid inputs
  if ((nargin == 1) && isstruct(varargin{1}))
    % Set inputs
    fins = varargin{1};
  else
    error('Incorrect usage. Correct syntax: fins_scale(FinStreams fins)');
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
    % Scale the values
    %****************************************
    if (stream.is_complex)
      % Find the full scale value based on the data format
      if (stream.is_signed)
        full_scale = 2^((stream.bit_width/2)-1)-1;
      else
        full_scale = 2^(stream.bit_width/2)-1;
      end
      % Find the how the max of the values fits into the .bit_width's full scale
      max_scale = full_scale / max(max(real(stream.values)), max(imag(stream.values)));
      % Find a power of 2 scale factor that keeps values within max_scale
      stream.scale_factor = floor(log2(max_scale));
      % Scale the data
      stream.values = complex(round(real(stream.values) .* 2^(stream.scale_factor)), ...
                              round(imag(stream.values) .* 2^(stream.scale_factor)));
    else
      % Find the full scale value based on the data format
      if (stream.is_signed)
        full_scale = 2^(stream.bit_width-1)-1;
      else
        full_scale = 2^(stream.bit_width)-1;
      end
      % Find the how the max of the values fits into the .bit_width's full scale
      max_scale = full_scale / max(stream.values);
      % Find a power of 2 scale factor that keeps values within max_scale
      stream.scale_factor = floor(log2(max_scale));
      % Scale the data
      stream.values = round(stream.values .* 2^(stream.scale_factor));
    end
    %****************************************
    % Put the stream back in FinStreams
    %****************************************
    fins.(stream_name) = stream;
  end
end
