# Controlador VGA con Reloj Digital

**Curso:** Taller de Diseño Digital (EL3313) — TEC, I Semestre 2026  
**Integrantes:** Milagro Rojas Sánchez · Angie Hernández Mairena · Brayan Solís Rojas  
**Profesor:** Luis G. León-Vega, Ph.D  
**Tarjeta:** Nexys A7-100T (Xilinx Artix-7, xc7a100tcsg324-1)

---

## Descripción

Diseño e implementación de un sistema digital en FPGA que visualiza un reloj HH:MM:SS en tiempo real sobre una pantalla VGA (640×480 @ 60 Hz). El usuario puede ajustar la hora y seleccionar entre formato 12h y 24h mediante los switches y botones de la tarjeta. El fondo de pantalla es un paisaje dinámico que cambia según la fase del día (madrugada, día, tarde, noche).

---

## Estado del proyecto

| Módulo | Estado |
|---|---|
| VGA controller + timing | ✅ Completo |
| VRAM dual-port (BRAM) | ✅ Completo |
| Generador de imagen / fondo | ✅ Completo |
| Control de hora | ✅ Completo |
| Integración del sistema | ✅ Completo |
| Simulación y testbench | ✅ Completo |

---

## Arquitectura del sistema

```
CLK100MHZ → (÷4 via contador 2 bits) → 25 MHz
                      │
                      ├── vga_controller ──────────→ VGA_HS / VGA_VS / RGB
                      │        │ lee
                      │   vram_dual_port (BRAM 640×480 × 8 bits RGB332)
                      │        ↑ escribe
                      ├── vram_background_writer ←── hour_disp, minute, second
                      │        │ instancia            am_pm, fmt_sel, tick_1hz
                      │        ├── bg_color           phase, astro_cy
                      │        └── digit_rom
                      │
                      ├── clock_controller ←── SW[1:0], btn_inc_db, btn_dec_db
                      │
                      └── debounce × 2 ←── BTNU, BTND
```

El reloj de píxel de 25 MHz se deriva de CLK100MHZ sin PLL ni IP cores, usando únicamente el bit [1] de un contador de 2 bits.

---

## Módulos

| Módulo | Autor | Descripción |
|---|---|---|
| `top_clock_vga.v` | Milagro | Integración de todos los módulos; calcula fase del día y posición del astro |
| `clock_controller.v` | Milagro | Timekeeping HH:MM:SS, tick 1 Hz, formato 12h/24h, ajuste por botones |
| `debounce.v` | Milagro | Sincronizador de 2 FF + contador de estabilidad 20 ms |
| `vga_controller.v` | Angie | Controlador VGA jerárquico con pipeline de 2 etapas |
| `vga_timing.v` | Angie | Generador de contadores H/V y señales hsync/vsync |
| `vga_memory_interface.v` | Angie | Cálculo de dirección VRAM: `y×640 + x` |
| `vram_dual_port.v` | Angie | BRAM dual-port 307 200 × 8 bits (RGB332) |
| `vram_background_writer.v` | Brayan / Milagro | FSM de 6 estados: renderiza fondo, dos puntos y dígitos del reloj en VRAM |
| `bg_color.v` | Brayan | Generador combinacional de paisaje dinámico por capas según fase del día |
| `digit_rom.v` | Angie | ROM combinacional de bitmaps 8×16 para dígitos 0–9 y letras A, M, P, H, 2, 4 |

---

## Interfaz de usuario

| Control | Función |
|---|---|
| `BTNC` | Reset — reinicia el reloj a 00:00:00 |
| `SW[0]` | Formato: 0 = 24h, 1 = 12h |
| `SW[1]` | Campo de ajuste: 0 = horas, 1 = minutos |
| `BTNU` | Incrementa el campo seleccionado |
| `BTND` | Decrementa el campo seleccionado |

---

## Visualización en pantalla

Los dígitos del reloj se escalan desde bitmaps de 8×16 px almacenados en `digit_rom`:

- **Dígitos de hora/minuto/segundo** → escala ×8 → 64×128 px
- **Letras de formato** (AM/PM/24H) → escala ×4 → 32×64 px

El fondo (`bg_color`) renderiza, en orden de prioridad:

1. Cielo base según fase
2. Estrellas (20 posiciones fijas, visibles en madrugada/noche)
3. Astro: luna (madrugada/noche), sol con rayos (día), halos concéntricos (tarde)
4. Nubes con tres capas y highlights
5. Dos montañas con escalonado de 16 y 12 niveles (via `generate`)
6. Suelo con hierba, patrón de baldosas y río con destellos

---

## Simulación

```bash
xvlog src/clock_controller.v sim/tb_clock_controller.v
xelab tb_clock_controller -s tb_clock_controller_sim
xsim tb_clock_controller_sim --runall
```

El testbench instancia `clock_controller` con `TICK_MAX=9` para acelerar la simulación. Cubre reset, conteo normal, rollover de segundos/minutos/horas, ajuste con botones, formato 12h/24h y wrap en decrementos.

---

## Estructura del repositorio

```
Proyecto_Digitales/
├── src/                         # Fuentes RTL (todos los módulos documentados con //!)
│   ├── top_clock_vga.v
│   ├── clock_controller.v
│   ├── debounce.v
│   ├── vga_controller.v
│   ├── vga_timing.v
│   ├── vga_memory_interface.v
│   ├── vram_dual_port.v
│   ├── vram_background_writer.v
│   ├── bg_color.v
│   └── digit_rom.v
├── sim/
│   └── tb_clock_controller.v
├── constraints/
│   └── nexys_a7.xdc
├── scripts/
│   └── gen_docs.mjs             # Generador de documentación HTML (Node.js, sin dependencias)
├── docs/
│   └── index.html               # Documentación técnica autogenerada
├── test_Mila/                   # Prueba de hardware independiente (no es entrega final)
└── README.md
```

---

## Documentación técnica

Los archivos fuente incluyen comentarios `//!` compatibles con **TerosHDL** (extensión de VS Code). Para generar el sitio de documentación localmente:

```bash
node scripts/gen_docs.mjs --src src/ --out docs/
```

El archivo `docs/index.html` resultante incluye descripción de cada módulo, tabla de puertos y parámetros, y diagrama de instancias.
