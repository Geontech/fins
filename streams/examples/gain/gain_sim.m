%===============================================================================
% Company:     Geon Technologies, LLC
% File:        gain_sim.m
% Description: This matlab/octave script simulates the gain algorithm
%
% Revision History:
% Date        Author             Revision
% ----------  -----------------  -----------------------------------------------
% 2017-08-15  Josh Schindehette  Initial Version
%
%===============================================================================
%-------------------------------------------------------------------------------
% Script Setup
%-------------------------------------------------------------------------------
% Clear workspace
clear; close all;

% Add path to FinStreams library
addpath('../../mcode')

% Simulation Parameters
% --> Must match gain_tb.vhd!
FRAMES_TO_RUN  = 50;
FRAME_SIZE     = 32;
GAIN_VALUE     = 23;
DATA_IS_SIGNED = true;
DATA_WIDTH     = 16;

%-------------------------------------------------------------------------------
% Model Data
%-------------------------------------------------------------------------------
% Setup Input Data Lane
model_in.data.bit_width  = DATA_WIDTH;
model_in.data.is_complex = false;
model_in.data.is_signed  = DATA_IS_SIGNED;
model_in.data.frame_size = FRAME_SIZE;
model_in.data.values     = 1000 .* sin(0:(FRAME_SIZE*FRAMES_TO_RUN-1));

% Check all FinStreams
fins_check(model_in);

% Plot all FinStreams
fins_plot(model_in, 'Model Input:');

% Setup Output Data Lane
model_out.data.bit_width  = DATA_WIDTH;
model_out.data.is_complex = false;
model_out.data.is_signed  = DATA_IS_SIGNED;
model_out.data.frame_size = FRAME_SIZE;
model_out.data.values     = model_in.data.values .* GAIN_VALUE;

% Check all FinStreams
fins_check(model_out);

% Plot all FinStreams
fins_plot(model_out, 'Model Output:');

%-------------------------------------------------------------------------------
% Simulation Data
%-------------------------------------------------------------------------------
% Initialize the simulation input
sim_in = model_in;

% Check all FinStreams
fins_check(sim_in);

% Plot all FinStreams
fins_plot(sim_in, 'Simulation Input:');

% Write the simulation input data to file
fins_write(sim_in);

%-------------------------------------------------------------------------------
% Run the Simulation
%-------------------------------------------------------------------------------
system('vivado -mode batch -source gain_sim.tcl');

%-------------------------------------------------------------------------------
% Simulation Output
%-------------------------------------------------------------------------------
% Initialize simulation output
sim_out = model_out;

% Read values
sim_out = fins_read(sim_out);

% Check all FinStreams
fins_check(sim_out);

% Plot all FinStreams
fins_plot(sim_out, 'Simulation Output:');

%-------------------------------------------------------------------------------
% Find the Error Between Simulation and Model
%-------------------------------------------------------------------------------
% Compare the model to the data
sim_error = fins_compare(model_out, sim_out); % Simulation MUST be second parameter

% Write the error to a results file
fins_error_write(sim_error, 'gain_results.txt');

% Plot Error & Overlay
fins_error_plot(sim_error);
fins_plot(model_out, sim_out, 'Model vs. Sim:'); % Simulation MUST be second parameter

% Save the data
save('gain_results.mat','model_in','model_out','sim_in','sim_out','sim_error');

% Wait for user to close octave
input('Press Enter to continue ...');
