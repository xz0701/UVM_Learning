`ifndef SYNC_FIFO_SCOREBOARD_SV
`define SYNC_FIFO_SCOREBOARD_SV

class sync_fifo_scoreboard extends uvm_component;

    `uvm_component_utils(sync_fifo_scoreboard)

    uvm_analysis_imp #(sync_fifo_transaction, sync_fifo_scoreboard) imp;

    bit [DATA_WIDTH-1:0] model_q[$];

    function new(string name = "sync_fifo_scoreboard", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        imp = new("imp", this);
    endfunction

    virtual function void write(sync_fifo_transaction tr);

        bit [DATA_WIDTH-1:0] exp_data;

        // Write accepted if wr_en is high and FIFO is not full.
        // For full + simultaneous read/write, allow write because read frees space.
        if (tr.wr_en && (!tr.full || tr.rd_en)) begin
            model_q.push_back(tr.wr_data);

            `uvm_info("FIFO_SCB",
                $sformatf("Model push: 0x%0h, depth=%0d",
                          tr.wr_data, model_q.size()),
                UVM_MEDIUM)
        end

        // Read accepted if rd_en is high and FIFO is not empty.
        // Empty + simultaneous read/write is treated as read fail, write only.
        if (tr.rd_en && !tr.empty) begin
            if (model_q.size() == 0) begin
                `uvm_error("FIFO_SCB", "Model queue underflow")
            end
            else begin
                exp_data = model_q.pop_front();

                if (tr.rd_data !== exp_data) begin
                    `uvm_error("FIFO_SCB",
                        $sformatf("Data mismatch: expected=0x%0h actual=0x%0h",
                                  exp_data, tr.rd_data))
                end
                else begin
                    `uvm_info("FIFO_SCB",
                        $sformatf("Data match: 0x%0h", tr.rd_data),
                        UVM_MEDIUM)
                end
            end
        end

    endfunction

endclass

`endif