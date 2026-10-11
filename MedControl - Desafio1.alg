algoritmo "MedControl"
// ============================================================================
// MEDCONTROL - Sistema de Gerenciamento de Atendimentos de uma Clinica Medica
// Desafio 1 - Logica de Programacao - Tema 2
//
// ESTRUTURAS DE DADOS
//  - REGISTRO TPaciente: agrupa todos os dados de um paciente.
//  - VETOR DE REGISTROS pacientes[1..30]: todos os cadastrados (ordem de chegada).
//  - VETOR DE REGISTROS fila[1..30]: copia ORDENADA dos que aguardam atendimento.
//  - MATRIZ estat[prioridade, coluna]:
//       linhas  = 4 niveis de prioridade (1 a 4)
//       colunas = 1-Cadastrados, 2-Aguardando, 3-Atendidos
//       Atualizada no cadastro (cadastrados+1, aguardando+1) e no
//       atendimento (aguardando-1, atendidos+1).
//
// CONSTANTES: variaveis em MAIUSCULAS preenchidas uma unica vez em
//  inicializarSistema e nunca alteradas depois.
//
// ESCOPO: globais apenas as constantes, os vetores, a matriz e o estado do menu
//  (o VisuAlg nao aceita vetor como parametro). Codigos, posicoes e quantidade
//  de pacientes sao passados por parametro; contadores e auxiliares sao locais.
// ============================================================================
tipo
   TPaciente = registro
      codigo: inteiro
      nome: caractere
      idade: inteiro
      sexo: caractere
      prioridade: inteiro
      sistolica: inteiro
      diastolica: inteiro
      temperatura: real
      status: inteiro
      ordemCadastro: inteiro
   fimregistro

var
   // ---------- "constantes" ----------
   MAX_PACIENTES: inteiro       // deve ser igual ao tamanho dos vetores (30)
   EMERGENCIA: inteiro
   MUITO_URGENTE: inteiro
   URGENTE: inteiro
   POUCO_URGENTE: inteiro
   AGUARDANDO: inteiro
   ATENDIDO: inteiro
   NAO_ENCONTRADO: inteiro      // retorno das buscas quando nada e encontrado
   COD_MAX: inteiro
   IDADE_MAXIMA: inteiro
   PA_SIST_MIN: inteiro
   PA_SIST_MAX: inteiro
   PA_DIAST_MIN: inteiro
   PA_DIAST_MAX: inteiro
   TEMP_MIN: real
   TEMP_MAX: real
   COL_CADASTRADOS: inteiro     // colunas da matriz de estatisticas
   COL_AGUARDANDO: inteiro
   COL_ATENDIDOS: inteiro

   // ---------- vetores de registros e matriz ----------
   pacientes: vetor[1..30] de TPaciente
   fila: vetor[1..30] de TPaciente
   estat: vetor[1..4,1..3] de inteiro

   // ---------- estado geral ----------
   qtdPacientes: inteiro
   opcao: inteiro

// ============================================================================
// INICIALIZACAO
// ============================================================================

procedimento inicializarSistema
var
   i, j: inteiro
inicio
   MAX_PACIENTES <- 30
   EMERGENCIA <- 1
   MUITO_URGENTE <- 2
   URGENTE <- 3
   POUCO_URGENTE <- 4
   AGUARDANDO <- 0
   ATENDIDO <- 1
   NAO_ENCONTRADO <- 0
   COD_MAX <- 99999
   IDADE_MAXIMA <- 120
   PA_SIST_MIN <- 50
   PA_SIST_MAX <- 300
   PA_DIAST_MIN <- 30
   PA_DIAST_MAX <- 200
   TEMP_MIN <- 30
   TEMP_MAX <- 45
   COL_CADASTRADOS <- 1
   COL_AGUARDANDO <- 2
   COL_ATENDIDOS <- 3
   qtdPacientes <- 0
   // zera a matriz de estatisticas (repeticao aninhada)
   para i de EMERGENCIA ate POUCO_URGENTE faca
      para j de COL_CADASTRADOS ate COL_ATENDIDOS faca
         estat[i, j] <- 0
      fimpara
   fimpara
fimprocedimento

// ============================================================================
// ENTRADA E VALIDACAO
// ============================================================================

// Escreve o texto e completa com espacos ate a largura informada
procedimento escreverPad(texto: caractere; largura: inteiro)
var
   i: inteiro
inicio
   escreva(texto)
   para i de compr(texto) + 1 ate largura faca
      escreva(" ")
   fimpara
fimprocedimento

// Le um numero INTEIRO como texto e so aceita se for realmente numerico
// (aceita sinal "-"). Evita erro de execucao do VisuAlg com letras.
funcao lerInteiro(mensagem: caractere): inteiro
var
   texto: caractere
   i, inicioDigitos, valor: inteiro
   valido, negativo: logico
inicio
   repita
      escreva(mensagem)
      leia(texto)
      valido <- verdadeiro
      negativo <- falso
      inicioDigitos <- 1
      se compr(texto) = 0 entao
         valido <- falso
      senao
         se copia(texto, 1, 1) = "-" entao
            negativo <- verdadeiro
            inicioDigitos <- 2
         fimse
         // so o sinal, ou texto longo demais
         se (compr(texto) < inicioDigitos) ou (compr(texto) > 9) entao
            valido <- falso
         fimse
         i <- inicioDigitos
         enquanto (i <= compr(texto)) e valido faca
            se (asc(copia(texto, i, 1)) < 48) ou (asc(copia(texto, i, 1)) > 57) entao
               valido <- falso
            fimse
            i <- i + 1
         fimenquanto
      fimse
      se nao valido entao
         escreval("Entrada invalida! Digite apenas numeros inteiros.")
      fimse
   ate valido
   // converte o texto validado em numero (acumulador)
   valor <- 0
   para i de inicioDigitos ate compr(texto) faca
      valor <- valor * 10 + (asc(copia(texto, i, 1)) - 48)
   fimpara
   se negativo entao
      valor <- -valor
   fimse
   retorne valor
fimfuncao

// Le um numero REAL (aceita ponto ou virgula) validando os caracteres
funcao lerReal(mensagem: caractere): real
var
   texto, ch: caractere
   i, qtdSeparadores, qtdDigitos: inteiro
   valido, passouSeparador: logico
   resultado, divisor: real
inicio
   repita
      escreva(mensagem)
      leia(texto)
      valido <- verdadeiro
      qtdSeparadores <- 0
      qtdDigitos <- 0
      se compr(texto) = 0 entao
         valido <- falso
      senao
         para i de 1 ate compr(texto) faca
            ch <- copia(texto, i, 1)
            se (asc(ch) >= 48) e (asc(ch) <= 57) entao
               qtdDigitos <- qtdDigitos + 1
            senao
               se (ch = ".") ou (ch = ",") entao
                  qtdSeparadores <- qtdSeparadores + 1
               senao
                  valido <- falso
               fimse
            fimse
         fimpara
         se (qtdSeparadores > 1) ou (qtdDigitos = 0) ou (compr(texto) > 8) entao
            valido <- falso
         fimse
      fimse
      se nao valido entao
         escreval("Entrada invalida! Digite um numero (ex.: 36.5).")
      fimse
   ate valido
   // converte o texto validado em numero real
   resultado <- 0
   divisor <- 1
   passouSeparador <- falso
   para i de 1 ate compr(texto) faca
      ch <- copia(texto, i, 1)
      se (ch = ".") ou (ch = ",") entao
         passouSeparador <- verdadeiro
      senao
         se passouSeparador entao
            divisor <- divisor * 10
            resultado <- resultado + (asc(ch) - 48) / divisor
         senao
            resultado <- resultado * 10 + (asc(ch) - 48)
         fimse
      fimse
   fimpara
   retorne resultado
fimfuncao

// Le um inteiro dentro de [limInf, limSup], repetindo ate ser valido
funcao lerInteiroEmFaixa(mensagem: caractere; limInf: inteiro; limSup: inteiro): inteiro
var
   entrada: inteiro
inicio
   repita
      escreva(mensagem, " [", limInf, " a ", limSup, "]")
      entrada <- lerInteiro(": ")
      se (entrada < limInf) ou (entrada > limSup) entao
         escreval("ERRO: valor fora do intervalo permitido!")
      fimse
   ate (entrada >= limInf) e (entrada <= limSup)
   retorne entrada
fimfuncao

// Le um real dentro de [limInf, limSup], repetindo ate ser valido
funcao lerRealEmFaixa(mensagem: caractere; limInf: real; limSup: real): real
var
   entrada: real
inicio
   repita
      escreva(mensagem, " [", limInf:4:1, " a ", limSup:4:1, "]")
      entrada <- lerReal(": ")
      se (entrada < limInf) ou (entrada > limSup) entao
         escreval("ERRO: valor fora do intervalo permitido!")
      fimse
   ate (entrada >= limInf) e (entrada <= limSup)
   retorne entrada
fimfuncao

// Le o sexo: aceita apenas M ou F (maiuscula ou minuscula)
funcao lerSexo(mensagem: caractere): caractere
var
   entrada: caractere
inicio
   repita
      escreva(mensagem)
      leia(entrada)
      entrada <- maiusc(entrada)
      se (entrada <> "M") e (entrada <> "F") entao
         escreval("ERRO: sexo invalido! Digite M ou F.")
      fimse
   ate (entrada = "M") ou (entrada = "F")
   retorne entrada
fimfuncao

// Um texto e valido se tiver ao menos um caractere diferente de espaco
funcao nomeValido(texto: caractere): logico
var
   i: inteiro
   achouLetra: logico
inicio
   achouLetra <- falso
   para i de 1 ate compr(texto) faca
      se copia(texto, i, 1) <> " " entao
         achouLetra <- verdadeiro
      fimse
   fimpara
   retorne achouLetra
fimfuncao

// Converte o codigo de prioridade em texto
funcao nomePrioridade(prio: inteiro): caractere
var
   texto: caractere
inicio
   se prio = EMERGENCIA entao
      texto <- "Emergencia"
   senao
      se prio = MUITO_URGENTE entao
         texto <- "Muito urgente"
      senao
         se prio = URGENTE entao
            texto <- "Urgente"
         senao
            texto <- "Pouco urgente"
         fimse
      fimse
   fimse
   retorne texto
fimfuncao

funcao nomeStatus(situacao: inteiro): caractere
var
   texto: caractere
inicio
   se situacao = AGUARDANDO entao
      texto <- "Aguardando atendimento"
   senao
      texto <- "Atendido"
   fimse
   retorne texto
fimfuncao

funcao calcularMedia(soma: real; quantidade: inteiro): real
var
   media: real
inicio
   se quantidade > 0 entao
      media <- soma / quantidade
   senao
      media <- 0
   fimse
   retorne media
fimfuncao

// ============================================================================
// BUSCAS E CONTAGENS
// ============================================================================

// Busca ITERATIVA: devolve a posicao do paciente ou NAO_ENCONTRADO
funcao localizarPaciente(codBusca: inteiro; qtd: inteiro): inteiro
var
   i, achado: inteiro
inicio
   achado <- NAO_ENCONTRADO
   i <- 1
   enquanto (i <= qtd) e (achado = NAO_ENCONTRADO) faca
      se pacientes[i].codigo = codBusca entao
         achado <- i
      fimse
      i <- i + 1
   fimenquanto
   retorne achado
fimfuncao

// Busca RECURSIVA
// CASO-BASE 1: posicao > qtd  -> todas as posicoes foram verificadas
// CASO-BASE 2: codigo igual   -> paciente encontrado
// PASSO RECURSIVO: buscaRecursiva(codBusca, posicao + 1, qtd)
funcao buscaRecursiva(codBusca: inteiro; posicao: inteiro; qtd: inteiro): inteiro
var
   achado: inteiro
inicio
   escreval("   [chamada] verificando posicao ", posicao)
   se posicao > qtd entao
      achado <- NAO_ENCONTRADO
   senao
      se pacientes[posicao].codigo = codBusca entao
         achado <- posicao
      senao
         achado <- buscaRecursiva(codBusca, posicao + 1, qtd)
      fimse
   fimse
   retorne achado
fimfuncao

// Contagem ITERATIVA de pacientes aguardando
funcao contarAguardando(qtd: inteiro): inteiro
var
   i, contador: inteiro
inicio
   contador <- 0
   para i de 1 ate qtd faca
      se pacientes[i].status = AGUARDANDO entao
         contador <- contador + 1
      fimse
   fimpara
   retorne contador
fimfuncao

// Contagem RECURSIVA de pacientes aguardando
// CASO-BASE: posicao > qtd -> 0
// PASSO RECURSIVO: (1 ou 0 da posicao atual) + contarAguardandoRec(posicao + 1, qtd)
funcao contarAguardandoRec(posicao: inteiro; qtd: inteiro): inteiro
var
   parcial: inteiro
inicio
   se posicao > qtd entao
      parcial <- 0
   senao
      se pacientes[posicao].status = AGUARDANDO entao
         parcial <- 1 + contarAguardandoRec(posicao + 1, qtd)
      senao
         parcial <- contarAguardandoRec(posicao + 1, qtd)
      fimse
   fimse
   retorne parcial
fimfuncao

// Le um codigo NOVO: repete enquanto for invalido ou duplicado
funcao lerCodigoNovo(qtd: inteiro): inteiro
var
   codigoLido: inteiro
   aceito: logico
inicio
   aceito <- falso
   repita
      codigoLido <- lerInteiroEmFaixa("Codigo do paciente", 1, COD_MAX)
      se localizarPaciente(codigoLido, qtd) <> NAO_ENCONTRADO entao
         escreval("ERRO: codigo ja cadastrado! Informe outro codigo.")
      senao
         aceito <- verdadeiro
      fimse
   ate aceito
   retorne codigoLido
fimfuncao

// ============================================================================
// CADASTRO, LISTAGEM E CONSULTA
// ============================================================================

// 'qtd' e passado POR REFERENCIA (var): o procedimento altera a quantidade
procedimento cadastrarPaciente(var qtd: inteiro)
var
   cod, ida, pri, sis, dia, novo: inteiro
   nom, sex: caractere
   tmp: real
inicio
   escreval("--- CADASTRO DE PACIENTE ---")
   se qtd >= MAX_PACIENTES entao
      escreval("ERRO: capacidade maxima de ", MAX_PACIENTES, " pacientes atingida.")
   senao
      cod <- lerCodigoNovo(qtd)
      repita
         escreva("Nome do paciente: ")
         leia(nom)
         se nao nomeValido(nom) entao
            escreval("ERRO: o nome nao pode ser vazio!")
         fimse
      ate nomeValido(nom)
      ida <- lerInteiroEmFaixa("Idade", 0, IDADE_MAXIMA)
      sex <- lerSexo("Sexo (M/F): ")
      escreval("Prioridade: 1-Emergencia 2-Muito urgente 3-Urgente 4-Pouco urgente")
      pri <- lerInteiroEmFaixa("Prioridade", EMERGENCIA, POUCO_URGENTE)
      sis <- lerInteiroEmFaixa("Pressao sistolica (mmHg)", PA_SIST_MIN, PA_SIST_MAX)
      repita
         dia <- lerInteiroEmFaixa("Pressao diastolica (mmHg)", PA_DIAST_MIN, PA_DIAST_MAX)
         se dia >= sis entao
            escreval("ERRO: a diastolica deve ser menor que a sistolica.")
         fimse
      ate dia < sis
      tmp <- lerRealEmFaixa("Temperatura corporal (graus C)", TEMP_MIN, TEMP_MAX)

      // todos os dados validos: grava o registro na proxima posicao livre
      qtd <- qtd + 1
      novo <- qtd
      pacientes[novo].codigo <- cod
      pacientes[novo].nome <- nom
      pacientes[novo].idade <- ida
      pacientes[novo].sexo <- sex
      pacientes[novo].prioridade <- pri
      pacientes[novo].sistolica <- sis
      pacientes[novo].diastolica <- dia
      pacientes[novo].temperatura <- tmp
      pacientes[novo].status <- AGUARDANDO
      pacientes[novo].ordemCadastro <- novo

      // atualiza a matriz de estatisticas
      estat[pri, COL_CADASTRADOS] <- estat[pri, COL_CADASTRADOS] + 1
      estat[pri, COL_AGUARDANDO] <- estat[pri, COL_AGUARDANDO] + 1
      escreval("Paciente cadastrado com sucesso na posicao ", novo, " do vetor (status: Aguardando).")
   fimse
fimprocedimento

procedimento exibirPaciente(idx: inteiro)
var
   temp: real
inicio
   temp <- pacientes[idx].temperatura
   escreval("Codigo.............: ", pacientes[idx].codigo)
   escreval("Nome...............: ", pacientes[idx].nome)
   escreval("Idade..............: ", pacientes[idx].idade)
   escreval("Sexo...............: ", pacientes[idx].sexo)
   escreval("Prioridade.........: ", pacientes[idx].prioridade, " - ", nomePrioridade(pacientes[idx].prioridade))
   escreval("Pressao arterial...: ", pacientes[idx].sistolica, "/", pacientes[idx].diastolica, " mmHg")
   escreval("Temperatura........: ", temp:4:1, " C")
   escreval("Status.............: ", nomeStatus(pacientes[idx].status))
   escreval("Ordem de cadastro..: ", pacientes[idx].ordemCadastro)
fimprocedimento

procedimento listarPacientes(qtd: inteiro)
var
   i, cod, ida: inteiro
inicio
   escreval("--- LISTA DE PACIENTES (ordem de cadastro) ---")
   se qtd = 0 entao
      escreval("Nenhum paciente cadastrado.")
   senao
      escreval("Pos  Cod    Nome                  Idade Sx Prioridade       Status")
      escreval("-----------------------------------------------------------------------")
      para i de 1 ate qtd faca
         cod <- pacientes[i].codigo
         ida <- pacientes[i].idade
         escreva(i:3, "  ", cod:5, "  ")
         escreverPad(pacientes[i].nome, 20)
         escreva(ida:6, "  ", pacientes[i].sexo, "  ")
         escreverPad(nomePrioridade(pacientes[i].prioridade), 15)
         escreval(" ", nomeStatus(pacientes[i].status))
      fimpara
      escreval("Total de pacientes: ", qtd)
   fimse
fimprocedimento

procedimento consultarPaciente(qtd: inteiro)
var
   cod, achado: inteiro
inicio
   escreval("--- CONSULTA DE PACIENTE ---")
   se qtd = 0 entao
      escreval("ERRO: nenhum paciente cadastrado para consultar.")
   senao
      cod <- lerInteiroEmFaixa("Codigo do paciente", 1, COD_MAX)
      achado <- localizarPaciente(cod, qtd)
      se achado = NAO_ENCONTRADO entao
         escreval("ERRO: nao existe paciente com o codigo ", cod, ".")
      senao
         escreval("Paciente encontrado (posicao ", achado, " do vetor).")
         exibirPaciente(achado)
      fimse
   fimse
fimprocedimento

procedimento executarConsultaRecursiva(qtd: inteiro)
var
   cod, achado, aguardRec, aguardIter: inteiro
inicio
   escreval("--- CONSULTA RECURSIVA ---")
   se qtd = 0 entao
      escreval("ERRO: nenhum paciente cadastrado.")
   senao
      cod <- lerInteiroEmFaixa("Codigo procurado", 1, COD_MAX)
      escreval("Acompanhando as chamadas recursivas:")
      achado <- buscaRecursiva(cod, 1, qtd)
      se achado = NAO_ENCONTRADO entao
         escreval("Resultado: paciente ", cod, " nao encontrado.")
      senao
         escreval("Resultado: paciente encontrado na posicao ", achado, ".")
         exibirPaciente(achado)
      fimse
      aguardRec <- contarAguardandoRec(1, qtd)
      aguardIter <- contarAguardando(qtd)
      escreval("Aguardando atendimento (recursivo): ", aguardRec)
      escreval("Aguardando atendimento (iterativo): ", aguardIter)
   fimse
fimprocedimento

// ============================================================================
// FILA DE ATENDIMENTO (copia dos que aguardam + ordenacao)
// ============================================================================

// Copia TODOS os campos de pacientes[origem] para fila[destino]
procedimento copiarParaFila(origem: inteiro; destino: inteiro)
inicio
   fila[destino].codigo <- pacientes[origem].codigo
   fila[destino].nome <- pacientes[origem].nome
   fila[destino].idade <- pacientes[origem].idade
   fila[destino].sexo <- pacientes[origem].sexo
   fila[destino].prioridade <- pacientes[origem].prioridade
   fila[destino].sistolica <- pacientes[origem].sistolica
   fila[destino].diastolica <- pacientes[origem].diastolica
   fila[destino].temperatura <- pacientes[origem].temperatura
   fila[destino].status <- pacientes[origem].status
   fila[destino].ordemCadastro <- pacientes[origem].ordemCadastro
fimprocedimento

// Monta o vetor "fila" apenas com os pacientes AGUARDANDO
procedimento montarFila(qtd: inteiro; var qtdFila: inteiro)
var
   i: inteiro
inicio
   qtdFila <- 0
   para i de 1 ate qtd faca
      se pacientes[i].status = AGUARDANDO entao
         qtdFila <- qtdFila + 1
         copiarParaFila(i, qtdFila)
      fimse
   fimpara
fimprocedimento

// Retorna VERDADEIRO se fila[b] deve vir ANTES de fila[a]
// Criterios: 1) menor numero de prioridade (1 e o mais urgente)
//            2) maior idade
//            3) menor ordem de cadastro
funcao deveTrocar(a: inteiro; b: inteiro): logico
var
   trocar: logico
inicio
   trocar <- falso
   se fila[b].prioridade < fila[a].prioridade entao
      trocar <- verdadeiro
   senao
      se fila[b].prioridade = fila[a].prioridade entao
         se fila[b].idade > fila[a].idade entao
            trocar <- verdadeiro
         senao
            se (fila[b].idade = fila[a].idade) e (fila[b].ordemCadastro < fila[a].ordemCadastro) entao
               trocar <- verdadeiro
            fimse
         fimse
      fimse
   fimse
   retorne trocar
fimfuncao

// Troca dois registros inteiros da fila, campo a campo, com variaveis auxiliares
procedimento trocarFila(a: inteiro; b: inteiro)
var
   auxInt: inteiro
   auxTxt: caractere
   auxReal: real
inicio
   auxInt <- fila[a].codigo
   fila[a].codigo <- fila[b].codigo
   fila[b].codigo <- auxInt

   auxTxt <- fila[a].nome
   fila[a].nome <- fila[b].nome
   fila[b].nome <- auxTxt

   auxInt <- fila[a].idade
   fila[a].idade <- fila[b].idade
   fila[b].idade <- auxInt

   auxTxt <- fila[a].sexo
   fila[a].sexo <- fila[b].sexo
   fila[b].sexo <- auxTxt

   auxInt <- fila[a].prioridade
   fila[a].prioridade <- fila[b].prioridade
   fila[b].prioridade <- auxInt

   auxInt <- fila[a].sistolica
   fila[a].sistolica <- fila[b].sistolica
   fila[b].sistolica <- auxInt

   auxInt <- fila[a].diastolica
   fila[a].diastolica <- fila[b].diastolica
   fila[b].diastolica <- auxInt

   auxReal <- fila[a].temperatura
   fila[a].temperatura <- fila[b].temperatura
   fila[b].temperatura <- auxReal

   auxInt <- fila[a].status
   fila[a].status <- fila[b].status
   fila[b].status <- auxInt

   auxInt <- fila[a].ordemCadastro
   fila[a].ordemCadastro <- fila[b].ordemCadastro
   fila[b].ordemCadastro <- auxInt
fimprocedimento

// Ordenacao por trocas (Bubble Sort), sem funcoes prontas
procedimento ordenarFila(qtdFila: inteiro)
var
   i, j: inteiro
inicio
   para i de 1 ate qtdFila - 1 faca
      para j de 1 ate qtdFila - i faca
         se deveTrocar(j, j + 1) entao
            trocarFila(j, j + 1)
         fimse
      fimpara
   fimpara
fimprocedimento

procedimento exibirLinhaFila(i: inteiro)
inicio
   escreval(i, ") Cod ", fila[i].codigo, " | ", fila[i].nome, " | Prioridade ", fila[i].prioridade, " (", nomePrioridade(fila[i].prioridade), ") | Idade ", fila[i].idade, " | Cadastro #", fila[i].ordemCadastro)
fimprocedimento

procedimento exibirFilaAtendimento(qtd: inteiro)
var
   qtdFila, i: inteiro
inicio
   escreval("--- FILA DE ATENDIMENTO ---")
   se qtd = 0 entao
      escreval("ERRO: nenhum paciente cadastrado.")
   senao
      montarFila(qtd, qtdFila)
      se qtdFila = 0 entao
         escreval("Fila vazia: nenhum paciente aguardando atendimento.")
      senao
         escreval("ANTES da ordenacao (ordem de cadastro):")
         para i de 1 ate qtdFila faca
            exibirLinhaFila(i)
         fimpara
         ordenarFila(qtdFila)
         escreval("")
         escreval("DEPOIS da ordenacao (ordem de atendimento):")
         para i de 1 ate qtdFila faca
            exibirLinhaFila(i)
         fimpara
      fimse
   fimse
fimprocedimento

// ============================================================================
// ATENDIMENTO
// ============================================================================

// Marca o paciente da posicao idx como atendido e atualiza a matriz
procedimento registrarAtendimento(idx: inteiro)
var
   pri: inteiro
inicio
   se pacientes[idx].status = ATENDIDO entao
      escreval("ERRO: o paciente ", pacientes[idx].nome, " ja foi atendido.")
   senao
      pri <- pacientes[idx].prioridade
      pacientes[idx].status <- ATENDIDO
      estat[pri, COL_AGUARDANDO] <- estat[pri, COL_AGUARDANDO] - 1
      estat[pri, COL_ATENDIDOS] <- estat[pri, COL_ATENDIDOS] + 1
      escreval("Atendimento registrado: ", pacientes[idx].nome, " (cod ", pacientes[idx].codigo, ").")
   fimse
fimprocedimento

procedimento realizarAtendimento(qtd: inteiro)
var
   qtdFila, achado, cod, modo: inteiro
inicio
   escreval("--- REALIZAR ATENDIMENTO ---")
   se qtd = 0 entao
      escreval("ERRO: nenhum paciente cadastrado.")
   senao
      montarFila(qtd, qtdFila)
      ordenarFila(qtdFila)
      se qtdFila > 0 entao
         escreval("Proximo da fila:")
         exibirLinhaFila(1)
      senao
         escreval("Fila vazia: nenhum paciente aguardando atendimento.")
      fimse
      escreval("1 - Atender o proximo da fila")
      escreval("2 - Atender informando o codigo do paciente")
      escreval("0 - Cancelar")
      modo <- lerInteiroEmFaixa("Opcao", 0, 2)
      escolha modo
         caso 1
            se qtdFila = 0 entao
               escreval("ERRO: nao ha paciente aguardando para atender.")
            senao
               achado <- localizarPaciente(fila[1].codigo, qtd)
               registrarAtendimento(achado)
            fimse
         caso 2
            cod <- lerInteiroEmFaixa("Codigo do paciente", 1, COD_MAX)
            achado <- localizarPaciente(cod, qtd)
            se achado = NAO_ENCONTRADO entao
               escreval("ERRO: paciente inexistente.")
            senao
               se (pacientes[achado].status = AGUARDANDO) e (pacientes[achado].codigo <> fila[1].codigo) entao
                  escreval("AVISO: este paciente nao e o proximo da fila.")
               fimse
               registrarAtendimento(achado)
            fimse
         caso 0
            escreval("Atendimento cancelado.")
      fimescolha
   fimse
fimprocedimento

procedimento exibirAtendidos(qtd: inteiro)
var
   i, contador: inteiro
inicio
   escreval("--- PACIENTES ATENDIDOS ---")
   contador <- 0
   para i de 1 ate qtd faca
      se pacientes[i].status = ATENDIDO entao
         contador <- contador + 1
         escreval(contador, ") Cod ", pacientes[i].codigo, " | ", pacientes[i].nome, " | ", nomePrioridade(pacientes[i].prioridade), " | ", pacientes[i].idade, " anos")
      fimse
   fimpara
   se contador = 0 entao
      escreval("Nenhum paciente atendido ate o momento.")
   fimse
fimprocedimento

// ============================================================================
// ESTATISTICAS
// ============================================================================

procedimento exibirEstatisticas(qtd: inteiro)
var
   i, j, atendidos, aguardando, prioritarios, maiorIdade, menorIdade, somaIdade: inteiro
   somaTemp, mediaIdade, mediaTemp, percAtend, percAguard: real
inicio
   escreval("--- ESTATISTICAS ---")
   se qtd = 0 entao
      escreval("ERRO: nenhum paciente cadastrado. Nao ha estatisticas para exibir.")
   senao
      somaIdade <- 0
      somaTemp <- 0
      atendidos <- 0
      prioritarios <- 0
      maiorIdade <- pacientes[1].idade
      menorIdade <- pacientes[1].idade
      para i de 1 ate qtd faca
         somaIdade <- somaIdade + pacientes[i].idade
         somaTemp <- somaTemp + pacientes[i].temperatura
         se pacientes[i].status = ATENDIDO entao
            atendidos <- atendidos + 1
         fimse
         se (pacientes[i].prioridade = EMERGENCIA) ou (pacientes[i].prioridade = MUITO_URGENTE) entao
            prioritarios <- prioritarios + 1
         fimse
         se pacientes[i].idade > maiorIdade entao
            maiorIdade <- pacientes[i].idade
         fimse
         se pacientes[i].idade < menorIdade entao
            menorIdade <- pacientes[i].idade
         fimse
      fimpara
      aguardando <- contarAguardando(qtd)
      mediaIdade <- calcularMedia(somaIdade, qtd)
      mediaTemp <- calcularMedia(somaTemp, qtd)
      percAtend <- atendidos * 100 / qtd
      percAguard <- aguardando * 100 / qtd

      escreval("Total de pacientes.............: ", qtd)
      escreval("Pacientes aguardando...........: ", aguardando)
      escreval("Pacientes atendidos............: ", atendidos)
      escreval("Media de idade.................: ", mediaIdade:6:2, " anos")
      escreval("Media de temperatura...........: ", mediaTemp:6:2, " C")
      escreval("Maior idade cadastrada.........: ", maiorIdade)
      escreval("Menor idade cadastrada.........: ", menorIdade)
      escreval("Percentual de atendidos........: ", percAtend:6:2, " %")
      escreval("Percentual aguardando..........: ", percAguard:6:2, " %")
      escreval("Pacientes com prioridade 1 ou 2: ", prioritarios)
      escreval("")
      escreval("Por prioridade (matriz de estatisticas):")
      escreval("Prioridade           Cadastrados  Aguardando   Atendidos")
      para i de EMERGENCIA ate POUCO_URGENTE faca
         escreverPad(nomePrioridade(i), 20)
         para j de COL_CADASTRADOS ate COL_ATENDIDOS faca
            escreva(estat[i, j]:12)
         fimpara
         escreval("")
      fimpara
   fimse
fimprocedimento

// ============================================================================
// MENU E ALGORITMO PRINCIPAL
// ============================================================================

procedimento exibirMenu
inicio
   escreval("")
   escreval("====== MEDCONTROL - GERENCIAMENTO DE ATENDIMENTOS ======")
   escreval("1. Cadastrar paciente")
   escreval("2. Listar pacientes")
   escreval("3. Consultar paciente")
   escreval("4. Exibir fila de atendimento")
   escreval("5. Realizar atendimento")
   escreval("6. Exibir pacientes atendidos")
   escreval("7. Exibir estatisticas")
   escreval("8. Executar consulta recursiva")
   escreval("9. Encerrar sistema")
   escreval("========================================================")
fimprocedimento

inicio
   inicializarSistema
   repita
      exibirMenu
      opcao <- lerInteiro("Escolha uma opcao: ")
      escreval("")
      escolha opcao
         caso 1
            cadastrarPaciente(qtdPacientes)
         caso 2
            listarPacientes(qtdPacientes)
         caso 3
            consultarPaciente(qtdPacientes)
         caso 4
            exibirFilaAtendimento(qtdPacientes)
         caso 5
            realizarAtendimento(qtdPacientes)
         caso 6
            exibirAtendidos(qtdPacientes)
         caso 7
            exibirEstatisticas(qtdPacientes)
         caso 8
            executarConsultaRecursiva(qtdPacientes)
         caso 9
            escreval("Sistema encerrado.")
         outrocaso
            escreval("ERRO: opcao inexistente! Escolha um numero de 1 a 9.")
      fimescolha
   ate opcao = 9
fimalgoritmo
