%================================================================================
% Company:     Geon Technologies, LLC
% Author:      Josh Schindehette
% Copyright:   (c) 2018 Geon Technologies, LLC. All rights reserved.
%              Dissemination of this information or reproduction of this 
%              material is strictly prohibited unless prior written
%              permission is obtained from Geon Technologies, LLC
% Description: This function converts a signed integer value with N_HEX*4 bit
%              width into a hex string.
%================================================================================
function y = signed2hex(x, N_HEX)

  % Get the number of bits
  N_BITS = N_HEX * 4;

  % Force x format
  x = x(:);

  % Get sizes
  num_rows = length(x);
  num_cols = N_HEX;

  % Validate input
  if (any(x > 2^(N_BITS-1)-1) || any(x < -2^(N_BITS-1)))
    error('The values you provided are too large to be represented by N_HEX');
  end

  % If negative, use the 2's complement
  %   * Could have used the following command if we didn't need compatibility
  %     with MATLAB *sigh*:
  %       x(x < 0) = bitcmp(abs(x(x < 0)), N_BITS) + 1;
  x_twoscomp_bin = dec2bin(abs(x), N_BITS);
  for n=1:num_rows
    for k=1:N_BITS
      if (x_twoscomp_bin(n,k) == '1')
        x_twoscomp_bin(n,k) = '0';
      else
        x_twoscomp_bin(n,k) = '1';
      end
    end
  end
  x_twoscomp = bin2dec(x_twoscomp_bin) + 1;
  x(x < 0) = x_twoscomp(x < 0);

  % Preallocate character matrix
  y(1:num_rows,1:num_cols) = ' ';

  % Convert to hex
  for n=1:num_rows
    y(n,:) = dec2hex(x(n), num_cols);
  end

end
