library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity seven_segment_display is
    Port (
        clk         : in  STD_LOGIC;          -- Clock input
        reset       : in  STD_LOGIC;          -- Reset signal
        binary_in   : in  STD_LOGIC_VECTOR(3 downto 0); -- 4-bit binary input
        seg         : out STD_LOGIC_VECTOR(6 downto 0); -- Seven-segment display output
        an          : out STD_LOGIC_VECTOR(3 downto 0)  -- Anode control for four digits
    );
end seven_segment_display;

architecture Behavioral of seven_segment_display is

    signal clk_div    : STD_LOGIC_VECTOR(15 downto 0) := (others => '0'); -- Clock divider for multiplexing rate
    signal mux_select : STD_LOGIC_VECTOR(1 downto 0) := "00";              -- Selects the active digit
    signal current_digit : STD_LOGIC_VECTOR(3 downto 0);                   -- Current digit to display
    signal seg_pattern   : STD_LOGIC_VECTOR(6 downto 0);                   -- Segment pattern for current digit

    -- Digit patterns for the seven-segment display (common cathode)
    function to_seven_seg (binary : STD_LOGIC_VECTOR(3 downto 0)) return STD_LOGIC_VECTOR is
    begin
        case binary is
            when "0000" => return "1000000"; -- 0
            when "0001" => return "1111001"; -- 1
            when "0010" => return "0100100"; -- 2
            when "0011" => return "0110000"; -- 3
            when "0100" => return "0011001"; -- 4
            when "0101" => return "0010010"; -- 5
            when "0110" => return "0000010"; -- 6
            when "0111" => return "1111000"; -- 7
            when "1000" => return "0000000"; -- 8
            when "1001" => return "0010000"; -- 9
            when others => return "1111111"; -- blank display
        end case;
    end function;

begin
    -- Clock divider to control multiplexing rate (adjustable for desired refresh rate)
    process (clk, reset)
    begin
        if reset = '1' then
            clk_div <= (others => '0');
        elsif rising_edge(clk) then
            clk_div <= clk_div + 1;
        end if;
    end process;

    -- Multiplexing logic for selecting each digit
    process (clk_div)
    begin
        if clk_div(15) = '1' then  -- Choose slower bit for multiplexing rate
            mux_select <= mux_select + 1;
        end if;
    end process;

    -- Set the anode and segment patterns based on the selected digit
    process (mux_select, binary_in)
    begin
        case mux_select is
            when "00" => -- First digit
                an <= "1110";          -- Enable first digit (active low)
                current_digit <= binary_in; -- Display the binary input directly for simplicity
            when "01" => -- Second digit
                an <= "1101";          -- Enable second digit
                current_digit <= binary_in; -- For demonstration, reuse the same input
            when "10" => -- Third digit
                an <= "1011";          -- Enable third digit
                current_digit <= binary_in;
            when "11" => -- Fourth digit
                an <= "0111";          -- Enable fourth digit
                current_digit <= binary_in;
            when others =>
                an <= "1111";          -- All off
        end case;
        -- Get the seven-segment pattern for the current digit
        seg_pattern <= to_seven_seg(current_digit);
    end process;

    -- Output assignment
    seg <= seg_pattern;

end Behavioral;
