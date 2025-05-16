
// CLKS_PER_BIT is calculated for 27 Mhz clock
// and 9600 Baud rate
// CLKS_PER_BIT = 27000000 / 9600
// chnage the value accordingly

// For Nexys4, clk = 100MHz
// CLKS_PER_BIT = 100000000 / 115200 = 868

module uart_top(input clk,
                input wire uart_rx,
                output wire uart_tx,
                output wire[7:0] LED);
    
    wire [7:0] data8;
    wire data8_avail;
    reg [7:0] led_reg;
    wire active;
    wire done;
    
    uart_rx#(.CLKS_PER_BIT(868))  UART_RX (
    .clock (clk),
    .i_rx (uart_rx),
    .o_data_byte (data8),
    .o_data_avail(data8_avail)
    );
    
    
    uart_tx# (.CLKS_PER_BIT(868)) UART_TX (
    .clock(clk),
    .i_data_avail(data8_avail),
    .i_data_byte(data8),
    .o_active (active),
    .o_tx (uart_tx),
    .o_done (done)
    );
    
    assign LED = led_reg;
    
    always @ (posedge clk)
    begin
        if (data8_avail)
            led_reg <= data8;
        
    end
    
endmodule
