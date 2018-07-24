%===============================================================================
% Company:      Geon Technologies, LLC
% Author:       Alex Newgent
% Copyright:    (c) 2018 Geon Technologies, LLC. All rights reserved.
%               Dissemination of this information or reproduction of this
%               material is strictly prohibited unless prior written
%               permission is obtained from Geon Technologies, LLC
% Description:  Octave/MATLAB script to convert a decimal integer into a binary
%               string
%
% Usage:        binstr = dec2binstr(dec,is_signed,is_complex,N_BITS);
%                 * binstr      - Output str representing the binary value
%
%                 * dec         - The decimal value to be converted
%                                 (Real or complex)
%
%                 * is_signed   - Boolean for whether or not to use a signed bit
%
%                 * is_complex  - Boolean for whether or not the input is
%                                 complex
%                               - If true, the output string will use the first
%                                 half of the bits (N_BITS/2) for the imaginary
%                                 part and the second half for the real part
%
%                 * N_BITS      - Bit length of the entire word
%===============================================================================

function binstr = dec2binstr(dec,is_signed,is_complex,N_BITS)
  % Converts a decimal number to a binary string of N_BITS-bits

  % Split the input value into its real and imaginary components
  real_x = real(dec);
  imag_x = imag(dec);

  % If the signal is complex, devote a bit_width of N_BITS/2 to each part of the
  % value
  if is_complex
    bit_width = N_BITS/2;
  else
    bit_width = N_BITS;
  end

  % If value is signed and negative, perform a basic 2's complement
  if is_signed
    if real_x < 0
      real_x = 2^bit_width+real_x;
    end
    if imag_x < 0
      imag_x = 2^bit_width+imag_x;
    end
  end

  % Convert the real part of the value into a binary string
  while real_x ~= 0
    % Find the remainder for real_x
    real_rem = int2str(rem(real_x,2));
    % Divide real_x by 2 and floor it
    real_x = floor(real_x/2);

    % Begin concatenating the string
    if ~exist('real_str')
      real_str = real_rem;
    else
      real_str = strcat(real_rem,real_str);
    end
  end

  % Catch-all incase the input value is 0
  if ~exist('real_str')
    real_str = int2str(0);
  end
  % Pad the front the of binary string until it is the required bit width
  while length(real_str) ~= bit_width
    real_str = strcat('0',real_str);
  end

  % Convert the imaginary part of the value into a binary string
  while imag_x ~= 0
    % Find the remained for imag_x
    imag_rem = int2str(rem(imag_x,2));
    % Divide imag_x by 2 and floor it
    imag_x = floor(imag_x/2);

    % Begin concatenating the imaginary string
    if ~exist('imag_str')
      imag_str = imag_rem;
    else
      imag_str = strcat(imag_rem,imag_str);
    end
  end

  % Catch-all incase the input value is 0
  if ~exist('imag_str')
    imag_str = int2str(0);
  end

  % Pad the front of the imaginary string until it is the required bit width
  while length(imag_str) ~= bit_width
    imag_str = strcat('0',imag_str);
  end

  % Save the output string
  if is_complex
    % If it's a complex number, put the real and imaginary halves together
    binstr = strcat(imag_str,real_str);
  else
    % Otherwise, just shoot out the real values
    binstr = real_str;
  end
endfunction
