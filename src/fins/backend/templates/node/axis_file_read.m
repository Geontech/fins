{#-
 %
 % Copyright (C) 2021 Geon Technologies, LLC
 %
 % This file is part of FINS.
 %
 % FINS is free software: you can redistribute it and/or modify it under the
 % terms of the GNU Lesser General Public License as published by the Free
 % Software Foundation, either version 3 of the License, or (at your option)
 % any later version.
 %
 % FINS is distributed in the hope that it will be useful, but WITHOUT ANY
 % WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 % FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License for
 % more details.
 %
 % You should have received a copy of the GNU Lesser General Public License
 % along with this program.  If not, see http://www.gnu.org/licenses/.
 %
-#}
{%- if 'license_lines' in fins %}
{%-  for line in fins['license_lines'] -%}
% {{ line }}
{%-  endfor %}
{%- endif %}

%==============================================================================
% Firmware IP Node Specification (FINS) Auto-Generated File
% ---------------------------------------------------------
% Template:    axis_file_read.m
% Backend:     {{ fins['backend'] }}
% ---------------------------------------------------------
% Description: MATLAB/Octave function that reads a text file with AXI-Stream
%              transactions in hex characters, one transaction per line. The
%              last is read from a single hex character first, followed by
%              a space, followed by the data, followed by another space, and
%              then followed by the metadata (if applicable). If the data is
%              complex, it is read from the file with the imag component first
%              (in the MSBs). The data/metadata definitions are sourced from a
%              FINS Port, and the text file is written by the axis_verify.vhd
%              module as a testbench "sink".
%              Example: "0 1F455AB2 A1" where "0" is the last, "1F45" is imag,
%                       and "5AB2" is real, and "A1" is the metadata
% Inputs:      port_name - string
%                  The name of the port as defined in the FINS Node JSON
%              filepath - string
%                  The filepath of the text file
%              use_cell_array (optional) - bool
%                  When reading a hex character text file with last and data
%                  fields only, this instructs the function to return a cell
%                  array instead of a numeric array.
%                  Default: false
% Outputs:     packets - cell[], int[], or complex[]
%                  The packets read from the text file. All formats assume
%                  that the channels are interleaved.
%                  When there is metadata in the FINS Port definition or
%                  use_cell_array argument is true, each cell of packes is
%                  a struct with fields:
%                      .data - int[] or complex[]
%                          The data for each packet
%                      .metadata - struct
%                          A structure containing named metadata fields that
%                          match the port definition in the FINS Node JSON
%                  When the FINS Port definition does not have metadata and
%                  the use_cell_array argument is false, packets is an int[]
%                  or complex[] containing the data for the entire file.
%              lasts - int[]
%                  An array the length of the input file containing the last
%                  flags.
% Usage:       [ packets, lasts ] = {{ fins['name']|lower }}_axis_file_read(
%                  port_name, filepath
%              )
%              [ packets, lasts ] = {{ fins['name']|lower }}_axis_file_read(
%                  port_name, filepath, use_cell_array
%              )
% Notes:       This code was written in such a way that the metadata field
%              could exist by itself. This is currently not allowed with FINS,
%              so there is validation in this function to require that the
%              data field exists. However, if this validation is removed, the
%              rest of the code permits metadata to exist without data.
% TODO:        This function currently does not support metadata.
%==============================================================================

function [ packets, lasts ] = {{ fins['name']|lower }}_axis_file_read( port_name, filepath, use_cell_array )

  %----------------------------------------------------------------------------
  % Output Port Definitions
  %----------------------------------------------------------------------------
  {% if 'ports' in fins %}
  {% if 'ports' in fins['ports'] %}
  {%- for port in fins['ports']['ports'] %}
  ports.{{ port['name']|lower }}.data.bit_width    = {{ port['data']['bit_width'] }};
  ports.{{ port['name']|lower }}.data.is_complex   = {{ port['data']['is_complex']|lower }};
  ports.{{ port['name']|lower }}.data.is_signed    = {{ port['data']['is_signed']|lower }};
  ports.{{ port['name']|lower }}.data.num_samples  = {{ port['data']['num_samples'] }};
  ports.{{ port['name']|lower }}.data.num_channels = {{ port['data']['num_channels'] }};
  {%- if 'metadata' in port %}
  {%- for metafield in port['metadata'] %}
  ports.{{ port['name']|lower }}.metadata.{{ metafield['name']|lower }}.bit_width  = {{ metafield['bit_width'] }};
  ports.{{ port['name']|lower }}.metadata.{{ metafield['name']|lower }}.is_complex = {{ metafield['is_complex']|lower }};
  ports.{{ port['name']|lower }}.metadata.{{ metafield['name']|lower }}.is_signed  = {{ metafield['is_signed']|lower }};
  {%- endfor %} {#### for metafield in port['metadata'] ####}
  {%- endif %} {#### if 'metadata' in port ####}
  {%- endfor %} {#### for port in fins['ports']['ports'] ####}
  {% endif %} {#### if 'ports' in fins['ports'] ####}
  {% endif %} {#### if 'ports' in fins ####}

  %----------------------------------------------------------------------------
  % Argument Validation
  %----------------------------------------------------------------------------
  % Variable Argument Defaults
  if (nargin == 2)
    % By default, return numeric when possible
    use_cell_array = false;
  end

  % Validate that there are ports
  port_names = fieldnames(ports);
  if (length(port_names) == 0)
    error('No ports have been defined for this module');
  end

  % Validate that the `port_name` argument has a definition
  found_port_name = false;
  for name_index=1:length(port_names)
    if (strcmpi(port_name, port_names{name_index}))
      found_port_name = true;
    end
  end
  if (~found_port_name)
    error(['No port definition for port ',port_name]);
  end

  % Check if file exists
  if (~exist(filepath, 'file'))
    error(['File: ',filepath,' cannot be found.']);
  end

  %----------------------------------------------------------------------------
  % Calculate Parameters
  %----------------------------------------------------------------------------
  % Set the max bit width supported by MATLAB/Octave for decimal to hex conversions
  % NOTE: It is assumed that a single real component does not have have more than 52 bits
  PROCESSOR_WIDTH = 52;
  NUM_PROCESSOR_HEX_CHARS = PROCESSOR_WIDTH/4; % MUST be an integer

  % Get the input port definition for `port_name` argument
  PORT_DEFINITION = ports.(lower(port_name));

  % Retreive commonly used data from PORT_DEFINITION once
  PORT_HAS_DATA = isfield(PORT_DEFINITION, 'data');
  PORT_HAS_METADATA = isfield(PORT_DEFINITION, 'metadata');
  if (PORT_HAS_METADATA)
    METADATA_FIELDNAMES = fieldnames(PORT_DEFINITION.metadata);
    NUM_METADATA_FIELDNAMES = length(METADATA_FIELDNAMES);
  end

  % Calculate derived parameters
  if (PORT_HAS_DATA)
    NUM_SAMPLES_PER_TRANSACTION = PORT_DEFINITION.data.num_channels * PORT_DEFINITION.data.num_samples;
  else
    NUM_SAMPLES_PER_TRANSACTION = 1;
  end

  %----------------------------------------------------------------------------
  % TODO: Remove this when Metadata is implemented
  %----------------------------------------------------------------------------
  if (PORT_HAS_METADATA)
    error('This function currently does not support metadata');
  end

  %----------------------------------------------------------------------------
  % Read File and Convert to Unsigned
  %----------------------------------------------------------------------------
  % Open the file
  fid = fopen(filepath);
  if (PORT_HAS_DATA && PORT_HAS_METADATA)
    % Read each column of the space-separated file into a cell array with dimensions {3}(length of file)
    hex_cell = textscan(fid, '%s %s %s');
  else
    % Read each column of the space-separated file into a cell array with dimensions {2}(length of file)
    hex_cell = textscan(fid, '%s %s');
  end
  fclose(fid);

  % Convert to character matrices
  transactions_last_hex = char(hex_cell{1});
  if (PORT_HAS_DATA)
    transactions_data_hex = char(hex_cell{2});
    if (PORT_HAS_METADATA)
      transactions_metadata_hex = char(hex_cell{3});
    end
  else
    transactions_metadata_hex = char(hex_cell{2});
  end

  % Convert to unsigned column arrays
  num_hex_chars = ceil(NUM_SAMPLES_PER_TRANSACTION*PORT_DEFINITION.data.bit_width/4);
  num_unsigned_columns = ceil(num_hex_chars/NUM_PROCESSOR_HEX_CHARS);
  transactions_last_unsigned = hex2dec(transactions_last_hex);
  if (PORT_HAS_DATA)
    % Convert each hex character into columns that are convertable by the processor
    transactions_data_unsigned = zeros(size(transactions_data_hex,1), num_unsigned_columns);
    for column_index=1:num_unsigned_columns
      if (column_index == num_unsigned_columns)
        transactions_data_unsigned(:, column_index) = hex2dec(transactions_data_hex(:, 1:end-(column_index-1)*NUM_PROCESSOR_HEX_CHARS));
      else
        transactions_data_unsigned(:, column_index) = hex2dec(transactions_data_hex(:, end-column_index*NUM_PROCESSOR_HEX_CHARS+1:end-(column_index-1)*NUM_PROCESSOR_HEX_CHARS));
      end
    end
  end
  if (PORT_HAS_METADATA)
    transactions_metadata_unsigned = hex2dec(transactions_metadata_hex);
  end

  % Validate that lengths match
  if (PORT_HAS_DATA)
    if (length(transactions_last_unsigned) ~= size(transactions_data_unsigned, 1))
      error('Parsing of the hex character file failed, make sure the file format matches the port definition!');
    end
  end
  if (PORT_HAS_METADATA)
    if (length(transactions_last_unsigned) ~= length(transactions_metadata_unsigned))
      error('Parsing of the hex character file failed, make sure the file format matches the port definition!');
    end
  end

  % Calculate some convenience variables
  num_transactions = length(transactions_last_unsigned);
  num_total_samples = num_transactions*NUM_SAMPLES_PER_TRANSACTION;

  %----------------------------------------------------------------------------
  % Data/Last Parsing
  %----------------------------------------------------------------------------
  % Initialize
  lasts = zeros(num_total_samples, 1);
  datas_unsigned = zeros(num_total_samples, 1);
  datas = zeros(num_total_samples, 1);

  % Reverse the time-multiplexing
  % NOTE: Zero-based indexing used
  for t=0:num_transactions-1
    % Unpack last
    lasts(t*NUM_SAMPLES_PER_TRANSACTION+1:(t+1)*NUM_SAMPLES_PER_TRANSACTION) = [zeros(NUM_SAMPLES_PER_TRANSACTION-1, 1); transactions_last_unsigned(t+1)];
    % Unpack data
    if (PORT_HAS_DATA)
      if (PORT_DEFINITION.data.is_complex)
        complex_unsigned = unpack_unsigned_from_columns(transactions_data_unsigned(t+1, :), PORT_DEFINITION.data.bit_width/2, NUM_SAMPLES_PER_TRANSACTION*2);
        datas_unsigned(t*NUM_SAMPLES_PER_TRANSACTION+1:(t+1)*NUM_SAMPLES_PER_TRANSACTION) = complex(complex_unsigned(1:2:end), complex_unsigned(2:2:end));
      else
        datas_unsigned(t*NUM_SAMPLES_PER_TRANSACTION+1:(t+1)*NUM_SAMPLES_PER_TRANSACTION) = unpack_unsigned_from_columns(transactions_data_unsigned(t+1, :), PORT_DEFINITION.data.bit_width, NUM_SAMPLES_PER_TRANSACTION);
      end
    end
  end

  % Convert to signed if applicable  
  if (PORT_HAS_DATA)
    if (PORT_DEFINITION.data.is_signed)
      if (PORT_DEFINITION.data.is_complex)
        datas_real = real(datas_unsigned);
        datas_imag = imag(datas_unsigned);
        datas_real = datas_real - ((datas_real >= 2^(PORT_DEFINITION.data.bit_width/2-1)) .* 2^(PORT_DEFINITION.data.bit_width/2));
        datas_imag = datas_imag - ((datas_imag >= 2^(PORT_DEFINITION.data.bit_width/2-1)) .* 2^(PORT_DEFINITION.data.bit_width/2));
        datas = complex(datas_real, datas_imag);
      else
        datas = datas_unsigned - ((datas_unsigned >= 2^(PORT_DEFINITION.data.bit_width-1)) .* 2^PORT_DEFINITION.data.bit_width);
      end
    else
      datas = datas_unsigned;
    end
  end

  % Final conversion to packets
  if (use_cell_array || PORT_HAS_METADATA)
    % Initialize
    last_indices = find(lasts);
    num_packets = length(last_indices);
    packets = cell(num_packets, 1);
    % Assemble
    for packet_index=1:num_packets
      packets{packet_index} = struct();
      if (packet_index == 1)
        packets{packet_index}.data = datas(1:last_indices(packet_index), 1);
      else
        packets{packet_index}.data = datas(last_indices(packet_index-1)+1:last_indices(packet_index), 1);
      end
    end
  else
    packets = datas;
  end

  %----------------------------------------------------------------------------
  % Metadata Parsing
  %----------------------------------------------------------------------------
  if (PORT_HAS_METADATA)
    % Get the indices of the first transactions of each packet
    transactions_last_indices = find(transactions_last_unsigned);
    transactions_first_indices = [1; transactions_last_indices(1:end-1)+1];
    % Retrieve the metadata for each packet
    packet_metadatas_unsigned = transactions_metadata_unsigned(transactions_first_indices);
    % Set up variables that wouldn't be set up if no data
    if (~PORT_HAS_DATA)
      num_packets = length(packet_metadatas_unsigned);
      packets = cell(num_packets, 1);
      for packet_index=1:num_packets
        packets{packet_index} = struct();
      end
    end
    % Parse each metadata word
    for packet_index=1:num_packets
      % Initialize metadata structure
      packets{packet_index}.metadata = struct();
      % Parse the data by successively right shifting and ANDing with 2^bit_width (using mod)
      bit_index = 0;
      for field_index=1:NUM_METADATA_FIELDNAMES
        % For simplicity, rename some fields
        metafield_bit_width = PORT_DEFINITION.metadata.(METADATA_FIELDNAMES{field_index}).bit_width;
        metafield_is_complex = PORT_DEFINITION.metadata.(METADATA_FIELDNAMES{field_index}).is_complex;
        metafield_is_signed = PORT_DEFINITION.metadata.(METADATA_FIELDNAMES{field_index}).is_signed;
        % Parse the field
        if (metafield_is_complex)
          % Parse into real/imag
          metafield_value_real = mod(floor(packet_metadatas_unsigned(packet_index) / 2^bit_index), 2^(metafield_bit_width/2));
          metafield_value_imag = mod(floor(packet_metadatas_unsigned(packet_index) / 2^(bit_index+metafield_bit_width/2)), 2^(metafield_bit_width/2));
          % Handle the sign bit
          if (metafield_is_signed)
            if (metafield_value_real >= 2^(metafield_bit_width/2-1))
              metafield_value_real = metafield_value_real - 2^(metafield_bit_width/2);
            end
            if (metafield_value_imag >= 2^(metafield_bit_width/2-1))
              metafield_value_imag = metafield_value_imag - 2^(metafield_bit_width/2);
            end
          end
          % Convert to complex
          metafield_value = complex(metafield_value_real, metafield_value_imag);
        else
          % Parse
          metafield_value = mod(floor(packet_metadatas_unsigned(packet_index) / 2^bit_index), 2^metafield_bit_width);
          % Handle sign bit
          if (metafield_is_signed)
            if (metafield_value >= 2^(metafield_bit_width-1))
              metafield_value = metafield_value - 2^metafield_bit_width;
            end
          end
        end
        % Set the field value into the structure
        packets{packet_index}.metadata.(METADATA_FIELDNAMES{field_index}) = metafield_value;
        % Update the bit index
        bit_index = bit_index + metafield_bit_width;
      end
    end
  end

  %----------------------------------------------------------------------------
  % Nested Function
  %----------------------------------------------------------------------------
  function [ y ] = unpack_unsigned_from_columns( x, bit_width, num_samples )
    % Initialize the output rows
    y = zeros(num_samples, 1);

    % Initialize the bit index
    % NOTE: Zero-based index used here
    bit_index = 0;

    % Initialize the column index
    % NOTE: One-based index used here
    column_index = 1;

    % Process all samples
    for sample_index=1:num_samples
      % Calculate how many bits we can unpack in the current column
      num_bits_remaining_in_current_column = PROCESSOR_WIDTH - bit_index;

      % If there are more bits in this sample than can be retreived from the current number of bits
      if (bit_width > num_bits_remaining_in_current_column)
        % Mask off the upper bits for the current column
        current_sample_lsbs = floor(x(column_index) / 2^bit_index);
        % Accumulate the data in the current sample
        y(sample_index) = y(sample_index) + current_sample_lsbs;
        % Move to the next column
        column_index = column_index + 1;
        % Mask off the lower bits for the next column
        current_sample_msbs = mod(x(column_index), 2^(bit_width-num_bits_remaining_in_current_column));
        % Accumulate the data in the current sample
        y(sample_index) = y(sample_index) + current_sample_msbs * 2^num_bits_remaining_in_current_column;
        % Update bit index
        bit_index = bit_width - num_bits_remaining_in_current_column;
        % Move to the next next column if this one is filled
        if (bit_index == PROCESSOR_WIDTH-1)
          bit_index = 0;
          column_index = column_index + 1;
        end
      else
        % Accumulate the data in the current sample
        y(sample_index) = mod(floor(x(column_index) / 2^bit_index), 2^bit_width);
        % Update bit index
        bit_index = bit_index + bit_width;
        % Move to the next column if this one is filled
        if (bit_index == PROCESSOR_WIDTH-1)
          bit_index = 0;
          column_index = column_index + 1;
        end
      end
    end
  end

end