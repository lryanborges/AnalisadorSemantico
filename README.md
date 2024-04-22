Segue o passo a passo pra executar o Analisador Sintático em C:

<h2>Para instalação:</h2>

 - Deve ser executado dentro de um sistema Unix
 - No terminal:
  1. sudo apt update
  2. sudo apt upgrade
  3. sudo apt install g++ gdb
  4. sudo apt install make cmake
  5. sudo apt install flex libfl-dev
  6. sudo apt install bison libbison-dev

<h2>Para execução:</h2>

 - Abrir o projeto no VSCode
 - Executar os comandos:
  1. flex  analisadorLex.l
  2. bison -d analisadorSint.y
  3. g++ lex.yy.c  analisadorSint.tab.c  -std=c++17 -o analisador
  4. ./analisador moreTest.txt

Detalhes:
 - No passo 2 da execução, o -d é para conseguir gerar o arquivo.h do analisadorSint, que o analisadorLex utiliza pra conhecimento dos tokens/enum.
 - No passo 4 da execução, temos as opções de ler os arquivos:
   1. sintTest.txt
   2. finalTest.txt
   3. newTest.txt
   4. moreTest.txt
   5. errorTest.txt
 - O arquivo errorTest.txt possui erros intencionais, para demonstração.
 - O arquivo moreTest.txt é o que mais possui classes, sendo o verdadeiro arquivo de "teste final".
