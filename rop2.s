    .section .data
start_time:  .quad 0
end_time:    .quad 0
diff_time:   .quad 0
output_msg:  .asciz "Execution time (cycles): %ld\n"

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
    mov %rax, diff_time(%rip)

    # Siapkan hasil untuk dicetak
    mov diff_time(%rip), %rsi        # Argumen ke-2: nilai diff_time
    lea output_msg(%rip), %rdi       # Argumen ke-1: format string
    xor %rax, %rax                   # Bersihkan %rax untuk syscall
    call print_result                # Panggil fungsi print_result

    # Exit syscall (keluar program dengan kode 0)
    mov $60, %rax       # syscall: exit
    xor %rdi, %rdi      # status: 0
    syscall

print_result:
    # Panggil syscall write untuk mencetak string
    mov $1, %rax        # syscall: write
    mov $1, %rdi        # file descriptor: stdout
    lea output_msg(%rip), %rsi  # buffer pointer
    mov $50, %rdx       # panjang pesan maksimal
    syscall
    ret

