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

localparam DAWN  = 2'b00; // Madrugada
localparam DAY   = 2'b01; // Día
localparam DUSK  = 2'b10; // Tarde
localparam NIGHT = 2'b11; // Noche

// ---------------------------------------------------------------------------
// Colores de cielo
// ---------------------------------------------------------------------------

localparam [7:0] SKY_DAWN  = 8'b000_000_01; 
localparam [7:0] SKY_DAY   = 8'b010_100_11;
localparam [7:0] SKY_DUSK  = 8'b101_001_00;
localparam [7:0] SKY_NIGHT = 8'b000_000_01;

// ---------------------------------------------------------------------------
// Colores de suelo
// ---------------------------------------------------------------------------

localparam [7:0] GROUND_DAWN_GRASS  = 8'b000_001_01;
localparam [7:0] GROUND_DAWN_BASE   = 8'b000_000_00;
localparam [7:0] GROUND_DAWN_DARK   = 8'b000_001_00;

localparam [7:0] GROUND_DAY_GRASS   = 8'b001_100_01;
localparam [7:0] GROUND_DAY_BASE    = 8'b001_011_01;
localparam [7:0] GROUND_DAY_DARK    = 8'b000_010_01;

localparam [7:0] GROUND_DUSK_GRASS  = 8'b010_001_00;
localparam [7:0] GROUND_DUSK_BASE   = 8'b001_001_00;
localparam [7:0] GROUND_DUSK_DARK   = 8'b001_000_00;

localparam [7:0] GROUND_NIGHT_GRASS = 8'b000_001_01;
localparam [7:0] GROUND_NIGHT_BASE  = 8'b000_001_00;
localparam [7:0] GROUND_NIGHT_DARK  = 8'b000_000_00;

// ---------------------------------------------------------------------------
// Colores de río
// ---------------------------------------------------------------------------

localparam [7:0] RIVER_DAWN  = 8'b000_001_01;
localparam [7:0] RIVER_DAY   = 8'b001_011_11;
localparam [7:0] RIVER_DUSK  = 8'b011_001_00;
localparam [7:0] RIVER_NIGHT = 8'b000_001_01;
localparam [7:0] RIVER_SHINE = 8'hFF;  // blanco para destellos

// ---------------------------------------------------------------------------
// Colores de nubes RGB332
// ---------------------------------------------------------------------------

localparam [7:0] CLOUD_DAWN_DARK  = 8'b010_001_10;
localparam [7:0] CLOUD_DAWN_LIGHT = 8'b011_001_10;
localparam [7:0] CLOUD_DAWN_HL    = 8'b101_010_01;

localparam [7:0] CLOUD_DAY_DARK   = 8'b110_110_11;
localparam [7:0] CLOUD_DAY_LIGHT  = 8'b111_111_11;
localparam [7:0] CLOUD_DAY_HL     = 8'b111_111_11;

localparam [7:0] CLOUD_DUSK_DARK  = 8'b011_001_10;
localparam [7:0] CLOUD_DUSK_LIGHT = 8'b100_001_10;
localparam [7:0] CLOUD_DUSK_HL    = 8'b110_011_01;

localparam [7:0] CLOUD_NIGHT_DARK = 8'b001_000_10;
localparam [7:0] CLOUD_NIGHT_LIGHT= 8'b010_001_10;
localparam [7:0] CLOUD_NIGHT_HL   = 8'b011_010_10;

// ---------------------------------------------------------------------------
// Colores de montañas
// ---------------------------------------------------------------------------

localparam [7:0] MTN_DAWN_AL  = 8'b001_010_01;
localparam [7:0] MTN_DAWN_AD  = 8'b000_001_01;
localparam [7:0] MTN_DAWN_BL  = 8'b000_001_01;
localparam [7:0] MTN_DAWN_BD  = 8'b000_001_01;

localparam [7:0] MTN_DAY_AL   = 8'b001_100_01;
localparam [7:0] MTN_DAY_AD   = 8'b001_011_01;
localparam [7:0] MTN_DAY_BL   = 8'b001_011_01;
localparam [7:0] MTN_DAY_BD   = 8'b001_011_00;

localparam [7:0] MTN_DUSK_AL  = 8'b001_000_00;
localparam [7:0] MTN_DUSK_AD  = 8'b001_000_00;
localparam [7:0] MTN_DUSK_BL  = 8'b000_000_00;
localparam [7:0] MTN_DUSK_BD  = 8'b000_000_00;

localparam [7:0] MTN_NIGHT_AL = 8'b001_010_10;
localparam [7:0] MTN_NIGHT_AD = 8'b000_001_10;
localparam [7:0] MTN_NIGHT_BL = 8'b000_010_10;
localparam [7:0] MTN_NIGHT_BD = 8'b000_001_01;

// ---------------------------------------------------------------------------
// Colores del astro
// ---------------------------------------------------------------------------

// Luna núcleo/anillo/manchas
localparam [7:0] MOON_OUTER  = 8'b110_101_00;
localparam [7:0] MOON_INNER  = 8'b111_110_01;
localparam [7:0] MOON_SPOT   = 8'b110_100_00;

// Sol día
localparam [7:0] SUN_OUTER   = 8'b111_111_10;
localparam [7:0] SUN_INNER   = 8'b111_111_01;
localparam [7:0] SUN_RAY     = 8'b111_110_00;

// Sol atardecer (halos concéntricos)
localparam [7:0] DUSK_H1     = 8'b111_010_00;
localparam [7:0] DUSK_H2     = 8'b111_100_01;
localparam [7:0] DUSK_H3     = 8'b111_110_01;
localparam [7:0] DUSK_CORE   = 8'b111_111_10;

// ---------------------------------------------------------------------------
// Constantes de geometría
// ---------------------------------------------------------------------------

localparam signed [10:0] ASTRO_CX    = 11'sd530;
localparam        [9:0]  HORIZON_Y   = 10'd340;

// Montaña A
localparam [9:0] MTN_A_CX     = 10'd320;
localparam [3:0] MTN_A_LEVELS = 4'd15;

// Montaña B
localparam [9:0] MTN_B_CX     = 10'd210;
localparam [3:0] MTN_B_LEVELS = 4'd11;

localparam [4:0] STEP_H = 5'd16;
localparam [4:0] STEP_W = 5'd16;

// Radio del astro
localparam [5:0] MOON_R_OUTER = 6'd30;
localparam [5:0] MOON_R_INNER = 6'd24;
localparam [5:0] SUN_R_OUTER  = 6'd26;
localparam [5:0] SUN_R_INNER  = 6'd18;
localparam [5:0] DUSK_R1      = 6'd44;
localparam [5:0] DUSK_R2      = 6'd32;
localparam [5:0] DUSK_R3      = 6'd20;
localparam [5:0] DUSK_R4      = 6'd10;

wire signed [10:0] dx_astro = $signed({1'b0, x}) - ASTRO_CX;
wire signed [10:0] dy_astro = $signed({1'b0, y}) - $signed({1'b0, astro_cy});
wire [21:0] dist2_astro = dx_astro * dx_astro + dy_astro * dy_astro;

// ---------------------------------------------------------------------------
// Funciones de pertenencia a pirámide
// Devuelven 1 si el píxel (x,y) pertenece a ese nivel de la pirámide.
// ---------------------------------------------------------------------------

// Montaña A - 16 niveles
// Montaña B - 12 niveles
// Se implementa con bloques generate.

wire in_mtn_a;
wire in_mtn_a_shadow;
wire in_mtn_b;
wire in_mtn_b_shadow;

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
// Nubes - 2 grupos, 4 capas cada uno
// ---------------------------------------------------------------------------

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
// Estrellas - 20 posiciones fijas
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
// Astros
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
wire in_ground_tile_dark;
wire [5:0] tile_bx = x[9:0] / 10'd24;   // columna de bloque (0..26)
wire [4:0] tile_by = y[9:0] / 10'd16;   // fila de bloque   (0..29)
assign in_ground_tile_dark = in_ground && !in_ground_grass &&
                             ((tile_bx[0] ^ tile_by[0]) == 1'b0);

// Río: banda y=358..400, ancho completo
wire in_river = (y >= 10'd358) && (y < 10'd400);

// Destellos: 3 líneas horizontales desplazadas entre sí
// patrón: (x + desplazamiento) % periodo < grosor
wire river_shine =
    ( (y >= 10'd362) && (y < 10'd364) && (x[4:0] < 5'd6)              ) ||
    ( (y >= 10'd374) && (y < 10'd376) && ((x + 10'd10) % 10'd28 < 5'd8) ) ||
    ( (y >= 10'd388) && (y < 10'd390) && ((x + 10'd20) % 10'd22 < 5'd5) );

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
        rgb = (phase == NIGHT) ? 8'b110_110_10 :
                                 8'b100_100_10 ;
    end

    // ── 3. Astro
    case (phase)
        DAWN, NIGHT: begin
            if (in_moon_outer) rgb = MOON_OUTER;
            if (in_moon_inner) rgb = MOON_INNER;
            
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
        end else if (in_river) begin
            case (phase)
                DAWN:    rgb = RIVER_DAWN;
                DAY:     rgb = RIVER_DAY;
                DUSK:    rgb = RIVER_DUSK;
                default: rgb = RIVER_NIGHT;
            endcase
            if (river_shine) rgb = RIVER_SHINE;
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