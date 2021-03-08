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
% Template:    axis_file_write.m
% Backend:     {{ fins['backend'] }}
% ---------------------------------------------------------
% Description: MATLAB/Octave function that writes a text file with AXI-Stream
%              transactions in hex characters, one transaction per line. The
%              last is written with a single hex character first, followed by
%              a space, followed by the data, followed by another space, and
%              then followed by the metadata (if applicable). If the data is
%              complex, it is written to file with the imag component first (in
%              the MSBs). The data/metadata definitions are sourced from a
%              FINS Port, and the text file is read by the axis_verify.vhd
%              module as a testbench "source".
%              Example: "0 1F455AB2 A1" where "0" is the last, "1F45" is imag,
%                       and "5AB2" is real, and "A1" is the metadata
% Inputs:      port_name - string
%                  The name of the port as defined in the FINS Node JSON
%              filepath - string
%                  The filepath of the text file
%              packets - cell[], int[], or complex[]
%                  The packets to write to the text file. All formats assume
%                  that the channels are interleaved.
%                  When cell[] type, each cell of packets is assumed to be a
%                  struct with fields:
%                      .data - int[] or complex[]
%                          The data for each packet
%                      .metadata - struct
%                          A structure containing named metadata fields that
%                          match the port definition in the FINS Node JSON
%                  When int[] or complex[] type, packets are assumed to be
%                  the data for the entire file. Packet boundaries marked
%                  with the last flag are determined by the packet_size input,
%                  which is required when packets is int[] or complex[].
%              packet_size (optional) - int
%                  The packet size if the packets input was provided as a
%                  numeric array.
% Usage:       [] = {{ fins['name']|lower }}_axis_file_write(
%                  port_name, filepath, packets
%              )
%              [] = {{ fins['name']|lower }}_axis_file_write(
%                  port_name, filepath, packets, packet_size
%              )
% Notes:       This code was written in such a way that the metadata field
%              could exist by itself. This is currently not allowed with FINS,
%              so there is validation in this function to require that the
%              data field exists. However, if this validation is removed, the
%              rest of the code permits metadata to exist without data.
% TODO:        This function currently does not support metadata.
%==============================================================================

function [ ] = {{ fins['name']|lower }}_axis_file_write( port_name, filepath, packets, packet_size )

  %----------------------------------------------------------------------------
  % Input Port Definitions
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
  % Variable Argument Validation
  if ((nargin == 3) && (isnumeric(packets)))
    error('You must provide the packet_size argument when setting packets to a numeric array');
  elseif ((nargin == 4) && (iscell(packets)))
    error('You may not provide a packet_size argument when setting packets to a cell array');
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

  % Calculate sizes of samples and packets
  if (iscell(packets))
    % Get the number of packets
    NUM_PACKETS = length(packets);
    % If there is data or data+metadata
    if (PORT_HAS_DATA)
      % Accumulate the total number of samples
      NUM_TOTAL_SAMPLES = 0;
      for packet_index=1:NUM_PACKETS
        NUM_TOTAL_SAMPLES = NUM_TOTAL_SAMPLES + length(packets{packet_index}.data);
      end
      NUM_SAMPLES_PER_TRANSACTION = PORT_DEFINITION.data.num_channels * PORT_DEFINITION.data.num_samples;
      NUM_TRANSACTIONS = NUM_TOTAL_SAMPLES / NUM_SAMPLES_PER_TRANSACTION;
    else
      % If there is ONLY a metadata field, assume a single sample per packet
      NUM_TOTAL_SAMPLES = NUM_PACKETS;
      NUM_SAMPLES_PER_TRANSACTION = 1;
      NUM_TRANSACTIONS = NUM_PACKETS;
    end
    % Count the number of metadata bits
    NUM_TOTAL_METADATA_BITS = 0;
    if (PORT_HAS_METADATA)
      for field_index=1:NUM_METADATA_FIELDNAMES
        NUM_TOTAL_METADATA_BITS = NUM_TOTAL_METADATA_BITS + PORT_DEFINITION.metadata.(METADATA_FIELDNAMES{field_index}).bit_width;
      end
    end
  elseif (isnumeric(packets))
    % This is data ONLY
    NUM_TOTAL_SAMPLES = length(packets);
    NUM_PACKETS = NUM_TOTAL_SAMPLES / packet_size;
    NUM_SAMPLES_PER_TRANSACTION = PORT_DEFINITION.data.num_channels * PORT_DEFINITION.data.num_samples;
    NUM_TRANSACTIONS = NUM_TOTAL_SAMPLES / NUM_SAMPLES_PER_TRANSACTION;
  end

  %----------------------------------------------------------------------------
  % TODO: Remove this when Metadata is implemented
  %----------------------------------------------------------------------------
  if (PORT_HAS_METADATA)
    error('This function currently does not support metadata');
  end

  %----------------------------------------------------------------------------
  % Type Validation
  %----------------------------------------------------------------------------
  % Handle different data types for the `packets` argument
  if (iscell(packets))
    %**********************************
    % Cell Array
    %**********************************
    % Validate that there are packets to write
    if (NUM_PACKETS == 0)
      error('No packets were provided to write to file');
    end

    % Validate each packet
    for packet_index=1:NUM_PACKETS
      % Validate that the data field is present if required and vice versa
      packet_has_data = isfield(packets{packet_index}, 'data');
      if (~packet_has_data)
        error(['The required .data field was not defined in packet number ',num2str(packet_index)]);
      end

      % Data field validation
      if (PORT_HAS_DATA)
        % Validate that the data length is a multiple of the number of channels/samples
        num_transactions_for_packet = length(packets{packet_index}.data) / PORT_DEFINITION.data.num_channels / PORT_DEFINITION.data.num_samples;
        if (rem(num_transactions_for_packet, 1) > 0)
          message = sprintf('The data length %d for packet number %d is not a multiple of num_channels (%d) and num_samples (%d)', length(packets{packet_index}.data), packet_index, PORT_DEFINITION.data.num_channels, PORT_DEFINITION.data.num_samples);
          error(message);
        end
      end

      % Validate that the metadata field is present if required and vice versa
      packet_has_metadata = isfield(packets{packet_index}, 'metadata');
      if (PORT_HAS_METADATA && (~packet_has_metadata))
        error(['The required .metadata field was not defined in packet number ',num2str(packet_index)]);
      elseif ((~PORT_HAS_METADATA) && packet_has_metadata)
        disp(['WARNING: The .metadata field was defined in packet number ',num2str(packet_index),' but will NOT be used']);
      end

      % Metadata field validation
      if (PORT_HAS_METADATA)
        % Validate that all required metadata fields are present
        packet_metadata_field_names = fieldnames(packets{packet_index}.metadata);
        if (~isequal(sort(METADATA_FIELDNAMES), sort(packet_metadata_field_names)))
          error(['The metadata fields of packet number ',num2str(packet_index),' do not match the required fields']);
        end
      end
    end
  elseif (isnumeric(packets))
    %**********************************
    % Numeric Array
    %**********************************
    % Validate that a numeric array is valid for this port
    if (PORT_HAS_METADATA)
      error('You may not use a numeric array for the packets argument because the port definition has metadata');
    end

    % Validate that there is data to write
    if (NUM_TOTAL_SAMPLES == 0)
      error('No samples were provided in the packets argument to write to file');
    end

    % Validate that the data length is a multiple of the packet_size
    if (rem(NUM_PACKETS, 1) > 0)
      error('The data length is not a multiple of the packet_size');
    end

    % Validate that packet size is a multiple of the number of channels and the number of samples
    num_transactions_per_packet = NUM_TOTAL_SAMPLES / NUM_PACKETS / PORT_DEFINITION.data.num_channels / PORT_DEFINITION.data.num_samples;
    if (rem(num_transactions_per_packet, 1) > 0)
      error('The calculated packet size is not a multiple of the num_channels and num_samples');
    end
  else
    % Error
    error('Unsupported data type provided for the packets argument');
  end

  %----------------------------------------------------------------------------
  % Data/Last Assembly
  %----------------------------------------------------------------------------
  % Initialize the vectors to write to file
  packets_data = zeros(NUM_TOTAL_SAMPLES, 1);
  packets_last = zeros(NUM_TOTAL_SAMPLES, 1);

  % Populate the vectors to write to file
  if (iscell(packets))
    %**********************************
    % Cell Array
    %**********************************
    % Set the default packet size to 1 when data is not present in port definition
    current_packet_size = 1;
    % Loop through packets, tracking samples
    sample_index = 1;
    for packet_index=1:NUM_PACKETS
      % Populate data
      if (PORT_HAS_DATA)
        current_packet_size = length(packets{packet_index}.data);
        packets_data(sample_index:sample_index+current_packet_size-1) = packets{packet_index}.data;
      end
      % Populate last
      packets_last(sample_index+current_packet_size-1) = 1;
      % Update loop variable
      sample_index = sample_index + current_packet_size;
    end
  elseif (isnumeric(packets))
    %**********************************
    % Numeric Array
    %**********************************
    % Populate data
    packets_data = packets;
    % Populate last
    packets_last(packet_size:packet_size:end) = 1;
  end

  %----------------------------------------------------------------------------
  % Data/Metadata Validation
  %----------------------------------------------------------------------------
  % Data Validation
  if (PORT_HAS_DATA)
    packets_data = validate_fixed_point_data(...
      packets_data,...
      PORT_DEFINITION.data.bit_width,...
      PORT_DEFINITION.data.is_complex,...
      PORT_DEFINITION.data.is_signed...
    );
  end

  % Metadata Validation
  if (PORT_HAS_METADATA)
    % Loop through the packets and through the fields and validate
    for packet_index=1:NUM_PACKETS
      for field_index=1:NUM_METADATA_FIELDNAMES
        packets{packet_index}.metadata.(METADATA_FIELDNAMES{field_index}) = validate_fixed_point_data(...
          packets{packet_index}.metadata.(METADATA_FIELDNAMES{field_index}),...
          PORT_DEFINITION.metadata.(METADATA_FIELDNAMES{field_index}).bit_width,...
          PORT_DEFINITION.metadata.(METADATA_FIELDNAMES{field_index}).is_complex,...
          PORT_DEFINITION.metadata.(METADATA_FIELDNAMES{field_index}).is_signed...
        );
      end
    end
  end

  %----------------------------------------------------------------------------
  % Convert to hex
  %----------------------------------------------------------------------------
  % Convert data to hex
  if (PORT_HAS_DATA)
    % Cast into unsigned words that represent the bits of samples
    packets_data_unsigned = cast_to_unsigned(packets_data, PORT_DEFINITION.data.bit_width);
    % Initialize the unsigned words that represent the data bits of AXI-Stream transactions
    % NOTE: Columns represent chunks in order to not exceed processor (or MATLAB/Octave) capabilities
    %       Initialize to zero for accumulation below
    num_columns = ceil(NUM_SAMPLES_PER_TRANSACTION*PORT_DEFINITION.data.bit_width/PROCESSOR_WIDTH);
    transactions_data_unsigned = zeros(NUM_TRANSACTIONS, num_columns);
    % Populate the transactions data
    % NOTE: Zero-based index used here
    for t=0:NUM_TRANSACTIONS-1
      if (PORT_DEFINITION.data.is_complex)
        % Pack complex data into columns of PROCESSOR_WIDTH
        current_complex_samples = zeros(1, NUM_SAMPLES_PER_TRANSACTION*2);
        current_complex_samples(1:2:end) = real(packets_data_unsigned(t*NUM_SAMPLES_PER_TRANSACTION+1:(t+1)*NUM_SAMPLES_PER_TRANSACTION));
        current_complex_samples(2:2:end) = imag(packets_data_unsigned(t*NUM_SAMPLES_PER_TRANSACTION+1:(t+1)*NUM_SAMPLES_PER_TRANSACTION));
        transactions_data_unsigned(t+1, :) = pack_unsigned_into_columns(current_complex_samples, PORT_DEFINITION.data.bit_width/2);
      else
        % Pack data into columns of PROCESSOR_WIDTH
        transactions_data_unsigned(t+1, :) = pack_unsigned_into_columns(packets_data_unsigned(t*NUM_SAMPLES_PER_TRANSACTION+1:(t+1)*NUM_SAMPLES_PER_TRANSACTION), PORT_DEFINITION.data.bit_width);
      end
    end
    % Initialize a character array
    num_hex_chars = ceil(NUM_SAMPLES_PER_TRANSACTION*PORT_DEFINITION.data.bit_width/4);
    transactions_data_hex = repmat(char(0), NUM_TRANSACTIONS, num_hex_chars);
    % Convert columns to hex
    for column_index=1:num_columns
      % Convert the unsigned representation of the data into a hex matrix with dimensions (samples)(NUM_PROCESSOR_HEX_CHARS) using built-in function
      hex_column = dec2hex(transactions_data_unsigned(:, column_index), NUM_PROCESSOR_HEX_CHARS);
      if (column_index == num_columns)
        num_remaining_hex_chars = mod(num_hex_chars, NUM_PROCESSOR_HEX_CHARS);
        if (num_remaining_hex_chars == 0)
          % The num_hex_chars is a multiple of NUM_PROCESSOR_HEX_CHARS, so assign the entire first block
          transactions_data_hex(:, 1:NUM_PROCESSOR_HEX_CHARS) = hex_column;
        else
          % Assign the num_remaining_hex_chars from the end (LSBs) of the hex_column
          transactions_data_hex(:, 1:num_remaining_hex_chars) = hex_column(:, end-num_remaining_hex_chars+1:end);
        end
      else
        % Assign hex characters from the end since LSBs appear at the end (on the right)
        transactions_data_hex(:, end-column_index*NUM_PROCESSOR_HEX_CHARS+1:end-(column_index-1)*NUM_PROCESSOR_HEX_CHARS) = hex_column;
      end
    end
  end

  % Aggregate last flags (don't convert to hex)
  % NOTE: Using zero-based index
  transactions_last = zeros(NUM_TRANSACTIONS, 1);
  for t=0:NUM_TRANSACTIONS-1
    % Effectively a reduction OR
    transactions_last(t+1) = any(packets_last(t*NUM_SAMPLES_PER_TRANSACTION+1:(t+1)*NUM_SAMPLES_PER_TRANSACTION));
  end

  % Convert metadata to hex
  if (PORT_HAS_METADATA)
    % Get the indices of the transactions last flags
    transactions_last_indices = find(transactions_last);
    % Initialize the unsigned words that represent the metadata bits of AXI-Stream transactions
    transactions_metadata_unsigned = zeros(NUM_TRANSACTIONS, 1);
    % Loop through the packets, convert metadata to unsigned word, and then assign to transaction indices
    for packet_index=1:NUM_PACKETS
      % Initialize the accumulator for this packet
      packet_metadata_unsigned = 0;
      % Scale and accumulate the fields that compose the metadata
      scaling_index = 0;
      for field_index=1:NUM_METADATA_FIELDNAMES
        packet_metadata_unsigned = packet_metadata_unsigned + 2^scaling_index * cast_to_unsigned(packets{packet_index}.metadata.(METADATA_FIELDNAMES{field_index}), PORT_DEFINITION.metadata.(METADATA_FIELDNAMES{field_index}).bit_width);
        scaling_index = scaling_index + PORT_DEFINITION.metadata.(METADATA_FIELDNAMES{field_index}).bit_width;
      end
      % Assign the transaction indices to the converted metadata for this packet
      if (packet_index == 1)
        transaction_indices = 1:transactions_last_indices(packet_index);
      else
        transaction_indices = transactions_last_indices(packet_index-1)+1:transactions_last_indices(packet_index);
      end
      transactions_metadata_unsigned(transaction_indices) = packet_metadata_unsigned;
    end
    % Convert to hex
    transactions_metadata_hex = dec2hex(transactions_metadata_unsigned, ceil(NUM_TOTAL_METADATA_BITS/4));
  end

  %----------------------------------------------------------------------------
  % Write to file
  %----------------------------------------------------------------------------
  % Open file
  fid = fopen(filepath, 'w');

  % Write hexadecimal data to file
  if (PORT_HAS_DATA && PORT_HAS_METADATA)
    for t=1:NUM_TRANSACTIONS
      fprintf(fid, '%1x %s %s\n', transactions_last(t), transactions_data_hex(t, :), transactions_metadata_hex(t, :));
    end
  elseif (PORT_HAS_DATA)
    for t=1:NUM_TRANSACTIONS
      fprintf(fid, '%1x %s\n', transactions_last(t), transactions_data_hex(t, :));
    end
  elseif (PORT_HAS_METADATA)
    for t=1:NUM_TRANSACTIONS
      fprintf(fid, '%1x %s\n', transactions_last(t), transactions_metadata_hex(t, :));
    end
  end

  % Close file
  fclose(fid);

  %----------------------------------------------------------------------------
  % Nested Function
  %----------------------------------------------------------------------------
  function [ y ] = cast_to_unsigned( x, N_BITS )
    % Force column vector
    y = x(:);

    % Typecast to unsigned using 2's complement conversion
    if (iscomplex(y))
      real_y = real(y);
      imag_y = imag(y);
      if (exist ('OCTAVE_VERSION', 'builtin') > 0)
        % Efficient Octave Function
        real_y(real_y < 0) = bitcmp(abs(real_y(real_y < 0)), N_BITS/2) + 1;
        imag_y(imag_y < 0) = bitcmp(abs(imag_y(imag_y < 0)), N_BITS/2) + 1;
      else
        % Inefficient MATLAB function
        real_y = matlab_twos_complement(real_y, N_BITS/2);
        imag_y = matlab_twos_complement(imag_y, N_BITS/2);
      end
      y = complex(real_y, imag_y);
    else
      if (exist ('OCTAVE_VERSION', 'builtin') > 0)
        % Efficient Octave Function
        y(y < 0) = bitcmp(abs(y(y < 0)), N_BITS) + 1;
      else
        % Inefficient MATLAB function
        y = matlab_twos_complement(y, N_BITS);
      end
    end
  end

  %----------------------------------------------------------------------------
  % Nested Function
  %----------------------------------------------------------------------------
  function [ y ] = pack_unsigned_into_columns( x, bit_width )
    % Calculate the number of samples
    num_samples = length(x);

    % Initialize the output columns
    y = zeros(1, ceil(num_samples*bit_width/PROCESSOR_WIDTH));

    % Initialize the bit index
    % NOTE: Zero-based index used here
    bit_index = 0;

    % Initialize the column index
    % NOTE: One-based index used here
    column_index = 1;

    % Process all samples
    for sample_index=1:num_samples
      % Calculate how many bits we can pack in the current column
      num_bits_remaining_in_current_column = PROCESSOR_WIDTH - bit_index;

      % If there are more bits in this sample than can be held in the current number of bits
      if (bit_width > num_bits_remaining_in_current_column)
        % Mask off the lower bits for the current column
        current_sample_lsbs = mod(x(sample_index), 2^num_bits_remaining_in_current_column);
        % Accumulate the data in the current column
        y(column_index) = y(column_index) + current_sample_lsbs * 2^bit_index;
        % Move to the next column
        column_index = column_index + 1;
        % Mask off the upper bits for the next column
        current_sample_msbs = floor(x(sample_index) / 2^num_bits_remaining_in_current_column);
        % Accumulate the data in the next column
        y(column_index) = y(column_index) + current_sample_msbs;
        % Update bit index
        bit_index = bit_width - num_bits_remaining_in_current_column;
        % Move to the next next column if this one is filled
        if (bit_index == PROCESSOR_WIDTH-1)
          bit_index = 0;
          column_index = column_index + 1;
        end
      else
        % Accumulate the data in the current column
        y(column_index) = y(column_index) + x(sample_index) * 2^bit_index;
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

  %----------------------------------------------------------------------------
  % Nested Function
  %----------------------------------------------------------------------------
  function [ y ] = matlab_twos_complement( x, N_BITS )
    % Force column vector
    x = x(:);
    % Convert to bit string
    x_twoscomp_bin = dec2bin(abs(x), N_BITS);
    % Flip bits
    for n=1:num_rows
      for k=1:N_BITS
        if (x_twoscomp_bin(n, k) == '1')
          x_twoscomp_bin(n, k) = '0';
        else
          x_twoscomp_bin(n, k) = '1';
        end
      end
    end
    % Convert back to decimal and add one
    x_twoscomp = bin2dec(x_twoscomp_bin) + 1;
    x(x < 0) = x_twoscomp(x < 0);
    y = x;
  end

  %----------------------------------------------------------------------------
  % Nested Function
  %----------------------------------------------------------------------------
  function [y] = validate_fixed_point_data(x, bit_width, is_complex, is_signed)
    % Validate that the data is complex if required
    if (iscomplex(x) && ~is_complex)
      disp('WARNING: The data is complex when it should be real-only, dropping the imaginary component');
      x = real(x);
    elseif (~iscomplex(x) && is_complex)
      disp('WARNING: The data is real-only when it should be complex, adding a zero imaginary component');
      x = complex(x, 0);
    end

    % Validate the data values
    if (is_complex)
      % Check that the bit width is even for the complex conversion
      if (mod(bit_width, 2) > 0)
        error(['The complex data cannot be converted to hex because the bit width (',num2str(bit_width),') is odd.']);
      end

      % Check that the data fits in the bit width
      if (is_signed)
        required_max_value = 2^(bit_width/2 - 1) - 1;
        required_min_value = -2^(bit_width/2 - 1);
      else
        required_max_value = 2^(bit_width/2) - 1;
        required_min_value = 0;
      end
      if (max(max(real(x)), max(imag(x))) > required_max_value)
        error('The complex data is greater than the maximum possible value allowed by the port definition');
      end
      if (min(min(real(x)), min(imag(x))) < required_min_value)
        error('The complex data is less than the minimum possible value allowed by the port definition');
      end

      % Round data if not integers
      if (any((rem(real(x), 1) > 0)) || any((rem(imag(x), 1) > 0)))
        y = complex(round(real(x)), round(imag(x)));
        disp('WARNING: Rounded the complex data');
      else
        y = x;
      end
    else
      % Check that the data fits in the bit width
      if (is_signed)
        required_max_value = 2^(bit_width - 1) - 1;
        required_min_value = -2^(bit_width - 1);
      else
        required_max_value = 2^(bit_width) - 1;
        required_min_value = 0;
      end
      if (max(x) > required_max_value)
        error('The data is greater than the maximum possible value allowed by the port definition');
      end
      if (min(x) < required_min_value)
        error('The data is less than the minimum possible value allowed by the port definition');
      end

      % Round data if not integers
      if (any(rem(x, 1) > 0))
        y = round(x);
        disp('WARNING: The data contains fractional parts, rounding the data');
      else
        y = x;
      end
    end
  end

end