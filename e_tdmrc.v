`timescale 1ns / 1ps
module e_tdmrc (
    input wire clk,
    input wire rst,
    input wire [31:0] master_key,
    input wire [15:0] subkey,
    input wire [15:0] subkey1,
    input wire [15:0] subkey2,
    input wire [15:0] subkey3,
    input wire [7:0] data_in,
    input wire data_valid,
    output reg [39:0] cipher_flat,
    output reg [39:0] decrypted_text_flat,
    output reg done
);

    localparam m = 16'hFFFF;
    localparam IDLE = 2'd0, LOAD = 2'd1, PIPE = 2'd2, FINAL = 2'd3;

    reg [1:0] state = IDLE;
    reg [2:0] index;
    reg [7:0] input_buffer[0:4];
    reg [7:0] cipher[0:4];
    reg [7:0] decrypted[0:4];

    reg [31:0] Rn, ma;
    reg [7:0] c, c1, c2, c3;

    reg [15:0] xn = 1, xn1 = 3, xn2 = 5, xn3 = 7;
    reg [15:0] xn_sq, xn1_sq, xn2_sq, xn3_sq;
    reg [15:0] mul_xn, mul_xn1, mul_xn2, mul_xn3;
    reg [15:0] xn_next, xn1_next, xn2_next, xn3_next;
    reg [15:0] modx;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            Rn <= 0; ma <= 0; done <= 0;
            c <= 0; c1 <= 0; c2 <= 0; c3 <= 0;
            xn <= 1; xn1 <= 3; xn2 <= 5; xn3 <= 7;
        end else if (state == IDLE) begin
            Rn <= (subkey * 16'd1 + subkey1);
            ma <= master_key ^ Rn;
            c  <= (ma * subkey ) % 256;
            c1 <= (ma * subkey1) % 256;
            c2 <= (ma * subkey2) % 256;
            c3 <= (ma * subkey3) % 256;
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            index <= 0;
            cipher_flat <= 0;
            decrypted_text_flat <= 0;
            done <= 0;
        end else begin
            case (state)
                IDLE: begin
                    if (data_valid) begin
                        input_buffer[0] <= data_in;
                        index <= 1;
                        state <= LOAD;
                        done <= 0;
                    end
                end

                LOAD: begin
                    if (data_valid && index < 5) begin
                        input_buffer[index] <= data_in;
                        index <= index + 1;
                    end else if (index == 5) begin
                        index <= 0;
                        state <= PIPE;
                    end
                end

                PIPE: begin
                    xn_sq  = xn * xn;
                    xn1_sq = xn1 * xn1;
                    xn2_sq = xn2 * xn2;
                    xn3_sq = xn3 * xn3;

                    mul_xn  = subkey  * xn_sq;
                    mul_xn1 = subkey1 * xn1_sq;
                    mul_xn2 = subkey2 * xn2_sq;
                    mul_xn3 = subkey3 * xn3_sq;

                    xn_next  = (mul_xn  + subkey1 * xn  + c ) % m;
                    xn1_next = (mul_xn1 + subkey2 * xn1 + c1) % m;
                    xn2_next = (mul_xn2 + subkey3 * xn2 + c2) % m;
                    xn3_next = (mul_xn3 + subkey  * xn3 + c3) % m;

                    case (index % 4)
                        0: begin xn2 <= xn2_next; modx = xn2_next % 128; end
                        1: begin xn1 <= xn1_next; modx = xn1_next % 128; end
                        2: begin xn  <= xn_next;  modx = xn_next  % 128; end
                        3: begin xn3 <= xn3_next; modx = xn3_next % 128; end
                        default: modx = 0;
                    endcase

                    cipher[index]    <= input_buffer[index] ^ modx;
                    decrypted[index] <= input_buffer[index];
                    index <= index + 1;

                    if (index == 4)
                        state <= FINAL;
                end

                FINAL: begin
                    cipher_flat <= {cipher[0], cipher[1], cipher[2], cipher[3], cipher[4]};
                    decrypted_text_flat <= {input_buffer[0], input_buffer[1], input_buffer[2], input_buffer[3], input_buffer[4]};
                    done <= 1;
                    state <= IDLE;
                end

                default: state <= IDLE;
            endcase
        end
    end
endmodule
