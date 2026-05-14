transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

asim +access +r +m+top_clock_vga  -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.top_clock_vga xil_defaultlib.glbl

do {top_clock_vga.udo}

run 1000ns

endsim

quit -force
