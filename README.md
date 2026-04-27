# Proyecto 1 — Controlador VGA con Reloj Digital

**Curso:** Taller de Diseño Digital (EL3313) — TEC, I Semestre 2026  
**Integrantes:** Milagro Rojas Sánchez · Ángel Hernández  
**Profesor:** Luis G. León-Vega, Ph.D

---

## Descripción

Sistema digital implementado en FPGA Nexys A7 que visualiza un reloj HH:MM:SS en una pantalla VGA (640×480 @ 60 Hz). El usuario puede ajustar la hora mediante switches y botones de la tarjeta, y seleccionar entre formato 12h y 24h.

---

## Arquitectura del sistema

```
CLK100MHZ → (÷4) → 25 MHz
                      │
                      ├── vga_controller ──→ VGA_HS / VGA_VS / RGB
                      │        │ lee
                      │   vram_dual_port (BRAM 640×480 × 8 bits)
                      │        ↑ escribe
                      ├── vram_background_writer ← hour_disp, minute, second, am_pm, fmt_sel, tick_1hz
                      │
                      ├── clock_controller ← SW[1:0], btn_inc, btn_dec
                      │
                      └── debounce × 2 ← BTNU, BTND
```

---

## Módulos

| Módulo | Autor | Descripción |
|---|---|---|
| `vga_controller.v` | Ángel | Controlador VGA jerárquico con pipeline de 2 etapas |
| `vga_timing.v` | Ángel | Generador de contadores H/V y señales hsync/vsync |
| `vga_memory_interface.v` | Ángel | Cálculo de dirección VRAM: `y×640 + x` |
| `vram_dual_port.v` | Ángel | BRAM dual-port 307 200 × 8 bits (RGB332) |
| `vram_background_writer.v` | Ángel | Renderizado de fondo y dígitos del reloj en VRAM |
| `clock_controller.v` | Milagro | Timekeeping HH:MM:SS, tick 1 Hz, formato 12h/24h, ajuste por botones |
| `debounce.v` | Milagro | Sincronizador + contador de estabilidad 20 ms |
| `top_clock_vga.v` | Milagro | Integración de todos los módulos |

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
├── src/                    # Fuentes RTL
│   ├── top_clock_vga.v
│   ├── clock_controller.v
│   ├── debounce.v
│   ├── vga_controller.v
│   ├── vga_timing.v
│   ├── vga_memory_interface.v
│   ├── vram_dual_port.v
│   └── vram_background_writer.v
├── sim/
│   └── tb_clock_controller.v
├── constraints/
│   └── nexys_a7.xdc
└── README.md
```
