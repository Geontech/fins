%===============================================================================
% Company:     Geon Technologies, LLC
% File:        fins_compare.m
% Description: This function inputs two FinStreams structures, compares them,
%              and saves the error in the second FinStreams structure.
% Inputs:      model_fins - FinStreams structure
%                * Each field within structure requires the following fields:
%                    .values
%              sim_fins - FinStreams structure
%                * Each field within structure requires the following fields:
%                    .values
%                    .bit_width
%                    .is_signed
%                * Each field within the structure can optionally have the
%                  following fields:
%                    .scale_factor
% Outputs:     fins_error - FinStreamsError structure
%                * Each field within structure has the following fields:
%                    .error_values_absolute
%                    .error_max_absolute
%                    .error_avg_absolute
%                    .error_values_relative
%                    .error_max_relative
%                    .error_avg_relative
% Usage:       [FinStreamsError fins_error] = fins_compare(FinStreams model_fins, FinStreams sim_fins)
%
% Revision History:
% Date        Author             Revision
% ----------  -----------------  -----------------------------------------------
% 2017-08-15  Josh Schindehette  Initial Version
%
%===============================================================================
function [ fins_error ] = fins_compare( varargin )

  %-----------------------------------------------------------------------------
  % Get Variable Inputs
  %-----------------------------------------------------------------------------
  % Default error to be true
  input_error = true;

  % Check for valid inputs
  if ((nargin == 2) && isstruct(varargin{1}) && isstruct(varargin{2}))
    % Set inputs
    model_fins  = varargin{1};
    sim_fins    = varargin{2};
    % Turn off error
    input_error = false;
  end

  % Report input error
  if (input_error)
    error('Incorrect usage. Correct syntax: [FinStreamsError fins_error] = fins_compare(FinStreams model_fins, FinStreams sim_fins)');
  end

  %-----------------------------------------------------------------------------
  % Get FinStreams
  %-----------------------------------------------------------------------------
  % Retrieve the stream names
  model_stream_names = fieldnames(model_fins);
  sim_stream_names   = fieldnames(sim_fins);

  % Check that there are the same streams between the two FinStreams structures
  if (~isequal(sort(model_stream_names), sort(sim_stream_names)))
    error('The stream names do not match between the two FinStreams structures.');
  elseif (length(sim_stream_names) == 0)
    error('There are no streams in the FinStreams structures.');
  end

  %-----------------------------------------------------------------------------
  % Iterate through streams
  %-----------------------------------------------------------------------------
  % Initialize the output FinStreamsError structure
  fins_error = {};

  % Loop through streams
  for n=1:length(sim_stream_names)
    % Get the stream name
    stream_name = sim_stream_names{n};

    % Get the individual stream structures from the FinStreams structure
    sim_stream   = sim_fins.(stream_name);
    model_stream = model_fins.(stream_name);

    % Get the scale factor if there is one
    if (isfield(sim_stream,'scale_factor'))
      scale_factor = sim_stream.scale_factor;
    else
      scale_factor = 0;
    end

    % Initialize the FinStreamError structure
    error_stream = {};

    % Compare the values
    if (length(sim_stream.values) > 0)
      %****************************************
      % Retrieve the values
      %****************************************
      % Scale the model values and force to column vector
      model_values = model_stream.values(:) .* 2^(scale_factor);
      % Force the sim values to column vector
      sim_values   = sim_stream.values(:);
      %****************************************
      % Get the absolute error values
      %****************************************
      % Calculate the Error
      error_stream.error_values_absolute = abs(sim_values - model_values);
      % Find the Max & Avg
      error_stream.error_max_absolute = max(error_stream.error_values_absolute);
      error_stream.error_avg_absolute = mean(error_stream.error_values_absolute);
      %****************************************
      % Get the relative error values
      %****************************************
      % Calculate the Error
      if (sim_stream.is_signed)
        error_stream.error_values_relative = error_stream.error_values_absolute ./ 2^(sim_stream.bit_width-1);
      else
        error_stream.error_values_relative = error_stream.error_values_absolute ./ 2^(sim_stream.bit_width);
      end
      % Find the Max & Avg
      error_stream.error_max_relative = max(error_stream.error_values_relative);
      error_stream.error_avg_relative = mean(error_stream.error_values_relative);
    else
      disp('WARNING: The simulation output is empty.');
    end

    % Give the error_stream the same properties as sim_stream
    if (isfield(sim_stream,'xlabel'))
      error_stream.xlabel = sim_stream.xlabel;
    end
    if (isfield(sim_stream,'ylabel'))
      error_stream.ylabel = sim_stream.ylabel;
    end
    if (isfield(sim_stream,'title'))
      error_stream.title = sim_stream.title;
    end

    % Put the FinStreamError back in the FinStreamsError
    fins_error.(stream_name) = error_stream;

  end
end
