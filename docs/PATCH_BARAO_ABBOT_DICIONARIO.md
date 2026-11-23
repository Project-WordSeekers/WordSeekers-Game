# Patch — Barão Abbot e O Dicionário

## Point02
- Barão Abbot adicionado à praça do Point02.
- Interação: `E`.
- Na primeira conversa, o Barão entrega **O Dicionário**.
- O item só pode ser recebido uma vez por partida.

> Observação: o histórico acessível não continha as falas antigas exatas do Barão. O texto atual está isolado em `scripts/npcs/baron_abbot.gd`, no array `first_dialogue_lines`, para substituição simples quando o roteiro original for recuperado.

## O Dicionário
Descrição:

> Um grimório misterioso. O dicionário tem o poder de ajudar seu usuário a desvendar o mistério das palavras.

- Possui 3 usos por partida.
- Funciona somente durante quizzes.
- Pressione `T` (Translate) para usar.
- Cada uso revela visualmente a alternativa correta da pergunta atual.
- Uma mesma pergunta não pode consumir mais de um uso.
- Ao chegar a 0/3, o item continua na mochila, mas não pode mais ser usado.

## HUD
- Durante quizzes, se o jogador possui O Dicionário, uma segunda barra aparece abaixo da barra de HP.
- A barra exibe ícone, nome e usos restantes (`3/3` até `0/3`).

## Ajuda e mochila
- `H`: abre/fecha AJUDA, incluindo a instrução de `T`.
- `I`: abre/fecha MOCHILA.
- A mochila mostra o nome, descrição, usos restantes e a instrução de `T`.

## Nova partida
Ao confirmar a aparência na tela inicial, HP e inventário são reiniciados. O Dicionário deverá ser obtido novamente com o Barão Abbot.
