Olá, aqui está meu estudo sobre como automatizar linha de comando de programas como:
* cmd.exe (MS-DOS)
* plink.exe
* sqlplus.exe

Outros programas também podem funcionar.

A intenção é perceber por onde flui as mensagens normais e as mensagens de erro e como capturá-las.

MS-DOS
A saída normal é capturada por 'StdoutRead', na variável $normal.
A saída de erro é capturada por 'StderrRead', na variável $error.
Diante dessa perspectiva, parece bastante simples perceber se um comando (automatizado) foi executado com sucesso ou não.

Resta saber se no restante da lista o comportamento é o mesmo.

(AINDA EM DESENVOLVIMENTO)

Não sei tudo, se você conhece algum detalhe a mais que não foi mencionado aqui, por favor, compartilhe.
