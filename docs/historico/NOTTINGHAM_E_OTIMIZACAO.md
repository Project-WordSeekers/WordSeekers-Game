# Nottingham e patch de otimização

## Nottingham
- Cidade de Nottingham substitui o placeholder do MapPoint Nottingham.
- Inclui mapa, colisões polygonais originais, entrada do castelo e da City of Caves.
- O interior da City of Caves utiliza a ilustração enviada; o castelo permanece um protótipo desenhado por script.
- O player usa a cena compartilhada do WordSeekers (evita duplicação de personagens).
- Saída ao mapa-múndi na borda inferior; entradas dos interiores via tecla E.
- Um NPC de orientação permite registrar a conclusão de conversa do Nível 1.

## Patch de otimização Winchester, Cambridge e Salisbury
- O patch fornecido recomprime PNGs sem mudar pixels, e não contém cenas nem scripts.
- O projeto já utiliza WebP nos cenários correspondentes; não duplicamos PNGs sem uso.
- O mapa PNG do patch de Winchester tem 1404x1120, enquanto a cena atual usa WebP de 1402x1122: não substituímos para evitar desalinhamento de colisões.
- A arte adicional do Grande Salão / Távola Redonda foi preservada em assets/environments/winchester/round_table_hall.webp, sem vinculá-la a um portal inexistente.
- Cambridge e Salisbury continuam usando seus cenários WebP existentes.

## Validação
- Estrutura ZIP, caminhos de recursos e links de MapPoint verificados estaticamente.
- Execução e colisões não testadas na engine Godot 4.
