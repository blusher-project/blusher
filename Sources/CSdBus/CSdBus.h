#ifndef BLUSHER_CSDBUS_H
#define BLUSHER_CSDBUS_H

#include <systemd/sd-bus.h>

typedef sd_bus_vtable bl_sd_bus_desc_t;

bl_sd_bus_desc_t bl_sd_bus_desc_start();

bl_sd_bus_desc_t bl_sd_bus_desc_end();

#endif
