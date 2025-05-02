ENTRY(kmain)                /* Ensures your entry point (_start) is kept */
OUTPUT_FORMAT(binary)        /* Raw binary output (no ELF/PE/etc.) */

SECTIONS {
    . = 0x100000;            /* Load at 1MB (standard for kernels) */

    /* Code section (all executable code) */
    .text : {
        *(.text .text.*)     /* ASM + C code */
    }

    /* Read-only data (if referenced, must be included) */
    .rodata : {
        *(.rodata .rodata.*) /* Constants, strings, etc. */
    }

    /* Initialized data (global/static variables with values) */
    .data : {
        *(.data .data.*)
    }

    /* Zero-initialized data (BSS) - MUST be present for C */
    .bss : {
        *(.bss .bss.*)
        *(COMMON)            /* Uninitialized globals */
    }

    /* Explicitly discard EVERYTHING else (debug, comments, etc.) */
    /DISCARD/ : {
        *(*)
    }
}
