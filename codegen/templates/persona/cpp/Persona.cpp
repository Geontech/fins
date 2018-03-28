/**************************************************************************

    This is the device code. This file contains the child class where
    custom functionality can be added to the device. Custom
    functionality to the base class can be extended here. Access to
    the ports can also be done from this class

**************************************************************************/

#include "{{ persona['name'] }}.h"
#include <fcntl.h>
#include <sys/mman.h>

PREPARE_LOGGING({{ persona['name'] }}_i)

{{ persona['name'] }}_i::{{ persona['name'] }}_i(char *devMgr_ior, char *id, char *lbl, char *sftwrPrfl) :
    {{ persona['name'] }}_persona_base(devMgr_ior, id, lbl, sftwrPrfl),
    allocated(false),
    digitalTunerPort(FRONTEND::DigitalTuner::_nil()),
    extendedFEIDevice(NULL),
    mapBase(NULL),
    mapFd(-1),
    {% for reg in persona['regs'] -%}
    {{ reg['name'] }}Ptr(NULL){% if loop.index < loop.length %},{% endif %}
    {% endfor %}
{
    LOG_TRACE({{ persona['name'] }}_i, __PRETTY_FUNCTION__);
}

{{ persona['name'] }}_i::{{ persona['name'] }}_i(char *devMgr_ior, char *id, char *lbl, char *sftwrPrfl, char *compDev) :
    {{ persona['name'] }}_persona_base(devMgr_ior, id, lbl, sftwrPrfl, compDev),
    allocated(false),
    digitalTunerPort(FRONTEND::DigitalTuner::_nil()),
    extendedFEIDevice(NULL),
    mapBase(NULL),
    mapFd(-1),
    {% for reg in persona['regs'] -%}
    {{ reg['name'] }}Ptr(NULL){% if loop.index < loop.length %},{% endif %}
    {% endfor %}
{
    LOG_TRACE({{ persona['name'] }}_i, __PRETTY_FUNCTION__);
}

{{ persona['name'] }}_i::{{ persona['name'] }}_i(char *devMgr_ior, char *id, char *lbl, char *sftwrPrfl, CF::Properties capacities) :
    {{ persona['name'] }}_persona_base(devMgr_ior, id, lbl, sftwrPrfl, capacities),
    allocated(false),
    digitalTunerPort(FRONTEND::DigitalTuner::_nil()),
    extendedFEIDevice(NULL),
    mapBase(NULL),
    mapFd(-1),
    {% for reg in persona['regs'] -%}
    {{ reg['name'] }}Ptr(NULL){% if loop.index < loop.length %},{% endif %}
    {% endfor %}
{
    LOG_TRACE({{ persona['name'] }}_i, __PRETTY_FUNCTION__);
}

{{ persona['name'] }}_i::{{ persona['name'] }}_i(char *devMgr_ior, char *id, char *lbl, char *sftwrPrfl, CF::Properties capacities, char *compDev) :
    {{ persona['name'] }}_persona_base(devMgr_ior, id, lbl, sftwrPrfl, capacities, compDev),
    allocated(false),
    digitalTunerPort(FRONTEND::DigitalTuner::_nil()),
    extendedFEIDevice(NULL),
    mapBase(NULL),
    mapFd(-1),
    {% for reg in persona['regs'] -%}
    {{ reg['name'] }}Ptr(NULL){% if loop.index < loop.length %},{% endif %}
    {% endfor %}
{
    LOG_TRACE({{ persona['name'] }}_i, __PRETTY_FUNCTION__);
}

{{ persona['name'] }}_i::~{{ persona['name'] }}_i()
{
    LOG_TRACE({{ persona['name'] }}_i, __PRETTY_FUNCTION__);
}

int {{ persona['name'] }}_i::serviceFunction()
{
    bulkio::InShortPort::StreamType stream = this->dataShort_in->getCurrentStream(bulkio::Const::BLOCKING);
    
    if (not stream) {
        return NOOP;
    }

    bulkio::InShortStream::DataBlockType block = stream.read();

    if (not block) {
        if (stream.eos()) {
            LOG_DEBUG({{ persona['name'] }}_i, "The EOS was received");
        }

        return NOOP;
    }

    LOG_DEBUG({{ persona['name'] }}_i, "Got data on stream " << stream.streamID() << "! #Samples = " << block.cxsize());

    return NORMAL;
}

void {{ persona['name'] }}_i::constructor()
{
    // Add property listeners
    this->addPropertyListener(this->center_frequency, this, &{{ persona['name'] }}_i::center_frequencyChanged);
    this->addPropertyListener(this->rxtxTuning1, this, &{{ persona['name'] }}_i::rxtxTuning1Changed);
    this->addPropertyListener(this->rxtxTuning2, this, &{{ persona['name'] }}_i::rxtxTuning2Changed);
    {% for reg in persona['regs'] -%}
    {% if reg['writable'] -%}
    this->addPropertyListener(this->{{ reg['name'] }}, this, &{{ persona['name'] }}_i::{{ reg['name'] }}Changed);
    {% endif -%}
    {% endfor %}
}

CORBA::Boolean {{ persona['name'] }}_i::allocateCapacity(const CF::Properties& capacities)
        throw (CF::Device::InvalidState, CF::Device::InvalidCapacity, CF::Device::InsufficientCapacity, CORBA::SystemException) 
{
    LOG_TRACE({{ persona['name'] }}_i, __PRETTY_FUNCTION__);

    if (isBusy() || isLocked()) {
        LOG_WARN({{ persona['name'] }}_i, "Cannot allocate capacities... Device state is locked and/or busy");
        return false;
    }

    if (this->allocated) {
        LOG_WARN({{ persona['name'] }}_i, "Cannot allocate capacities... Device is already allocated");
        return false;
    }

    if (not attemptToProgramParent()) {
        LOG_ERROR({{ persona['name'] }}_i, "Failed to program parent");
        return false;
    }

    return true;
}

void {{ persona['name'] }}_i::deallocateCapacity(const CF::Properties& capacities)
        throw (CF::Device::InvalidState, CF::Device::InvalidCapacity, CORBA::SystemException) 
{
    LOG_TRACE({{ persona['name'] }}_i, __PRETTY_FUNCTION__);

    attemptToUnprogramParent();

    this->allocated = false;
}

void {{ persona['name'] }}_i::afterHardwareProgramSuccess()
{
    LOG_TRACE({{ persona['name'] }}_i, __PRETTY_FUNCTION__);

    // Mark the persona as allocated
    this->allocated = true;

    // Map the memory
    this->mapFd = open("/dev/mem", O_RDWR | O_SYNC);

    if (this->mapFd == -1) {
        LOG_ERROR({{ persona['name'] }}_i, "Failed to open /dev/mem with error: " << strerror(errno));
        attemptToUnprogramParent();
        return;
    }

    this->mapBase = mmap(0, REGS_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, this->mapFd, REGS_BASE);

    if (this->mapBase == (void *) -1) {
        LOG_ERROR({{ persona['name'] }}_i, "Failed to map memory with error: " << strerror(errno));
        close(this->mapFd);
        attemptToUnprogramParent();
        return;
    }

    // Set the pointers for the registers
    {% for reg in persona['regs'] -%}
    this->{{ reg['name'] }}Ptr = (uint32_t *) (this->mapBase + {{ '%0#10x' | format(reg['offset']) }});
    {% endfor %}

    // Read the registers and make sure they have the correct default values
    // Note: Don't do this check for RAMs
    {% for reg in persona['regs'] -%}
    {% if 'default' in reg -%}
    {% if reg['length'] > 1 -%}
    {% for val in reg['default'] -%}
    if ({{ val }} != *(this->{{ reg['name'] }}Ptr + {{ loop.index }})) {
        LOG_WARN({{ persona['name'] }}_i, "Register {{ reg['name'] }} does not have the correct default value at index {{ loop.index }}.");
    }
    {% endfor -%}
    {% else -%}
    if ({{ reg['default']}} != *this->{{ reg['name']}}Ptr) {
        LOG_WARN({{ persona['name'] }}_i, "Register {{ reg['name'] }} does not have the correct default value.");
    }
    {% endif -%}
    {% endif -%}
    {% endfor %}

    // Allocate the parent FEI device

    // Get the parent FEI pointer
    Device_impl *parentFEI = this->getParentDevice();

    // Populate the frontend tuner allocation structures
    this->tunerAllocations.resize(4);

    // This is used to indicate if sensing on RX 0 and/or RX 1 should be enabled
    bool firstAllocationSuccess = false;
    bool secondAllocationSuccess = false;
    bool allAllocationSuccess = true;

    for (size_t i = 0; i < this->tunerAllocations.size(); ++i) {
        this->tunerAllocations[i].allocation_id = frontend::uuidGenerator();
        this->tunerAllocations[i].bandwidth = (i == 0 or i == 2) ? this->rxtxTuning1.bandwidth : this->rxtxTuning2.bandwidth;
        this->tunerAllocations[i].bandwidth_tolerance = 10;
        this->tunerAllocations[i].center_frequency = this->center_frequency;
        this->tunerAllocations[i].device_control = true;
        this->tunerAllocations[i].group_id = "";
        this->tunerAllocations[i].rf_flow_id = "";
        this->tunerAllocations[i].sample_rate = (i == 0 or i == 2) ? this->rxtxTuning1.sample_rate : this->rxtxTuning2.sample_rate;
        this->tunerAllocations[i].sample_rate_tolerance = 10;
        this->tunerAllocations[i].tuner_type = (i == 0 or i == 1) ? "RX_DIGITIZER" : "TX";

        // Convert to CF::Properties
        redhawk::PropertyMap allocationProps;

        allocationProps["FRONTEND::tuner_allocation"] <<= this->tunerAllocations[i];

        bool allocationSuccess = false;

        try {
            // This interface allows a persona to request a specific tuner ID based
            // on the knowledge of what's in the PL load
            allocationSuccess = this->extendedFEIDevice->allocateTuner(allocationProps, i);
        } catch(...) {
            LOG_ERROR({{ persona['name'] }}_i, "Failed to allocate parent, sensing will be unavailable");
        }

        allAllocationSuccess &= allocationSuccess;

        if (allocationSuccess and i == 0) {
            firstAllocationSuccess = true;
        } else if (allocationSuccess and i == 1) {
            secondAllocationSuccess = true;
        }
    }

    // Attempt the connection from the first RX channel if successful
    if (firstAllocationSuccess) {
        CF::ConnectionManager_ptr cm = this->getDomainManager()->getRef()->connectionMgr();

        CF::ConnectionManager::EndpointRequest providesRequest, usesRequest;

        providesRequest.endpoint.deviceId(this->_identifier.c_str());
        providesRequest.portName = "dataShort_in";
        usesRequest.endpoint.deviceId(parentFEI->_identifier.c_str());
        usesRequest.portName = "dataShort_out";

        try {
            this->connectionRequestId1 = cm->connect(usesRequest, providesRequest, this->_identifier.c_str(), this->tunerAllocations[0].allocation_id.c_str());
        } catch(...) {
            LOG_ERROR({{ persona['name'] }}_i, "Failed to connect parent do persona");
        }
    }

    // Attempt the connection from the second RX channel if successful
    if (secondAllocationSuccess) {
        CF::ConnectionManager_ptr cm = this->getDomainManager()->getRef()->connectionMgr();

        CF::ConnectionManager::EndpointRequest providesRequest, usesRequest;

        providesRequest.endpoint.deviceId(this->_identifier.c_str());
        providesRequest.portName = "dataShort_in";
        usesRequest.endpoint.deviceId(parentFEI->_identifier.c_str());
        usesRequest.portName = "dataShort_out";

        try {
            this->connectionRequestId2 = cm->connect(usesRequest, providesRequest, this->_identifier.c_str(), this->tunerAllocations[1].allocation_id.c_str());
        } catch(...) {
            LOG_ERROR({{ persona['name'] }}_i, "Failed to connect parent do persona");
        }
    }

    // Get the DigitalTuner_in port, if necessary
    if (CORBA::is_nil(this->digitalTunerPort)) {
        try {
            this->digitalTunerPort = FRONTEND::DigitalTuner::_narrow(this->getParentDevice()->getPort("DigitalTuner_in"));

            if (this->digitalTunerPort->_is_nil()) {
                throw std::exception();
            }
        } catch(...) {
            LOG_ERROR({{ persona['name'] }}_i, "Failed to obtain DigitalTuner_in port");
        }
    }

    // Start the Device
    start();
}

void {{ persona['name'] }}_i::beforeHardwareUnprogrammed()
{
    LOG_TRACE({{ persona['name'] }}_i, __PRETTY_FUNCTION__);

    // Stop the Device
    stop();

    // Disconnect if necessary
    CF::ConnectionManager_ptr cm = this->getDomainManager()->getRef()->connectionMgr();

    try {
        cm->disconnect(this->connectionRequestId1.c_str());
        this->connectionRequestId1.clear();
    } catch(...) {
        LOG_ERROR({{ persona['name'] }}_i, "Failed to disconnect parent from persona");
    }

    try {
        cm->disconnect(this->connectionRequestId2.c_str());
        this->connectionRequestId2.clear();
    } catch(...) {
        LOG_ERROR({{ persona['name'] }}_i, "Failed to disconnect parent from persona");
    }

    // Deallocate
    Device_impl *parentFEI = this->getParentDevice();

    for (size_t i = 0; i < this->tunerAllocations.size(); ++i) {
        redhawk::PropertyMap deallocationProps;

        deallocationProps["FRONTEND::tuner_allocation"] <<= this->tunerAllocations[i];

        try {
            parentFEI->deallocateCapacity(deallocationProps);
        } catch(...) {
            LOG_ERROR({{ persona['name'] }}_i, "Failed to deallocate parent");
        }
    }

    // Clear the tuner allocations
    this->tunerAllocations.clear();

    // Clear the pointers to the registers
    {% for reg in persona['regs'] -%}
    this->{{ reg['name'] }}Ptr = NULL;
    {% endfor %}

    // Unmap the memory
    if (munmap(this->mapBase, 1024) == -1) {
        LOG_ERROR({{ persona['name'] }}_i, "Failed to unmap memory with error: " << strerror(errno));
    }

    close(this->mapFd);

    this->mapBase = NULL;
}

void {{ persona['name'] }}_i::hwLoadRequest(CF::Properties& request)
{
    LOG_TRACE({{ persona['name'] }}_i, __PRETTY_FUNCTION__);

    // Simple example of a single hw_load_request
    request.length(4);
    request[0].id = CORBA::string_dup("hardware_id");
    request[0].value <<= this->HARDWARE_ID;
    request[1].id = CORBA::string_dup("load_filepath");
    request[1].value <<= this->LOAD_FILEPATH;
    request[2].id = CORBA::string_dup("request_id");
    request[2].value <<= ossie::generateUUID();
    request[3].id = CORBA::string_dup("requester_id");
    request[3].value <<= ossie::corba::returnString(identifier());
}

void {{ persona['name'] }}_i::center_frequencyChanged(const double &oldValue, const double &newValue)
{
    LOG_TRACE({{ persona['name'] }}_i, __PRETTY_FUNCTION__);

    if (not this->allocated) {
        LOG_WARN({{ persona['name'] }}_i, "Unable to set center frequency, the persona is not yet loaded");
        this->center_frequency = oldValue;
        return;
    }

    if (not this->digitalTunerPort) {
        LOG_WARN({{ persona['name'] }}_i, "Unable to set center frequency, DigitalTuner_in port not available");
        this->center_frequency = oldValue;
        return;
    }

    for (size_t i = 0; i < this->tunerAllocations.size(); ++i) {
        try {
            this->digitalTunerPort->setTunerCenterFrequency(this->tunerAllocations[i].allocation_id.c_str(), newValue);
            this->center_frequency= this->digitalTunerPort->getTunerCenterFrequency(this->tunerAllocations[i].allocation_id.c_str());
        } catch(...) {
            LOG_WARN({{ persona['name'] }}_i, "Failed to set center frequency on parent for tuner ID " << i);
            this->center_frequency = oldValue;
        }
    }
}

{% for reg in persona['regs'] -%}
{% if reg['writable'] -%}
void {{ persona['name'] }}_i::{{ reg['name'] }}Changed(const {% if reg['length'] > 1 %}std::vector<CORBA::Long>{% else %}CORBA::Long{% endif %} &oldValue, const {% if reg['length'] > 1 %}std::vector<CORBA::Long>{% else %}CORBA::Long{% endif %} &newValue)
{
    LOG_TRACE({{ persona['name'] }}_i, __PRETTY_FUNCTION__);

    if (not this->allocated) {
        LOG_WARN({{ persona['name'] }}_i, "Unable to set register, the persona is not yet loaded");
        this->{{ reg['name'] }} = oldValue;
        return;
    }

    if (not this->{{ reg['name'] }}Ptr) {
        LOG_WARN({{ persona['name'] }}_i, "Unable to set register, the register pointer is NULL");
        this->{{ reg['name'] }} = oldValue;
        return;
    }

    {% if reg['length'] > 1 -%}
    // Write RAM
    std::vector<CORBA::Long> temp = newValue;
    if ({{ reg['length'] }} != temp.size()) {
        LOG_WARN({{ persona['name'] }}_i, "Unable to write to RAM {{ reg['name'] }}, incorrect vector length given. Correct length: {{ reg['length'] }}");
    } else {
        for (uint i = 0; i < {{ reg['length']}}; ++i) {
            *(this->{{ reg['name'] }}Ptr + 4*i) = temp[i];
        }
    }
    {% else -%}
    // Write register
    CORBA::Long temp = newValue;
    *this->{{ reg['name'] }}Ptr = temp;
    boost::this_thread::sleep(boost::posix_time::milliseconds(1));
    if (newValue != *this->{{ reg['name'] }}Ptr) {
        LOG_WARN({{ persona['name'] }}_i, "An error occurred while writing to register {{ reg['name'] }}");
        this->{{ reg['name'] }} = oldValue;
    } else {
        this->{{ reg['name'] }} = temp;
    }
    {% endif %}
}
{% endif -%}
{% endfor %}

void {{ persona['name'] }}_i::rxtxTuning1Changed(const rxtxTuning1_struct &oldValue, const rxtxTuning1_struct &newValue)
{
    LOG_TRACE({{ persona['name'] }}_i, __PRETTY_FUNCTION__);

    if (not this->allocated) {
        LOG_WARN({{ persona['name'] }}_i, "Unable to set RX/TX 1 tuning, the persona is not yet loaded");
        this->rxtxTuning1 = oldValue;
        return;
    }

    if (not this->digitalTunerPort) {
        LOG_WARN({{ persona['name'] }}_i, "Unable to set RX/TX 1 tuning, DigitalTuner_in port not available");
        this->rxtxTuning1 = oldValue;
        return;
    }

    for (size_t i = 0; i < this->tunerAllocations.size(); ++i) {
        if (i == 0 or i == 2) {
            try {
                this->digitalTunerPort->setTunerBandwidth(this->tunerAllocations[i].allocation_id.c_str(), newValue.bandwidth);
                this->rxtxTuning1.bandwidth = this->digitalTunerPort->getTunerBandwidth(this->tunerAllocations[i].allocation_id.c_str());
            } catch(...) {
                LOG_WARN({{ persona['name'] }}_i, "Failed to set bandwidth on parent for tuner ID " << i);
                this->rxtxTuning1.bandwidth = oldValue.bandwidth;
            }

            try {
                this->digitalTunerPort->setTunerOutputSampleRate(this->tunerAllocations[i].allocation_id.c_str(), newValue.sample_rate);
                this->rxtxTuning1.sample_rate = this->digitalTunerPort->getTunerOutputSampleRate(this->tunerAllocations[i].allocation_id.c_str());
            } catch(...) {
                LOG_WARN({{ persona['name'] }}_i, "Failed to set sample rate on parent for tuner ID " << i);
                this->rxtxTuning1.sample_rate = oldValue.sample_rate;
            }
        }
    }
}

void {{ persona['name'] }}_i::rxtxTuning2Changed(const rxtxTuning2_struct &oldValue, const rxtxTuning2_struct &newValue)
{
    LOG_TRACE({{ persona['name'] }}_i, __PRETTY_FUNCTION__);

    if (not this->allocated) {
        LOG_WARN({{ persona['name'] }}_i, "Unable to set RX/TX 2 tuning, the persona is not yet loaded");
        this->rxtxTuning2 = oldValue;
        return;
    }

    if (not this->digitalTunerPort) {
        LOG_WARN({{ persona['name'] }}_i, "Unable to set RX/TX 2 tuning, DigitalTuner_in port not available");
        this->rxtxTuning2 = oldValue;
        return;
    }

    for (size_t i = 0; i < this->tunerAllocations.size(); ++i) {
        if (i == 1 or i == 4) {
            try {
                this->digitalTunerPort->setTunerBandwidth(this->tunerAllocations[i].allocation_id.c_str(), newValue.bandwidth);
                this->rxtxTuning2.bandwidth = this->digitalTunerPort->getTunerBandwidth(this->tunerAllocations[i].allocation_id.c_str());
            } catch(...) {
                LOG_WARN({{ persona['name'] }}_i, "Failed to set bandwidth on parent for tuner ID " << i);
                this->rxtxTuning2.bandwidth = oldValue.bandwidth;
            }

            try {
                this->digitalTunerPort->setTunerOutputSampleRate(this->tunerAllocations[i].allocation_id.c_str(), newValue.sample_rate);
                this->rxtxTuning2.sample_rate = this->digitalTunerPort->getTunerOutputSampleRate(this->tunerAllocations[i].allocation_id.c_str());
            } catch(...) {
                LOG_WARN({{ persona['name'] }}_i, "Failed to set sample rate on parent for tuner ID " << i);
                this->rxtxTuning2.sample_rate = oldValue.sample_rate;
            }
        }
    }
}
