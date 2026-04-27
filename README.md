# Controlador VGA con Reloj Digital

**Curso:** Taller de Diseño Digital (EL3313) — TEC, I Semestre 2026  
**Integrantes:** Milagro Rojas Sánchez · Ángel Hernández  
**Profesor:** Luis G. León-Vega, Ph.D  
**Tarjeta:** Nexys A7-100T (Xilinx Artix-7)

---

## Descripción

Diseño e implementación de un sistema digital en FPGA que visualiza un reloj en tiempo real sobre una pantalla VGA (640×480 @ 60 Hz). El usuario puede ajustar la hora y seleccionar entre formato 12h y 24h mediante los switches y botones de la tarjeta.

---

## Estado del proyecto

| Módulo | Estado |
|---|---|
| VGA controller + timing | ✅ Completo |
| VRAM dual-port (BRAM) | ✅ Completo |
| Generador de imagen / fondo | 🔄 En desarrollo |
| Control de hora | ✅ Completo |
| Integración del sistema | ✅ Completo |
| Simulación y testbench | ✅ Completo |

---

## Estructura de ramas

| Rama | Descripción |
|---|---|
| `main` | Versión estable / entregable |
| `develop` | Integración del avance actual |
| `feature/vga-vram-clock` | Módulos VGA y VRAM (Ángel) |
| `feature/clock-controller` | Control de hora e integración (Milagro) |

---

## Integrantes

| Nombre | Módulos |
|---|---|
| Ángel Hernández | VGA controller, VRAM, generador de imagen |
| Milagro Rojas Sánchez | Clock controller, debounce, integración top-level |
