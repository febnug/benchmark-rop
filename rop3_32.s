    .section .data
start_time:  .long 0
end_time:    .long 0

    .section .text
    .global _start

_start:
    # Simpan waktu awal
    rdtsc
    mov %eax, start_time

    # Inisialisasi loop counter
    mov $1000000, %ecx  # Ulangi eksekusi 1 juta kali

benchmark_loop:
    # Simulasi gadget ROP (pop; ret)
    pop %eax
    ret

    loop benchmark_loop

    # Simpan waktu akhir
    rdtsc
    mov %eax, end_time

    # Hitung selisih waktu (end_time - start_time)
    mov end_time, %eax
    sub start_time, %eax

    # Exit syscall (keluar program dengan kode 0)
    mov $1, %eax       # syscall: exit
    xor %ebx, %ebx     # status: 0
    int $0x80

