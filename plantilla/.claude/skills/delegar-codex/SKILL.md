---
name: delegar-codex
description: Delegar en Codex (el agente de OpenAI) una tarea con su ficha, en un clon aparte, y revisar lo que programó antes de abrir la PR. Usar cuando el usuario diga "que lo programe Codex" o "pásale esto a Codex", y cuando una ola le asigna una ficha a Codex.
metadata:
  origin: metodo-de-trabajo
  type: workflow
---

# Delegar una tarea en Codex

Codex programa y Claude revisa. Codex trabaja con la ficha en un clon del repo y no pushea; quien
coordina verifica su trabajo, abre la PR y la lleva a la `compuerta`. Como gasta el límite de
ChatGPT y no el de Claude, corre en paralelo con las sesiones en la nube de una ola, con su propia
zona. Su modelo y su esfuerzo están en "Modelos" de `CLAUDE.md`.

Los scripts están junto a este archivo y se corren con Git Bash desde el repo. `codex.sh` encuentra
el runtime del plugin de Codex y le pasa los argumentos; `bash .claude/skills/delegar-codex/codex.sh setup`
dice si Codex está instalado y con sesión iniciada.

## Pasos

1. **Ficha** con `escribir-ficha`: Codex no ve la conversación, así que lo que no está en la ficha no
   existe para él.
2. **Clon:**
   `bash .claude/skills/delegar-codex/preparar-clon.sh <ID> <ficha> <carpeta-en-el-scratchpad> [base]`.
   Deja la rama `codex/<id>` con la ficha commiteada, los `.env` copiados y el prompt de Codex en
   `.git/codex-prompt.md`. Después instalá las dependencias en el clon, como en la combinación de la
   compuerta: Codex puede no tener red. Va en un clon porque `/codex:rescue` trabaja sobre la
   carpeta del repo y pisaría el árbol de trabajo; `--cwd` lo lleva al clon.
3. **Lanzar** con Bash en segundo plano (`run_in_background`), una tarea de Codex a la vez:
   `bash .claude/skills/delegar-codex/codex.sh task --write --cwd <carpeta> --prompt-file <carpeta>/.git/codex-prompt.md`.
   Al terminar imprime la respuesta final de Codex. `codex.sh status` muestra el avance.
4. **Revisión de Claude**, como la de una PR ajena:
   - `git -C <carpeta> log --oneline origin/<base>..` y el diff entero: cada punto de la ficha tiene
     su commit y su test, el test prueba lo que dice el punto, y nada sale de la zona. En
     `git diff --stat`, ni tokens, ni cobertura, ni builds. Si Codex no pudo commitear, armá vos un
     commit por punto con lo que dijo.
   - Corré vos la verificación de "Cómo entregar" en el clon: lo que dice Codex no es evidencia.
   - Lo que falta o está mal vuelve a Codex en el mismo hilo, con archivo y motivo:
     `bash .claude/skills/delegar-codex/codex.sh task --write --resume-last --cwd <carpeta> "<qué corregir>"`.
     Tope de dos vueltas; lo que quede lo arreglás vos en el clon, con su commit.
5. **PR:** `git -C <carpeta> push -u origin codex/<id>` y la PR contra la base con
   `.github/pull_request_template.md`. En "Sesión" va "Codex" con el ID de su sesión
   (`codex.sh result`), y en "Cómo se probó", lo que corriste vos en el paso 4.

## Terminada cuando

La PR está abierta y con el CI en verde, cada punto de la ficha tiene su commit y su test, y "Cómo se
probó" trae la verificación que corrió Claude, con sus números. Lo que sigue es la `compuerta`, donde
la revisión de Claude es la de un modelo distinto del que escribió.
