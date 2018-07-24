
%===============================================================================
% Company:      Geon Technologies, LLC
% Author:       Alex Newgent
% Copyright:    (c) 2018 Geon Technologies, LLC. All rights reserved.
%               Dissemination of this information or reproduction of this
%               material is strictly prohibited unless prior written
%               permission is obtained from Geon Technologies, LLC
% Description:  Octave/MATLAB script for checking user's coefficients and
%               ensuring they are within the correct bit length. If a value is
%               outside the allowed range, returns an error.
%
% Usage:        bit_width_check(N_BITS,values,is_signed,is_complex,value_name)
%                 * N_BITS      - Bit length to represent the values
%
%                 * values      - Vector of (real or complex) numbers
%
%                 * is_signed   - Bool that denotes if the values are signed
%
%                 * is_complex  - Bool that denotes if the values are complex
%                               - If true, the effective bit width is N_BITS/2
%
%                 * value_name  - Str giving the name of the values under test
%===============================================================================
function bit_width_check(N_BITS,values,is_signed,is_complex,value_name)
  %This function checks user's coefficients to see if they are within a valid
  % bit range

  if is_complex
    if is_signed
      max_val = 2^(N_BITS/2-1)-1;
      min_val = -1*2^(N_BITS/2-1);
    else
      max_val = 2^(N_BITS/2)-1;
      min_val = 0;
    end
  else
    if is_signed
      max_val = 2^(N_BITS-1)-1;
      min_val = -1 * 2^(N_BITS-1);
    else
      max_val = 2^(N_BITS)-1;
      min_val = 0;
    end
  end
  for i=1:1:length(values)
    if (real(values(i)) < min_val || imag(values(i)) < min_val)
      error('Value %d below minimum value (%d) for %s',values(i),min_val,value_name);
    elseif (real(values(i)) > max_val || imag(values(i)) > max_val)
      error('Value %d above maximum value (%d) for %s',values(i),max_val,value_name);
    end
  end
end
