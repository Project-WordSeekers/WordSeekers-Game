# Saídas das cidades: seta azul com mapa

Marcador reutilizável: `res://scenes/ui/map_exit_indicator.tscn`.
Arte azul com mapa acima de seta e fundo transparente: `res://assets/ui/map_exit_arrow.webp`.
O indicador flutua suavemente (10 unidades de amplitude total), sem alterar o teleporte.
Ao chegar a 155 unidades do centro da área de saída, o texto **Saída para o mapa** aparece.
As marcações são colocadas como filhos dos portais de saída para `res://scenes/world/world_map.tscn`, usando a posição do `CollisionShape2D` real (inclusive quando deslocado).
Somente cenas externas de cidades foram marcadas; interiores não receberam indicadores azuis.
Restaurado também o `ScenePortal` de saída de Liverpool que estava ausente do nó `WorldMapExit`.
Imagens e scripts anteriores preservados; não foi necessário mudar o cenário do mapa-múndi.
Validação: ZIP, referências e estrutura; teste visual no Godot 4 pendente.
