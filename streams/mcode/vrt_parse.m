%===============================================================================
% Company:     Geon Technologies, LLC
% Author:      Josh Schindehette
% Copyright:   (c) 2018 Geon Technologies, LLC. All rights reserved.
%              Dissemination of this information or reproduction of this 
%              material is strictly prohibited unless prior written
%              permission is obtained from Geon Technologies, LLC
% Description: This function parses hex characters in a VITA 49 (VRT) format
%              that exist in a text file
% Inputs:      filename - str
%                  The filename of a text file with hex characters.
%                  The file MUST contain 8 hex characters per line (one 
%                  VRT word), and each line should contain one VRT word. 
%                  The hex is assumed to be big-endian.
% Outputs:     packets - struct[]
%                  .header - struct (1 word)
%                      .packet_type - uint (4 bits)
%                          The type of the packet
%                            0: IF data packet with no stream ID word
%                            1: IF data packet with stream ID word
%                            2: Extension data packet with no stream ID word
%                            3: Extension data packet with stream ID word
%                            4: IF context packet
%                            5: Extension context packet
%                      .c - uint (1 bit)
%                          A flag indicating if the class ID word is included
%                      .t - uint (1 bit)
%                          A flag indicating if the trailer word is included
%                      .r - uint (2 bits)
%                          Reserved bits - serve no function
%                      .tsi - uint (2 bits)
%                          The format of the integer timestamp
%                            0: The integer timestamp word is not included
%                            1: The integer timestamp is UTC time
%                            2: The integer timestamp is GPS time
%                            3: The integer timestamp is another format
%                      .tsf - uint (2 bits)
%                          The format of the fractional timestamp
%                            0: The fractional timestamp word is not included
%                            1: The fractional timestamp is a sample count
%                            2: The fractional timestamp is in picoseconds
%                            3: The fractional timestamp is a freerun counter
%                      .packet_count - uint (4 bits)
%                          A rolling counter that increments for each packet
%                      .packet_size - uint (16 bits)
%                          The number of 32 bit words that are in this packet,
%                          including the header
%                  .stream_id - uint (1 word)
%                  .class_id - uint (2 words)
%                  .int_timestamp - uint (1 word)
%                  .frac_timestamp - uint (2 words)
%                  .data - uint[] (N words)
%                  .trailer - struct (1 word)
%                      .ind_enables (12 bits)
%                           .calibrated_time - uint (1 bit)
%                           .data_valid - uint (1 bit)
%                           .reference_lock - uint (1 bit)
%                           .agc_active - uint (1 bit)
%                           .detected_signal - uint (1 bit)
%                           .spectral_inversion - uint (1 bit)
%                           .over_range - uint (1 bit)
%                           .sample_loss - uint (1 bit)
%                           .user0 - uint (1 bit)
%                           .user1 - uint (1 bit)
%                           .user2 - uint (1 bit)
%                           .user3 - uint (1 bit)
%                      .ind_status (12 bits)
%                           .calibrated_time - uint (1 bit)
%                           .data_valid - uint (1 bit)
%                           .reference_lock - uint (1 bit)
%                           .agc_active - uint (1 bit)
%                           .detected_signal - uint (1 bit)
%                           .spectral_inversion - uint (1 bit)
%                           .over_range - uint (1 bit)
%                           .sample_loss - uint (1 bit)
%                           .user0 - uint (1 bit)
%                           .user1 - uint (1 bit)
%                           .user2 - uint (1 bit)
%                           .user3 - uint (1 bit)
%                      .e - uint (1 bit)
%                          A flag indicating if there is an associated context
%                          packet
%                      .ac_packet_count - uint (7 bits)
%                          The packet count value of the associated context
%                          packet
% Usage:       [ packets ] = vrt_parse( filename, [verbose] )
%===============================================================================
function [ packets ] = vrt_parse( varargin )

    % Constants
    BITS_PER_WORD = 32;

    % Get Variable Inputs
    if ((nargin == 1) && ischar(varargin{1}))
        filename = varargin{1};
        verbose = false;
    elseif ((nargin == 2) && ischar(varargin{1}) && islogical(varargin{2}))
        filename = varargin{1};
        verbose = varargin{2};
    else
        error('Incorrect usage. Correct syntax: vrt_parse(filename, [verbose])');
    end

    % Read the text file
    hex_chars = char(textread(filename,'%s'));

    % Initialize output
    packets = [];
    if (verbose)
        fprintf('| pkt_type  | c         | t         | r         | tsi       | tsf       | pkt_count | pkt_size  |\n');
        fprintf('| --------- | --------- | --------- | --------- | --------- | --------- | --------- | --------- |\n');
    end

    % Loop through words
    w = 0;
    while (w < size(hex_chars, 1))
        % Initialize packet
        packet = {};

        % Decode header
        w = w + 1;
        word_bin = dec2bin(hex2dec(hex_chars(w, :)), BITS_PER_WORD);
        packet.header.packet_type  = bin2dec(word_bin(1:4));
        packet.header.c            = bin2dec(word_bin(5));
        packet.header.t            = bin2dec(word_bin(6));
        packet.header.r            = bin2dec(word_bin(7:8));
        packet.header.tsi          = bin2dec(word_bin(9:10));
        packet.header.tsf          = bin2dec(word_bin(11:12));
        packet.header.packet_count = bin2dec(word_bin(13:16));
        packet.header.packet_size  = bin2dec(word_bin(17:32));
        if (verbose)
            fprintf('| %9d | %9d | %9d | %9d | %9d | %9d | %9d | %9d |\n',...
                packet.header.packet_type ,...
                packet.header.c           ,...
                packet.header.t           ,...
                packet.header.r           ,...
                packet.header.tsi         ,...
                packet.header.tsf         ,...
                packet.header.packet_count,...
                packet.header.packet_size  ...
            );
        end

        % Decode stream ID
        switch packet.header.packet_type
            case 0 % IF data packet with no stream ID word
                has_stream_id = false;
            case 1 % IF data packet with stream ID word
                has_stream_id = true;
            case 2 % Extension data packet with no stream ID word
                has_stream_id = false;
            case 3 % Extension data packet with stream ID word
                has_stream_id = true;
            case 4 % IF context packet
                error('Parsing of IF context packets is not supported');
            case 5 % Extension context packet
                error('Parsing of Extension context packets is not supported');
            otherwise
                error('Invalid packet type in header');
        end
        if (has_stream_id)
            w = w + 1;
            packet.stream_id = hex2dec(hex_chars(w, :));
        end

        % Decode class ID
        if (packet.header.c)
            w = w + 1;
            packet.class_id = hex2dec(hex_chars(w, :)) * 2^BITS_PER_WORD;
            w = w + 1;
            packet.class_id = packet.class_id + hex2dec(hex_chars(w, :));
        end

        % Decode integer timestamp
        switch packet.header.tsi
            case 0 % The integer timestamp word is not included
                has_tsi = false;
            case 1 % The integer timestamp is UTC time
                has_tsi = true;
            case 2 % The integer timestamp is GPS time
                has_tsi = true;
            case 3 % The integer timestamp is another format
                has_tsi = true;
            otherwise
                error('Invalid integer timestamp type in header');
        end
        if (has_tsi)
            w = w + 1;
            packet.int_timestamp = hex2dec(hex_chars(w, :));
        end

        % Decode fractional timestamp
        switch packet.header.tsf
            case 0 % The fractional timestamp word is not included
                has_tsf = false;
            case 1 % The fractional timestamp is a sample count
                has_tsf = true;
            case 2 % The fractional timestamp is in picoseconds
                has_tsf = true;
            case 3 % The fractional timestamp is a freerun counter
                has_tsf = true;
            otherwise
                error('Invalid fractional timestamp type in header');
        end
        if (has_tsf)
            w = w + 1;
            packet.frac_timestamp = hex2dec(hex_chars(w, :)) * 2^BITS_PER_WORD;
            w = w + 1;
            packet.frac_timestamp = packet.frac_timestamp + hex2dec(hex_chars(w, :));
        end

        % Decode data
        num_data = packet.header.packet_size - 1;
        if (has_stream_id)
            num_data = num_data - 1;
        end
        if (packet.header.c)
            num_data = num_data - 2;
        end
        if (has_tsi)
            num_data = num_data - 1;
        end
        if (has_tsf)
            num_data = num_data - 2;
        end
        if (packet.header.t)
            num_data = num_data - 1;
        end
        packet.data = zeros(num_data, 1);
        for d=1:num_data
            w = w + 1;
            packet.data(d) = hex2dec(hex_chars(w, :));
        end

        % Decode trailer
        if (packet.header.t)
            w = w + 1;
            word_bin = dec2bin(hex2dec(hex_chars(w, :)), BITS_PER_WORD);
            packet.trailer.ind_enables.calibrated_time    = bin2dec(word_bin(1));
            packet.trailer.ind_enables.data_valid         = bin2dec(word_bin(2));
            packet.trailer.ind_enables.reference_lock     = bin2dec(word_bin(3));
            packet.trailer.ind_enables.agc_active         = bin2dec(word_bin(4));
            packet.trailer.ind_enables.detected_signal    = bin2dec(word_bin(5));
            packet.trailer.ind_enables.spectral_inversion = bin2dec(word_bin(6));
            packet.trailer.ind_enables.over_range         = bin2dec(word_bin(7));
            packet.trailer.ind_enables.sample_loss        = bin2dec(word_bin(8));
            packet.trailer.ind_enables.user0              = bin2dec(word_bin(9));
            packet.trailer.ind_enables.user1              = bin2dec(word_bin(10));
            packet.trailer.ind_enables.user2              = bin2dec(word_bin(11));
            packet.trailer.ind_enables.user3              = bin2dec(word_bin(12));
            packet.trailer.ind_status.calibrated_time     = bin2dec(word_bin(13));
            packet.trailer.ind_status.data_valid          = bin2dec(word_bin(14));
            packet.trailer.ind_status.reference_lock      = bin2dec(word_bin(15));
            packet.trailer.ind_status.agc_active          = bin2dec(word_bin(16));
            packet.trailer.ind_status.detected_signal     = bin2dec(word_bin(17));
            packet.trailer.ind_status.spectral_inversion  = bin2dec(word_bin(18));
            packet.trailer.ind_status.over_range          = bin2dec(word_bin(19));
            packet.trailer.ind_status.sample_loss         = bin2dec(word_bin(20));
            packet.trailer.ind_status.user0               = bin2dec(word_bin(21));
            packet.trailer.ind_status.user1               = bin2dec(word_bin(22));
            packet.trailer.ind_status.user2               = bin2dec(word_bin(23));
            packet.trailer.ind_status.user3               = bin2dec(word_bin(24));
            packet.trailer.e                              = bin2dec(word_bin(25));
            packet.trailer.ac_packet_count                = bin2dec(word_bin(26:32));
        end

        % Add to output
        packets = [packets, packet];
    end

end