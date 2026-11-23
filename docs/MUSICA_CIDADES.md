# Trilha musical das cidades
A trilha original `res://assets/audio/music/cities_theme.ogg` toca automaticamente em todas as cenas externas de cidade, inclusive o cenário provisório compartilhado.
Cambridge conserva seu nó de música original.
Cada cidade usa um `AudioStreamPlayer` com `looping_music.gd`, portanto a música reinicia ao entrar em outra cidade.
Não foi adicionada música aos interiores: templos, mina, biblioteca, capela, castelo, cavernas, escritório e demais interiores.
Ao sair da cidade, o player de música da cena é removido automaticamente, evitando música simultânea no interior.
Validação: estrutura do ZIP; execução no Godot ainda não testada.
