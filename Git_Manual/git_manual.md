# Guia de Git

## Indice

- [Instalação do Git](#instalação-do-git)
- [Clonar um repositório](#clonar-um-repositório)
- [Criar e publicar um projeto novo no GitHub](#criar-e-publicar-um-projeto-novo-no-github)
- [Fluxo diário básico](#fluxo-diário-básico)
- [Trabalhando com branches](#trabalhando-com-branches)
- [Boas práticas](#boas-práticas)
- [Remover arquivos do índice (sem apagar localmente)](#remover-arquivos-do-índice-sem-apagar-localmente)
- [Patches e reaplicacao de commits](#patches-e-reaplicacao-de-commits)
- [Pre-check antes de aplicar patch](#pre-check-antes-de-aplicar-patch)
- [Quando usar git apply vs git am](#quando-usar-git-apply-vs-git-am)
- [Erros comuns ao aplicar patch](#erros-comuns-ao-aplicar-patch)
- [Resolucao de conflitos](#resolucao-de-conflitos)
- [Recuperacao e reversao](#recuperacao-e-reversao)
- [Historico e diagnostico](#historico-e-diagnostico)
- [Fluxo seguro para aplicacao de patch](#fluxo-seguro-para-aplicacao-de-patch)
- [Resumo operacional rapido](#resumo-operacional-rapido)

## Instalação do Git

### Linux (Debian/Ubuntu)

```bash
sudo apt update && sudo apt install git -y
```

### Windows

Instale pelo site oficial: [https://git-scm.com](https://git-scm.com)

Após a instalação, use o Git Bash.

### macOS

```bash
brew install git
```

## Clonar um repositório

### Via HTTPS

```bash
git clone https://github.com/usuario/projeto.git
```

### Via SSH

```bash
git clone git@github.com:usuario/projeto.git
```

Requer chave SSH previamente configurada.

### Acessar a pasta clonada

```bash
cd projeto
```

## Criar e publicar um projeto novo no GitHub

### Criar repositório no GitHub

1. Acesse `github.com`.
2. Clique em `New repository`.
3. Crie o repositório (sem README se já existir projeto local).

### Inicializar repositório local

```bash
git init
git add .
git commit -m "initial commit"
```

### Conectar ao repositório remoto

```bash
git remote add origin https://github.com/usuario/projeto.git
git remote -v
```

### Enviar para o GitHub

```bash
git push -u origin main
```

Se o branch principal for `master`:

```bash
git push -u origin master
```

### Autenticação no GitHub (HTTPS + PAT e SSH)

Esse erro acontece porque o GitHub nao aceita mais autenticacao por senha em operacoes de `git push`.
Agora e necessario usar **Personal Access Token (PAT)** ou **chaves SSH**.

Aqui estao os dois metodos mais comuns:

#### Metodo 1: HTTPS com Personal Access Token

1. Crie um token no GitHub:
   - Va em **Settings > Developer settings > Personal access tokens > Tokens (classic)**.
   - Clique em **Generate new token**.
   - Marque permissoes como `repo` (para acesso a repositorios).
   - Copie o token gerado.

2. Configure o Git para usar seu usuario e email:

```bash
git config --global user.name "seu-usuario-github"
git config --global user.email "seu-email@exemplo.com"
```

3. Ao fazer `git push`, use o token no lugar da senha:

```bash
git push -u origin main
```

Quando pedir usuario, use seu **username do GitHub**.
Quando pedir senha, cole o **token**.

#### Metodo 2: SSH (mais pratico a longo prazo)

1. Gere uma chave SSH:

```bash
ssh-keygen -t ed25519 -C "seu-email@exemplo.com"
```

(pressione Enter para aceitar os padroes).

2. Adicione a chave ao agente SSH:

```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

3. Copie a chave publica:

```bash
cat ~/.ssh/id_ed25519.pub
```

Cole esse conteudo em **GitHub > Settings > SSH and GPG keys > New SSH key**.

4. Troque o remote para usar SSH:

```bash
git remote set-url origin git@github.com:cezardsilva/battery_test.git
```

5. Agora o push funciona sem pedir senha:

```bash
git push -u origin main
```

Recomendacao: prefira SSH se voce vai trabalhar bastante com GitHub, porque evita digitar token com frequencia.

## Fluxo diário básico

```bash
git status
git add arquivo.xx
git add .
git commit -m "feat: adiciona nova funcionalidade"
git push
```

## Trabalhando com branches

### Criar branch

```bash
git checkout -b minha-branch
```

### Trocar branch

```bash
git checkout main
```

### Listar branches

```bash
git branch
```

### Deletar branch local

```bash
git branch -d minha-branch
```

### Uso recomendado

- `main`: produção
- `develop`: integração
- `feature/nome`: novas funcionalidades
- `fix/nome`: correções

## Boas práticas

### Padrão de mensagens de commit

Use padrão semântico:

- `feat`: nova funcionalidade
- `fix`: correção de bug
- `docs`: documentação
- `refactor`: melhoria interna
- `chore`: tarefas internas

Exemplo:

```bash
git commit -m "feat: adiciona validacao de entrada"
```

### Exemplo de `.gitignore`

```gitignore
node_modules/
dist/
build/
__pycache__/
.env
*.pyc
*.log
```

## Remover arquivos do índice (sem apagar localmente)

Use quando arquivos passaram a ser ignorados no `.gitignore`.

```bash
git rm -r --cached prompts diretorio arquivo.xx *.ext
git commit -m "chore: remove arquivos ignorados"
git push
```

## Patches e reaplicacao de commits

### Validar e aplicar patch

```bash
git apply --check arquivo.patch
git apply arquivo.patch
```

### Conferir estado antes de reaplicar

```bash
git status
git log --oneline -n 5
```

### Reaplicar commit especifico

```bash
git cherry-pick <hash_do_commit>
```

## Pre-check antes de aplicar patch

Use este checklist para reduzir risco antes de aplicar alteracoes em outros scripts:

1. Garantir worktree limpo:

```bash
git status
```

2. Criar branch de seguranca:

```bash
git checkout -b backup/antes-patch-YYYYMMDD
```

3. Validar patch sem aplicar:

```bash
git apply --check arquivo.patch
```

4. Revisar escopo do patch:

```bash
git apply --stat arquivo.patch
```

5. Revisar diff final antes de commit:

```bash
git apply arquivo.patch
git diff
```

## Quando usar git apply vs git am

- `git apply`: aplica apenas o diff (nao cria commit automaticamente e nao preserva metadados do commit original).
- `git am`: aplica patches gerados com `git format-patch`, preservando autor, data e mensagem de commit.

Exemplo de fluxo com `git am`:

```bash
git format-patch -1 <hash_do_commit>
git am 0001-*.patch
```

## Erros comuns ao aplicar patch

| Erro/Sintoma | Causa comum | Correcao pratica |
| --- | --- | --- |
| `patch does not apply` | Contexto do arquivo mudou | Atualize a branch e reaplique; se necessario, regenere o patch na base correta |
| Arquivo nao encontrado no caminho do patch | Prefixo de caminho diferente (`a/`, `b/`) | Tente `git apply -p1 arquivo.patch` (ou ajuste `-p`) |
| Mudancas de fim de linha (CRLF/LF) | Ambiente com EOL diferente | Normalize EOL e tente novamente |
| Falha por whitespace | Espacos extras ou tabs divergentes | Use `git apply --check --whitespace=warn arquivo.patch` |
| Apenas parte do patch aplica | Hunks com conflito local | Use `git apply --reject arquivo.patch` e resolva arquivos `.rej` |
| Patch maior que o esperado | Alteracoes fora de escopo | Rode `git apply --stat arquivo.patch` e `git diff` antes do commit |
| Permissao de execucao incorreta | Bit de execucao nao ajustado como esperado | Verifique com `git diff --summary` e ajuste com `chmod +/-x arquivo` |

## Resolucao de conflitos

### Ver arquivos em conflito

```bash
git status
```

Resolva manualmente removendo os marcadores:

```text
<<<<<<<
=======
>>>>>>>
```

Depois finalize:

```bash
git add arquivo.xx
git commit -m "fix: resolve conflito"
```

## Recuperacao e reversao

### Remover do stage

```bash
git reset HEAD arquivo.xx
```

### Restaurar arquivo

Forma moderna:

```bash
git restore arquivo.xx
```

Forma antiga:

```bash
git checkout -- arquivo.xx
```

### Restaurar stage e worktree

```bash
git restore --source=HEAD --staged --worktree arquivo.xx
```

### Reset completo (cuidado)

```bash
git reset --hard
```

Descarta todas as alteracoes nao commitadas.

## Historico e diagnostico

### Historico resumido

```bash
git log --oneline
```

### Ultimos 5 commits

```bash
git log --oneline -n 5
```

### Remotos configurados

```bash
git remote -v
```

## Fluxo seguro para aplicacao de patch

1. Validar:

```bash
git apply --check arquivo.patch
```

2. Conferir estado:

```bash
git status
```

3. Aplicar:

```bash
git apply arquivo.patch
```

4. Confirmar alteracoes:

```bash
git status
```

## Resumo operacional rapido

| Situacao | Comando |
| --- | --- |
| Iniciar repositorio | `git init` |
| Clonar | `git clone URL` |
| Ver estado | `git status` |
| Adicionar | `git add .` |
| Commitar | `git commit -m "msg"` |
| Enviar | `git push` |
| Criar remoto | `git remote add origin URL` |
| Reset total | `git reset --hard` |
| Restaurar arquivo | `git restore arquivo.xx` |
| Aplicar patch | `git apply arquivo.patch` |
| Cherry-pick | `git cherry-pick <hash>` |
