    .section .data
start_time:  .quad 0
end_time:    .quad 0

    .section .text
    .global _start

_start:
    # Simpan waktu awal
    rdtsc
    shl $32, %rdx
    or %rdx, %rax
    mov %rax, start_time(%rip)

    # Inisialisasi loop counter
    mov $1000000, %ecx  # Ulangi eksekusi 1 juta kali

benchmark_loop:
    # Simulasi gadget ROP (pop; ret)
    pop %rax
    ret

    loop benchmark_loop

    # Simpan waktu akhir
    rdtsc
    shl $32, %rdx
    or %rdx, %rax
    mov %rax, end_time(%rip)

    # Hitung selisih waktu (end_time - start_time)
    mov end_time(%rip), %rax
    sub start_time(%rip), %rax

    # Exit syscall (keluar program dengan kode 0)
    mov $60, %rax       # syscall: exit
    xor %rdi, %rdi      # status: 0
    syscall

