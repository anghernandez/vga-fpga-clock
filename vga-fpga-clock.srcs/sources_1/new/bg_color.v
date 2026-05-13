// =============================================================================
// bg_color.v
// Módulo combinacional de fondo pixel-art para reloj VGA 640×480
// EL3313 Taller de Diseño Digital - I Sem 2026
//
// Traducción directa de vga_sim.py (build_bg + helpers).
// Puramente combinacional: always @(*), sin registros, sin reloj.
//
// Entradas:
//   x, y      - coordenada del píxel actual (0-639, 0-479)
//   phase     - 2'b00 DAWN | 2'b01 DAY | 2'b10 DUSK | 2'b11 NIGHT
//   astro_cy  - Y fija del astro según fase (ver top_clock_vga.v)
//
// Salida:
//   rgb       - color RGB332 del píxel de fondo
//
// Orden de capas (de atrás hacia adelante):
//   1. Cielo base
//   2. Estrellas   (solo DAWN / NIGHT)
//   3. Astro       (luna o sol)
//   4. Nubes
//   5. Montaña B   (trasera, cx=210)
//   6. Montaña A   (delantera, cx=320)
//   7. Suelo
// =============================================================================

module bg_color (
    input  wire [9:0] x,
    input  wire [9:0] y,
    input  wire [1:0] phase,
    input  wire [9:0] astro_cy,
    output reg  [7:0] rgb
);

// ---------------------------------------------------------------------------
// Parámetros de fase
// ---------------------------------------------------------------------------
localparam DAWN  = 2'b00;
localparam DAY   = 2'b01;
localparam DUSK  = 2'b10;
localparam NIGHT = 2'b11;

// ---------------------------------------------------------------------------
// Helpers RGB888→RGB332
// r3g3b2: toma los 3 MSB de R, 3 MSB de G, 2 MSB de B
// Los valores de color abajo ya están pre-calculados en RGB332.
// ---------------------------------------------------------------------------
// Macro local: rgb332(r8,g8,b8) = {r8[7:5], g8[7:5], b8[7:6]}
// Se usan funciones de tarea de valor constante para claridad.

// ---------------------------------------------------------------------------
// Colores de cielo RGB332 (pre-calculados desde Python)
//   DAWN  sky (24,16,58)  → R=24→000, G=16→000, B=58→01  → 8'h01
//   DAY   sky (72,152,220)→ R=72→010, G=152→100,B=220→11 → 8'h4B  (010_100_11)
//   DUSK  sky (184,60,16) → R=184→101,G=60→001, B=16→00  → 8'hA4  (101_001_00)
//   NIGHT sky (12,20,48)  → R=12→000, G=20→000, B=48→01  → 8'h01
// ---------------------------------------------------------------------------
localparam [7:0] SKY_DAWN  = 8'b000_000_01;   // (24,16,58)
localparam [7:0] SKY_DAY   = 8'b010_100_11;   // (72,152,220)
localparam [7:0] SKY_DUSK  = 8'b101_001_00;   // (184,60,16)
localparam [7:0] SKY_NIGHT = 8'b000_000_01;   // (12,20,48)

// ---------------------------------------------------------------------------
// Colores de suelo RGB332
// GROUND_COLORS = {phase: (base, dark, grass)}
//   DAWN  base(18,48,18)  dark(12,32,12)  grass(26,64,26)
//   DAY   base(42,122,42) dark(26,90,26)  grass(58,154,58)
//   DUSK  base(60,36,8)   dark(40,24,4)   grass(88,56,16)
//   NIGHT base(14,36,14)  dark(8,22,8)    grass(20,52,20)
// ---------------------------------------------------------------------------
localparam [7:0] GROUND_DAWN_GRASS  = 8'b000_001_01;  // (26,64,26)
localparam [7:0] GROUND_DAWN_BASE   = 8'b000_000_00;  // (18,48,18)
localparam [7:0] GROUND_DAWN_DARK   = 8'b000_001_00;  // (12,32,12) ≈ misma banda

localparam [7:0] GROUND_DAY_GRASS   = 8'b001_100_01;  // (58,154,58)
localparam [7:0] GROUND_DAY_BASE    = 8'b001_011_01;  // (42,122,42)
localparam [7:0] GROUND_DAY_DARK    = 8'b000_010_01;  // (26,90,26)

localparam [7:0] GROUND_DUSK_GRASS  = 8'b010_001_00;  // (88,56,16)
localparam [7:0] GROUND_DUSK_BASE   = 8'b001_001_00;  // (60,36,8)
localparam [7:0] GROUND_DUSK_DARK   = 8'b001_000_00;  // (40,24,4)

localparam [7:0] GROUND_NIGHT_GRASS = 8'b000_001_01;  // (20,52,20)
localparam [7:0] GROUND_NIGHT_BASE  = 8'b000_001_00;  // (14,36,14)
localparam [7:0] GROUND_NIGHT_DARK  = 8'b000_000_00;  // (8,22,8)

// ---------------------------------------------------------------------------
// Colores de nubes RGB332
// CLOUD_COLORS = {phase: (dark, light, highlight)}
//   DAWN  dark(90,40,152) light(112,56,176) hl(168,88,72)
//   DAY   dark(192,192,212) light(224,224,236) hl(255,255,255)
//   DUSK  dark(120,32,154) light(152,48,180) hl(208,96,48)
//   NIGHT dark(48,24,104) light(72,40,128) hl(104,72,160)
// ---------------------------------------------------------------------------
localparam [7:0] CLOUD_DAWN_DARK  = 8'b010_001_10;  // (90,40,152)
localparam [7:0] CLOUD_DAWN_LIGHT = 8'b011_001_10;  // (112,56,176)
localparam [7:0] CLOUD_DAWN_HL    = 8'b101_010_01;  // (168,88,72)

localparam [7:0] CLOUD_DAY_DARK   = 8'b110_110_11;  // (192,192,212)
localparam [7:0] CLOUD_DAY_LIGHT  = 8'b111_111_11;  // (224,224,236)
localparam [7:0] CLOUD_DAY_HL     = 8'b111_111_11;  // (255,255,255)

localparam [7:0] CLOUD_DUSK_DARK  = 8'b011_001_10;  // (120,32,154)
localparam [7:0] CLOUD_DUSK_LIGHT = 8'b100_001_10;  // (152,48,180)
localparam [7:0] CLOUD_DUSK_HL    = 8'b110_011_01;  // (208,96,48)

localparam [7:0] CLOUD_NIGHT_DARK = 8'b001_000_10;  // (48,24,104)
localparam [7:0] CLOUD_NIGHT_LIGHT= 8'b010_001_10;  // (72,40,128)
localparam [7:0] CLOUD_NIGHT_HL   = 8'b011_010_10;  // (104,72,160)

// ---------------------------------------------------------------------------
// Colores de montañas RGB332
// MTN_COLORS = {phase: (A_light, A_dark, B_light, B_dark)}
//   DAWN  AL(42,64,96) AD(26,48,80) BL(26,46,68) BD(16,32,52)
//   DAY   AL(58,144,64) AD(42,120,48) BL(46,120,48) BD(32,96,36)
//   DUSK  AL(52,20,8) AD(36,12,4) BL(30,12,4) BD(20,8,2)
//   NIGHT AL(24,36,48) AD(14,24,36) BL(14,26,40) BD(8,16,24)
// ---------------------------------------------------------------------------
localparam [7:0] MTN_DAWN_AL  = 8'b001_010_01;  // (42,64,96)
localparam [7:0] MTN_DAWN_AD  = 8'b000_001_01;  // (26,48,80)
localparam [7:0] MTN_DAWN_BL  = 8'b000_001_01;  // (26,46,68)
localparam [7:0] MTN_DAWN_BD  = 8'b000_001_01;  // (16,32,52)

localparam [7:0] MTN_DAY_AL   = 8'b001_100_01;  // (58,144,64)
localparam [7:0] MTN_DAY_AD   = 8'b001_011_01;  // (42,120,48)
localparam [7:0] MTN_DAY_BL   = 8'b001_011_01;  // (46,120,48)
localparam [7:0] MTN_DAY_BD   = 8'b001_011_00;  // (32,96,36)

localparam [7:0] MTN_DUSK_AL  = 8'b001_000_00;  // (52,20,8)
localparam [7:0] MTN_DUSK_AD  = 8'b001_000_00;  // (36,12,4)
localparam [7:0] MTN_DUSK_BL  = 8'b000_000_00;  // (30,12,4)
localparam [7:0] MTN_DUSK_BD  = 8'b000_000_00;  // (20,8,2)

localparam [7:0] MTN_NIGHT_AL = 8'b001_010_10;  // (24,36,48)
localparam [7:0] MTN_NIGHT_AD = 8'b000_001_10;  // (14,24,36)
localparam [7:0] MTN_NIGHT_BL = 8'b000_010_10;  // (14,26,40)
localparam [7:0] MTN_NIGHT_BD = 8'b000_001_01;  // (8,16,24)

// ---------------------------------------------------------------------------
// Colores del astro RGB332
// ---------------------------------------------------------------------------
// Luna núcleo/anillo/manchas
localparam [7:0] MOON_OUTER  = 8'b110_101_00;  // (220,188,48)  → 110_101_00
localparam [7:0] MOON_INNER  = 8'b111_110_01;  // (242,212,80)  → 111_110_01
localparam [7:0] MOON_SPOT   = 8'b110_100_00;  // (192,158,28)  → 110_100_00

// Sol día
localparam [7:0] SUN_OUTER   = 8'b111_111_10;  // (255,255,200) → 111_111_10
localparam [7:0] SUN_INNER   = 8'b111_111_01;  // (255,240,120) → 111_111_01
localparam [7:0] SUN_RAY     = 8'b111_110_00;  // (255,208,32)  → 111_110_00

// Sol atardecer (halos concéntricos)
localparam [7:0] DUSK_H1     = 8'b111_010_00;  // (255,80,16)   → 111_010_00
localparam [7:0] DUSK_H2     = 8'b111_100_01;  // (255,148,40)  → 111_100_01
localparam [7:0] DUSK_H3     = 8'b111_110_01;  // (255,210,72)  → 111_110_01
localparam [7:0] DUSK_CORE   = 8'b111_111_10;  // (255,248,160) → 111_111_10

// ---------------------------------------------------------------------------
// Constantes de geometría
// ---------------------------------------------------------------------------
localparam signed [10:0] ASTRO_CX    = 11'sd530;
localparam        [9:0]  HORIZON_Y   = 10'd340;

// Montaña A
localparam [9:0] MTN_A_CX     = 10'd320;
localparam [3:0] MTN_A_LEVELS = 4'd15;   // índice 0..15 → 16 niveles

// Montaña B
localparam [9:0] MTN_B_CX     = 10'd210;
localparam [3:0] MTN_B_LEVELS = 4'd11;   // índice 0..11 → 12 niveles

localparam [4:0] STEP_H = 5'd16;
localparam [4:0] STEP_W = 5'd16;

// Radio del astro
localparam [5:0] MOON_R_OUTER = 6'd30;
localparam [5:0] MOON_R_INNER = 6'd24;
localparam [5:0] SUN_R_OUTER  = 6'd26;
localparam [5:0] SUN_R_INNER  = 6'd18;   // 26-8
localparam [5:0] DUSK_R1      = 6'd44;
localparam [5:0] DUSK_R2      = 6'd32;
localparam [5:0] DUSK_R3      = 6'd20;
localparam [5:0] DUSK_R4      = 6'd10;

// ---------------------------------------------------------------------------
// Wires de trabajo (signed para restas de coordenadas)
// ---------------------------------------------------------------------------
wire signed [10:0] dx_astro = $signed({1'b0, x}) - ASTRO_CX;
wire signed [10:0] dy_astro = $signed({1'b0, y}) - $signed({1'b0, astro_cy});

// dist² del astro (capped a 22 bits, máx ~530²+480² ≈ 510.000 < 2²⁰)
wire [21:0] dist2_astro = dx_astro * dx_astro + dy_astro * dy_astro;

// ---------------------------------------------------------------------------
// Funciones de pertenencia a pirámide
// Devuelven 1 si el píxel (x,y) pertenece a ese nivel de la pirámide.
// Se implementa con un generate + OR de todos los niveles.
// ---------------------------------------------------------------------------

// ── Pirámide helper: dado cx, level_idx (0=pico), devuelve si (x,y) está en él
// Para evitar multiplicaciones: half_w = (level*2+1)*STEP_W/2 = level*STEP_W + STEP_W/2
// Usamos la forma: x dentro de [cx - half_w, cx + half_w)
//                  y dentro de [HORIZON_Y - (level+1)*STEP_H, HORIZON_Y - level*STEP_H)

// Montaña A - 16 niveles
// Montaña B - 12 niveles
// Se implementa con bloques generate.

// Señales de resultado de pirámide
wire in_mtn_a;
wire in_mtn_a_shadow;   // en la mitad derecha (shadow) de montaña A
wire in_mtn_b;
wire in_mtn_b_shadow;

// Arrays temporales para el OR de niveles
wire [15:0] mtn_a_hit;
wire [15:0] mtn_a_shad;
wire [11:0] mtn_b_hit;
wire [11:0] mtn_b_shad;

genvar gi;
generate
    // ── Montaña A (cx=320, 16 niveles)
    for (gi = 0; gi < 16; gi = gi + 1) begin : GEN_MTN_A
        // level = gi (0=pico, 15=base)
        // half_w = gi*STEP_W + STEP_W/2  = gi*16 + 8
        // shadow_w = STEP_W/2 = 8
        // y_top = HORIZON_Y - (gi+1)*STEP_H
        // y_bot = y_top + STEP_H
        localparam signed [10:0] HW  = (15 - gi) * 16 + 8;
        localparam signed [10:0] SW  = 8;
        localparam        [9:0]  YT  = HORIZON_Y - (gi + 1) * 16;

        wire in_y  = (y >= YT) && (y < YT + 10'd16);
        wire in_x  = ($signed({1'b0,x}) >= ($signed({1'b0, MTN_A_CX}) - HW)) &&
                     ($signed({1'b0,x}) <  ($signed({1'b0, MTN_A_CX}) + HW));
        // sombra: mitad derecha
        wire in_sh = ($signed({1'b0,x}) >= ($signed({1'b0, MTN_A_CX}) + HW - SW)) &&
                     ($signed({1'b0,x}) <  ($signed({1'b0, MTN_A_CX}) + HW));

        assign mtn_a_hit [gi] = in_y && in_x;
        assign mtn_a_shad[gi] = in_y && in_sh;
    end

    // ── Montaña B (cx=210, 12 niveles)
    for (gi = 0; gi < 12; gi = gi + 1) begin : GEN_MTN_B
        localparam signed [10:0] HW  = (11 - gi) * 16 + 8;
        localparam signed [10:0] SW  = 8;
        localparam        [9:0]  YT  = HORIZON_Y - (gi + 1) * 16;

        wire in_y  = (y >= YT) && (y < YT + 10'd16);
        wire in_x  = ($signed({1'b0,x}) >= ($signed({1'b0, MTN_B_CX}) - HW)) &&
                     ($signed({1'b0,x}) <  ($signed({1'b0, MTN_B_CX}) + HW));
        wire in_sh = ($signed({1'b0,x}) >= ($signed({1'b0, MTN_B_CX}) + HW - SW)) &&
                     ($signed({1'b0,x}) <  ($signed({1'b0, MTN_B_CX}) + HW));

        assign mtn_b_hit [gi] = in_y && in_x;
        assign mtn_b_shad[gi] = in_y && in_sh;
    end
endgenerate

assign in_mtn_a        = |mtn_a_hit;
assign in_mtn_a_shadow = |(mtn_a_hit & mtn_a_shad);
assign in_mtn_b        = |mtn_b_hit;
assign in_mtn_b_shadow = |(mtn_b_hit & mtn_b_shad);

// ---------------------------------------------------------------------------
// Nubes - 2 grupos, 4 capas cada uno (rectángulos apilados hacia arriba)
// CLOUD_DEFS = [(130,108,110), (490,88,90)]
// layers relativas a cy_base (empezando hacia ARRIBA):
//   capa 0 (base):  w=wb,    h=14, dy_from_base=0        → y=[cy_base..cy_base+14)
//   capa 1:         w=wb-18, h=16, dy_from_base=-16       → y=[cy_base-16..cy_base)
//   capa 2:         w=wb-36, h=14, dy_from_base=-16-14    → y=[cy_base-30..cy_base-16)
//   capa 3 (cima):  w=wb-54, h=12, dy_from_base=-16-14-12 → y=[cy_base-42..cy_base-30)
//
// El highlight es un sub-rect: x+4, y+2, w//3, h=6 dentro de capas LIGHT (1,2,3)
// Para RGB332 usamos: capa 0 = DARK, capas 1-3 = LIGHT, sub-rect = HL
// ---------------------------------------------------------------------------

// Nube izquierda: cx=130, cy_base=108, wb=110
// Nube derecha:   cx=490, cy_base=88,  wb=90

// Función inline: ¿está (x,y) en un rect [x0,x0+w) × [y0,y0+h)?
// Se expande a wires para cada nube×capa.

// ── Nube izquierda (cx=130, cy=108, wb=110)
localparam [9:0] CL_CX = 10'd130;
localparam [9:0] CL_CY = 10'd108;
localparam [6:0] CL_WB = 7'd110;

wire cl_L0 = (x >= CL_CX - CL_WB/2) && (x < CL_CX + CL_WB/2) &&
             (y >= CL_CY)            && (y < CL_CY + 10'd14);
wire cl_L1 = (x >= CL_CX - (CL_WB-18)/2) && (x < CL_CX + (CL_WB-18)/2) &&
             (y >= CL_CY - 10'd16)         && (y < CL_CY);
wire cl_L2 = (x >= CL_CX - (CL_WB-36)/2) && (x < CL_CX + (CL_WB-36)/2) &&
             (y >= CL_CY - 10'd30)         && (y < CL_CY - 10'd16);
wire cl_L3 = (x >= CL_CX - (CL_WB-54)/2) && (x < CL_CX + (CL_WB-54)/2) &&
             (y >= CL_CY - 10'd42)         && (y < CL_CY - 10'd30);

// Highlight de nube izquierda (solo dentro de capas LIGHT = L1,L2,L3)
wire cl_HL1 = cl_L1 && (x >= CL_CX - (CL_WB-18)/2 + 10'd4) &&
                        (x <  CL_CX - (CL_WB-18)/2 + 10'd4 + (CL_WB-18)/3) &&
                        (y >= CL_CY - 10'd16 + 10'd2) && (y < CL_CY - 10'd16 + 10'd8);
wire cl_HL2 = cl_L2 && (x >= CL_CX - (CL_WB-36)/2 + 10'd4) &&
                        (x <  CL_CX - (CL_WB-36)/2 + 10'd4 + (CL_WB-36)/3) &&
                        (y >= CL_CY - 10'd30 + 10'd2) && (y < CL_CY - 10'd30 + 10'd8);
wire cl_HL3 = cl_L3 && (x >= CL_CX - (CL_WB-54)/2 + 10'd4) &&
                        (x <  CL_CX - (CL_WB-54)/2 + 10'd4 + (CL_WB-54)/3) &&
                        (y >= CL_CY - 10'd42 + 10'd2) && (y < CL_CY - 10'd42 + 10'd8);

wire in_cloud_left    = cl_L0 || cl_L1 || cl_L2 || cl_L3;
wire in_cloud_left_hl = cl_HL1 || cl_HL2 || cl_HL3;
wire in_cloud_left_dk = cl_L0;

// ── Nube derecha (cx=490, cy=88, wb=90)
localparam [9:0] CR_CX = 10'd490;
localparam [9:0] CR_CY = 10'd88;
localparam [6:0] CR_WB = 7'd90;

wire cr_L0 = (x >= CR_CX - CR_WB/2) && (x < CR_CX + CR_WB/2) &&
             (y >= CR_CY)            && (y < CR_CY + 10'd14);
wire cr_L1 = (x >= CR_CX - (CR_WB-18)/2) && (x < CR_CX + (CR_WB-18)/2) &&
             (y >= CR_CY - 10'd16)         && (y < CR_CY);
wire cr_L2 = (x >= CR_CX - (CR_WB-36)/2) && (x < CR_CX + (CR_WB-36)/2) &&
             (y >= CR_CY - 10'd30)         && (y < CR_CY - 10'd16);
wire cr_L3 = (x >= CR_CX - (CR_WB-54)/2) && (x < CR_CX + (CR_WB-54)/2) &&
             (y >= CR_CY - 10'd42)         && (y < CR_CY - 10'd30);

wire cr_HL1 = cr_L1 && (x >= CR_CX - (CR_WB-18)/2 + 10'd4) &&
                        (x <  CR_CX - (CR_WB-18)/2 + 10'd4 + (CR_WB-18)/3) &&
                        (y >= CR_CY - 10'd16 + 10'd2) && (y < CR_CY - 10'd16 + 10'd8);
wire cr_HL2 = cr_L2 && (x >= CR_CX - (CR_WB-36)/2 + 10'd4) &&
                        (x <  CR_CX - (CR_WB-36)/2 + 10'd4 + (CR_WB-36)/3) &&
                        (y >= CR_CY - 10'd30 + 10'd2) && (y < CR_CY - 10'd30 + 10'd8);
wire cr_HL3 = cr_L3 && (x >= CR_CX - (CR_WB-54)/2 + 10'd4) &&
                        (x <  CR_CX - (CR_WB-54)/2 + 10'd4 + (CR_WB-54)/3) &&
                        (y >= CR_CY - 10'd42 + 10'd2) && (y < CR_CY - 10'd42 + 10'd8);

wire in_cloud_right    = cr_L0 || cr_L1 || cr_L2 || cr_L3;
wire in_cloud_right_hl = cr_HL1 || cr_HL2 || cr_HL3;
wire in_cloud_right_dk = cr_L0;

wire in_cloud    = in_cloud_left    || in_cloud_right;
wire in_cloud_hl = in_cloud_left_hl || in_cloud_right_hl;
wire in_cloud_dk = in_cloud_left_dk || in_cloud_right_dk;

// ---------------------------------------------------------------------------
// Estrellas - 20 posiciones fijas (solo DAWN / NIGHT)
// ---------------------------------------------------------------------------
wire is_star;
assign is_star = (
    (x == 10'd45  && y == 10'd55)  || (x == 10'd98  && y == 10'd40)  ||
    (x == 10'd160 && y == 10'd70)  || (x == 10'd210 && y == 10'd48)  ||
    (x == 10'd255 && y == 10'd60)  || (x == 10'd300 && y == 10'd38)  ||
    (x == 10'd350 && y == 10'd80)  || (x == 10'd70  && y == 10'd90)  ||
    (x == 10'd180 && y == 10'd110) || (x == 10'd320 && y == 10'd85)  ||
    (x == 10'd470 && y == 10'd100) || (x == 10'd580 && y == 10'd95)  ||
    (x == 10'd130 && y == 10'd130) || (x == 10'd390 && y == 10'd120) ||
    (x == 10'd30  && y == 10'd150) || (x == 10'd490 && y == 10'd60)  ||
    (x == 10'd560 && y == 10'd75)  || (x == 10'd620 && y == 10'd50)  ||
    (x == 10'd420 && y == 10'd45)  || (x == 10'd150 && y == 10'd45)
);

// ---------------------------------------------------------------------------
// Astro - wires de pertenencia
// dist² ya calculado arriba (dist2_astro)
// ---------------------------------------------------------------------------

// Luna (DAWN / NIGHT)
wire in_moon_outer = (dist2_astro <= MOON_R_OUTER * MOON_R_OUTER);   // ≤ 900
wire in_moon_inner = (dist2_astro <= MOON_R_INNER * MOON_R_INNER);   // ≤ 576
// Manchas de la luna (rectángulos)
wire in_moon_spot1 = (dx_astro >= -12) && (dx_astro < -3)  &&
                     (dy_astro >= -10) && (dy_astro <  -1);  // (-12,-10)  9×9
wire in_moon_spot2 = (dx_astro >=   4) && (dx_astro <  11) &&
                     (dy_astro >=   5) && (dy_astro <  12);  //  (4,5)   7×7

// Sol día - círculo base + rayos
wire in_sun_outer  = (dist2_astro <= SUN_R_OUTER * SUN_R_OUTER);    // ≤ 676
wire in_sun_inner  = (dist2_astro <= SUN_R_INNER * SUN_R_INNER);    // ≤ 324

// Rayos rectos: 4 rectángulos delgados
localparam [5:0] RAY_GAP = 4;    // espacio entre borde sol y rayo
localparam [5:0] RAY_LEN = 28;
localparam [2:0] RAY_W   = 6;

// Rayo arriba
wire in_ray_up   = (dx_astro >= -3) && (dx_astro < 3) &&
                   (dy_astro <= -(SUN_R_OUTER + RAY_GAP)) &&
                   (dy_astro > -(SUN_R_OUTER + RAY_GAP + RAY_LEN));
// Rayo abajo
wire in_ray_down = (dx_astro >= -3) && (dx_astro < 3) &&
                   (dy_astro >= (SUN_R_OUTER + RAY_GAP)) &&
                   (dy_astro <  (SUN_R_OUTER + RAY_GAP + RAY_LEN));
// Rayo izquierda
wire in_ray_left = (dy_astro >= -3) && (dy_astro < 3) &&
                   (dx_astro <= -(SUN_R_OUTER + RAY_GAP)) &&
                   (dx_astro > -(SUN_R_OUTER + RAY_GAP + RAY_LEN));
// Rayo derecha
wire in_ray_rght = (dy_astro >= -3) && (dy_astro < 3) &&
                   (dx_astro >= (SUN_R_OUTER + RAY_GAP)) &&
                   (dx_astro <  (SUN_R_OUTER + RAY_GAP + RAY_LEN));

// Rayos diagonales: triángulos pequeños
// Para cada diagonal (sx,sy) ∈ {(1,1),(1,-1),(-1,1),(-1,-1)}
// origen (x0,y0) = (cx + sx*(R+6), cy + sy*(R+6))
// polígono: (x0, y0), (x0+sx*20, y0+sy*5), (x0+sx*5, y0+sy*20)
// Aproximamos como: |dx| > (R+6) && |dy| > (R+6) && dx*sy - dy*sx > 0 && en bbox
// Simplificación práctica: bbox del triángulo con condición diagonal
localparam signed [10:0] DIAG_OFF = SUN_R_OUTER + 6;   // 32
localparam signed [10:0] DIAG_LEN = 20;

wire in_diag_pp = (dx_astro >=  DIAG_OFF) && (dx_astro < DIAG_OFF + DIAG_LEN) &&
                  (dy_astro >=  DIAG_OFF) && (dy_astro < DIAG_OFF + DIAG_LEN) &&
                  ((dx_astro - DIAG_OFF) + (dy_astro - DIAG_OFF) < DIAG_LEN);
wire in_diag_pn = (dx_astro >=  DIAG_OFF) && (dx_astro < DIAG_OFF + DIAG_LEN) &&
                  (dy_astro <= -DIAG_OFF) && (dy_astro > -(DIAG_OFF + DIAG_LEN)) &&
                  ((dx_astro - DIAG_OFF) + (-dy_astro - DIAG_OFF) < DIAG_LEN);
wire in_diag_np = (dx_astro <= -DIAG_OFF) && (dx_astro > -(DIAG_OFF + DIAG_LEN)) &&
                  (dy_astro >=  DIAG_OFF) && (dy_astro < DIAG_OFF + DIAG_LEN) &&
                  ((-dx_astro - DIAG_OFF) + (dy_astro - DIAG_OFF) < DIAG_LEN);
wire in_diag_nn = (dx_astro <= -DIAG_OFF) && (dx_astro > -(DIAG_OFF + DIAG_LEN)) &&
                  (dy_astro <= -DIAG_OFF) && (dy_astro > -(DIAG_OFF + DIAG_LEN)) &&
                  ((-dx_astro - DIAG_OFF) + (-dy_astro - DIAG_OFF) < DIAG_LEN);

wire in_sun_ray = in_ray_up || in_ray_down || in_ray_left || in_ray_rght ||
                  in_diag_pp || in_diag_pn || in_diag_np || in_diag_nn;

// Sol atardecer - halos concéntricos
wire in_dusk_h1   = (dist2_astro <= DUSK_R1 * DUSK_R1);   // ≤ 1936
wire in_dusk_h2   = (dist2_astro <= DUSK_R2 * DUSK_R2);   // ≤ 1024
wire in_dusk_h3   = (dist2_astro <= DUSK_R3 * DUSK_R3);   // ≤ 400
wire in_dusk_core = (dist2_astro <= DUSK_R4 * DUSK_R4);   // ≤ 100

// ---------------------------------------------------------------------------
// Suelo
// ---------------------------------------------------------------------------
wire in_ground       = (y >= HORIZON_Y);
wire in_ground_grass = (y >= HORIZON_Y) && (y < HORIZON_Y + 10'd8);
// Patrón de baldosas: bloques 24×16 alternados
// (bx//24 + by//16) % 2 == 0  → dark
wire in_ground_tile_dark;
wire [5:0] tile_bx = x[9:0] / 10'd24;   // columna de bloque (0..26)
wire [4:0] tile_by = y[9:0] / 10'd16;   // fila de bloque   (0..29)
assign in_ground_tile_dark = in_ground && !in_ground_grass &&
                             ((tile_bx[0] ^ tile_by[0]) == 1'b0);

// ---------------------------------------------------------------------------
// Lógica principal de pintado - orden de prioridad (último sobreescribe)
// ---------------------------------------------------------------------------
always @(*) begin
    // ── 1. Cielo base
    case (phase)
        DAWN:  rgb = SKY_DAWN;
        DAY:   rgb = SKY_DAY;
        DUSK:  rgb = SKY_DUSK;
        default: rgb = SKY_NIGHT;
    endcase

    // ── 2. Estrellas (solo DAWN / NIGHT)
    if ((phase == DAWN || phase == NIGHT) && is_star) begin
        rgb = (phase == NIGHT) ? 8'b110_110_10 :   // bright=210 → 110_110_10
                                 8'b100_100_10 ;    // bright=150 → 100_100_10
    end

    // ── 3. Astro
    case (phase)
        DAWN, NIGHT: begin
            if (in_moon_outer) rgb = MOON_OUTER;
            if (in_moon_inner) rgb = MOON_INNER;
            // manchas solo si están dentro del disco exterior
            if (in_moon_outer && in_moon_spot1) rgb = MOON_SPOT;
            if (in_moon_outer && in_moon_spot2) rgb = MOON_SPOT;
        end
        DAY: begin
            if (in_sun_ray)   rgb = SUN_RAY;
            if (in_sun_outer) rgb = SUN_OUTER;
            if (in_sun_inner) rgb = SUN_INNER;
        end
        DUSK: begin
            if (in_dusk_h1)   rgb = DUSK_H1;
            if (in_dusk_h2)   rgb = DUSK_H2;
            if (in_dusk_h3)   rgb = DUSK_H3;
            if (in_dusk_core) rgb = DUSK_CORE;
        end
    endcase

    // ── 4. Nubes
    if (in_cloud) begin
        // Selección de paleta por fase
        // dark = capa base, light = capas 1-3, hl = sub-rect highlight
        if (in_cloud_dk) begin
            case (phase)
                DAWN:    rgb = CLOUD_DAWN_DARK;
                DAY:     rgb = CLOUD_DAY_DARK;
                DUSK:    rgb = CLOUD_DUSK_DARK;
                default: rgb = CLOUD_NIGHT_DARK;
            endcase
        end else begin
            case (phase)
                DAWN:    rgb = CLOUD_DAWN_LIGHT;
                DAY:     rgb = CLOUD_DAY_LIGHT;
                DUSK:    rgb = CLOUD_DUSK_LIGHT;
                default: rgb = CLOUD_NIGHT_LIGHT;
            endcase
        end
        // Highlight sobreescribe (más brillante)
        if (in_cloud_hl) begin
            case (phase)
                DAWN:    rgb = CLOUD_DAWN_HL;
                DAY:     rgb = CLOUD_DAY_HL;
                DUSK:    rgb = CLOUD_DUSK_HL;
                default: rgb = CLOUD_NIGHT_HL;
            endcase
        end
    end

    // ── 5. Montaña B (trasera)
    if (in_mtn_b) begin
        if (in_mtn_b_shadow) begin
            case (phase)
                DAWN:    rgb = MTN_DAWN_BD;
                DAY:     rgb = MTN_DAY_BD;
                DUSK:    rgb = MTN_DUSK_BD;
                default: rgb = MTN_NIGHT_BD;
            endcase
        end else begin
            case (phase)
                DAWN:    rgb = MTN_DAWN_BL;
                DAY:     rgb = MTN_DAY_BL;
                DUSK:    rgb = MTN_DUSK_BL;
                default: rgb = MTN_NIGHT_BL;
            endcase
        end
    end

    // ── 6. Montaña A (delantera)
    if (in_mtn_a) begin
        if (in_mtn_a_shadow) begin
            case (phase)
                DAWN:    rgb = MTN_DAWN_AD;
                DAY:     rgb = MTN_DAY_AD;
                DUSK:    rgb = MTN_DUSK_AD;
                default: rgb = MTN_NIGHT_AD;
            endcase
        end else begin
            case (phase)
                DAWN:    rgb = MTN_DAWN_AL;
                DAY:     rgb = MTN_DAY_AL;
                DUSK:    rgb = MTN_DUSK_AL;
                default: rgb = MTN_NIGHT_AL;
            endcase
        end
    end

    // ── 7. Suelo
    if (in_ground) begin
        if (in_ground_grass) begin
            case (phase)
                DAWN:    rgb = GROUND_DAWN_GRASS;
                DAY:     rgb = GROUND_DAY_GRASS;
                DUSK:    rgb = GROUND_DUSK_GRASS;
                default: rgb = GROUND_NIGHT_GRASS;
            endcase
        end else if (in_ground_tile_dark) begin
            case (phase)
                DAWN:    rgb = GROUND_DAWN_DARK;
                DAY:     rgb = GROUND_DAY_DARK;
                DUSK:    rgb = GROUND_DUSK_DARK;
                default: rgb = GROUND_NIGHT_DARK;
            endcase
        end else begin
            case (phase)
                DAWN:    rgb = GROUND_DAWN_BASE;
                DAY:     rgb = GROUND_DAY_BASE;
                DUSK:    rgb = GROUND_DUSK_BASE;
                default: rgb = GROUND_NIGHT_BASE;
            endcase
        end
    end
end

endmodule