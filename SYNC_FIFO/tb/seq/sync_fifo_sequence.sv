`ifndef SYNC_FIFO_SEQUENCE_SV
`define SYNC_FIFO_SEQUENCE_SV

class sync_fifo_sequence extends uvm_sequence #(sync_fifo_transaction);
    `uvm_object_utils(sync_fifo_sequence)

    function new(string name = "sync_fifo_sequence");
        super.new(name);
    endfunction

    virtual task body ();
        sync_fifo_transaction req;

        // 1. Random Traffic
        repeat(100) begin
            req = sync_fifo_transaction::type_id::create("req");

            start_item(req);

            if (!req.randomize()) begin
                `uvm_error("SYNC_FIFO_SEQ", "Randomization Failed")
            end

            finish_item(req);

        end

        // 2. Fill FIFO to full
        repeat (DEPTH) begin 
            req = sync_fifo_transaction::type_id::create("req");
            start_item(req);
            req.wr_en = 1'b1;
            req.rd_en = 1'b0;
            req.wr_data = $urandom();
            finish_item(req);
        end

        // Hold full for one idle cycle
        req = sync_fifo_transaction::type_id::create("req");
        start_item(req);
        req.rd_en   = 1'b0;
        req.wr_en   = 1'b0;
        req.wr_data = '0;
        finish_item(req);

        // Read when full, write off
        req = sync_fifo_transaction::type_id::create("req");
        start_item(req);
        req.rd_en   = 1'b1;
        req.wr_en   = 1'b0;
        req.wr_data = '0;
        finish_item(req);

        // 3. Write when full
        req = sync_fifo_transaction::type_id::create("req");
        start_item(req);

        req.wr_en = 1'b1;
        req.rd_en = 1'b0;
        req.wr_data = $urandom();

        finish_item(req);

        // 4. Simulatenous read/write when full
        req = sync_fifo_transaction::type_id::create("req");
        start_item(req);

        req.wr_en = 1'b1;
        req.rd_en = 1'b1;
        req.wr_data = $urandom();

        finish_item(req);

        // 5. Drain FIFO to empty
        repeat (DEPTH) begin
            req = sync_fifo_transaction::type_id::create("req");
            start_item(req);

            req.wr_en = 1'b0;
            req.rd_en = 1'b1;
            req.wr_data = '0;

            finish_item(req);

        end

        // 6. Read when empty
        req = sync_fifo_transaction::type_id::create("req");
        start_item(req);

        req.wr_en = 1'b0;
        req.rd_en = 1'b1;
        req.wr_data = '0;

        finish_item(req);

        // 7. Simulatenous read/write when empty
        req = sync_fifo_transaction::type_id::create("req");
        start_item(req);

        req.wr_en = 1'b1;
        req.rd_en = 1'b1;
        req.wr_data = $urandom();

        

        finish_item(req);


    endtask

endclass

`endif