package main

import "core:fmt"
import "core:math"
import "core:math/rand"
import "vendor:raylib"

SCREEN_WIDTH : i32 : 1024
SCREEN_HEIGHT : i32 : 800
SCENE_WIDTH : f32 : 2000
SCENE_HEIGHT : f32 : 1000
OBJ_RADIUS : f32 : 10.0
OBJ_COLLISION_RADIUS : f32 : 12.0

all_movables := make([dynamic]^Movable, 0, 2000)


//MOVABLE
Movable :: struct{
	movid : int,
	next_pos : raylib.Vector2,
	position : raylib.Vector2,
	advance : raylib.Vector2,
	angle : f32,
	color : raylib.Color,
}

//MAIN
main :: proc() {
	
	using raylib

	V_ZERO := Vector2{ 0.0, 0.0}
	V_HALF_SCREEN := Vector2 { 
		f32(SCREEN_WIDTH) * 0.5, 
		f32(SCREEN_HEIGHT) * 0.5 }

	//WINDOW
	InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "raylib odin test")
	defer(CloseWindow())

	//FPS
	SetTargetFPS(60)
	
	//CAMERA2D
	//target, offset, rotation, zoom
	camera := Camera2D{ V_HALF_SCREEN, V_HALF_SCREEN, 0.0, 1.0 }
	

	//ZOMBIES
	zombies := make([dynamic]Movable, 100) 
	defer( delete(zombies) )
	for &z in zombies {
		initialize_movable(&z)
		z.angle = rand.float32_uniform(0.0, 2 * PI)
		z.color = RED
		z.movid = len( all_movables ) 
		append(&all_movables, &z)
	} 

	//HUMANS
	humans := make([dynamic]Movable, 100)
	defer( delete(humans) )
	for &h in humans {
		initialize_movable(&h)
		h.angle = rand.float32_uniform(0.0, 2 * PI)
		h.color = BLUE
		h.movid = len( all_movables )
		append(&all_movables, &h)
	} 
	
	scenemap := Rectangle{0.0, 0.0, SCENE_WIDTH, SCENE_HEIGHT}

	//PLAYER
	player := Rectangle { V_HALF_SCREEN.x, V_HALF_SCREEN.y, 10, 10 }

	//LOOP
	for !WindowShouldClose() {
		update_states(&player, &camera)

		BeginDrawing()
		defer(EndDrawing())
		BeginMode2D(camera)
		defer(EndMode2D())

		// DRAWING 
		ClearBackground(BLACK)
		DrawRectangleRec(scenemap, RAYWHITE)
		DrawRectangleRec(player, RED)		

		update_movables(zombies, humans)
	}
	delete( all_movables )
}

initialize_movable :: proc(m: ^Movable) {
	m.position = random_vector2( 
		0.0, f32(SCREEN_WIDTH), 
		0.0, f32(SCREEN_HEIGHT))
		
	for m_collides := true; m_collides; {
		m_collides = false
		for x in all_movables {
			if check_collision(m^, x^) {
				m.position = random_vector2(
					0.0, f32(SCREEN_WIDTH),
					0.0, f32(SCREEN_HEIGHT))
				m_collides = true
				break
			}
		}
	}
	m.next_pos = raylib.Vector2{0,0}
}

update_movables :: proc(movables: ..[dynamic]Movable){
	using raylib
	collides : bool

	for movGroup in movables {
		for &m in movGroup {
			m.advance.x, m.advance.y = math.cos(m.angle), math.sin(m.angle)
			m.next_pos = m.position + m.advance
		}
	}


	for movGroup in movables{
		for &m in movGroup {
			collides = false
			for x in all_movables {
				if x.movid == m.movid { continue }
				if will_collide(m, x^){
					collides = true
					break
				}
			}
			if collides == false {
				m.position.x, m.position.y = m.next_pos.x, m.next_pos.y
			}

		}
	}

	for movGroup in movables{
		for &m in movGroup {
			DrawCircleV(m.position, OBJ_RADIUS, m.color)
			DrawCircleLinesV(m.position, OBJ_COLLISION_RADIUS, m.color)
			dirvector := m.position + m.advance * OBJ_COLLISION_RADIUS
			DrawLineV(m.position, dirvector, GREEN)
			m.angle += rand.float32_uniform(-PI*0.05, PI*0.05)
		}
	}
}

update_states :: proc(player: ^raylib.Rectangle, camera: ^raylib.Camera2D){
	if raylib.IsKeyDown(raylib.KeyboardKey.D) { player.x += 2 }
	if raylib.IsKeyDown(raylib.KeyboardKey.A) { player.x -= 2 }
	if raylib.IsKeyDown(raylib.KeyboardKey.W) { player.y -= 2 }
	if raylib.IsKeyDown(raylib.KeyboardKey.S) { player.y += 2 }
	
	camera.target.x, camera.target.y = player.x, player.y
	camera.zoom += f32(raylib.GetMouseWheelMove()) * 0.05
}

random_vector2 :: proc(minx, maxx, miny, maxy : f32) -> raylib.Vector2 {
	return raylib.Vector2{
			rand.float32_uniform(minx, maxx),
			rand.float32_uniform(miny, maxy)}
}

check_collision :: proc(mova, movb : Movable) -> bool {
	return raylib.CheckCollisionCircles(
		mova.position, OBJ_COLLISION_RADIUS,
 		movb.position, OBJ_COLLISION_RADIUS)
}

will_collide :: proc(mova, movb : Movable) -> bool {
	return raylib.CheckCollisionCircles(
		mova.next_pos, OBJ_COLLISION_RADIUS,
		movb.next_pos, OBJ_COLLISION_RADIUS)
}

