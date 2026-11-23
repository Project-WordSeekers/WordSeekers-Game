# Correção — cidades bloqueadas e tecla E

- O bloqueio é verificado para **todo** MapPoint antes de tentar carregar a cena.
- Mensagem unificada: `Cidade bloqueada, explore outras cidades para liberar`.
- O painel de diálogo processa a tecla `E` em `_input`, evitando que o evento seja consumido antes pelo mapa ou por elementos de interface.
- O jogador pode fechar o aviso com `E` e continuar andando pelo mapa.
- O mapa aguarda soltar a tecla `E` antes de aceitar uma nova interação, evitando reabertura imediata.
- A progressão original por NPCs e níveis permanece inalterada.

## Testes no Godot 4
1. Iniciar jogo novo, navegar para York, Newcastle, Liverpool, Stratford, Londres e outras cidades de níveis 2 e 3.
2. Pressionar E: confirmar que o aviso aparece em todas as cidades bloqueadas.
3. Pressionar E novamente: confirmar que fecha; depois usar setas para caminhar.
4. Visitar cidades de nível 1 e concluir diálogos dos NPCs; confirmar desbloqueio do nível 2.
5. Confirmar que o nível 3 permanece bloqueado até concluir as cinco cidades do nível 2.

Não foi possível executar Godot neste ambiente; testes são necessários.
