/* 
 * =============================================================================
 * Company:     Geon Technologies, LLC
 * Author:      Josh Schindehette
 * Copyright:   (c) 2018 Geon Technologies, LLC. All rights reserved.
 *              Dissemination of this information or reproduction of this 
 *              material is strictly prohibited unless prior written
 *              permission is obtained from Geon Technologies, LLC
 * Description: The implementation of the register map constructor
 * =============================================================================
 */

#include "fpga_32bit_reg_map.hpp"

fpga_32bit_reg_map::fpga_32bit_reg_map() {
    {% for reg in persona['regs'] -%}
    this->regs.push_back(fpga_32bit_reg_impl("{{ reg['name'] }}", {{ '0x%08X' % reg['offset'] }}, {{ reg['width'] }}, {{ "{" }}{{ reg['default_values']|join(',') }}{{ "}" }}, {{ reg['writable']|lower }}, "{{ reg['description'] }}", {{ reg['range_min'] }}, {{ reg['range_max'] }}, {{ reg['length'] }}));
    {% endfor %}
}