/* 
 * =============================================================================
 * Company:     Geon Technologies, LLC
 * Author:      Josh Schindehette
 * Copyright:   (c) 2018 Geon Technologies, LLC. All rights reserved.
 *              Dissemination of this information or reproduction of this 
 *              material is strictly prohibited unless prior written
 *              permission is obtained from Geon Technologies, LLC
 * Description: 
 * =============================================================================
 */

#ifndef INCLUDED_FPGA_32BIT_REG_MAP_HPP
#define INCLUDED_FPGA_32BIT_REG_MAP_HPP

#include <vector>
#include <iostream>
#include <boost/format.hpp>
#include "fpga_32bit_reg_impl.hpp"

class fpga_32bit_reg_map {
public:
    fpga_32bit_reg_map();

    int size() const { return this->regs.size(); }

    void print() const {
        // Header
        std::cout << boost::format("|%20s|%8s|%10s|%10s|%10s|%10s|%10s|%10s|%10s|%20s|")
            % std::string(20, '-') % std::string(8, '-')  % std::string(10, '-')
            % std::string(10, '-') % std::string(10, '-') % std::string(10, '-')
            % std::string(10, '-') % std::string(10, '-') % std::string(10, '-')
            % std::string(20, '-') << std::endl;
        std::cout << boost::format("|%20s|%8s|%10s|%10s|%10s|%10s|%10s|%10s|%10s|%20s|")
            % "Name" % "Offset" % "Value" % "Default" % "Width" % "Writable"
            % "Range Min" % "Range Max" % "Length" % "Description" << std::endl;
        std::cout << boost::format("|%20s|%8s|%10s|%10s|%10s|%10s|%10s|%10s|%10s|%20s|")
            % std::string(20, '-') % std::string(8, '-')  % std::string(10, '-')
            % std::string(10, '-') % std::string(10, '-') % std::string(10, '-')
            % std::string(10, '-') % std::string(10, '-') % std::string(10, '-')
            % std::string(20, '-') << std::endl;
        // Print the values
        for (unsigned int i = 0; i < this->size(); ++i) {
            this->regs[i].print();
        }
        // Trailer
        std::cout << boost::format("|%20s|%8s|%10s|%10s|%10s|%10s|%10s|%10s|%10s|%20s|")
            % std::string(20, '-') % std::string(8, '-')  % std::string(10, '-')
            % std::string(10, '-') % std::string(10, '-') % std::string(10, '-')
            % std::string(10, '-') % std::string(10, '-') % std::string(10, '-')
            % std::string(20, '-') << std::endl;
    }

    bool test_default_values() const {
        bool result = true;
        for (unsigned int i = 0; i < this->size(); ++i) {
            if (!this->regs[i].test_default_values()) {
                result = false;
            }
        }
        return result;
    }

    bool test_write_width() const {
        bool result = true;
        for (unsigned int i = 0; i < this->size(); ++i) {
            if (!this->regs[i].test_write_width()) {
                result = false;
            }
        }
        return result;
    }

public:
    std::vector<fpga_32bit_reg_impl> regs;

};

#endif /* INCLUDED_FPGA_32BIT_REG_MAP_HPP */
