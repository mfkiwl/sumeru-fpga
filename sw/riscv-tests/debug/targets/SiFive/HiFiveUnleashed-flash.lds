OUTPUT_ARCH( "riscv" )

SECTIONS
{
  . = 0x20000000;
  .text :
  {
    *(.text.entry)
    *(.text)
  }
  _text_end = .;

  . = 0x80000000;
  /* data segment */
  .data : { *(.data) }

  .sdata : {
    __global_pointer$ = . + 0x800;
    *(.srodata.cst16) *(.srodata.cst8) *(.srodata.cst4) *(.srodata.cst2)
    *(.srodata*)
    *(.sdata .sdata.* .gnu.linkonce.s.*)
  }

  /* bss segment */
  __bss_start = .;
  .sbss : {
    *(.sbss .sbss.* .gnu.linkonce.sb.*)
    *(.scommon)
  }
  .bss : { *(.bss) }
  __bss_end = .;

  __malloc_start = .;
  . = . + 512;

  /* End of uninitalized data segement */
  _end = .;
}

ASSERT(_text_end < 0x20100000, "program is too large")
ASSERT(_end < 0x80100000, "program is too large")
