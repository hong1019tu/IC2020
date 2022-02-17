module SME(clk,reset,chardata,isstring,ispattern,valid,match,match_index);
input clk;
input reset;
input [7:0] chardata;
input isstring;
input ispattern;
output reg match;
output reg [4:0] match_index;
output reg valid;

reg [7:0]string[31:0];
reg [7:0]pattern[8:0];
reg [5:0]str_len;
reg [5:0]patt_len;
reg [5:0]str_index,str_search;
reg [5:0]patt_index,patt_search;
reg [5:0]tmp;
reg [2:0]state;
always @(*) begin
    if(pattern[0] == 8'h5E && pattern[patt_len - 1] == 8'h24)begin
        state = 4;
    end
    else if(pattern[0] == 8'h5E && pattern[patt_len - 1] != 8'h24)begin
        state = 3;
    end
    else if(pattern[0] != 8'h5E && pattern[patt_len - 1] == 8'h24)begin
        state = 2;
    end
    else if(pattern[0] != 8'h5E && pattern[patt_len - 1] != 8'h24)begin
        state = 1;
    end
    else begin
        state = 5;
    end
end
always @(posedge clk or posedge reset) begin
    if(reset)begin
        valid <= 0;
        str_len <= 0;
        patt_len <= 0;
        str_index <= 0;
        patt_index <= 0;
        str_search <= 0;
        patt_search <= 0;
    end
    else begin
        if(valid == 1)begin
            valid <= 0;
        end
        if(isstring)begin //讀str
            string[str_len] <= chardata;
            str_len <= str_len + 1;
        end
        else if(ispattern)begin //讀pattern
            pattern[patt_len] <= chardata;
            patt_len <= patt_len + 1;
            if (str_len == 0) begin
                str_len <= tmp;
            end
        end
        else begin
            case(state)
            4:begin
                if(pattern[patt_search] == 8'h5E)begin //排除符號
                    patt_search <= patt_search + 1;
                    patt_index <= patt_index + 1;
                end
                else if(pattern[patt_search] != string[str_search] && pattern[patt_search] != 8'h2E)begin //找到第一個match
                    str_search <= str_search + 1;
                    str_index <= str_search + 1;
                    if(str_search == str_len || (str_search + patt_len-2 > str_len))begin
                        str_index <= 0;
                        patt_index <= 0;
                        str_search <= 0;
                        valid <= 1;
                        match <= 0;
                        str_len <= 0;
                        tmp <= str_len;
                        patt_len <= 0;
                        patt_search <= 0;
                    end
                end
                else begin
                    if(str_search == str_len || (str_search + patt_len-2 > str_len))begin
                        str_index <= 0;
                        patt_index <= 0;
                        str_search <= 0;
                        valid <= 1;
                        match <= 0;
                        str_len <= 0;
                        tmp <= str_len;
                        patt_len <= 0;
                        patt_search <= 0;
                    end
                    else if(((pattern[patt_index] == string[str_index] || pattern[patt_index] == 8'h2E) && patt_index < patt_len-1 ))begin
                        patt_index <= patt_index + 1;
                        str_index <= str_index + 1;
                        if((patt_index == patt_len - 2) &&((string[str_index+1] == 8'h20) || (str_index+1 == str_len)) &&((string[str_search - 1]==8'h20||str_search == 0))) begin
                            valid <= 1;
                            match <= 1;
                            match_index <= str_search;
                            str_index <= 0;
                            patt_index <= 0;
                            str_search <= 0;
                            str_len <= 0;
                            tmp <= str_len;
                            patt_len <= 0;
                            patt_search <= 0;
                        end
                    end
                    else begin
                        str_search <= str_search + 1;
                        patt_index <= patt_search;
                        str_index <= str_search + 1;
                    end
                end
            end
            3:begin
                if(pattern[patt_search] == 8'h5E)begin //排除符號
                    patt_search <= patt_search + 1;
                    patt_index <= patt_index + 1;
                end
                else if(pattern[patt_search] != string[str_search]&& pattern[patt_search] != 8'h2E)begin //找到第一個match
                    str_search <= str_search + 1;
                    str_index <= str_search + 1;
                    if(str_search == str_len || (str_search + patt_len-1 > str_len))begin
                        str_index <= 0;
                        patt_index <= 0;
                        str_search <= 0;
                        valid <= 1;
                        match <= 0;
                        str_len <= 0;
                        tmp <= str_len;
                        patt_len <= 0;
                        patt_search <= 0;
                    end
                end
                else begin
                    if(str_search == str_len || (str_search + patt_len-1 > str_len))begin
                        str_index <= 0;
                        patt_index <= 0;
                        str_search <= 0;
                        valid <= 1;
                        match <= 0;
                        str_len <= 0;
                        tmp <= str_len;
                        patt_len <= 0;
                        patt_search <= 0;
                    end
                    else if(((pattern[patt_index] == string[str_index] || pattern[patt_index] == 8'h2E) && patt_index < patt_len))begin
                        patt_index <= patt_index + 1;
                        str_index <= str_index + 1;
                        if((patt_index == patt_len-1)&& (string[str_search - 1]==8'h20||str_search == 0)) begin
                            valid <= 1;
                            match <= 1;
                            match_index <= str_search;
                            str_index <= 0;
                            patt_index <= 0;
                            str_search <= 0;
                            str_len <= 0;
                            tmp <= str_len;
                            patt_len <= 0;
                            patt_search <= 0;
                        end
                    end
                    else begin
                        str_search <= str_search + 1;
                        patt_index <= patt_search;
                        str_index <= str_search + 1;
                    end
                end
            end
            2:begin
                if(pattern[patt_search] != string[str_search] && pattern[patt_search] != 8'h2E)begin //找到第一個match
                    str_search <= str_search + 1;
                    str_index <= str_search + 1;
                    if(str_search == str_len || (str_search + patt_len-1 > str_len))begin
                        str_index <= 0;
                        patt_index <= 0;
                        str_search <= 0;
                        valid <= 1;
                        match <= 0;
                        str_len <= 0;
                        tmp <= str_len;
                        patt_len <= 0;
                        patt_search <= 0;
                    end
                end
                else begin
                    if(str_search == str_len || (str_search + patt_len-1 > str_len))begin
                        str_index <= 0;
                        patt_index <= 0;
                        str_search <= 0;
                        valid <= 1;
                        match <= 0;
                        str_len <= 0;
                        tmp <= str_len;
                        patt_len <= 0;
                        patt_search <= 0;
                    end
                    else if(((pattern[patt_index] == string[str_index] || pattern[patt_index] == 8'h2E) && patt_index < patt_len-1 ))begin
                        patt_index <= patt_index + 1;
                        str_index <= str_index + 1;
                        if(((patt_index == patt_len-2)) &&((string[str_index+1] == 8'h20) || (str_index+1 == str_len))) begin
                            valid <= 1;
                            match <= 1;
                            match_index <= str_search;
                            str_index <= 0;
                            patt_index <= 0;
                            str_search <= 0;
                            str_len <= 0;
                            tmp <= str_len;
                            patt_len <= 0;
                            patt_search <= 0;
                        end
                    end
                    else begin
                        str_search <= str_search + 1;
                        patt_index <= patt_search;
                        str_index <= str_search + 1;
                    end
                end
            end
            1:begin
                if(pattern[patt_search] != string[str_search] && pattern[patt_search] != 8'h2E)begin //找到第一個match
                    str_search <= str_search + 1;
                    str_index <= str_search + 1;
                    if(str_search == str_len || (str_search + patt_len > str_len) )begin
                        str_index <= 0;
                        patt_index <= 0;
                        str_search <= 0;
                        valid <= 1;
                        match <= 0;
                        str_len <= 0;
                        tmp <= str_len;
                        patt_len <= 0;
                        patt_search <= 0;
                    end
                end
                else begin
                    if(str_search == str_len || (str_search + patt_len > str_len) )begin
                        str_index <= 0;
                        patt_index <= 0;
                        str_search <= 0;
                        valid <= 1;
                        match <= 0;
                        str_len <= 0;
                        tmp <= str_len;
                        patt_len <= 0;
                        patt_search <= 0;
                    end
                    else if(((pattern[patt_index] == string[str_index] || pattern[patt_index] == 8'h2E) && patt_index < patt_len))begin
                        patt_index <= patt_index + 1;
                        str_index <= str_index + 1;
                        if((patt_index == patt_len - 1)) begin
                            valid <= 1;
                            match <= 1;
                            match_index <= str_search;
                            str_index <= 0;
                            patt_index <= 0;
                            str_search <= 0;
                            str_len <= 0;
                            tmp <= str_len;
                            patt_len <= 0;
                            patt_search <= 0;
                        end
                    end
                    else begin
                        str_search <= str_search + 1;
                        patt_index <= patt_search;
                        str_index <= str_search + 1;
                    end
                end
            end
            endcase
        end
    end
end
endmodule