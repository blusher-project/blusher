#ifndef BLUSHER_CSDBUS_H
#define BLUSHER_CSDBUS_H

#include <stddef.h>

#include <systemd/sd-bus.h>

typedef struct bl_sd_bus_entry_t bl_sd_bus_entry_t;

typedef struct bl_sd_bus_arg_t bl_sd_bus_arg_t;

struct bl_sd_bus_arg_t {
    const char *name;
    const char *signature;
};

/// Min: 2 for start/end.
bl_sd_bus_entry_t* bl_sd_bus_entry_new(size_t length);

void bl_sd_bus_entry_start(bl_sd_bus_entry_t *entry);

void bl_sd_bus_entry_end(bl_sd_bus_entry_t *entry);

void bl_sd_bus_entry_append_method(bl_sd_bus_entry_t *entry,
                                   const char *name,
                                   size_t argc,
                                   bl_sd_bus_arg_t *argv[]);

#endif
