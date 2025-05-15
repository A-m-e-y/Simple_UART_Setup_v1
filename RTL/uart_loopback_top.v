module uart_loopback_top #(
    parameter CLKS_PER_BIT = 868
)(
    input        i_Clock,
    input        i_Rx_Serial,
    output       o_Tx_Serial,
    output       o_Tx_Active,
    output       o_Tx_Done
);

  // UART RX output
  wire       w_Rx_DV;
  wire [7:0] w_Rx_Byte;

  // UART TX control
  wire       w_Tx_Active;
  wire       w_Tx_Done;

     
  uart_rx #(.CLKS_PER_BIT(CLKS_PER_BIT)) UART_RX_INST
    (.i_Clock(i_Clock),
     .i_Rx_Serial(i_Rx_Serial),
     .o_Rx_DV(w_Rx_DV),
     .o_Rx_Byte(w_Rx_Byte)
     );
   
  uart_tx #(.CLKS_PER_BIT(CLKS_PER_BIT)) UART_TX_INST
    (.i_Clock(i_Clock),
     .i_Tx_DV(w_Rx_DV),
     .i_Tx_Byte(w_Rx_Byte),
     .o_Tx_Active(o_Tx_Active),
     .o_Tx_Serial(o_Tx_Serial),
     .o_Tx_Done(o_Tx_Done)
     );


endmodule
