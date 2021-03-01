section .data
    delim db " ", 0
    sign DD 0

section .bss
    root resd 1

section .text
extern check_atoi
extern malloc
extern strdup
extern strtok
extern print_tree_inorder
extern print_tree_preorder
extern evaluate_tree

global create_tree
global iocla_atoi

iocla_atoi:
	push ebp
    mov ebp, esp
    push edx
	push ebx
	push ecx
	push edi
	push esi

	; se retine sirul primit de pe stiva
	mov edx, [ebp + 8]
	; in eax se va retine numarul construit
	xor eax, eax
	; indica daca numarul este negativ sau pozitiv
	mov [sign], dword 0
	; indica pozitia actuala in sir
	mov ecx, 0

	; daca nu s-a ajuns la finalul sirului
	; se retine cate un caracter
	; daca nu reprezinta o cifra se termina algoritmul
	; daca este cifra se va continua construirea noului numar
loop:
	cmp edx, 0
	je end
	xor ebx, ebx
	inc ecx

	mov bl, byte[edx + ecx - 1]
	cmp ebx, '-'
	; daca primul caracter este - indica un numar negativ
	je minus
	cmp ebx, '\0'
	je end
	cmp ebx, 48
	jl end
	cmp ebx, 57
	jg end

number:
	push ecx;
	push edx

	; se transforma caracterul in cifra
	sub ebx, '0'
	mov ecx, ebx

	; se inmulteste cu 10 numarul format anterior
	mov ebx, 10
	mul ebx

	; se aduna noua cifra la numarul anterior
	add eax, ecx
	pop ecx
	pop edx

	; se va citi urmatoarea cifra
	jmp loop

	; se seteaza variabila care indica semnul numarului
	; se continua parcurgerea sirului
minus:
    mov [sign], dword -1
    jmp loop

    ; ajuns la finalul sirului daca este numar pozitiv
    ; se opreste functia
end:
    cmp [sign], dword -1
    jne finish

    ; daca este numar negativ se inmulteste la final cu -1
negative: 
    mov ebx, -1
    mul ebx

    ; se restaureaza stiva
finish:
	pop edi
	pop esi
	pop ecx
	pop ebx
	pop edx
	leave
    ret


create_tree:
	push ebp
	mov ebp, esp
	push edx
	push ebx
	push ecx
	push edi
	push esi

	; se retine sirul primit pe stiva
	mov edx, [ebp + 8]
	push edx

	; se aloca memorie pentru primul nod
	push 12
	call malloc
	add esp, 4
	mov ebx, eax
	
	; se retine primul caracter din expresie utilizand strtok
	pop edx
	push ebx
	push delim
	push edx
	call strtok
	add esp,8
	mov edi, eax

	; se aloca memorie si este retinut caracterul in nodul radacina
	push edi
	call strdup
	add esp, 4
	pop ebx
	mov [ebx], eax

	; se salveaza un pointer catre nodul radacina in variabila root
	; registrele eax si ebx
	mov [root], ebx
	mov eax, [root]

	; se apeleaza functia care va construi arborele in mod recursiv
	push ebx
	push eax
	call build_tree
	add esp, 4
	pop ebx

	; se retine in registrul eax pointer-ul catre nodul radacina
    mov eax, [root]

    ; se restaureaza stiva
	pop edi
	pop esi
	pop ecx
	pop ebx
	pop edx
	mov esp, ebp
	pop ebp
	enter 0,0
    leave
    ret

build_tree:
	push ebp
	mov ebp, esp
	push edx
	push ebx
	push ecx
	push edi
	push esi

	; se retine pointer-ul la nodul actual
	mov ebx, [ebp + 8]

	; daca nu are memorie alocata iese din functie
	cmp ebx, dword 0
	je end_tree

	; daca nu exista un caracter retinut in nod
	; se va aloca memorie si se retine urmatorul caracter
	cmp [ebx], dword 0
	jne check_recursion

	push ebx
	push delim
	xor edx, edx
	push edx
	call strtok
	add esp,8
	mov edi, eax

	push edi
	call strdup
	add esp, 4

	pop ebx
	mov [ebx], eax

check_recursion:
	mov edi, ebx
	mov edi, [edi]

	; daca este un operator se va apela recursiv functia
	; pentru subarborele stang si drept
	cmp dword[edi] , '+'
	je recursion
	cmp dword[edi] , '-'
	je recursion
	cmp dword[edi] , '/'
	je recursion
	cmp dword[edi] , '*'
	je recursion

	; daca este un operand s-a ajuns la finalul functiei
	jmp end_tree

recursion:	
	; se aloca memorie pentru fii stang si drept ai nodului curent
	push ebx
	push 12
	call malloc
	add esp, 4
	pop ebx
	mov [ebx + 4], eax

	push ebx
	push 12
	call malloc
	add esp, 4
	pop ebx
	mov [ebx + 8], eax

	; recursivitate subarbore stang
left:
	push ebx
	push dword[ebx + 4]
	call build_tree
	add esp, 4
	pop ebx

	; recursivitate subarbore drept
right:
	push ebx
	push dword[ebx + 8]
	call build_tree
	add esp, 4
	pop ebx

	
end_tree:
	mov eax, ebx
	; se restaureaza stiva
    pop esi
	pop edi
	pop ecx
	pop ebx
	pop edx
    leave
    ret
