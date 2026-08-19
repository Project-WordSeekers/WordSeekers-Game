# WordSeekers

Protótipo Godot 4.7 preparado para exportação Web usando o renderer Compatibility.

## Protótipo atual

- mapa principal 10x10;
- movimentação em grade com WASD ou setas;
- jogador inicia em `(1, 1)`;
- NPC fica em `(5, 5)`;
- o quadrado do NPC é bloqueado;
- ao entrar em qualquer um dos 8 quadrados adjacentes ao NPC, ele mostra `oi` por 1,5 segundo;
- câmera 3D inclinada acompanha o jogador;
- preset inicial de exportação Web incluído.

## Estrutura

- `assets/`: arte, áudio e texturas;
- `maps/`: mapas e dungeons;
- `scenes/`: Player, NPCs, inimigos, itens e UI;
- `scripts/`: lógica organizada por sistema;
- `ui/`: telas de login, menu, HUD e diálogos.

## Executar

1. Abra a pasta `word-seekers` no Godot 4.7.x.
2. Execute o projeto com `F6/F5`.
3. Use WASD ou as setas.
4. Caminhe até um quadrado adjacente ao NPC laranja.

## Web

Use `Project > Export > Web` e gere o projeto em `build/web/index.html`.
Para testar localmente, sirva a pasta com um servidor HTTP; não abra o HTML diretamente via `file://`.
