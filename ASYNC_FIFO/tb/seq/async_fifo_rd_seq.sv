class async_fifo_rd_seq extends uvm_sequence #(async_fifo_rd_tr);

    `uvm_object_utils(async_fifo_rd_seq)

    function new(string name = "async_fifo_rd_seq");
        super.new(name);
    endfunction

    virtual task body();

        async_fifo_rd_tr req;

        // 1. Random Traffic
        repeat (100) begin
            req = async_fifo_rd_tr::type_id::create("req");

            start_item(req);

            if (!req.randomize()) begin
                `uvm_error("ASYNC_FIFO_RD_SEQ", "RD SEQ Randomization Failed")
            end

            finish_item(req);
        end

        // 2. Drain FIFO to empty
        // Read side can only control read ops, we can't know the actual occupancy,
        // So use a big margin
        repeat (DEPTH * 2) begin
            req = async_fifo_rd_tr::type_id::create("req");

            start_item(req);

            req.rd_en = 1'b1;

            finish_item(req);
        end

        // 3. Hold read idle
        repeat (10) begin
            req = async_fifo_rd_tr::type_id::create("req");
            start_item(req);

            req.rd_en   = 1'b0;

            finish_item(req);
        end

        // 4. More random read traffic
        repeat (100) begin
            req = async_fifo_rd_tr::type_id::create("req");
            start_item(req);

            if (!req.randomize()) begin
                `uvm_error("ASYNC_FIFO_RD_SEQ", "RD randomization failed")
            end

            finish_item(req);
        end

    endtask
endclass