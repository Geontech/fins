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
    [stream.values,stream.scale_factor] = make_full_scale(stream.values,...
                                                          stream.bit_width, ...
                                                          stream.is_complex, ...
                                                          stream.is_signed);
    %****************************************
    % Put the stream back in FinStreams
    %****************************************
    fins.(stream_name) = stream;
  end
end
