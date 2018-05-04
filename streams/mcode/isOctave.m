%===============================================================================
% Description: Function to determine the software running the script, returns
%              true if the environment is Octave.
% Source:      https://www.gnu.org/software/octave/doc/v4.0.1
%              /How-to-distinguish-between-Octave-and-Matlab_003f.html
%===============================================================================
function retval = isOctave
  persistent cacheval;  % speeds up repeated calls

  if isempty (cacheval)
    cacheval = (exist ('OCTAVE_VERSION', 'builtin') > 0);
  end

  retval = cacheval;
end
