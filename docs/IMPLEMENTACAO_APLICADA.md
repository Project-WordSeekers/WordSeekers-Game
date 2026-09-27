# Implementação aplicada ao projeto

## Alterações principais

- Estrutura de pastas reorganizada para separar cenas, scripts, assets, dados, documentação e protótipos.
- `WorldMapPlayer` movido para `scenes/player/` e seu script para `scripts/player/`.
- `MapPoint` movido para `scenes/world/` com script em `scripts/systems/`.
- `world_map.tscn` movido para `scenes/world/world_map.tscn`.
- Asset das setas movido para `assets/ui/world_map/direction_arrow.png`.
- Sprite do player do mapa-múndi movido para `assets/characters/player/world/player_world.png`.
- Sprite usado pelo player interno copiado para `assets/characters/player/overworld/player_walk.png`.
- `player.tscn` convertido do protótipo 3D para um `CharacterBody2D` reutilizável.
- `cena1.tscn` agora instancia `scenes/player/player.tscn` em vez de manter um player duplicado dentro da cena.
- Adicionados `CollisionShape2D` e `InteractionArea` ao Player interno.
- Adicionado `GameState` como Autoload para persistir o último `MapPoint`.
- `MapPoint` agora possui `destination_scene` opcional.
- `WorldMapPlayer` mostra setas somente nas direções válidas, oculta durante o movimento e restaura ao chegar.
- A ação `interact` é garantida em tempo de execução pelo `GameState` e vinculada à tecla E quando ainda não existir no projeto.
- O protótipo 3D antigo foi preservado em `prototypes/legacy_3d/` para não perder trabalho anterior.
- Arquivos auxiliares sem integração com a cena principal foram preservados em `prototypes/misc/`.
- O cache `.godot/` foi removido do pacote para evitar referências antigas; o Godot irá recriá-lo ao abrir o projeto.

## Ponto propositalmente não automatizado

Nenhum `MapPoint` recebeu uma `destination_scene` automaticamente, pois o projeto não informa de forma inequívoca qual Point representa a vila/cidade de `cena1.tscn`. O campo já está disponível no Inspector para fazer esse vínculo sem alterar novamente os scripts.


## Atualização: Point01 e transições de cena

- `Point01` do mapa-múndi possui `destination_scene = res://scenes/locations/cena1/cena1.tscn`.
- O projeto inicia em `res://scenes/world/world_map.tscn`.
- `SceneTransition` foi adicionado como Autoload (`res://scripts/systems/scene_transition.gd`).
- Toda troca de cena do fluxo implementado deve passar por `SceneTransition.change_scene_to_packed(...)` ou `SceneTransition.change_scene_to_file(...)`.
- O comportamento padrão é: **fade out → troca da cena → fade in**.
- Ao iniciar o jogo, também é executado um fade in.
- A ação `interact` é criada em tempo de execução com a tecla `E` caso ainda não exista no Input Map.

## Camera seguindo o jogador

- `Camera2D` agora e filha de `Player` e `WorldMapPlayer`, portanto acompanha o personagem nos mapas internos e no mapa-mundi.
- O script compartilhado `res://scripts/systems/player_camera.gd` calcula automaticamente o zoom usando como alvo cerca de **30% da area visual da cena**.
- O percentual pode ser ajustado pelo campo `Visible Scene Fraction` da Camera2D no Inspector.
- A camera usa limites baseados no maior `Sprite2D` da cena para reduzir a exibicao de areas fora do mapa.
- `Position Smoothing` foi habilitado para o acompanhamento nao ficar seco.

## Ajuste de câmera em mapas internos

- O mapa-múndi mantém `visible_scene_fraction = 0.30`.
- O Player de mapas internos usa `visible_scene_fraction = 0.12`.
- Como o cálculo da câmera é baseado em área, 0.12 corresponde aproximadamente a 35% das dimensões lineares do mapa, deixando a câmera mais próxima do personagem.
- O valor continua exposto no `Camera2D` do `player.tscn` e pode ser refinado por cena, se necessário.



## Hierarquia atual de cenas

A organização foi ajustada para representar a relação de contenção lógica do jogo:

```text
Mapa Múndi
└── cena1
    └── biblioteca
```

Caminhos correspondentes:

- `res://scenes/world/world_map.tscn`
- `res://scenes/locations/cena1/cena1.tscn`
- `res://scenes/locations/cena1/biblioteca/biblioteca.tscn`

`Point01` leva para `cena1`. A porta da biblioteca em `cena1` leva para `biblioteca`, e a saída da biblioteca retorna para um `Marker2D` em frente à porta em `cena1`. Todas essas trocas utilizam `SceneTransition`, preservando fade out/fade in.

## Áudio

- `cena1`: `res://assets/audio/cena1/musica_cena1.ogg` em loop.
- `biblioteca`: `res://assets/audio/cena1/biblioteca/biblioteca.ogg` em loop.

As faixas antigas da branch colaborativa não foram importadas nem referenciadas.
