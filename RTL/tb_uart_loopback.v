`timescale 1ns/1ps

module uart_loopback_tb;

  parameter CLK_PERIOD = 100;               // 100 MHz clock
  parameter CLKS_PER_BIT = 87;           // For 115200 baud @ 100 MHz
  parameter BIT_PERIOD = 8600;

  reg clk = 0;
  reg rx = 1;
  wire tx;
  wire o_Tx_Active;
  wire o_Tx_Done;

  // Instantiate the loopback DUT
  uart_loopback_top #(.CLKS_PER_BIT(CLKS_PER_BIT)) dut (
    .i_Clock(clk),
    .i_Rx_Serial(rx),
    .o_Tx_Serial(tx),
    .o_Tx_Active(o_Tx_Active),
    .o_Tx_Done(o_Tx_Done)
  );

  // Generate clock
  always #(CLK_PERIOD/2) clk = ~clk;

  // Task to send UART byte via RX line
  task uart_send_byte(input [7:0] data);
    integer i;
    begin
      $display("Sending byte: %c (0x%h)", data, data);
      rx <= 0; #(BIT_PERIOD);// start bit
      // #1000;
      for (i = 0; i < 8; i = i + 1) begin
        rx <= data[i];
        // $display("Sending bit %d: %b", i, data[i]);
        #(BIT_PERIOD);
      end
      rx <= 1; #(BIT_PERIOD);// stop bit
    end
  endtask

  task uart_receive_byte(output [7:0] data);
    integer i, timeout;
    begin
      timeout = 0;
      while (o_Tx_Active == 0 && timeout < 100000) begin
        @(posedge clk);
        timeout = timeout + 1;
      end
      if (timeout == 100000) begin
        $display("Timeout waiting for TX start bit!");
        data = 8'h00;
        disable uart_receive_byte;
      end

      if (o_Tx_Active == 1) begin
        #(BIT_PERIOD); // start bit
        // #(BIT_PERIOD + BIT_PERIOD/2); // move to center of first data bit
        for (i = 0; i < 8; i = i + 1) begin
          data[i] = tx;
          // $display("Receiving bit %d: %b", i, tx);
          #(BIT_PERIOD);
        end
        #(BIT_PERIOD); // stop bit
      end
    end
  endtask

  reg [7:0] rcvd;

  // initial $monitor("Time: %0t | o_Tx_Active: %b | o_Tx_Done: %b | w_Rx_DV: %b | w_Rx_Byte: %x", $time, o_Tx_Active, o_Tx_Done, dut.w_Rx_DV, dut.w_Rx_Byte);
  // Simulation logic
  initial begin
    $display("Starting UART Loopback TB...");
    #1000;

    uart_send_byte(8'h41);
    @(posedge clk);
    uart_receive_byte(rcvd);
    $display("TX Received: %c (0x%h)", rcvd, rcvd);

    uart_send_byte(8'h42);
    @(posedge clk);
    uart_receive_byte(rcvd);
    $display("TX Received: %c (0x%h)", rcvd, rcvd);

    uart_send_byte(8'h43);
    @(posedge clk);
    uart_receive_byte(rcvd);
    $display("TX Received: %c (0x%h)", rcvd, rcvd);

    uart_send_byte(8'h44);
    @(posedge clk);
    uart_receive_byte(rcvd);
    $display("TX Received: %c (0x%h)", rcvd, rcvd);

    #10000;
    $finish;
  end

endmodule
