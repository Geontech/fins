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

#ifndef INCLUDED_FPGA_32BIT_REG_HPP
#define INCLUDED_FPGA_32BIT_REG_HPP

#include <string>
#include <vector>
#include <iostream>
#include <stdint.h>
#include <math.h>
#include <boost/format.hpp>

class fpga_32bit_reg {
public:
    static const uint8_t BIT_WIDTH = 32;
    static const uint8_t NUM_BYTES = 4;

    fpga_32bit_reg(
        std::string name,
        uint32_t offset,
        uint8_t width,
        std::vector<uint32_t> default_values,
        bool writable,
        std::string description,
        uint32_t range_min,
        uint32_t range_max,
        uint32_t length
    ) : name(name),
        offset(offset),
        width(width),
        default_values(default_values),
        writable(writable),
        description(description),
        range_min(range_min),
        range_max(range_max),
        length(length) {}

    virtual ~fpga_32bit_reg();

    virtual std::vector<uint32_t> read() const = 0;
    virtual void write(std::vector<uint32_t> &values) const = 0;

    bool write_valid(std::vector<uint32_t> &values) const {
        if (this->check_write(values)) {
            this->write(values);
            return true;
        }
        return false;
    }

    bool write_verified(std::vector<uint32_t> &values) const {
        if (this->write_valid(values)) {
            std::vector<uint32_t> written_values = this->read();
            if (written_values == values) {
                return true;
            }
        }
        return false;
    }

    bool check_write(std::vector<uint32_t> &values) const {
        // Init to true, look for false
        bool result = true;
        // Check that this register is writable
        if (result && (!this->writable)) {
            result = false;
        }
        // Check that the vector provided has the same length as the register
        if (result && (values.size() != this->length)) {
            result = false;
        }
        // Check that the provided values are within the valid ranges
        if (result) {
            for (unsigned int i = 0; i < this->length; ++i) {
                if ((values[i] > this->range_max) || (values[i] < this->range_min)) {
                    result = false;
                }
            }
        }
        return result;
    }

    void print() const {
        // Read the values
        std::vector<uint32_t> values = this->read();
        // Print the values
        for (unsigned int i = 0; i < this->length; ++i) {
            std::cout << boost::format("|%20s|%08X|%10u|%10u|%10u|%10u|%10u|%10u|%10u|%20s|")
                % this->name
                % (this->offset + i*NUM_BYTES)
                % values[i]
                % this->default_values[i]
                % (unsigned int)this->width
                % this->writable
                % this->range_min
                % this->range_max
                % this->length
                % this->description
                << std::endl;
        }
    }

    bool test_default_values() const {
        bool result = false;
        if (!this->writable) {
            // A read-only register cannot be easily tested for default values
            result = true;
        } else if (this->default_values.size() == this->length) {
            // Check that the default values match
            std::vector<uint32_t> current_values = this->read();
            if (current_values == this->default_values) {
                result = true;
            }
        }
        return result;
    }

    bool test_write_width() const {
        // A read-only register cannot be tested for write width
        if (!this->writable) {
            return true;
        }
        // Initialize vectors of bit width max data
        std::vector<uint32_t> reg_32bit_max(this->length, this->get_bit_max(BIT_WIDTH));
        std::vector<uint32_t> reg_width_max(this->length, this->get_bit_max(this->width));
        // Store off original value to set it back after the test
        std::vector<uint32_t> original_values = this->read();
        // Write a vector of all the 32bit max values
        // NOTE: Use write_reg() because it does not do validation of inputs
        this->write(reg_32bit_max);
        // Read the values
        std::vector<uint32_t> current_values = this->read();
        // Write the original values back
        this->write(original_values);
        // Compare
        if (current_values == reg_width_max) {
            return true;
        }
        return false;
    }

private:
    inline uint32_t get_bit_max(uint8_t bit_width) const {
        return (pow(2, bit_width) - 1);
    }

public:
    const std::string name;
    const uint32_t offset;
    const uint8_t width;
    const std::vector<uint32_t> default_values;
    const bool writable;
    const std::string description;
    const uint32_t range_min;
    const uint32_t range_max;
    const uint32_t length;

};

#endif /* INCLUDED_FPGA_32BIT_REG_HPP */
