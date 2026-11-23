# Cálice restaurado — seis templos

Posição no mapa compartilhado: `(0, 20)` em coordenadas locais do TileMapLayer, correspondendo ao centro marcado em vermelho no mapa 2048 × 1529.
Imagem base original do cálice com transparência e halo luminoso: `assets/environments/shared/temple_chalice_new.webp` (WebP RGBA sem perdas).
A imagem foi redimensionada no Sprite2D; o corpo do cálice tem aproximadamente 128 unidades de altura, contra 64 do player (player escalado 2×). Há luz dourada suave ao redor do cálice.
A mensagem `Pressione 'E'` fica acima do cálice quando o player entra na área de interação. Ao pressionar E, o script compartilhado `chalice.gd` chama `GameState.restore_full_health()` e o aviso reaparece se o jogador permanecer próximo.
A base tem colisão física própria; a interação é uma Area2D de raio 96.
Nenhuma das tochas antigas ou dos efeitos defeituosos foi restaurada.
O modelo `temple.tscn` é compartilhado por Colchester, York, Newcastle, Liverpool, Stratford e Londres.
Verificação do ZIP realizada; execução no Godot 4 não testada.
