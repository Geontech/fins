%===============================================================================
% Company:     Geon Technologies, LLC
% Author:      Josh Schindehette
% Copyright:   (c) 2018 Geon Technologies, LLC. All rights reserved.
%              Dissemination of this information or reproduction of this 
%              material is strictly prohibited unless prior written
%              permission is obtained from Geon Technologies, LLC
% Description: This function inputs an array of structs and returns only the
%              ones that have a certain field value.
% Inputs:      structs - struct[]
%                  An array of structs.
%              sfield - cell[]
%                  A cell array of fieldnames
%              svalue - any
%                  The value to match
% Outputs:     fstructs - struct[]
%                  An array of filtered structs whose "sfield" field has the
%                  value "svalue".
% Usage:       [ fstructs ] = filter_struct_array(structs, sfield, svalue)
%===============================================================================
function [ fstructs ] = filter_struct_array(structs, sfield, svalue)

    % Initialize the output structs
    fstructs = [];

    % Loop through the input structs
    for s=1:length(structs)

        % Get the value of the field in question
        switch length(sfield)
            case 1
                fvalue = structs(s).(sfield{1});
            case 2
                fvalue = structs(s).(sfield{1}).(sfield{2});
            case 3
                fvalue = structs(s).(sfield{1}).(sfield{2}).(sfield{3});
            case 4
                fvalue = structs(s).(sfield{1}).(sfield{2}).(sfield{3}).(sfield{4});
            case 5
                fvalue = structs(s).(sfield{1}).(sfield{2}).(sfield{3}).(sfield{4}).(sfield{5});
            otherwise
                error('Unsupported number of fields.');
        end

        % Check the value and add to output
        if (fvalue == svalue)
            fstructs = [fstructs, structs(s)];
        end

    end
end