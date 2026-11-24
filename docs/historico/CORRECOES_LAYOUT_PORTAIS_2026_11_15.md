# Correções do projeto — layout e transições por área

- `dialogue_ui.gd`: painel de quiz com largura máxima de 650 px, centralizado no topo; Dicionário posicionado fora do HUD (que ocupa aproximadamente x16..316 / y16..188). Para telas menores, o botão fica abaixo do quiz ou no canto inferior direito, dependendo do espaço.
- `batalha.gd`: player e monstro com pés na mesma linha horizontal (Y=88% da altura do viewport); escala individual para altura-alvo semelhante.
- Nottingham: entrada no castelo e na City of Caves por `Area2D` com `scene_portal.gd`; retorno ao exterior também automático ao cruzar a faixa de saída, com respawns distintos `FromCastle` e `FromCaves`. Removido uso de E nesses portais; E continua para NPCs, quiz e objetos.
- Liverpool: portas/saídas de `Area2D` passaram a usar `collision_mask = 1`, compatível com a camada do player; já operavam por proximidade e não exigiam E.
- Outros interiores de Cambridge, Salisbury, Stratford, Winchester e Newcastle já possuem `scene_portal.gd` ativado por `body_entered`.
- Não alterados conteúdo dos quizzes, música, progressão, arte ou lógica de combate.
- Verificação estática de referências e integridade ZIP; execução no Godot 4 ainda necessária.
