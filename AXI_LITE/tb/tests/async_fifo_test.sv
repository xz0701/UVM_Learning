class async_fifo_test extends uvm_test;
    `uvm_component_utils(async_fifo_test)

    async_fifo_env env;
    async_fifo_wr_seq wr_seq;
    async_fifo_rd_seq rd_seq;
    virtual async_fifo_if vif;

    function new(string name = "async_fifo_test", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        env = async_fifo_env::type_id::create("env", this);

        if (!uvm_config_db #(virtual async_fifo_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("ASYNC_FIFO_TEST", "Failed to get virtual interface")
        end

    endfunction

    virtual task run_phase(uvm_phase phase);

        phase.raise_objection(this);
        wr_seq = async_fifo_wr_seq::type_id::create("wr_seq");
        rd_seq = async_fifo_rd_seq::type_id::create("rd_seq");

        fork
            wr_seq.start(env.wr_agt.sequencer);
            rd_seq.start(env.rd_agt.sequencer);
        join

        repeat (10) @(posedge vif.wr_clk);
        repeat (10) @(posedge vif.rd_clk);

        phase.drop_objection(this);
    endtask
endclass
