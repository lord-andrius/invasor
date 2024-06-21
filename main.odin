// POR FAVOR VERIFICAR POR QUE A COLISÃO QUEBRA QUANDO APROXIMAMOS O ESCUDO DO JOGADOR
package main

import rl "vendor:raylib"
import "core:math/rand"
import "core:time"
import "sprites"
import "core:fmt"
import "core:runtime"

LARGURA :: 480
ALTURA :: 640
VERDE :: rl.Color{3,111,61,255}
VERDE_CLARO :: rl.Color{3 * 2, 111 * 2, 61 * 2,255}
FONTE_BASE :: 30
TAMANHO_TIRO :: rl.Vector2{1, 10}
COR_TIRO :: rl.Color{255,0,0,255}
VEL_TIRO :: 5
POS_PRIMEIRO_ESCUDO :: [?]i32{50,ALTURA - (ALTURA / 5)}
SCALA_PADRAO :: 5

EstadoDeJogo :: enum {
	Menu,
	Jogando,
	Pausado,
}

OpcoesMenu :: enum {
	Jogar,
	Sair,
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

menu :: proc(opcoes_menu: map[OpcoesMenu]cstring, opcao_selecionada: ^OpcoesMenu, estado:^EstadoDeJogo,continuar: ^bool) {
	tamanho_fonte : i32 = FONTE_BASE * 2
	titulo: cstring = "O Invasor"
	x_titulo: i32 = LARGURA / 2 - (rl.MeasureText(titulo, tamanho_fonte) / 2)
	y_titulo: i32 = ALTURA /2 - (tamanho_fonte)
	rl.DrawText(titulo, x_titulo, y_titulo, tamanho_fonte, VERDE)

	tamanho_fonte_opcao:i32 = FONTE_BASE + 10 if opcao_selecionada^ == .Jogar else FONTE_BASE
	cor_opcao: rl.Color = VERDE_CLARO if opcao_selecionada^ == .Jogar else VERDE
	x_opcao: i32 = LARGURA / 2 - (rl.MeasureText(opcoes_menu[.Jogar], tamanho_fonte_opcao) / 2) 
	y_opcao: i32 = y_titulo + tamanho_fonte 
	rl.DrawText(opcoes_menu[.Jogar], x_opcao, y_opcao, tamanho_fonte_opcao, cor_opcao)

	tamanho_fonte_opcao = FONTE_BASE + 10 if opcao_selecionada^ == .Sair else FONTE_BASE
	cor_opcao = VERDE_CLARO if opcao_selecionada^ == .Sair else VERDE
	x_opcao = LARGURA / 2 - (rl.MeasureText(opcoes_menu[.Sair], tamanho_fonte_opcao) / 2) 
	y_opcao += tamanho_fonte
	rl.DrawText(opcoes_menu[.Sair], x_opcao, y_opcao, tamanho_fonte_opcao, cor_opcao)

	if rl.IsKeyPressed(.DOWN) {
		opcao_selecionada^ = .Sair if opcao_selecionada^ == .Jogar else .Jogar	
	} else if rl.IsKeyPressed(.UP) {

		opcao_selecionada^ = .Jogar if opcao_selecionada^ == .Sair else .Sair	
	}	

	if rl.IsKeyPressed(.ENTER) {
		#partial switch opcao_selecionada^ {
			case .Sair:
				continuar^ = false
			case .Jogar:
				estado^ = .Jogando
		}	
	}
 }


 desenha_sprite :: proc(sprite: [][]rune, x:i32, y:i32,scala: i32 = SCALA_PADRAO,vazio: rune = sprites.CARACTERE_VAZIO, claro: rune = sprites.CARACTERE_CLARO, escuro: rune = sprites.CARACTERE_ESCURO) {
	y := y
	for linha in sprite {
		x_tmp := x
		for coluna in linha {
			if coluna == claro {
				rl.DrawRectangle(x_tmp,y,scala,scala,VERDE_CLARO)
			} else if coluna == escuro {
				rl.DrawRectangle(x_tmp,y,scala,scala, VERDE)
			}
			x_tmp += scala
		}
		y += scala
	}

 }


tiro :: proc(tiros: []rl.Vector3, frame_time: f32, escudos: [3][][]rune) { 
	tiros := tiros	
	for &tiro in tiros {
		if tiro[1] < TAMANHO_TIRO[1] + ALTURA && tiro[1] > -TAMANHO_TIRO[1] {
			tiro[1] += f32((1 + frame_time) * tiro[2])
		}
		rl.DrawRectangleV({tiro[0],tiro[1]}, TAMANHO_TIRO, COR_TIRO)
	}
	x_escudo, y_escudo := POS_PRIMEIRO_ESCUDO[0], POS_PRIMEIRO_ESCUDO[1]
	for escudo in escudos {
	    y_parte_escudo := f32(y_escudo)
	    for linha_escudo, num_linha_escudo in escudo {
		x_parte_escudo := f32(x_escudo)
		for &parte_escudo, num_coluna_escudo in linha_escudo {
		    parte_escudo_rec := rl.Rectangle{
		       x_parte_escudo,
		       y_parte_escudo,
		       SCALA_PADRAO,
		       SCALA_PADRAO
		    }
		    for &tiro in tiros {
			tiro_rec := rl.Rectangle {
			    f32(tiro[0]),
			    f32(tiro[1]),
			    f32(TAMANHO_TIRO[0]),
			    f32(TAMANHO_TIRO[1])
			}
			if rl.CheckCollisionRecs(parte_escudo_rec, tiro_rec) && parte_escudo != sprites.CARACTERE_VAZIO {
			    tiro[1] = -TAMANHO_TIRO[1]
			    parte_escudo = sprites.CARACTERE_VAZIO 
			}
		    }
		    x_parte_escudo += SCALA_PADRAO
		}
		y_parte_escudo += SCALA_PADRAO
	    }
	    x_escudo += i32(len(escudo[0])) * SCALA_PADRAO + LARGURA / 4 
	}
}

nave :: proc(x_nave:^i32, y_nave:^i32, scala_nave: i32, tiros_nave:[]rl.Vector3, frame_time: f32) {
	sprite_nave := sprites.SPRITES_JOGADOR.Parado
	x_minimo_nave: i32 = 0
	x_maximo_nave: i32 = LARGURA - i32(len(sprites.SPRITE_JOGADOR[sprite_nave][0])) * scala_nave

	if rl.IsKeyDown(.LEFT) && x_nave^ >= x_minimo_nave + i32((1 + frame_time) * 5){ // limitando o movimento na lateral
		x_nave^ -= i32((1 + frame_time) * 5)
	} else if rl.IsKeyDown(.RIGHT)  && x_nave^ <= x_maximo_nave - i32((1 + frame_time) * 5){ // limitando o movimento na lateral
		x_nave^ += i32((1 + frame_time) * 5)
	}

	if rl.IsKeyPressed(.SPACE) {
		indice_tiro_disponivel: int = -1 // -1 quer dizer sem tiro disponivel
		for tiro, indice in tiros_nave {
			if tiro[1] >= ALTURA + TAMANHO_TIRO[1] || tiro[1] < 0{ // verifica se o tiro está fora da tela
				indice_tiro_disponivel = indice
			}
		}
		
		if indice_tiro_disponivel > -1 {
			tiros_nave[indice_tiro_disponivel][0] = f32(x_nave^ + (5  * scala_nave) - i32(TAMANHO_TIRO[0]))
			tiros_nave[indice_tiro_disponivel][1] = f32(y_nave^)
			tiros_nave[indice_tiro_disponivel][2] = -VEL_TIRO
		}

	}
	
	desenha_sprite(sprites.SPRITE_JOGADOR[sprite_nave][:][:], x_nave^, y_nave^, scala_nave)

}

inicializa_escudos :: proc() -> [3][][]rune {
	escudos: [3][][]rune = ---
	for &escudo in escudos {
		erro: runtime.Allocator_Error
		escudo, erro = sprites.copia_sprite(sprites.SPRITE_ESCUDO)
		if erro != .None do panic("Erro ao alocar os sprites do escudo")
        }
	return escudos
}

escudo :: proc(escudos: [3][][]rune) {
	x_escudo, y_escudo := POS_PRIMEIRO_ESCUDO[0], POS_PRIMEIRO_ESCUDO[1]
	for escudo in escudos {
	    desenha_sprite(escudo,x_escudo, y_escudo)
	    x_escudo += i32(len(escudo[0])) * SCALA_PADRAO + LARGURA / 4 
	}
} 


Inimigos :: struct {
	posicao: []rl.Vector2
	sprite: []sprites.SPRITES_INVASOR
}


inimigos :: proc (inimigos: []Inimigos) {
	using inimigos
	for indice in 0..<len(inimigos)

}


main :: proc() {
	estado := EstadoDeJogo.Menu
	rand.set_global_seed(u64(time.to_unix_nanoseconds(time.now())))
	estrelas := inicializar_estrelas()
	opcoes_menu := make(map[OpcoesMenu]cstring)
	opcoes_menu[.Jogar] = "Jogar"
	opcoes_menu[.Sair] = "Sair"
	defer delete(opcoes_menu)
	opcao_selecionada := OpcoesMenu.Jogar
	x_nave: i32 = 0
	scala_nave: i32 = 5
	y_nave: i32 = ALTURA - (i32(len(sprites.SPRITE_JOGADOR[0])) * scala_nave)
	continuar := true
    escudos: [3][][]rune = inicializa_escudos()
    defer for escudo in escudos {
        delete(escudo)
    }

	tiros := [?]rl.Vector3{{0,ALTURA + 10,0},{0,ALTURA + 10,0},{0,ALTURA + 10,0},{0,ALTURA + 10,0},{0,ALTURA + 10,0},{0,ALTURA + 10,0},{0,ALTURA + 10,0},{0,ALTURA + 10,0},{0,ALTURA + 10,0},{0,ALTURA + 10,0}}
	qtd_tiros := len(tiros)
	tiros_nave := tiros[:4]

	rl.InitWindow(LARGURA, ALTURA, "Invasores do espaco")	
	defer rl.CloseWindow()
	rl.SetTargetFPS(60)
	for (!rl.WindowShouldClose() && continuar == true){
		frame_time := rl.GetFrameTime()
		rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)
		desenhar_estrelas(estrelas)
		switch estado {
			case .Menu:
				menu(opcoes_menu, &opcao_selecionada, &estado, &continuar)	
			case .Jogando:
		                tiro(tiros[:], frame_time, escudos) // tiro deve ser desenhado primeiro para dar a impressão do tiro siar de baixo da nave
				nave(&x_nave, &y_nave, scala_nave, tiros_nave, frame_time)
				escudo(escudos)
			
			case .Pausado:
		}
		rl.EndDrawing()
	}
}
