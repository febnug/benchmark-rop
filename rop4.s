    .section .data
start_time:  .long 0
end_time:    .long 0
output_msg:  .asciz "Execution time (cycles): "
newline:     .asciz "\\n"
buffer:      .space 12  # Buffer untuk menyimpan angka sebagai string

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

    # Konversi hasil ke string
    mov %eax, %ebx          # Pindahkan hasil ke %ebx
    lea buffer, %edi        # Buffer untuk hasil string
    call int_to_string      # Panggil konversi angka ke string

    # Cetak pesan ke stdout
    mov $4, %eax            # syscall: write
    mov $1, %ebx            # file descriptor: stdout
    lea output_msg, %ecx    # Pesan output
    mov $23, %edx           # Panjang pesan
    int $0x80

    # Cetak hasil (angka dalam buffer)
    mov $4, %eax            # syscall: write
    mov $1, %ebx            # file descriptor: stdout
    lea buffer, %ecx        # Hasil buffer
    mov $12, %edx           # Panjang buffer
    int $0x80

    # Cetak newline
    mov $4, %eax            # syscall: write
    mov $1, %ebx            # file descriptor: stdout
    lea newline, %ecx       # Newline string
    mov $1, %edx            # Panjang newline
    int $0x80

    # Exit syscall (keluar program dengan kode 0)
    mov $1, %eax            # syscall: exit
    xor %ebx, %ebx          # status: 0
    int $0x80

# Konversi integer ke string (desimal, null-terminated)
int_to_string:
    xor %ecx, %ecx          # Clear ECX (index counter)
    mov $10, %edi           # Divisor (10 untuk desimal)
convert_loop:
    xor %edx, %edx          # Clear EDX
    div %edi                # EAX /= 10, sisa ada di EDX
    add $'0', %dl           # Konversi ke karakter ASCII
    mov %dl, -1(%esi,%ecx)  # Simpan karakter ke buffer
    inc %ecx                # Increment index
    test %eax, %eax         # Apakah EAX == 0?
    jnz convert_loop        # Jika belum, ulangi

    # Balikkan string di buffer
    lea buffer, %edi        # Awal buffer
    sub %ecx, %edi          # Offset untuk menulis awal string
    mov %ecx, %eax          # Panjang string
reverse_loop:
    cmp %ecx, %eax          # Jika index == panjang, selesai
    je reverse_done
    mov -1(%esi,%eax), %dl  # Karakter awal
    mov (%esi,%edi), %dh    # Karakter akhir
    mov %dh, -1(%esi,%eax)  # Tukar
    mov %dl, (%esi,%edi)    # Tukar
    dec %eax                # Kurangi panjang
    inc %edi                # Naikkan indeks
    jmp reverse_loop
reverse_done:
    ret

