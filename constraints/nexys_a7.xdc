## =============================================================================
## Constraints: Nexys A7-100T (xc7a100tcsg324-1)
## Proyecto 1 — Controlador VGA con Reloj Digital
## EL3313 Taller de Diseño Digital, I Sem 2026
## Pines verificados contra Nexys-A7-100T-Master.xdc de Digilent.
## =============================================================================

## -----------------------------------------------------------------------------
## Reloj principal 100 MHz
## -----------------------------------------------------------------------------
set_property -dict { PACKAGE_PIN E3  IOSTANDARD LVCMOS33 } [get_ports CLK100MHZ]
create_clock -period 10.000 -name CLK100MHZ [get_ports CLK100MHZ]

## -----------------------------------------------------------------------------
## Reset — BTNC (activo-alto)
## -----------------------------------------------------------------------------
set_property -dict { PACKAGE_PIN N17 IOSTANDARD LVCMOS33 } [get_ports reset]

## -----------------------------------------------------------------------------
## Switches
## SW[0] = fmt_sel  (0=24h, 1=12h)
## SW[1] = adj_sel  (0=ajustar horas, 1=ajustar minutos)
## -----------------------------------------------------------------------------
set_property -dict { PACKAGE_PIN J15 IOSTANDARD LVCMOS33 } [get_ports {SW[0]}]
set_property -dict { PACKAGE_PIN L16 IOSTANDARD LVCMOS33 } [get_ports {SW[1]}]

## -----------------------------------------------------------------------------
## Botones
## -----------------------------------------------------------------------------
set_property -dict { PACKAGE_PIN M18 IOSTANDARD LVCMOS33 } [get_ports BTNU]
set_property -dict { PACKAGE_PIN P18 IOSTANDARD LVCMOS33 } [get_ports BTND]

## -----------------------------------------------------------------------------
## VGA — Salida de video
## -----------------------------------------------------------------------------
set_property -dict { PACKAGE_PIN B11 IOSTANDARD LVCMOS33 } [get_ports VGA_HS]
set_property -dict { PACKAGE_PIN B12 IOSTANDARD LVCMOS33 } [get_ports VGA_VS]

set_property -dict { PACKAGE_PIN A3  IOSTANDARD LVCMOS33 } [get_ports {VGA_R[0]}]
set_property -dict { PACKAGE_PIN B4  IOSTANDARD LVCMOS33 } [get_ports {VGA_R[1]}]
set_property -dict { PACKAGE_PIN C5  IOSTANDARD LVCMOS33 } [get_ports {VGA_R[2]}]
set_property -dict { PACKAGE_PIN A4  IOSTANDARD LVCMOS33 } [get_ports {VGA_R[3]}]

set_property -dict { PACKAGE_PIN C6  IOSTANDARD LVCMOS33 } [get_ports {VGA_G[0]}]
set_property -dict { PACKAGE_PIN A5  IOSTANDARD LVCMOS33 } [get_ports {VGA_G[1]}]
set_property -dict { PACKAGE_PIN B6  IOSTANDARD LVCMOS33 } [get_ports {VGA_G[2]}]
set_property -dict { PACKAGE_PIN A6  IOSTANDARD LVCMOS33 } [get_ports {VGA_G[3]}]

set_property -dict { PACKAGE_PIN B7  IOSTANDARD LVCMOS33 } [get_ports {VGA_B[0]}]
set_property -dict { PACKAGE_PIN C7  IOSTANDARD LVCMOS33 } [get_ports {VGA_B[1]}]
set_property -dict { PACKAGE_PIN D7  IOSTANDARD LVCMOS33 } [get_ports {VGA_B[2]}]
set_property -dict { PACKAGE_PIN D8  IOSTANDARD LVCMOS33 } [get_ports {VGA_B[3]}]
