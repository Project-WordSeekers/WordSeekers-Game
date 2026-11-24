# Merge seletivo — York, Manchester, portais e retorno de templos

## Incorporado
- Mapas de York e Manchester, com polígonos de colisão do projeto do colega.
- Imagens convertidas para WebP lossless, preservando dimensões.
- MapPoints York e Manchester agora apontam às cenas reais, sem placeholders.
- York: entrada conectada a `temple_york.tscn`, com `FromTemple` na cidade.
- Manchester: não recebe templo padrão, conforme a lista oficial de seis cidades.
- Proteção contra reentrada de portais: ignora corpos sobrepostos nos primeiros três frames de física, até saírem do portal.
- Retorno do templo: mantém origem e marcador salvos; fallback ao mapa-múndi quando a cena é aberta sem origem.
- Nenhuma `cena1`, `point02` ou templo de Canterbury/Winchester importado.
- Newcastle, mina e pergaminho preservados.

## Atenção
- Não houve execução da engine Godot 4 neste ambiente.
- Testar colisões e posição dos marcadores de York e Manchester.
- O retorno do templo requer verificação prática, especialmente em cidades com portais posicionados muito próximos da porta.
