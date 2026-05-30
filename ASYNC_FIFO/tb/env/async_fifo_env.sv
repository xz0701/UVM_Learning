class async_fifo_env extends uvm_env;

    `uvm_component_utils(async_fifo_env)

    async_fifo_wr_agent wr_agt;
    async_fifo_rd_agent rd_agt;
    async_fifo_scoreboard scb;
    async_fifo_cov cov;

    function new(string name = "async_fifo_env", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        wr_agt = async_fifo_wr_agent::type_id::create("wr_agt", this);
        rd_agt = async_fifo_rd_agent::type_id::create("rd_agt", this);
        scb    = async_fifo_scoreboard::type_id::create("scb", this);
        cov    = async_fifo_cov::type_id::create("cov", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        wr_agt.monitor.ap.connect(scb.wr_imp);
        rd_agt.monitor.ap.connect(scb.rd_imp);
    endfunction

endclass