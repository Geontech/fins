%===============================================================================
% Company:     Geon Technologies, LLC
% Author:      Josh Schindehette
% Copyright:   (c) 2018 Geon Technologies, LLC. All rights reserved.
%              Dissemination of this information or reproduction of this
%              material is strictly prohibited unless prior written
%              permission is obtained from Geon Technologies, LLC
% Description: This function inputs a structure and creates a VHDL simulation
%              package with constants of each field of the structure.
% Inputs:      sim_pkg - struct
%                * Each field of sim_pkg must be a scalar integer/boolean
%                   or a vector of integers
%              pkg_name - string
%                * The name of the VHDL output package
%              file_name - string
%                * The file path of the VHDL output file
% Outputs:     Text file is generated
% Usage:       gen_sim_pkg(struct sim_pkg, string pkg_name)
%===============================================================================
function gen_sim_pkg( sim_pkg , pkg_name , file_name )

  %-----------------------------------------------------------------------------
  % Input validation
  %-----------------------------------------------------------------------------
  % Check type
  if (~isstruct(sim_pkg))
    error('Invalid usage. sim_pkg input is not a structure.')
  end

  % Retrieve the fieldnames
  fields = fieldnames(sim_pkg);

  % Check that there are streams
  if (length(fields) == 0)
    error('There are no fields in the simulation package structure.')
  end

  %-----------------------------------------------------------------------------
  % Create the file
  %-----------------------------------------------------------------------------
  % Open file
  fileID = fopen(file_name, 'w');

  % Generate file
  fprintf(fileID, 'library ieee;\n');
  fprintf(fileID, 'use ieee.std_logic_1164.all;\n');
  fprintf(fileID, 'use ieee.numeric_std.all;\n');
  fprintf(fileID, '\n');
  fprintf(fileID, 'package %s is\n', pkg_name);
  fprintf(fileID, '\n');
  for n=1:length(fields)
    field = fields{n};
    field_value = sim_pkg.(field);
    if (islogical(field_value))
      if (field_value)
        fprintf(fileID, 'constant %s : boolean := true;\n', field);
      else
        fprintf(fileID, 'constant %s : boolean := false;\n', field);
      end
    elseif (isnumeric(field_value))
      if (length(field_value) > 1)
        field_value_type = ['t_', field];
        fprintf(fileID, 'type %s is array (%d to %d) of integer;\n', field_value_type, 0, length(field_value)-1);
        fprintf(fileID, 'constant %s : %s := (\n', field, field_value_type);
        for m=1:length(field_value)
          if (m < length(field_value))
            fprintf(fileID, '  %d,\n', field_value(m));
          else
            fprintf(fileID, '  %d \n);\n', field_value(m));
          end
        end
      else
        fprintf(fileID, 'constant %s : integer := %d;\n', field, field_value);
      end
    else
      error('Only integer and boolean values are supported within the fields of the sim_pkg structure.');
    end
  end
  fprintf(fileID, '\n');
  fprintf(fileID, 'end %s;\n', pkg_name);

  % Close the file
  fclose(fileID);

end
