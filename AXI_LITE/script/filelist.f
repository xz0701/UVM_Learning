+incdir+../third_party/axi/include
+incdir+../third_party/common_cells/include

+incdir+../tb/pkg
+incdir+../tb/seq
+incdir+../tb/agent
+incdir+../tb/env
+incdir+../tb/interface
+incdir+../tb/models
+incdir+../tb/tests
+incdir+../tb/assertions

../third_party/common_cells/src/cf_math_pkg.sv
../third_party/common_cells/src/addr_decode_dync.sv
../third_party/common_cells/src/addr_decode.sv
../third_party/common_cells/src/spill_register_flushable.sv
../third_party/common_cells/src/spill_register.sv
../third_party/common_cells/src/fall_through_register.sv
../third_party/common_cells/src/stream_register.sv
../third_party/common_cells/src/fifo_v3.sv
../third_party/common_cells/src/delta_counter.sv
../third_party/common_cells/src/counter.sv
../third_party/common_cells/src/lzc.sv
../third_party/common_cells/src/rr_arb_tree.sv

../third_party/axi/src/axi_pkg.sv
../third_party/axi/src/axi_intf.sv
../third_party/axi/src/axi_atop_filter.sv
../third_party/axi/src/axi_lite_to_axi.sv
../third_party/axi/src/axi_err_slv.sv
../third_party/axi/src/axi_lite_regs.sv
../third_party/axi/src/axi_lite_demux.sv
../third_party/axi/src/axi_lite_mux.sv
../third_party/axi/src/axi_lite_xbar.sv

../tb/interface/axi_lite_ctrl_if.sv
../tb/models/axi_lite_mem_slave.sv
../tb/pkg/axi_lite_pkg.sv
../tb/assertions/axi_lite_assertions.sv

../tb/top/tb_top.sv
../tb/top/tb_demux_top.sv
../tb/top/tb_mux_top.sv
../tb/top/tb_xbar_top.sv
../tb/tb_axi_lite_regs.sv
