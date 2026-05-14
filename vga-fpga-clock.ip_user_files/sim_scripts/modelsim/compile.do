vlib modelsim_lib/work
vlib modelsim_lib/msim

vlib modelsim_lib/msim/xil_defaultlib

vmap xil_defaultlib modelsim_lib/msim/xil_defaultlib

vlog -work xil_defaultlib -64 -incr -mfcu  "+incdir+../../../project_Controlador VGA con Reloj Digital.gen/sources_1/ip/clk_wiz_0" \
"../../../project_Controlador VGA con Reloj Digital.srcs/sources_1/new/vga_controller.v" \
"../../../project_Controlador VGA con Reloj Digital.srcs/sources_1/new/vga_memory_interface.v" \
"../../../project_Controlador VGA con Reloj Digital.srcs/sources_1/new/vga_timing.v" \
"../../../project_Controlador VGA con Reloj Digital.srcs/sources_1/new/vram_background_writer.v" \
"../../../project_Controlador VGA con Reloj Digital.srcs/sources_1/new/vram_dual_port.v" \
"../../../project_Controlador VGA con Reloj Digital.srcs/sources_1/new/top_clock_vga.v" \


vlog -work xil_defaultlib \
"glbl.v"

