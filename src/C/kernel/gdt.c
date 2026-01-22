#include "../include/gdt.h"

static gdt_entry_t gdt_ent[3];
static gdt_ptr_t gdt_ptr;

extern void gdt_flush(uint32_t gdt_addr);

static void gdt_set_gate(size_t num, uint32_t base, uint32_t limit, uint8_t access, uint8_t gran) {
    gdt_ent[num].base_low = (uint16_t)base; 
    gdt_ent[num].base_middle = (uint8_t)(base >> 16);
    gdt_ent[num].base_high = (uint8_t)(base >> 24);

    gdt_ent[num].access = access;
    gdt_ent[num].granularity = (uint8_t)((gran & 0xF0) | ((limit >> 16) & 0xF));

    gdt_ent[num].limit_low = (uint16_t)limit;
}

void init_gdt(void) {
    gdt_set_gate(0, 0, 0, 0, 0);
    gdt_set_gate(1, 0, 0xFFFFFFFF, 0x9A, 0xCF);
    gdt_set_gate(2, 0, 0xFFFFFFFF, 0x92, 0xCF);

    gdt_ptr.limit = (sizeof(gdt_entry_t) * 3) - 1;
    gdt_ptr.base = (uint32_t)&gdt_ent;

    gdt_flush((uint32_t)&gdt_ptr);
}