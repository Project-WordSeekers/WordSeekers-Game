# Newcastle — integração (14/11/2026)

- Mapa limpo de Newcastle convertido para WebP (1402 × 1122); a imagem com linhas rosas foi utilizada apenas como referência para delimitar colisões.
- Cena: `res://scenes/locations/newcastle/newcastle.tscn`.
- MapPoint Newcastle direciona à cena nova, substituindo o placeholder.
- 16 polígonos `CollisionPolygon2D` delimitam edifícios, mina, fonte, ponte, cais, rio e muros, seguindo o traçado rosa de referência.
- Placas sobre as entradas: Mina de Carvão, Tyne Bridge, Newcastle Castle e St Nicholas Cathedral.
- Catedral: entrada para o templo padrão de Newcastle com cálice de cura; marcador `FromTemple` para retorno.
- Saída ao mapa-múndi na borda inferior central.
- Player compartilhado do projeto, com spawn inicial na região inferior.
- As outras três entradas nomeadas são apenas pontos de interesse: não há interiores específicos fornecidos para mina, ponte ou castelo.
- Verificar no Godot as bordas dos polígonos, placas e portais. Não foi possível executar a engine neste ambiente.
