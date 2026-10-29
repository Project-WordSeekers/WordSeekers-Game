Templos reutilizáveis - WordSeekers

A cena scenes/temples/temple.tscn é a estrutura compartilhada (paredes, cálice, jogador e saída).
As cenas temple_colchester.tscn, temple_canterbury.tscn e temple_winchester.tscn herdam dela e personalizam apenas NPC e destino da saída.
A cena temple_npc.tscn e o script simple_dialogue_npc.gd são reutilizados.

IMPORTANTE: O ZIP de origem não contém o PNG original do templo. A cena antiga fazia referência direta a um arquivo .ctex em .godot/imported/ que também não estava no ZIP. Essa referência inválida foi retirada para permitir a abertura da cena; será necessário reatribuir a textura original do templo em TempleBase/TileMapLayer/Sprite2D quando o PNG estiver disponível.

As cenas dos templos foram criadas sem adicionar portais nas cidades, pois o projeto não informa quais prédios/portas devem levar a elas. Abra uma cena temple_<cidade>.tscn diretamente no editor para testá-la. Ao conectar uma porta, use scene_portal.gd e aponte para a cena do templo correspondente.

Os diálogos e a aparência do NPC são provisórios e podem ser personalizados em cada cena herdada.
