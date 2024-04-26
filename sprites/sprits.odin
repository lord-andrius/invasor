package sprites

import "core:slice"
import "core:runtime"

CARACTERE_VAZIO :: '*'
CARACTERE_CLARO :: '#'
CARACTERE_ESCURO :: '@'

copia_sprite :: proc(sprite: [][]rune) -> ([][]rune, runtime.Allocator_Error) {
    novo_sprite, erro := make([dynamic][]rune, len(sprite)) 
    if erro != .None do return nil, erro
    for &s, indice in novo_sprite {
        nova_linha, erro := slice.clone(sprite[indice])
        if erro != .None {
            for i in 0..<indice {
                delete(novo_sprite[i])
            }
            delete(novo_sprite)
            return nil, erro
        }
        s = nova_linha
    }
    return novo_sprite[:], .None
}

