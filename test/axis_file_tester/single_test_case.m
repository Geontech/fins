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

function single_test_case( port_name, write_packets, packet_size, num_packets )
  % Constants
  TEST_FILEPATH = 'test.txt';

  % Write data to file
  if (iscell(write_packets))
    is_cell = true;
    axis_file_tester_axis_file_write(port_name, TEST_FILEPATH, write_packets);
  else
    is_cell = false;
    axis_file_tester_axis_file_write(port_name, TEST_FILEPATH, write_packets, packet_size);
  end

  % Read data from file
  read_packets = axis_file_tester_axis_file_read(port_name, TEST_FILEPATH, is_cell);

  % Compare
  if (~isequal(write_packets, read_packets))
    message = sprintf('FAIL: Port %s, packet_size=%d, num_packets=%d, cell_array=%d', port_name, packet_size, num_packets, is_cell);
    error(message);
  end

  % Notify user of pass
  message = sprintf('PASS: Port %s, packet_size=%d, num_packets=%d, cell_array=%d', port_name, packet_size, num_packets, is_cell);
  disp(message);
end
