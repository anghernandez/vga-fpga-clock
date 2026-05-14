# Controlador VGA con Reloj Digital

Sistema digital implementado en FPGA que visualiza un reloj en tiempo real sobre una pantalla VGA con fondo dinámico dependiente de la fase del día.

Proyecto desarrollado para el curso **Taller de Diseño Digital (EL3313)** del Tecnológico de Costa Rica.

---

## Información del proyecto

| Campo | Información |
|---|---|
| Curso | Taller de Diseño Digital (EL3313) |
| Institución | Tecnológico de Costa Rica |
| Profesor | Luis G. León-Vega, Ph.D |
| FPGA | Nexys A7-100T (Xilinx Artix-7) |
| Resolución VGA | 640×480 @ 60 Hz |

### Integrantes

- Milagro Rojas Sánchez
- Angie Hernández Mairena
- Brayan Solís Rojas

---

# Descripción

El sistema implementa un reloj digital en formato HH:MM:SS desplegado sobre una interfaz VGA.

El usuario puede:

- Ajustar horas y minutos mediante botones físicos.
- Seleccionar formato 12h o 24h.
- Visualizar un paisaje dinámico generado completamente en hardware.

El fondo cambia automáticamente entre:

- Madrugada
- Día
- Atardecer
- Noche

Todo el sistema fue desarrollado en Verilog utilizando una arquitectura modular jerárquica.

---

# Características principales

- Controlador VGA 640×480 @ 60 Hz
- Pipeline de video
- VRAM dual-port usando BRAM
- Generación procedural del paisaje
- Renderizado de texto mediante ROM bitmap
- Máquina de estados para escritura de fondo
- Debouncing por hardware
- Soporte 12h / 24h
- Diseño completamente sintetizable

---

# Arquitectura del sistema

```text
CLK100MHZ → Clocking Wizard → 25 MHz
                      │
                      ├── vga_controller ─────→ VGA_HS / VGA_VS / RGB
                      │        │
                      │        └── vram_dual_port
                      │
                      ├── vram_background_writer
                      │        ├── bg_color
                      │        └── digit_rom
                      │
                      ├── clock_controller
                      │
                      └── debounce
```

---

# Módulos del sistema

| Módulo | Función |
|---|---|
| `top_clock_vga.v` | Integración completa del sistema |
| `clock_controller.v` | Manejo del reloj y ajustes |
| `debounce.v` | Filtrado de rebotes de botones |
| `vga_controller.v` | Pipeline y control VGA |
| `vga_timing.v` | Generación de sincronización VGA |
| `vga_memory_interface.v` | Cálculo de direcciones VRAM |
| `vram_dual_port.v` | Memoria de video BRAM |
| `vram_background_writer.v` | Renderizado de fondo y reloj |
| `bg_color.v` | Generador de paisaje dinámico |
| `digit_rom.v` | ROM de caracteres bitmap |

---

# Interfaz de usuario

| Entrada | Función |
|---|---|
| `BTNC` | Reset del sistema |
| `SW[0]` | Selección 12h / 24h |
| `SW[1]` | Selección de ajuste |
| `BTNU` | Incremento |
| `BTND` | Decremento |

---

# Renderizado gráfico

El sistema utiliza bitmaps almacenados en ROM para representar caracteres y números.

## Escalamiento

| Elemento | Escala |
|---|---|
| Dígitos HH:MM:SS | ×8 |
| Texto AM/PM/24H | ×4 |

## Capas gráficas

El paisaje dinámico incluye:

1. Cielo dependiente de la fase del día
2. Sol y luna
3. Nubes multicapa
4. Montañas
5. Suelo y río

---

# Uso de recursos FPGA

La arquitectura fue diseñada buscando eficiencia en recursos hardware:

- Uso de BRAM para almacenamiento de video
- Lógica combinacional para generación de paisaje
- Pipeline simple para timing VGA
- Minimización de LUTs mediante reutilización de módulos
- Separación clara entre lógica secuencial y combinacional

---

# Simulación

```bash
xvlog src/clock_controller.v sim/tb_clock_controller.v

xelab tb_clock_controller -s tb_clock_controller_sim

xsim tb_clock_controller_sim --runall
```

El testbench valida:

- Reset
- Conteo normal
- Ajustes por botones
- Formato 12h / 24h

---

# Estructura del repositorio

```text
vga-fpga-clock/
├── contraints/
├── sim/
├── src/
├── .gitnore
├── README.md
└── vga-fpga-clock.xpr

```

---

# Documentación técnica

La documentación técnica autogenerada se encuentra en:

```text
docs/index.html
```

Incluye:

- Tabla de puertos
- Parámetros
- Descripción de módulos
- Comentarios extraídos mediante TerosHDL

---

# Herramientas utilizadas

- Verilog HDL
- Vivado Design Suite
- Xilinx Nexys A7
- TerosHDL
- Git & GitHub

---

# Resultados

El sistema fue implementado exitosamente en FPGA y logra:

- Generación estable VGA @ 60 Hz
- Renderizado en tiempo real
- Interfaz interactiva mediante switches y botones
- Fondo dinámico completamente generado en hardware

---

# Licencia

Proyecto académico desarrollado para fines educativos.
