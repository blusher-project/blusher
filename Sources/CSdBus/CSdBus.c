#include "CSdBus.h"

bl_sd_bus_desc_t bl_sd_bus_desc_start()
{
    return SD_BUS_VTABLE_START(0);
}

bl_sd_bus_desc_t bl_sd_bus_desc_end()
{
    return SD_BUS_VTABLE_END();
}
