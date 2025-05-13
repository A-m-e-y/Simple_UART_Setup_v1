module uart_loopback_top #(
    parameter CLKS_PER_BIT = 868  // Adjust this based on your FPGA clock (e.g., 100 MHz / 115200 baud)
)(
    input        i_Clock,       // System clock (e.g., 100 MHz for Nexys 4)
    input        i_Rx_Serial,   // UART RX input from PC
    output       o_Tx_Serial    // UART TX output to PC
);

  wire       w_Rx_DV;
  wire [7:0] w_Rx_Byte;
  reg        r_Tx_DV = 0;
  reg  [7:0] r_Tx_Byte;
  wire       w_Tx_Active;
  wire       w_Tx_Done;

  // Instantiate UART Receiver
  uart_rx #(.CLKS_PER_BIT(CLKS_PER_BIT)) uart_rx_inst (
    .i_Clock(i_Clock),
    .i_Rx_Serial(i_Rx_Serial),
    .o_Rx_DV(w_Rx_DV),
    .o_Rx_Byte(w_Rx_Byte)
  );

  // Instantiate UART Transmitter
  uart_tx #(.CLKS_PER_BIT(CLKS_PER_BIT)) uart_tx_inst (
    .i_Clock(i_Clock),
    .i_Tx_DV(r_Tx_DV),
    .i_Tx_Byte(r_Tx_Byte),
    .o_Tx_Active(w_Tx_Active),
    .o_Tx_Serial(o_Tx_Serial),
    .o_Tx_Done(w_Tx_Done)
  );

  // State machine to send received byte back
  typedef enum logic [1:0] {IDLE, SEND} state_t;
  state_t r_State = IDLE;

  always @(posedge i_Clock) begin
    case (r_State)
      IDLE: begin
        r_Tx_DV <= 1'b0;  // default
        if (w_Rx_DV && ~w_Tx_Active) begin
          r_Tx_Byte <= w_Rx_Byte;
          r_Tx_DV   <= 1'b1;
          r_State   <= SEND;
        end
      end

      SEND: begin
        r_Tx_DV <= 1'b0;  // one-shot pulse
        if (w_Tx_Done) begin
          r_State <= IDLE;
        end
      end
    endcase
  end

endmodule
