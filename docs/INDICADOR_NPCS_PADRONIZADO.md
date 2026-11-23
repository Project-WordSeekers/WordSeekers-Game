# Indicador de diálogo não realizado — padronização

- **Fonte única:** `scripts/npcs/npc_dialogue_indicator.gd`. Os seis scripts de NPC não repetem mais o código de escala, posicionamento, Tween ou persistência.
- **Imagem:** `assets/ui/icons/npc_new_dialogue_exclamation.png`, redimensionada para aproximadamente 11 pixels de altura (cerca de 1/3 de um NPC com altura de 32 px), com transparência.
- **Posição:** 26 px acima da origem local do NPC; flutuação suave de 4 px em ciclos de 1,1 segundo.
- **Persistência:** mantém os mesmos IDs e o `GameState.register_npc_talked`/`has_talked_to_npc` já utilizados no save. O marcador some quando o diálogo termina e não reaparece ao voltar à cena.
- **NPCs abrangidos:** simples, Irmã Agnes, Charles Abbot, morador de Cambridge, Bridge Guide e Professor John. Qualquer instância que compartilhe esses scripts recebe o comportamento.
- **Para novos NPCs:** instanciar `NPC_INDICATOR_SCRIPT` via `npc_indicator.setup(self, npc_id)` em `_ready()` e usar `npc_indicator.mark_talked(String(GameState.world_map_point_name))` ao concluir a conversa.
- **Validação:** scripts e referências revisados, ZIP testado. Não houve execução no Godot 4.
