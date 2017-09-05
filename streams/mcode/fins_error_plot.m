%===============================================================================
% Company:     Geon Technologies, LLC
% File:        fins_error_plot.m
% Description: This function plots the error values of a FinStreamsError structure
% Inputs:      fins_error - FinStreamsError structure
%                * Each field within structure requires the following fields:
%                    .error_values_absolute
%                    .error_values_relative
%                * Each field within structure can have the optional fields:
%                    .frame_size
%                    .xlabel
%                    .ylabel
%                    .title
% Outputs:     (none - this function creates a plot window)
% Usage:       fins_error_plot(FinStreamsError fins_error)
%
% Revision History:
% Date        Author             Revision
% ----------  -----------------  -----------------------------------------------
% 2017-08-15  Josh Schindehette  Initial Version
%
%===============================================================================
function [] = fins_error_plot( varargin )

  %-----------------------------------------------------------------------------
  % Get Variable Inputs
  %-----------------------------------------------------------------------------
  % Defaults
  input_error = true;

  % Check for valid inputs
  if ((nargin == 1) && isstruct(varargin{1}))
    % Set inputs
    fins_error  = varargin{1};
    % Turn off error
    input_error = false;
  end

  % Report input error
  if (input_error)
    error('Incorrect usage. Correct syntax: fins_error_plot(FinStreamsError fins_error)');
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
    % Plot Absolute Errors
    %****************************************
    % Create the figure
    figure; hold on;
    % Check if data is complex
    if (~isreal(stream.error_values_absolute))
      % Plot error
      plot(real(stream.error_values_absolute),'b');
      plot(imag(stream.error_values_absolute),'r');
      % Get the min and max values for the frame lines
      max_plot_value = max(max(real(stream.error_values_absolute)),max(imag(stream.error_values_absolute)));
      min_plot_value = min(min(real(stream.error_values_absolute)),min(imag(stream.error_values_absolute)));
    else
      % Plot error
      plot(stream.error_values_absolute);
      % Get the min and max values for the frame lines
      max_plot_value = max(stream.error_values_absolute);
      min_plot_value = min(stream.error_values_absolute);
    end
    % Add a line to separate the frames
    if (isfield(stream,'frame_size'))
      num_frames = floor(length(stream.values) / stream.frame_size);
      for n=1:num_frames
        line([n*stream.frame_size n*stream.frame_size],[min_plot_value max_plot_value],'linestyle','--','color','k');
      end
    end
    % Add the Plot Text
    if (isfield(stream,'xlabel'))
      xlabel(stream.xlabel);
    end
    if (isfield(stream,'ylabel'))
      ylabel(stream.ylabel);
    end
    if (isfield(stream,'title'))
      title(['Absolute Error: ', stream.title]);
    else
      title(['Absolute Error: ', stream_name]);
    end
    %****************************************
    % Plot Relative Errors (to Full Scale)
    %****************************************
    % Create the figure
    figure; hold on;
    % Check if data is complex
    if (~isreal(stream.error_values_relative))
      % Plot error
      plot(real(stream.error_values_relative),'b');
      plot(imag(stream.error_values_relative),'r');
      % Get the min and max values for the frame lines
      max_plot_value = max(max(real(stream.error_values_relative)),max(imag(stream.error_values_relative)));
      min_plot_value = min(min(real(stream.error_values_relative)),min(imag(stream.error_values_relative)));
    else
      % Plot error
      plot(stream.error_values_relative);
      % Get the min and max values for the frame lines
      max_plot_value = max(stream.error_values_relative);
      min_plot_value = min(stream.error_values_relative);
    end
    % Add a line to separate the frames
    if (isfield(stream,'frame_size'))
      num_frames = floor(length(stream.values) / stream.frame_size);
      for n=1:num_frames
        line([n*stream.frame_size n*stream.frame_size],[min_plot_value max_plot_value],'linestyle','--','color','k');
      end
    end
    % Add the Plot Text
    if (isfield(stream,'xlabel'))
      xlabel(stream.xlabel);
    end
    if (isfield(stream,'ylabel'))
      ylabel(stream.ylabel);
    end
    if (isfield(stream,'title'))
      title(['Relative Error (to FS): ', stream.title]);
    else
      title(['Relative Error (to FS): ', stream_name]);
    end
  end
end
