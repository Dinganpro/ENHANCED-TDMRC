`timescale 1ns / 1ps
module tb_e_tdmrc;

    reg clk = 0;
    reg rst = 1;
    reg data_valid = 0;
    reg [7:0] data_in;
    reg [7:0] input_word [0:4];
    reg [2:0] i;

    wire [39:0] cipher_flat;
    wire [39:0] decrypted_text_flat;
    wire done;

    reg [7:0] cipher_byte, decrypted_byte;

    // Test keys
    reg [31:0] master_key = 32'h009a4e2a;
    reg [15:0] subkey  = 16'h04d2;
    reg [15:0] subkey1 = 16'h162e;
    reg [15:0] subkey2 = 16'h03eb;
    reg [15:0] subkey3 = 16'h0647;

    // Instantiate DUT
    e_tdmrc uut (
        .clk(clk),
        .rst(rst),
        .master_key(master_key),
        .subkey(subkey),
        .subkey1(subkey1),
        .subkey2(subkey2),
        .subkey3(subkey3),
        .data_in(data_in),
        .data_valid(data_valid),
        .cipher_flat(cipher_flat),
        .decrypted_text_flat(decrypted_text_flat),
        .done(done)
    );

    always #5 clk = ~clk;

    initial begin
        $display("==== ENCRYPTION TEST ====");

        // Test 5-letter word: modify here to test different input
        input_word[0] = "F";
        input_word[1] = "I";
        input_word[2] = "M";
        input_word[3] = "J";
        input_word[4] = "D";

        rst = 1; #20; rst = 0;

        data_valid = 1;
        for (i = 0; i < 5; i = i + 1) begin
            data_in = input_word[i];
            #10;
        end
        data_valid = 0;

        wait(done);
        #20;  // Wait for registers to update

        $display("\nCipher Values:");
        for (i = 0; i < 5; i = i + 1) begin
            case (i)
                0: cipher_byte = cipher_flat[39:32];
                1: cipher_byte = cipher_flat[31:24];
                2: cipher_byte = cipher_flat[23:16];
                3: cipher_byte = cipher_flat[15:8];
                4: cipher_byte = cipher_flat[7:0];
            endcase
            $display("Cipher[%0d] = %0d", i, cipher_byte);
        end

        $display("\nDecrypted Text:");
        for (i = 0; i < 5; i = i + 1) begin
            case (i)
                0: decrypted_byte = decrypted_text_flat[39:32];
                1: decrypted_byte = decrypted_text_flat[31:24];
                2: decrypted_byte = decrypted_text_flat[23:16];
                3: decrypted_byte = decrypted_text_flat[15:8];
                4: decrypted_byte = decrypted_text_flat[7:0];
            endcase
            $write("%c", decrypted_byte);
        end
        $display;

        $stop;
    end
endmodule
