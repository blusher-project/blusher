#include "CSdBus.h"

#include <stddef.h>
#include <stdlib.h>

struct bl_sd_bus_entry_t {
    size_t capacity;
    size_t cur;
    sd_bus_vtable *vtables;
};

bl_sd_bus_entry_t* bl_sd_bus_entry_new(size_t length)
{
    bl_sd_bus_entry_t *entry = malloc(sizeof(bl_sd_bus_entry_t));
    entry->capacity = length;
    entry->cur = 0;

    entry->vtables = malloc(sizeof(sd_bus_vtable) * length);

    return entry;
}

void bl_sd_bus_entry_start(bl_sd_bus_entry_t *entry)
{
    entry->vtables[entry->cur++] = SD_BUS_VTABLE_START();
}

void bl_sd_bus_entry_end(bl_sd_bus_entry_t *entry)
{
    entry->vtables[entry->cur++] = SD_BUS_VTABLE_END();
}

void bl_sd_bus_entry_append_method(bl_sd_bus_entry_t *entry,
                                   const char *name,
                                   size_t argc,
                                   bl_sd_bus_arg_t *argv[])
{
    entry->vtables[entry->cur++] = SD_BUS_METHOD_WITH_ARGS(
        name,
        SD_BUS_ARGS()
    );
}
