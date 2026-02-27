# leitor_markdown

Projeto com utilitários locais para:

- visualizar arquivos Markdown no navegador (`index.html`);
- registrar tempo de bateria com interface Tkinter (`battery_test.py`);
- manter os guias em `Git_Manual/git_manual.md` e `Git_Manual/bizu.md` com referência automática de commit e sincronização opcional no Google Drive (`./uc`).

## Estrutura

- `index.html`: visualizador Markdown com busca, destaque, botão de copiar blocos de código e impressão em PDF.
- `Git_Manual/git_manual.md`: manual de Git mantido no projeto.
- `Git_Manual/bizu.md`: anotações técnicas ("bizus") mantidas no projeto.
- `battery_test.py`: cronômetro para teste de bateria com persistência em `tempo_bateria.txt`.
- `uc`: script para atualizar o commit de referência no manual e enviar cópia para Google Drive.

## Script `./uc`

Execute na raiz do projeto:

```bash
./uc
```

O script:

1. lê o commit atual (`git rev-parse --short HEAD`);
2. atualiza a linha logo abaixo do título em:
   - `Git_Manual/git_manual.md`
   - `Git_Manual/bizu.md`
3. usa o formato:
   `<small>Commit de referencia: \`HASH\`</small>`;
4. remove duplicações dessa linha no topo dos arquivos;
5. tenta enviar para a pasta do Google Drive configurada no script, com nomes:
   - `git_manual.md`
   - `bizu.mb` (destino no Drive)

Se o `rclone` não estiver instalado/configurado, ele mantém apenas a atualização local.

## Configurar Google Drive (rclone)

### 1. Instalar

```bash
sudo apt update
sudo apt install -y rclone
```

### 2. Criar remote

```bash
rclone config
```

Fluxo recomendado:

1. `n` (New remote)
2. nome: `gdrive`
3. storage: `drive` (Google Drive)
4. `client_id`: Enter
5. `client_secret`: Enter
6. `scope`: `1` (full access)
7. `service_account_file`: Enter
8. `Edit advanced config?`: `n` (ou `y` se quiser customizar)
9. `Use auto config?`: `y`
10. autorize no navegador quando abrir o link `http://127.0.0.1:...`
11. `Configure this as a Shared Drive?`: `n`
12. `Keep this remote?`: `y`
13. `q` para sair

### 3. Validar remote

```bash
rclone listremotes
```

Deve aparecer:

```text
gdrive:
```

### 4. Informar o remote ao `uc`

Temporário (sessão atual):

```bash
export RCLONE_REMOTE=gdrive
```

Permanente:

```bash
echo 'export RCLONE_REMOTE=gdrive' >> ~/.bashrc
source ~/.bashrc
```

### 5. Testar sincronização

```bash
./uc
```

Saída esperada (exemplo):

```text
Atualizado: /home/cezar/leitor_markdown/Git_Manual/git_manual.md -> abc1234
Atualizado: /home/cezar/leitor_markdown/Git_Manual/bizu.md -> abc1234
Google Drive: arquivo atualizado em gdrive,root_folder_id=...:git_manual.md
Google Drive: arquivo atualizado em gdrive,root_folder_id=...:bizu.mb
```

## Observações

- O upload usa `root_folder_id` fixo no script `uc` (pasta compartilhada definida no projeto).
- Se aparecer `Google Drive: rclone nao encontrado. Sync ignorado.`, instale o `rclone`.
- Se aparecer mensagem pedindo `RCLONE_REMOTE`, exporte a variável:
  `export RCLONE_REMOTE=gdrive`.
