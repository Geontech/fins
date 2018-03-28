#ifndef {{ persona['name']|upper }}_I_IMPL_H
#define {{ persona['name']|upper }}_I_IMPL_H

#include "{{ persona['name'] }}_persona_base.h"
#include <frontend/frontend.h>
#include <stdint.h>
#include <ossie/CF/DataType.h>
#include <stddef.h>

// This comes from the BSP
const size_t REGS_BASE = 0x43C00000;
const size_t REGS_SIZE = 262144;

// Class used by persona
class ExtendedFEI
{
    public:
        ExtendedFEI() {}
        virtual ~ExtendedFEI() {}
        virtual bool allocateTuner(const CF::Properties& capacities, const size_t tuner_id) = 0;
};

// Persona class
class {{ persona['name'] }}_i;

class {{ persona['name'] }}_i : public {{ persona['name'] }}_persona_base
{
    ENABLE_LOGGING
    public:
        {{ persona['name'] }}_i(char *devMgr_ior, char *id, char *lbl, char *sftwrPrfl);
        {{ persona['name'] }}_i(char *devMgr_ior, char *id, char *lbl, char *sftwrPrfl, char *compDev);
        {{ persona['name'] }}_i(char *devMgr_ior, char *id, char *lbl, char *sftwrPrfl, CF::Properties capacities);
        {{ persona['name'] }}_i(char *devMgr_ior, char *id, char *lbl, char *sftwrPrfl, CF::Properties capacities, char *compDev);
        ~{{ persona['name'] }}_i();

        int serviceFunction();

        void constructor();

        CORBA::Boolean allocateCapacity(const CF::Properties& capacities) 
            throw (CF::Device::InvalidState, CF::Device::InvalidCapacity, CF::Device::InsufficientCapacity, CORBA::SystemException);
        void deallocateCapacity(const CF::Properties& capacities) 
            throw (CF::Device::InvalidState, CF::Device::InvalidCapacity, CORBA::SystemException);

    public:
        void setExtendedFEI(ExtendedFEI *extendedFEIDevice) { this->extendedFEIDevice = extendedFEIDevice; }

    protected:
        void afterHardwareProgramSuccess();
        void beforeHardwareUnprogrammed();
        void hwLoadRequest(CF::Properties& request);

    private:
        void center_frequencyChanged(const double &oldValue, const double &newValue);
        void rxtxTuning1Changed(const rxtxTuning1_struct &oldValue, const rxtxTuning1_struct &newValue);
        void rxtxTuning2Changed(const rxtxTuning2_struct &oldValue, const rxtxTuning2_struct &newValue);

    private:
        bool allocated;
        std::string connectionRequestId1;
        std::string connectionRequestId2;
        FRONTEND::DigitalTuner_ptr digitalTunerPort;
        ExtendedFEI *extendedFEIDevice;
        void *mapBase;
        int mapFd;
        std::vector<frontend::frontend_tuner_allocation_struct> tunerAllocations;

    private:
        {% for reg in persona['regs'] -%}
        {% if reg['writable'] -%}
        {% if reg['length'] > 1 -%}
        void {{ reg['name'] }}Changed(const std::vector<CORBA::Long> &oldValue, const std::vector<CORBA::Long> &newValue);
        {% else -%}
        void {{ reg['name'] }}Changed(const CORBA::Long &oldValue, const CORBA::Long &newValue);
        {% endif -%}
        {% endif -%}
        {% endfor %}
        {% for reg in persona['regs'] -%}
        volatile uint32_t *{{ reg['name'] }}Ptr;
        {% endfor %}
};

#endif // {{ persona['name']|upper }}_I_IMPL_H
