# Integração de Canterbury

- Cena: `res://scenes/locations/canterbury/canterbury.tscn`
- Mapa original (1312 x 1199): `res://assets/environments/canterbury/canterbury.png`
- Vinculada ao `Point04`, anteriormente sem destino. Colchester permanece no `Point01`.
- Reutiliza `scenes/player/player.tscn` (padrão visual 24 x 32, aparência escolhida, câmera e controles globais).
- Preserva os polígonos de colisão enviados pelo colega.
- Spawn em `(735, 1000)` e saída sul em `(735, 1074)` para o mapa-múndi.
- Não importamos o `project.godot`, `player.tscn` e `scripts/player.gd` externos, evitando sobrescrever sistemas existentes.

## Revisão manual no Godot
Verifique visualmente a posição da saída e o caminho livre ao redor do spawn, a geometria das colisões e a escala da câmera. A integração foi inspecionada estaticamente, não executada no editor.
