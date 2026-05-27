class async_fifo_rd_agent extends uvm_agent;

    `uvm_component_utils(async_fifo_rd_agent)

    async_fifo_wr_sequencer sequencer;
    async_fifo_wr_driver driver;
    async_fifo_wr_monitor monitor;

    function new(string name = "async_fifo_rd_agent", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        sequencer = async_fifo_rd_sequencer::type_id::create("sequencer", this);
        driver = async_fifo_rd_driver::type_id::create("driver", this);
        monitor = async_fifo_rd_monitor::type_id::create("monitor", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        
        driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction
endclass