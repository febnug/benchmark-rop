    .section .data
start_time:  .long 0
end_time:    .long 0
stack_space: .space 1024  # Alokasi ruang stack sebesar 1KB

    .section .text
    .global _start

_start:
    # Inisialisasi stack pointer
    lea stack_space+1024, %esp  # Setel ESP ke akhir ruang stack

    # Simpan waktu awal
    rdtsc
    mov %eax, start_time

    # Inisialisasi loop counter
    mov $1000000, %ecx  # Ulangi eksekusi 1 juta kali

benchmark_loop:
    # Simulasi gadget ROP (push; ret)
    push $0xDEADBEEF     # Push nilai dummy ke stack
    pop %eax             # Pop nilai dari stack ke EAX
    ret                  # Return (ambil alamat dari stack)

    loop benchmark_loop

    # Simpan waktu akhir
    rdtsc
    mov %eax, end_time

    # Hitung selisih waktu (end_time - start_time)
    mov end_time, %eax
    sub start_time, %eax

    # Exit syscall (keluar program dengan kode 0)
    mov $1, %eax         # syscall: exit
    xor %ebx, %ebx       # status: 0
    int $0x80

