# Andre-32

Processador de 32 bits desenvolvido em Verilog para FPGA usando o Quartus
Prime Lite 17.1.

## Conteúdo

- Módulos Verilog do processador e periféricos
- Projeto Quartus (`Andre-32.qpf` e `Andre-32.qsf`)
- Programas de exemplo e instruções em código de máquina
- Configuração de síntese com `processador_final` como entidade principal

## Módulos principais

- `processador_final.v`: integração principal do processador
- `processador.v`, `processador_fase1.v` e `processador_fase2.v`: versões e fases
- `unidade_de_controle.v`: unidade de controle
- `ULA.v`: unidade lógica e aritmética
- `banco.v`: banco de registradores
- `Imem.v` e `Dmem.v`: memórias de instruções e dados
- `gerenciador_pilha.v`: gerenciamento da pilha
- `porta_entrada.v` e `porta_saida.v`: interfaces de entrada e saída

## Abrir no Quartus

1. Instale o Intel Quartus Prime Lite 17.1.
2. Abra `Andre-32.qpf`.
3. Compile o projeto com `processador_final` como entidade principal.

O repositório contém somente os fontes e arquivos de projeto importantes.
Arquivos gerados pelo Quartus, arquivos de simulação e testbenches ficam fora
do repositório.

## Programas de exemplo

`Assembly_Programas.txt` documenta exemplos em assembly, incluindo Fibonacci e
fatorial recursivo. `programa.txt` e `programa1.txt` contêm instruções
codificadas em binário para carregar nas memórias do processador.
