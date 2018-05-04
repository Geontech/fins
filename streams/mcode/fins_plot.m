%===============================================================================
% Company:     Geon Technologies, LLC
% Author:      Josh Schindehette
% Copyright:   (c) 2018 Geon Technologies, LLC. All rights reserved.
%              Dissemination of this information or reproduction of this 
%              material is strictly prohibited unless prior written
%              permission is obtained from Geon Technologies, LLC
% Description: This function plots data that is formatted in a FinStreams
%              structure.
% Inputs:      model_fins - FinStreams structure
%                * Each field within structure requires the following fields:
%                    .values
%                * Each field within structure can have the optional fields:
%                    .frame_size
%                    .xlabel
%                    .ylabel
%                    .title
%              sim_fins   - FinStreams structure (optional)
%                * Each field within structure requires the following fields:
%                    .values
%                * Each field within structure can have the optional fields:
%                    .scale_factor
%                    .frame_size
%                    .xlabel
%                    .ylabel
%                    .title
%              do_fft   - logical (optional)
%                * false (default)
%                * true
% Outputs:     (none - this function creates a plot window)
% Usage:       fins_plot(FinStreams sl)
%              fins_plot(FinStreams sl, bool do_fft)
%              fins_plot(FinStreams sl, string title_prefix)
%              fins_plot(FinStreams sl, bool do_fft, string title_prefix)
%              fins_plot(FinStreams model_fins, FinStreams sim_fins)
%              fins_plot(FinStreams model_fins, FinStreams sim_fins, bool do_fft)
%              fins_plot(FinStreams model_fins, FinStreams sim_fins, string title_prefix)
%              fins_plot(FinStreams model_fins, FinStreams sim_fins, bool do_fft, string title_prefix)
%===============================================================================
function [] = fins_plot( varargin )

  %-----------------------------------------------------------------------------
  % Get Variable Inputs
  %-----------------------------------------------------------------------------
  % Set defaults
  use_overlay  = false;
  sim_fins       = {};
  do_fft       = false;
  title_prefix = '';

  % Check for valid inputs
  if ((nargin == 1) && isstruct(varargin{1}))
    % Set inputs
    model_fins  = varargin{1};
  elseif ((nargin == 2) && isstruct(varargin{1}) && isstruct(varargin{2}))
    % Set inputs
    model_fins  = varargin{1};
    sim_fins    = varargin{2};
    % Turn on overlay
    use_overlay = true;
  elseif ((nargin == 2) && isstruct(varargin{1}) && islogical(varargin{2}))
    % Set inputs
    model_fins  = varargin{1};
    do_fft      = varargin{2};
  elseif ((nargin == 2) && isstruct(varargin{1}) && ischar(varargin{2}))
    % Set inputs
    model_fins   = varargin{1};
    title_prefix = varargin{2};
  elseif ((nargin == 3) && isstruct(varargin{1}) && isstruct(varargin{2}) && islogical(varargin{3}))
    % Set inputs
    model_fins  = varargin{1};
    sim_fins    = varargin{2};
    do_fft      = varargin{3};
    % Turn on overlay
    use_overlay = true;
  elseif ((nargin == 3) && isstruct(varargin{1}) && isstruct(varargin{2}) && ischar(varargin{3}))
    % Set inputs
    model_fins   = varargin{1};
    sim_fins     = varargin{2};
    title_prefix = varargin{3};
    % Turn on overlay
    use_overlay  = true;
  elseif ((nargin == 3) && isstruct(varargin{1}) && islogical(varargin{2}) && ischar(varargin{3}))
    % Set inputs
    model_fins   = varargin{1};
    do_fft       = varargin{2};
    title_prefix = varargin{3};
  elseif ((nargin == 4) && isstruct(varargin{1})  && isstruct(varargin{2}) && ...
          islogical(varargin{3}) && ischar(varargin{4}))
    % Set inputs
    model_fins   = varargin{1};
    sim_fins     = varargin{2};
    do_fft       = varargin{3};
    title_prefix = varargin{4};
    % Turn on overlay
    use_overlay  = true;
  else
    error( ...
      ['Incorrect usage. Correct syntax:\n', ...
       '    fins_plot(FinStreams sl)\n', ...
       '    fins_plot(FinStreams sl, bool do_fft)\n', ...
       '    fins_plot(FinStreams sl, string title_prefix)\n', ...
       '    fins_plot(FinStreams sl, bool do_fft, string title_prefix)\n', ...
       '    fins_plot(FinStreams model_fins, FinStreams sim_fins)\n', ...
       '    fins_plot(FinStreams model_fins, FinStreams sim_fins, bool do_fft)\n', ...
       '    fins_plot(FinStreams model_fins, FinStreams sim_fins, string title_prefix)\n', ...
       '    fins_plot(FinStreams model_fins, FinStreams sim_fins, bool do_fft, string title_prefix)\n' ...
      ] ...
    );
  end

  %-----------------------------------------------------------------------------
  % Get FinStreams
  %-----------------------------------------------------------------------------
  % Retrieve the stream names
  model_stream_names = fieldnames(model_fins);
  if (use_overlay)
    sim_stream_names = fieldnames(sim_fins);
  end

  % Check that there are the same streams between the two FinStreams structures
  if (use_overlay && ~isequal(sort(model_stream_names), sort(sim_stream_names)))
    error('The stream names do not match between the two FinStreams structures.');
  end

  % Check that there are streams
  if (length(model_stream_names) == 0)
    error('There are no streams in the FinStreams structure.')
  end

  %-----------------------------------------------------------------------------
  % Iterate through streams
  %-----------------------------------------------------------------------------
  for n=1:length(model_stream_names)
    %****************************************
    % Get the streams
    %****************************************
    stream_name  = model_stream_names{n};
    model_stream = model_fins.(stream_name);
    if (use_overlay)
      sim_stream = sim_fins.(stream_name);
      if (isfield(sim_stream,'scale_factor'))
        scale_factor = sim_stream.scale_factor;
      else
        scale_factor = 0;
      end
    end

    %****************************************
    % Plot the figure
    %****************************************
    % Create figure
    figure; hold on;

    % Check if we need to do a FFT on the data to view frequency domain
    if (do_fft)
      % Create the scale for the x-axis
      f = linspace(-pi,pi,length(model_stream.values));
      % Calculate the frequency_values
      if (use_overlay)
        model_stream_freq = 20*log10(fftshift(abs(fft(model_stream.values .* 2^scale_factor))));
        sim_stream_freq = 20*log10(fftshift(abs(fft(sim_stream.values))));
      else
        model_stream_freq = 20*log10(fftshift(abs(fft(model_stream.values))));
      end
      % Plot the data
      p1 = plot(f,model_stream_freq,'b');
      if (use_overlay)
        p2 = plot(f,sim_stream_freq,'r');
        legend([p1,p2],'Model','Simulation');
      end
      % Set the axis boundaries
      axis([-pi pi]);
    else
      % Check if data is complex
      if (~isreal(model_stream.values))
        % Plot the data
        if (use_overlay)
          % Plot real
          subplot(2,1,1); hold on;
          p1 = plot(real(model_stream.values) .* 2^scale_factor,'b');
          p2 = plot(real(sim_stream.values),'r');
          % Add lines to separate the frames
          if (isfield(model_stream,'frame_size'))
            num_frames = floor(length(model_stream.values) / model_stream.frame_size);
            max_plot_value = max(max(real(model_stream.values)),max(real(sim_stream.values)));
            min_plot_value = min(min(real(model_stream.values)),min(real(sim_stream.values)));
            for n=1:num_frames
              line([n*model_stream.frame_size n*model_stream.frame_size],[min_plot_value max_plot_value],'linestyle','--','color','k');
            end
          end
          % Add legend
          legend([p1,p2],'Model','Simulation');
          % Plot imag
          subplot(2,1,2); hold on;
          p3 = plot(imag(model_stream.values) .* 2^scale_factor,'b');
          p4 = plot(imag(sim_stream.values),'r');
          % Add lines to separate the frames
          if (isfield(model_stream,'frame_size'))
            num_frames = floor(length(model_stream.values) / model_stream.frame_size);
            max_plot_value = max(max(imag(model_stream.values)),max(imag(sim_stream.values)));
            min_plot_value = min(min(imag(model_stream.values)),min(imag(sim_stream.values)));
            for n=1:num_frames
              line([n*model_stream.frame_size n*model_stream.frame_size],[min_plot_value max_plot_value],'linestyle','--','color','k');
            end
          end
          % Add legend
          legend([p3,p4],'Model','Simulation');
        else
          % Plot real & imaginary
          p1 = plot(real(model_stream.values),'b');
          p2 = plot(imag(model_stream.values),'r');
          % Add lines to separate the frames
          if (isfield(model_stream,'frame_size'))
            num_frames = floor(length(model_stream.values) / model_stream.frame_size);
            max_plot_value = max(max(real(model_stream.values)),max(imag(model_stream.values)));
            min_plot_value = min(min(real(model_stream.values)),min(imag(model_stream.values)));
            for n=1:num_frames
              line([n*model_stream.frame_size n*model_stream.frame_size],[min_plot_value max_plot_value],'linestyle','--','color','k');
            end
          end
          % Add legend
          legend([p1,p2],'Real','Imag');
        end
      else
        % Plot the data
        if (use_overlay)
          p1 = plot(model_stream.values .* 2^scale_factor,'b');
          p2 = plot(sim_stream.values,'r');
        else
          plot(model_stream.values,'b');
        end
        % Add lines to separate the frames
        if (isfield(model_stream,'frame_size'))
          num_frames = floor(length(model_stream.values) / model_stream.frame_size);
          if (use_overlay)
            max_plot_value = max(max(model_stream.values), max(sim_stream.values));
            min_plot_value = min(min(model_stream.values), min(sim_stream.values));
          else
            max_plot_value = max(model_stream.values);
            min_plot_value = min(model_stream.values);
          end
          for n=1:num_frames
            line([n*model_stream.frame_size n*model_stream.frame_size],[min_plot_value max_plot_value],'linestyle','--','color','k');
          end
        end
        % Add legend
        if (use_overlay)
          legend([p1,p2],'Model','Simulation');
        end
      end
    end
    %****************************************
    % Add the Plot Text
    %****************************************
    % Optional xlabel
    if (isfield(model_stream,'xlabel'))
      xlabel(model_stream.xlabel);
    end
    % Optional ylabel
    if (isfield(model_stream,'ylabel'))
      ylabel(model_stream.ylabel);
    end
    % Optional title
    if (isfield(model_stream,'title'))
      title([title_prefix,' ',model_stream.title]);
    else
      title([title_prefix,' ',stream_name]);
    end
  end
end
