# ============================================================
# BIBLIOPY 
# ============================================================

# ---------- Estruturas de dados globais ----------
livros = []      # cada livro: dicionário
usuarios = []    # cada usuário: dicionário
emprestimos = [] # cada empréstimo: dicionário


# ---------- Funções auxiliares de busca ----------
def buscar_livro(codigo):
    """Retorna o dicionário do livro ou None se não existir."""
    for livro in livros:
        if livro["codigo"] == codigo:
            return livro
    return None


def buscar_usuario(codigo):
    """Retorna o dicionário do usuário ou None se não existir."""
    for usuario in usuarios:
        if usuario["codigo"] == codigo:
            return usuario
    return None


def buscar_emprestimo(codigo_usuario, codigo_livro):
    """Retorna o empréstimo ativo correspondente ou None."""
    for emp in emprestimos:
        if emp["codigo_usuario"] == codigo_usuario and emp["codigo_livro"] == codigo_livro:
            return emp
    return None


# ---------- Menu ----------
def exibir_menu():
    print("\n" + "=" * 40)
    print("BIBLIOPY | MENU PRINCIPAL")
    print("=" * 40)
    print("1 - Cadastrar livro")
    print("2 - Cadastrar usuário")
    print("3 - Listar livros")
    print("4 - Listar usuários")
    print("5 - Realizar empréstimo")
    print("6 - Realizar devolução")
    print("7 - Consultar situação de um livro")
    print("8 - Consultar resumo da biblioteca")
    print("0 - Encerrar aplicação")
    print("=" * 40)


# ---------- Cadastro de livros ----------
def cadastrar_livro():
    print("\n--- CADASTRO DE LIVRO ---")
    codigo = input("Código do livro: ").strip()

    if codigo == "":
        print("Erro: o código não pode ser vazio.")
        return

    if buscar_livro(codigo) is not None:
        print("Erro: já existe um livro com esse código.")
        return

    titulo = input("Título da obra: ").strip()
    if titulo == "":
        print("Erro: o título não pode ser vazio.")
        return

    autor = input("Nome do autor: ").strip()
    if autor == "":
        print("Erro: o autor deve ser informado.")
        return

    categoria = input("Categoria da obra: ").strip()
    if categoria == "":
        print("Erro: a categoria deve ser informada.")
        return

    try:
        qtd_total = int(input("Quantidade total de exemplares: "))
    except ValueError:
        print("Erro: informe um número inteiro.")
        return

    if qtd_total <= 0:
        print("Erro: a quantidade deve ser maior que zero.")
        return

    livro = {
        "codigo": codigo,
        "titulo": titulo,
        "autor": autor,
        "categoria": categoria,
        "qtd_total": qtd_total,
        "qtd_disponivel": qtd_total,
    }
    livros.append(livro)
    print(f"Livro '{titulo}' cadastrado com sucesso!")


# ---------- Cadastro de usuários ----------
def cadastrar_usuario():
    print("\n--- CADASTRO DE USUÁRIO ---")
    codigo = input("Código do usuário: ").strip()

    if codigo == "":
        print("Erro: o código não pode ser vazio.")
        return

    if buscar_usuario(codigo) is not None:
        print("Erro: já existe um usuário com esse código.")
        return

    nome = input("Nome completo: ").strip()
    if nome == "":
        print("Erro: o nome deve ser informado.")
        return

    print("Tipo de usuário:")
    print("  1 - Estudante")
    print("  2 - Professor")
    print("  3 - Funcionário")
    tipo_opcao = input("Opção: ").strip()

    match tipo_opcao:
        case "1":
            tipo = "Estudante"
        case "2":
            tipo = "Professor"
        case "3":
            tipo = "Funcionário"
        case _:
            print("Erro: tipo de usuário inválido.")
            return

    curso_setor = input("Curso ou setor: ").strip()
    if curso_setor == "":
        print("Erro: o curso/setor deve ser informado.")
        return

    usuario = {
        "codigo": codigo,
        "nome": nome,
        "tipo": tipo,
        "curso_setor": curso_setor,
        "qtd_emprestimos": 0,
    }
    usuarios.append(usuario)
    print(f"Usuário '{nome}' cadastrado com sucesso!")


# ---------- Listagens ----------
def listar_livros():
    print("\n--- LISTA DE LIVROS ---")
    if len(livros) == 0:
        print("Nenhum livro cadastrado.")
        return

    for livro in livros:
        print("-" * 40)
        print(f"Código: {livro['codigo']}")
        print(f"Título: {livro['titulo']}")
        print(f"Autor: {livro['autor']}")
        print(f"Categoria: {livro['categoria']}")
        print(f"Quantidade total: {livro['qtd_total']}")
        print(f"Quantidade disponível: {livro['qtd_disponivel']}")
    print("-" * 40)


def listar_usuarios():
    print("\n--- LISTA DE USUÁRIOS ---")
    if len(usuarios) == 0:
        print("Nenhum usuário cadastrado.")
        return

    for usuario in usuarios:
        print("-" * 40)
        print(f"Código: {usuario['codigo']}")
        print(f"Nome: {usuario['nome']}")
        print(f"Tipo: {usuario['tipo']}")
        print(f"Curso/Setor: {usuario['curso_setor']}")
        print(f"Empréstimos realizados: {usuario['qtd_emprestimos']}")
    print("-" * 40)


# ---------- Empréstimo ----------
def realizar_emprestimo():
    print("\n--- REALIZAR EMPRÉSTIMO ---")
    codigo_usuario = input("Código do usuário: ").strip()
    usuario = buscar_usuario(codigo_usuario)
    if usuario is None:
        print("Erro: usuário não encontrado.")
        return

    codigo_livro = input("Código do livro: ").strip()
    livro = buscar_livro(codigo_livro)
    if livro is None:
        print("Erro: livro não encontrado.")
        return

    if livro["qtd_disponivel"] <= 0:
        print("Erro: não há exemplares disponíveis deste livro.")
        return

    try:
        dias = int(input("Quantidade de dias de empréstimo: "))
    except ValueError:
        print("Erro: informe um número inteiro.")
        return

    if dias <= 0:
        print("Erro: a quantidade de dias deve ser positiva.")
        return

    # Atualiza dados
    livro["qtd_disponivel"] -= 1
    usuario["qtd_emprestimos"] += 1

    emprestimo = {
        "codigo_usuario": codigo_usuario,
        "codigo_livro": codigo_livro,
        "dias": dias,
    }
    emprestimos.append(emprestimo)

    print(f"Empréstimo registrado! Livro '{livro['titulo']}' para {usuario['nome']} por {dias} dia(s).")


# ---------- Devolução ----------
def realizar_devolucao():
    print("\n--- REALIZAR DEVOLUÇÃO ---")
    codigo_usuario = input("Código do usuário: ").strip()
    codigo_livro = input("Código do livro: ").strip()

    emprestimo = buscar_emprestimo(codigo_usuario, codigo_livro)
    if emprestimo is None:
        print("Erro: não existe empréstimo ativo correspondente.")
        return

    livro = buscar_livro(codigo_livro)
    livro["qtd_disponivel"] += 1
    emprestimos.remove(emprestimo)

    print(f"Devolução registrada! Livro '{livro['titulo']}' devolvido.")


# ---------- Consulta de livro ----------
def consultar_livro():
    print("\n--- CONSULTAR SITUAÇÃO DE LIVRO ---")
    codigo = input("Código do livro: ").strip()
    livro = buscar_livro(codigo)

    if livro is None:
        print("Erro: livro não encontrado.")
        return

    emprestados = livro["qtd_total"] - livro["qtd_disponivel"]
    print("-" * 40)
    print(f"Código: {livro['codigo']}")
    print(f"Título: {livro['titulo']}")
    print(f"Autor: {livro['autor']}")
    print(f"Categoria: {livro['categoria']}")
    print(f"Total de exemplares: {livro['qtd_total']}")
    print(f"Exemplares disponíveis: {livro['qtd_disponivel']}")
    print(f"Exemplares emprestados: {emprestados}")
    print("-" * 40)


# ---------- Resumo geral ----------
def resumo_biblioteca():
    print("\n--- RESUMO GERAL DA BIBLIOTECA ---")

    total_livros = len(livros)
    total_usuarios = len(usuarios)
    total_emprestimos_ativos = len(emprestimos)

    total_disponiveis = 0
    total_emprestados = 0
    for livro in livros:
        total_disponiveis += livro["qtd_disponivel"]
        total_emprestados += livro["qtd_total"] - livro["qtd_disponivel"]

    print("-" * 40)
    print(f"Total de livros cadastrados: {total_livros}")
    print(f"Total de usuários cadastrados: {total_usuarios}")
    print(f"Total de empréstimos ativos: {total_emprestimos_ativos}")
    print(f"Total de exemplares disponíveis: {total_disponiveis}")
    print(f"Total de exemplares emprestados: {total_emprestados}")
    print("-" * 40)


# ---------- Loop principal ----------
def main():
    print("Bem-vindo ao BiblioPy!")

    while True:
        exibir_menu()
        opcao = input("Informe a opção desejada: ").strip()

        match opcao:
            case "1":
                cadastrar_livro()
            case "2":
                cadastrar_usuario()
            case "3":
                listar_livros()
            case "4":
                listar_usuarios()
            case "5":
                realizar_emprestimo()
            case "6":
                realizar_devolucao()
            case "7":
                consultar_livro()
            case "8":
                resumo_biblioteca()
            case "0":
                print("Encerrando o BiblioPy. Até logo!")
                break
            case _:
                print("Opção inválida! Tente novamente.")


# Ponto de entrada do programa
if __name__ == "__main__":
    main()