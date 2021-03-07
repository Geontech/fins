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
% Description: Creates a test packet for the metadata cases
%

function [ packets ] = create_metadata_packet( packet_size, num_packets, metadata_fields )

  % All metadata cases use port "data_signed_complex_24bit_2ch_3samp" data
  % NOTE: 1. Create linearly spaced data points from -2^11, 2^11-1 with the packet size * num_channels * num_samples
  %       2. Convert these data points to complex
  %       3. Repeat complex arrays for the num_packets
  packets = repmat(complex(round(linspace(-2^11, 2^11-1, packet_size*2*3).'), round(linspace(2^11-1, -2^11, packet_size*2*3).')), num_packets, 1);
  packets = convert_numeric_to_cell(packets, packet_size*2*3, num_packets);

  % The second dimension (columns) contains the number of fields to populate in the packets
  num_metadata_fields = size(metadata_fields, 2);
  for packet_index=1:length(packets)
    packets{packet_index}.metadata = struct();
    packets{packet_index}.metadata.field0 = metadata_fields(packet_index, 1);
    if (num_metadata_fields > 1)
      packets{packet_index}.metadata.field1 = metadata_fields(packet_index, 2);
    end
    if (num_metadata_fields > 2)
      packets{packet_index}.metadata.field2 = metadata_fields(packet_index, 3);
    end
  end
  
end