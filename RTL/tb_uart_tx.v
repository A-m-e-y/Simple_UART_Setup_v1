// This testbench will exercise both the UART Tx and Rx.
// It sends out byte 0xAB over the transmitter
// It then exercises the receive by receiving byte 0x3F
`timescale 1ns/10ps
 
module uart_tb ();
 
  // Testbench uses a 10 MHz clock
  // Want to interface to 115200 baud UART
  // 10000000 / 115200 = 87 Clocks Per Bit.
  parameter c_CLOCK_PERIOD_NS = 100;
  parameter c_CLKS_PER_BIT    = 87;
  parameter c_BIT_PERIOD      = 8600;
   
  reg r_Clock = 0;
  reg r_Tx_DV = 0;
  
  wire w_Tx_Done;
  wire w_Tx_Active;
  wire w_Tx_Serial;

  reg [7:0] r_Tx_Byte = 0;
  reg r_Rx_Serial = 1;
   
   
  uart_tx #(.CLKS_PER_BIT(c_CLKS_PER_BIT)) UART_TX_INST
    (.i_Clock(r_Clock),
     .i_Tx_DV(r_Tx_DV),
     .i_Tx_Byte(r_Tx_Byte),
     .o_Tx_Active(w_Tx_Active),
     .o_Tx_Serial(w_Tx_Serial),
     .o_Tx_Done(w_Tx_Done)
     );
 
   
  always
    #(c_CLOCK_PERIOD_NS/2) r_Clock <= !r_Clock;
 

  initial $monitor("Time: %0t | Tx_Serial: %b | Tx_Active: %b | Tx_Done: %b",
           $time, w_Tx_Serial, w_Tx_Active, w_Tx_Done);

  // Main Testing:
  initial
    begin
      // Enable waveform dump
      $dumpfile("uart_tb.vcd");
      $dumpvars(0, uart_tb);
      // Tell UART to send a command (exercise Tx)
      @(posedge r_Clock);
      @(posedge r_Clock);
      r_Tx_DV <= 1'b1;
      r_Tx_Byte <= 8'hAB;
      @(posedge r_Clock);
      r_Tx_DV <= 1'b0;
      @(posedge w_Tx_Done);
       
    
      #10000;
      $finish;

    end
   
endmodule
