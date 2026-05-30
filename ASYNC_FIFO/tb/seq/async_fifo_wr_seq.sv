class async_fifo_wr_seq extends uvm_sequence #(async_fifo_wr_tr);

    `uvm_object_utils(async_fifo_wr_seq)

    function new(string name = "async_fifo_wr_seq");
        super.new(name);
    endfunction

    virtual task body();

        async_fifo_wr_tr req;

        // 1. Random Traffic
        repeat (100) begin
            req = async_fifo_wr_tr::type_id::create("req");

            start_item(req);

            if (!req.randomize()) begin
                `uvm_error("ASYNC_FIFO_WR_SEQ", "WR SEQ Randomization Failed")
            end

            finish_item(req);
        end

        // 2. Fill FIFO to full
        // Write side can only control write ops, we can't know the actual occupancy,
        // So use a big margin
        repeat (DEPTH * 2) begin
            req = async_fifo_wr_tr::type_id::create("req");

            start_item(req);

            req.wr_en = 1'b1;
            req.wr_data = $urandom();

            finish_item(req);
        end

        // 3. Hold write active after FIFO is likely full
        repeat (20) begin
            req = async_fifo_wr_tr::type_id::create("req");
            start_item(req);

            req.wr_en   = 1'b1;
            req.wr_data = $urandom();

            finish_item(req);
        end

        // 4. More random write traffic
        repeat (100) begin
            req = async_fifo_wr_tr::type_id::create("req");
            start_item(req);

            if (!req.randomize()) begin
                `uvm_error("ASYNC_FIFO_WR_SEQ", "WR randomization failed")
            end

            finish_item(req);
        end

        // Wait while read side drains FIFO to empty
        repeat (DEPTH * 3) begin
            req = async_fifo_wr_tr::type_id::create("req");
            start_item(req);
            req.wr_en   = 1'b0;
            req.wr_data = '0;
            finish_item(req);
        end

        // Hit empty + simultaneous read/write
        repeat (20) begin
            req = async_fifo_wr_tr::type_id::create("req");
            start_item(req);
            req.wr_en   = 1'b1;
            req.wr_data = $urandom();
            finish_item(req);
        end

    endtask
endclass