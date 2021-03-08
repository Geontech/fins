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

% Add path to function under test
addpath('gen/core');

% Parameters
TEST_PACKET_SIZES = [1, 128, 113]; % Smallest case, even power of two, odd prime
TEST_NUM_PACKETS = [1, 4, 7]; % Smallest case, even power of two, odd prime

% Loop through the packets sizes we want to test
for packet_size_index=1:length(TEST_PACKET_SIZES)
  % Get the packet size
  packet_size = TEST_PACKET_SIZES(packet_size_index);

  % Loop through the number of packets we want to test
  for num_packets_index=1:length(TEST_NUM_PACKETS)
    % Get the number of packets
    num_packets = TEST_NUM_PACKETS(num_packets_index);

    %--------------------------------------------------------------------------
    % Data-only Cases
    %--------------------------------------------------------------------------
    %
    % Create the data for the test case and then run the test case
    %   1. Use linspace to utilize the full dynamic range per packet
    %   2. Convert to column vector
    %   3. Repeat for number of packets
    %   4. For complex, use the same sequence but reversed for imaginary component
    %   5. Run test
    %   6. Convert to cell array
    %   7. Run again
    %
    % Not tested:
    %   * Cell array input with packets of different sizes
    %   * The de-multiplexing order of num_channels vs. num_samples
    %

    %**********************************
    % 1 channel, 1 sample
    %**********************************
    packets = repmat(round(linspace(0, 2^11-1, packet_size).'), num_packets, 1);
    single_test_case('data_unsigned_real_11bit_1ch_1samp', packets, packet_size, num_packets);
    packets = convert_numeric_to_cell(packets, packet_size, num_packets);
    single_test_case('data_unsigned_real_11bit_1ch_1samp', packets, packet_size, num_packets);

    packets = repmat(round(linspace(0, 2^12-1, packet_size).'), num_packets, 1);
    single_test_case('data_unsigned_real_12bit_1ch_1samp', packets, packet_size, num_packets);
    packets = convert_numeric_to_cell(packets, packet_size, num_packets);
    single_test_case('data_unsigned_real_12bit_1ch_1samp', packets, packet_size, num_packets);

    packets = repmat(round(linspace(-2^10, 2^10-1, packet_size).'), num_packets, 1);
    single_test_case('data_signed_real_11bit_1ch_1samp', packets, packet_size, num_packets);
    packets = convert_numeric_to_cell(packets, packet_size, num_packets);
    single_test_case('data_signed_real_11bit_1ch_1samp', packets, packet_size, num_packets);

    packets = repmat(round(linspace(-2^11, 2^11-1, packet_size).'), num_packets, 1);
    single_test_case('data_signed_real_12bit_1ch_1samp', packets, packet_size, num_packets);
    packets = convert_numeric_to_cell(packets, packet_size, num_packets);
    single_test_case('data_signed_real_12bit_1ch_1samp', packets, packet_size, num_packets);

    packets = repmat(complex(round(linspace(0, 2^11-1, packet_size).'), round(linspace(2^11-1, 0, packet_size).')), num_packets, 1);
    single_test_case('data_unsigned_complex_22bit_1ch_1samp', packets, packet_size, num_packets);
    packets = convert_numeric_to_cell(packets, packet_size, num_packets);
    single_test_case('data_unsigned_complex_22bit_1ch_1samp', packets, packet_size, num_packets);

    packets = repmat(complex(round(linspace(0, 2^12-1, packet_size).'), round(linspace(2^12-1, 0, packet_size).')), num_packets, 1);
    single_test_case('data_unsigned_complex_24bit_1ch_1samp', packets, packet_size, num_packets);
    packets = convert_numeric_to_cell(packets, packet_size, num_packets);
    single_test_case('data_unsigned_complex_24bit_1ch_1samp', packets, packet_size, num_packets);

    packets = repmat(complex(round(linspace(-2^10, 2^10-1, packet_size).'), round(linspace(2^10-1, -2^10, packet_size).')), num_packets, 1);
    single_test_case('data_signed_complex_22bit_1ch_1samp', packets, packet_size, num_packets);
    packets = convert_numeric_to_cell(packets, packet_size, num_packets);
    single_test_case('data_signed_complex_22bit_1ch_1samp', packets, packet_size, num_packets);

    packets = repmat(complex(round(linspace(-2^11, 2^11-1, packet_size).'), round(linspace(2^11-1, -2^11, packet_size).')), num_packets, 1);
    single_test_case('data_signed_complex_24bit_1ch_1samp', packets, packet_size, num_packets);
    packets = convert_numeric_to_cell(packets, packet_size, num_packets);
    single_test_case('data_signed_complex_24bit_1ch_1samp', packets, packet_size, num_packets);

    %**********************************
    % 3 channel, 1 sample
    %**********************************
    packets = repmat(round(linspace(0, 2^11-1, packet_size*3).'), num_packets, 1);
    single_test_case('data_unsigned_real_11bit_3ch_1samp', packets, packet_size*3, num_packets);
    packets = convert_numeric_to_cell(packets, packet_size*3, num_packets);
    single_test_case('data_unsigned_real_11bit_3ch_1samp', packets, packet_size*3, num_packets);

    packets = repmat(round(linspace(0, 2^12-1, packet_size*3).'), num_packets, 1);
    single_test_case('data_unsigned_real_12bit_3ch_1samp', packets, packet_size*3, num_packets);
    packets = convert_numeric_to_cell(packets, packet_size*3, num_packets);
    single_test_case('data_unsigned_real_12bit_3ch_1samp', packets, packet_size*3, num_packets);

    packets = repmat(round(linspace(-2^10, 2^10-1, packet_size*3).'), num_packets, 1);
    single_test_case('data_signed_real_11bit_3ch_1samp', packets, packet_size*3, num_packets);
    packets = convert_numeric_to_cell(packets, packet_size*3, num_packets);
    single_test_case('data_signed_real_11bit_3ch_1samp', packets, packet_size*3, num_packets);

    packets = repmat(round(linspace(-2^11, 2^11-1, packet_size*3).'), num_packets, 1);
    single_test_case('data_signed_real_12bit_3ch_1samp', packets, packet_size*3, num_packets);
    packets = convert_numeric_to_cell(packets, packet_size*3, num_packets);
    single_test_case('data_signed_real_12bit_3ch_1samp', packets, packet_size*3, num_packets);

    packets = repmat(complex(round(linspace(0, 2^11-1, packet_size*3).'), round(linspace(2^11-1, 0, packet_size*3).')), num_packets, 1);
    single_test_case('data_unsigned_complex_22bit_3ch_1samp', packets, packet_size*3, num_packets);
    packets = convert_numeric_to_cell(packets, packet_size*3, num_packets);
    single_test_case('data_unsigned_complex_22bit_3ch_1samp', packets, packet_size*3, num_packets);

    packets = repmat(complex(round(linspace(0, 2^12-1, packet_size*3).'), round(linspace(2^12-1, 0, packet_size*3).')), num_packets, 1);
    single_test_case('data_unsigned_complex_24bit_3ch_1samp', packets, packet_size*3, num_packets);
    packets = convert_numeric_to_cell(packets, packet_size*3, num_packets);
    single_test_case('data_unsigned_complex_24bit_3ch_1samp', packets, packet_size*3, num_packets);

    packets = repmat(complex(round(linspace(-2^10, 2^10-1, packet_size*3).'), round(linspace(2^10-1, -2^10, packet_size*3).')), num_packets, 1);
    single_test_case('data_signed_complex_22bit_3ch_1samp', packets, packet_size*3, num_packets);
    packets = convert_numeric_to_cell(packets, packet_size*3, num_packets);
    single_test_case('data_signed_complex_22bit_3ch_1samp', packets, packet_size*3, num_packets);

    packets = repmat(complex(round(linspace(-2^11, 2^11-1, packet_size*3).'), round(linspace(2^11-1, -2^11, packet_size*3).')), num_packets, 1);
    single_test_case('data_signed_complex_24bit_3ch_1samp', packets, packet_size*3, num_packets);
    packets = convert_numeric_to_cell(packets, packet_size*3, num_packets);
    single_test_case('data_signed_complex_24bit_3ch_1samp', packets, packet_size*3, num_packets);

    %**********************************
    % 1 channel, 2 sample
    %**********************************
    packets = repmat(round(linspace(0, 2^11-1, packet_size*2).'), num_packets, 1);
    single_test_case('data_unsigned_real_11bit_1ch_2samp', packets, packet_size*2, num_packets);
    packets = convert_numeric_to_cell(packets, packet_size*2, num_packets);
    single_test_case('data_unsigned_real_11bit_1ch_2samp', packets, packet_size*2, num_packets);

    packets = repmat(round(linspace(0, 2^12-1, packet_size*2).'), num_packets, 1);
    single_test_case('data_unsigned_real_12bit_1ch_2samp', packets, packet_size*2, num_packets);
    packets = convert_numeric_to_cell(packets, packet_size*2, num_packets);
    single_test_case('data_unsigned_real_12bit_1ch_2samp', packets, packet_size*2, num_packets);

    packets = repmat(round(linspace(-2^10, 2^10-1, packet_size*2).'), num_packets, 1);
    single_test_case('data_signed_real_11bit_1ch_2samp', packets, packet_size*2, num_packets);
    packets = convert_numeric_to_cell(packets, packet_size*2, num_packets);
    single_test_case('data_signed_real_11bit_1ch_2samp', packets, packet_size*2, num_packets);

    packets = repmat(round(linspace(-2^11, 2^11-1, packet_size*2).'), num_packets, 1);
    single_test_case('data_signed_real_12bit_1ch_2samp', packets, packet_size*2, num_packets);
    packets = convert_numeric_to_cell(packets, packet_size*2, num_packets);
    single_test_case('data_signed_real_12bit_1ch_2samp', packets, packet_size*2, num_packets);

    packets = repmat(complex(round(linspace(0, 2^11-1, packet_size*2).'), round(linspace(2^11-1, 0, packet_size*2).')), num_packets, 1);
    single_test_case('data_unsigned_complex_22bit_1ch_2samp', packets, packet_size*2, num_packets);
    packets = convert_numeric_to_cell(packets, packet_size*2, num_packets);
    single_test_case('data_unsigned_complex_22bit_1ch_2samp', packets, packet_size*2, num_packets);

    packets = repmat(complex(round(linspace(0, 2^12-1, packet_size*2).'), round(linspace(2^12-1, 0, packet_size*2).')), num_packets, 1);
    single_test_case('data_unsigned_complex_24bit_1ch_2samp', packets, packet_size*2, num_packets);
    packets = convert_numeric_to_cell(packets, packet_size*2, num_packets);
    single_test_case('data_unsigned_complex_24bit_1ch_2samp', packets, packet_size*2, num_packets);

    packets = repmat(complex(round(linspace(-2^10, 2^10-1, packet_size*2).'), round(linspace(2^10-1, -2^10, packet_size*2).')), num_packets, 1);
    single_test_case('data_signed_complex_22bit_1ch_2samp', packets, packet_size*2, num_packets);
    packets = convert_numeric_to_cell(packets, packet_size*2, num_packets);
    single_test_case('data_signed_complex_22bit_1ch_2samp', packets, packet_size*2, num_packets);

    packets = repmat(complex(round(linspace(-2^11, 2^11-1, packet_size*2).'), round(linspace(2^11-1, -2^11, packet_size*2).')), num_packets, 1);
    single_test_case('data_signed_complex_24bit_1ch_2samp', packets, packet_size*2, num_packets);
    packets = convert_numeric_to_cell(packets, packet_size*2, num_packets);
    single_test_case('data_signed_complex_24bit_1ch_2samp', packets, packet_size*2, num_packets);

    %**********************************
    % 2 channel, 3 sample
    %**********************************
    packets = repmat(round(linspace(0, 2^11-1, packet_size*2*3).'), num_packets, 1);
    single_test_case('data_unsigned_real_11bit_2ch_3samp', packets, packet_size*2*3, num_packets);
    packets = convert_numeric_to_cell(packets, packet_size*2*3, num_packets);
    single_test_case('data_unsigned_real_11bit_2ch_3samp', packets, packet_size*2*3, num_packets);

    packets = repmat(round(linspace(0, 2^12-1, packet_size*2*3).'), num_packets, 1);
    single_test_case('data_unsigned_real_12bit_2ch_3samp', packets, packet_size*2*3, num_packets);
    packets = convert_numeric_to_cell(packets, packet_size*2*3, num_packets);
    single_test_case('data_unsigned_real_12bit_2ch_3samp', packets, packet_size*2*3, num_packets);

    packets = repmat(round(linspace(-2^10, 2^10-1, packet_size*2*3).'), num_packets, 1);
    single_test_case('data_signed_real_11bit_2ch_3samp', packets, packet_size*2*3, num_packets);
    packets = convert_numeric_to_cell(packets, packet_size*2*3, num_packets);
    single_test_case('data_signed_real_11bit_2ch_3samp', packets, packet_size*2*3, num_packets);

    packets = repmat(round(linspace(-2^11, 2^11-1, packet_size*2*3).'), num_packets, 1);
    single_test_case('data_signed_real_12bit_2ch_3samp', packets, packet_size*2*3, num_packets);
    packets = convert_numeric_to_cell(packets, packet_size*2*3, num_packets);
    single_test_case('data_signed_real_12bit_2ch_3samp', packets, packet_size*2*3, num_packets);

    packets = repmat(complex(round(linspace(0, 2^11-1, packet_size*2*3).'), round(linspace(2^11-1, 0, packet_size*2*3).')), num_packets, 1);
    single_test_case('data_unsigned_complex_22bit_2ch_3samp', packets, packet_size*2*3, num_packets);
    packets = convert_numeric_to_cell(packets, packet_size*2*3, num_packets);
    single_test_case('data_unsigned_complex_22bit_2ch_3samp', packets, packet_size*2*3, num_packets);

    packets = repmat(complex(round(linspace(0, 2^12-1, packet_size*2*3).'), round(linspace(2^12-1, 0, packet_size*2*3).')), num_packets, 1);
    single_test_case('data_unsigned_complex_24bit_2ch_3samp', packets, packet_size*2*3, num_packets);
    packets = convert_numeric_to_cell(packets, packet_size*2*3, num_packets);
    single_test_case('data_unsigned_complex_24bit_2ch_3samp', packets, packet_size*2*3, num_packets);

    packets = repmat(complex(round(linspace(-2^10, 2^10-1, packet_size*2*3).'), round(linspace(2^10-1, -2^10, packet_size*2*3).')), num_packets, 1);
    single_test_case('data_signed_complex_22bit_2ch_3samp', packets, packet_size*2*3, num_packets);
    packets = convert_numeric_to_cell(packets, packet_size*2*3, num_packets);
    single_test_case('data_signed_complex_22bit_2ch_3samp', packets, packet_size*2*3, num_packets);

    packets = repmat(complex(round(linspace(-2^11, 2^11-1, packet_size*2*3).'), round(linspace(2^11-1, -2^11, packet_size*2*3).')), num_packets, 1);
    single_test_case('data_signed_complex_24bit_2ch_3samp', packets, packet_size*2*3, num_packets);
    packets = convert_numeric_to_cell(packets, packet_size*2*3, num_packets);
    single_test_case('data_signed_complex_24bit_2ch_3samp', packets, packet_size*2*3, num_packets);

    %--------------------------------------------------------------------------
    % Metadata Cases
    %--------------------------------------------------------------------------
    %
    % Create the data and metadata for the test case and then run the test case
    %   1. Create metadata fields with linspace and dimensions (packets, field)
    %   2. Create data using same data as "data_signed_complex_24bit_2ch_3samp" port
    %   3. Convert to cell array
    %   4. Insert metadata into packets
    %   5. Run test case
    %

    % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    % TODO: Implement Metadata
    % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    if false
      %**********************************
      % Unsigned Real
      %**********************************
      metadata_matrix = linspace(0, 2^11-1, num_packets).';
      packets = create_metadata_packet(packet_size, num_packets, metadata_matrix);
      single_test_case('metadata_1field_unsigned_real', packets, packet_size*2*3, num_packets);

      metadata_matrix = [linspace(0, 2^11-1, num_packets).', linspace(0, 2^12-1, num_packets).'];
      packets = create_metadata_packet(packet_size, num_packets, metadata_matrix);
      single_test_case('metadata_2field_unsigned_real', packets, packet_size*2*3, num_packets);

      metadata_matrix = [linspace(0, 2^11-1, num_packets).', linspace(0, 2^12-1, num_packets).', linspace(0, 2^13-1, num_packets).'];
      packets = create_metadata_packet(packet_size, num_packets, metadata_matrix);
      single_test_case('metadata_3field_unsigned_real', packets, packet_size*2*3, num_packets);

      %**********************************
      % Signed Real
      %**********************************
      metadata_matrix = linspace(-2^10, 2^10-1, num_packets).';
      packets = create_metadata_packet(packet_size, num_packets, metadata_matrix);
      single_test_case('metadata_1field_signed_real', packets, packet_size*2*3, num_packets);

      metadata_matrix = [linspace(-2^10, 2^10-1, num_packets).', linspace(-2^11, 2^11-1, num_packets).'];
      packets = create_metadata_packet(packet_size, num_packets, metadata_matrix);
      single_test_case('metadata_2field_signed_real', packets, packet_size*2*3, num_packets);

      metadata_matrix = [linspace(-2^10, 2^10-1, num_packets).', linspace(-2^11, 2^11-1, num_packets).', linspace(-2^12, 2^12-1, num_packets).'];
      packets = create_metadata_packet(packet_size, num_packets, metadata_matrix);
      single_test_case('metadata_3field_signed_real', packets, packet_size*2*3, num_packets);

      %**********************************
      % Unsigned Complex
      %**********************************
      metadata_matrix = complex(linspace(0, 2^11-1, num_packets).', linspace(2^11-1, 0, num_packets).');
      packets = create_metadata_packet(packet_size, num_packets, metadata_matrix);
      single_test_case('metadata_1field_unsigned_complex', packets, packet_size*2*3, num_packets);

      metadata_matrix = [...
        complex(linspace(0, 2^11-1, num_packets).', linspace(2^11-1, 0, num_packets).'),...
        complex(linspace(0, 2^12-1, num_packets).', linspace(2^12-1, 0, num_packets).')...
      ];
      packets = create_metadata_packet(packet_size, num_packets, metadata_matrix);
      single_test_case('metadata_2field_unsigned_complex', packets, packet_size*2*3, num_packets);

      metadata_matrix = [...
        complex(linspace(0, 2^11-1, num_packets).', linspace(2^11-1, 0, num_packets).'),...
        complex(linspace(0, 2^12-1, num_packets).', linspace(2^12-1, 0, num_packets).'),...
        complex(linspace(0, 2^13-1, num_packets).', linspace(2^13-1, 0, num_packets).')...
      ];
      packets = create_metadata_packet(packet_size, num_packets, metadata_matrix);
      single_test_case('metadata_3field_unsigned_complex', packets, packet_size*2*3, num_packets);

      %**********************************
      % Signed Complex
      %**********************************
      metadata_matrix = complex(linspace(-2^10, 2^10-1, num_packets).', linspace(2^10-1, -2^10, num_packets).');
      packets = create_metadata_packet(packet_size, num_packets, metadata_matrix);
      single_test_case('metadata_1field_signed_complex', packets, packet_size*2*3, num_packets);

      metadata_matrix = [...
        complex(linspace(-2^10, 2^10-1, num_packets).', linspace(2^10-1, -2^10, num_packets).'),...
        complex(linspace(-2^11, 2^11-1, num_packets).', linspace(2^11-1, -2^11, num_packets).')...
      ];
      packets = create_metadata_packet(packet_size, num_packets, metadata_matrix);
      single_test_case('metadata_2field_signed_complex', packets, packet_size*2*3, num_packets);

      metadata_matrix = [...
        complex(linspace(-2^10, 2^10-1, num_packets).', linspace(2^10-1, -2^10, num_packets).'),...
        complex(linspace(-2^11, 2^11-1, num_packets).', linspace(2^11-1, -2^11, num_packets).'),...
        complex(linspace(-2^12, 2^12-1, num_packets).', linspace(2^12-1, -2^12, num_packets).')...
      ];
      packets = create_metadata_packet(packet_size, num_packets, metadata_matrix);
      single_test_case('metadata_3field_signed_complex', packets, packet_size*2*3, num_packets);

      %**********************************
      % Unsigned mixed
      %**********************************
      metadata_matrix = [...
        complex(linspace(0, 2^11-1, num_packets).', linspace(2^11-1, 0, num_packets).'),...
        linspace(0, 2^12-1, num_packets).'...
      ];
      packets = create_metadata_packet(packet_size, num_packets, metadata_matrix);
      single_test_case('metadata_2field_unsigned_mixed', packets, packet_size*2*3, num_packets);

      metadata_matrix = [...
        linspace(0, 2^11-1, num_packets).',...
        complex(linspace(0, 2^12-1, num_packets).', linspace(2^12-1, 0, num_packets).'),...
        linspace(0, 2^13-1, num_packets).'...
      ];
      packets = create_metadata_packet(packet_size, num_packets, metadata_matrix);
      single_test_case('metadata_3field_unsigned_mixed', packets, packet_size*2*3, num_packets);

      %**********************************
      % Signed Mixed
      %**********************************
      metadata_matrix = [...
        linspace(-2^10, 2^10-1, num_packets).',...
        complex(linspace(-2^11, 2^11-1, num_packets).', linspace(2^11-1, -2^11, num_packets).')...
      ];
      packets = create_metadata_packet(packet_size, num_packets, metadata_matrix);
      single_test_case('metadata_2field_signed_mixed', packets, packet_size*2*3, num_packets);

      metadata_matrix = [...
        complex(linspace(-2^10, 2^10-1, num_packets).', linspace(2^10-1, -2^10, num_packets).'),...
        linspace(-2^11, 2^11-1, num_packets).',...
        complex(linspace(-2^12, 2^12-1, num_packets).', linspace(2^12-1, -2^12, num_packets).')...
      ];
      packets = create_metadata_packet(packet_size, num_packets, metadata_matrix);
      single_test_case('metadata_3field_signed_mixed', packets, packet_size*2*3, num_packets);

    end

  end
end
