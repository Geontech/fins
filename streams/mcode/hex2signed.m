%================================================================================
% Company:     Geon Technologies, LLC
% File:        hex2signed.m
% Description: This function converts an array of hex character arrays into
%              an array of signed numbers.
% Inputs:      x      : hex array with dimensions x(hex_chars, samples)
%                       'row' dimension contains the hex characters
%                       'column' dimension contains the samples
%              N_BITS : number of bits
% Outputs:     y      : column matrix of signed decimal values
%
% Revision History:
% Date        Author             Revision
% ----------  -----------------  ------------------------------------------------
% 2017-07-25  Josh Schindehette  Initial Version
%
%================================================================================
function y = hex2signed(x, N_BITS)

  % Validation checks
  num_hex_chars = size(x,2);
  if ((num_hex_chars * 4) < N_BITS)
    error(['Too many bits (',num2str(N_BITS),') to parse ',num2str(num_hex_chars),' hex characters.']);
  elseif (((num_hex_chars * 4) - 4) > N_BITS)
    disp('Warning: Not all hex characters were used when creating the output.');
  end

  % Loop through the samples
  for n=1:size(x,1)
    y(n,1) = hex2dec(x(n,:));
    y(n,1) = y(n,1) - (y(n,1) >= 2.^(N_BITS-1)) .* 2.^N_BITS;
  end

end
