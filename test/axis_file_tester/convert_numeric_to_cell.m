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

function [ y ] = convert_numeric_to_cell( x, packet_size, num_packets )
  % Initialize cell array
  y = cell(num_packets, 1);

  % Loop through the packets
  % NOTE: Zero-based index used here
  for p=0:num_packets-1
    % Initialize structure
    y{p+1} = struct();
    % Assign the data and make sure data doesn't lose its complex type
    y{p+1}.data = x(p*packet_size+1:(p+1)*packet_size);
  end

end