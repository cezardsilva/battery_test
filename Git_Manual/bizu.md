# Bizus

<small>Commit de referencia: `2d44f2a`</small>

## Setup do HP

No SETUP, mude "Modo nativo SATA" para Desativar.

Mude "Modo de tradução do HDD" para LBA-assistido.

## Para rodar patches em Python do tipo

python3 - <<'PY'
from pathlib import Path
import difflib

p = Path("keyboard.c")
if not p.exists():
    raise SystemExit("ERRO: keyboard.c não encontrado.")...

```Bash
patch --dry-run -p0 < x_keyboard.patch
patch -p0 < x_keyboard.patch
```

## Criando o ambiente virtual

- No diretório do seu projeto, execute:

```Bash
python3 -m venv venv
```

- Ative o ambiente virtual

```Bash
source venv/bin/activate
```

- Desative o ambiente virtual

```Bash
deactivate
```

## Remover os arquivos e pastas do índice do Git (sem apagar localmente)

```Bash
git rm -r --cached prompts diretorio arqui.ext *.ext
```

## Commitar a remoção

```Bash
git commit -m "Remove pastas e arquivos ignorados do repositório"
```

## Enviar para o GitHub

```Bash
git push
```

- Depois disso, o GitHub não terá mais essas pastas/arquivos, e como estão no .gitignore, não voltarão a ser adicionados em futuros commits.

## Gravar no Pendrive (O comando "DD")

O pendrive não deve estar montado. Se o Ubuntu montou ele automaticamente (apareceu o ícone de pasta), desmonte-o primeiro (botão direito no ícone > ejetar/desmontar) ou use:

## Rodar patch (evitando erro de patch truncado/reverso)

Se aparecer:

- `Reversed (or previously applied) patch detected!`
- `patch unexpectedly ends in middle of line`

normalmente é um destes casos:

1. o patch já foi aplicado;
2. o arquivo `x.patch` está truncado (incompleto);
3. o patch foi salvo com quebra de linha incorreta (CRLF) ou sem newline final.

Use este fluxo:

- validar sem aplicar

```sh
patch --dry-run -p1 < x.patch
```

- se falhar por formato, normalize (Linux)

```sh
sed -i 's/\r$//' x.patch
```

- tente aplicar

```sh
patch -p1 < x.patch
```

Para patch gerado por Git, prefira:

```sh
git apply --check x.patch
# se OK:
git apply x.patch
```

Se o patch já estiver aplicado, NÃO use `-R` no escuro.
Primeiro confirme o estado:

```sh
git status
git log --oneline -n 5
```

Se quiser reaplicar a mudança corretamente, o melhor é usar commit hash:

```sh
# exemplo
# git cherry-pick <hash_do_commit>
```

## O que fazer no seu ambiente (onde houve conflito)

Ver os arquivos em conflito:

```sh
git status
```

- Abrir os conflitos:

```sh
rg -n '^(<<<<<<<|=======|>>>>>>>)' usb.c usb_msc.c usb_msc.h
```

- Resolver manualmente mantendo a versão mais nova da Fase 2 (mount manager lógico + estados + shell comandos), removendo marcadores <<<<<<<, =======, >>>>>>>.

- Validar compilação mínima:

```sh
gcc -m32 -c -std=gnu99 -ffreestanding -O2 -fno-stack-protector -fno-pic -Wall -Werror -fno-builtin -fno-common usb_msc.c -o /tmp/usb_msc.o
```

- Marcar como resolvido e concluir:

```sh
git add usb.c usb_msc.c usb_msc.h
```

```sh
git commit -m "resolve: merge conflicts in phase-3 usb msc patch"
```

## Para reverter uma atualização

Se o arquivo já está staged para commit, significa que você adicionou as mudanças ao índice (git add). Para voltar ao estado original do último commit, você precisa primeiro tirar o arquivo do stage e depois restaurá-lo.

Passo a passo:

- Remover do stage

```sh
git reset HEAD usb.c
```

Isso tira o arquivo do índice, mas mantém as alterações no diretório de trabalho.

- Restaurar o conteúdo original

```sh
git checkout -- usb.c
```

ou, em versões mais novas:

```sh
git restore usb.c
```

Isso descarta as alterações locais e traz o arquivo exatamente como está no último commit.

## Fazer o build ISO i386

```sh
clear
./build.sh
```

## Gravar o pendrive com a ISO i386

```bash
sudo umount /dev/sdb* 2>/dev/null
sudo dd if=myos.iso of=/dev/sdb status=progress
sync
sudo eject /dev/sdb
```

## Fazer o build ISO dual-boot

```sh
clear
./build_dual.sh
```

## Identificar os arquivos gerados

```bash
ls -l build/dual/cdsos-i386.bin build/dual/cdsos-x86_64.bin
```

Esperado: os dois arquivos listados com tamanho maior que 0.

## Identificar o pendrive

```bash
lsblk -o NAME,SIZE,MODEL,TRAN
```

## Gravar o pendrive com a ISO dual-boot

```bash
sudo umount /dev/sdb* 2>/dev/null || true
sudo dd if=build/dual/cdsos-dual.iso of=/dev/sdb bs=4M status=progress conv=fsync
sync
sudo eject /dev/sdb
```

- O sync é fundamental: ele garante que o cache de escrita do Linux seja totalmente escarregado para o hardware antes de você puxar o pendrive.

### Para rodar a VM

Fallback sem script (comando direto equivalente):

```bash
env -i PATH=/usr/sbin:/usr/bin:/sbin:/bin HOME="$HOME" USER="$USER" \
DISPLAY="$DISPLAY" XAUTHORITY="$XAUTHORITY" \
qemu-system-x86_64 -cdrom build/dual/cdsos-dual.iso -m 256
```

### Gravar ISO no pendrive no CDS_OSv3

```bash
sudo umount /dev/sdb* 2>/dev/null
sudo wipefs -a /dev/sdb
echo teste
sudo dd if=build/cdsos.iso of=/dev/sdb bs=4M status=progress conv=fsync
sync
sudo eject /dev/sdb
```

ou

```bash
./pen
```

*******************************************
