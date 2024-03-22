package main

import rl "vendor:raylib"
import "core:math/rand"
import "core:time"

LARGURA :: 480
ALTURA :: 640

EstadoDeJogo :: enum {
	Menu,
	Jogando,
	Pausado,
}

BufferEstrelas: [100]rl.Vector3
inicializar_estrelas :: proc() -> []rl.Vector3 {
	qtd_estrelas := rand.int31_max(len(BufferEstrelas))
	for i in 0..=qtd_estrelas {
		BufferEstrelas[i][0] = f32(rand.int31_max(LARGURA) + 1)
		BufferEstrelas[i][1] = f32(rand.int31_max(ALTURA) + 1)
		BufferEstrelas[i][2] = rand.float32() 
	}
	return BufferEstrelas[:qtd_estrelas + 1]
}

desenhar_estrelas :: proc(estrelas: []rl.Vector3) {
	for estrela in estrelas {
		rl.DrawRectangleV({estrela[0], estrela[1]}, estrela[2], rl.WHITE)
	}
}


main :: proc() {
	estado := EstadoDeJogo.Menu
	rand.set_global_seed(u64(time.to_unix_nanoseconds(time.now())))
	estrelas := inicializar_estrelas()
	rl.InitWindow(LARGURA, ALTURA, "Invasores do espaco")	
	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)
		desenhar_estrelas(estrelas)
		switch estado {
			case .Menu:
				tamanho_fonte : i32 = 60
				titulo: cstring = "O Invasor"
				x_titulo: i32 = LARGURA / 2 - (rl.MeasureText(titulo, tamanho_fonte) / 2)
				y_titulo: i32= ALTURA /4 - (tamanho_fonte / 2)
				rl.DrawText(titulo, x_titulo, y_titulo, tamanho_fonte, rl.Color{3,111,61,255})
			case .Jogando:
			case .Pausado:
		}
		rl.EndDrawing()
	}
}