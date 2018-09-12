----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    09:22:00 01/22/2018 
-- Design Name: 
-- Module Name:    beat - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;



-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ecgnew is
generic(width39:integer :=39;
        width19:integer :=19;
		  back:integer :=85);
port(ipt:in std_logic_vector (39 downto 0);
     winout :in std_logic_vector(4 downto 0);
	  peakd:out std_logic_vector(19 downto 0);
	  clk :in std_logic; ce:in std_logic :='1';
--from win Module
     wready :in std_logic;
	  r: out std_logic);

end entity ecgnew;

--Architecture
architecture Behavioral of ecgnew is
type state is (prefetch, load1, load2, peak1, peak2);
type inter is array(0 to 1)of std_logic_vector(19 downto 0);
signal reg2:inter;
signal c_state,n_state:state;
signal counter:integer:=0;
signal mx:std_logic_vector(39 downto 0) := X"0000000000";
signal th:std_logic_vector(39 downto 0);
signal peakv:std_logic_vector(19 downto 0);
signal iw,pw,tw,rw:std_logic;
signal ivalue:std_logic_vector(39 downto 0);

begin
  logic:process(clk) is
  variable iptest:std_logic_vector(39 downto 0);
  begin
    if clk'event and clk='1' then 
		if ce = '1' then 
			if ipt/= X"0000000000" then 
				counter <= counter+1;
				iptest := ipt;
				if counter <=400 then 
					if unsigned(iptest)> unsigned(mx) then
						mx <= iptest;
					end if;
				else
				c_state <= n_state;
			end if;
				
		end if;
		else
			c_state <= prefetch;
		end if;
	end if;
end process logic;

--Threshold register
process(mx,clk,tw) is
variable temp3i,temp3:std_logic_vector(41 downto 0);
variable thi1 :std_logic_vector (43 downto 0);
variable thi :std_logic_vector (43 downto 0);
begin
	if clk'event and clk ='1' then
		if counter <= 400 then 
			temp3i :=std_logic_vector((to_unsigned(3,2))*(unsigned(mx)));
			temp3:=std_logic_vector((unsigned(temp3i))/(to_unsigned(4,3)));
			--40 bits
			th <= std_logic_vector(resize(unsigned(temp3),40)); --40 bits
		else
			if tw ='1' then
			thi1 := std_logic_vector( to_unsigned(1,4)*unsigned(ivalue));
			thi := std_logic_vector (unsigned (thi1)/to_unsigned(8,7));
			th <=std_logic_vector(resize(unsigned(thi),40));
		end if;
	end if;
end if;
end process;

--Peak position
process(iw,clk) is
	begin
		 if clk'event and clk='1' then
			if pw ='1' then
				peakv <= std_logic_vector(to_unsigned(counter,20));
			end if;
		end if;
end process;

--Reg2 Storage Register
process(rw,clk) is
begin
	if clk'event and clk='1' then 
			if rw ='1' then
				reg2(1) <= reg2(0);
				reg2(0) <= peakv;
			end if;
	end if;
end process;

--Combinational Part of FSM begins here

detection: process( c_state, ipt, wready, winout, th,reg2) is
variable temp1:std_logic_vector(39 downto 0);
begin
	peakd <= X"00000";
		case c_state is
			when prefetch =>
			r <= '0';
			iw <='0';
			rw <='0';
			tw <='0';
			if counter >400 then
				n_state <= Load1;
			else 
				n_state <= prefetch;
			end if;
		
		when Load1 =>
			temp1 :=ipt;
			iw <= '0';
			rw <= '0';
			pw <= '0';
			tw <= '0';
			
			if unsigned(temp1)> unsigned(th) then --both 40 bits
				iw <= '1';
				pw <= '1';
				n_state <= Load2;
			else
				n_state <=Load1;
			end if;
			r <= '0';
		
		when Load2 =>
			 temp1 :=ipt;
			 r <='0';
			 iw <='0';
			 pw <='0';
			 rw <='0';
			 tw <='0';
			if unsigned(temp1)> unsigned(ivalue) then
				pw <='1';
				iw <='1';
				n_state <= Load2;
			end if;
			if to_unsigned(3,3)*unsigned(temp1)< resize(unsigned(ivalue),43)then
				rw <= '1';
					n_state <= peak1;
				else
					n_state <= Load2;
				end if;
				
				when peak1 =>
					r <= '0';
					iw <='0';
					pw <='0';
					rw <='0';
					tw <= '0';
				if( std_logic_vector(unsigned(reg2(1))-unsigned(reg2(0))))>
			std_logic_vector(to_unsigned(30,20)) then
					n_state <= peak2;
					r <= '1';
				else
					n_state <= Load1;
				end if;
			when peak2 =>
				r <= '1';
				tw <= '1';
				rw <= '0';
				iw <= '0';
				pw <= '0';
				if wready = '1' then 
					r <='0';
					peakd <= std_logic_vector(to_unsigned(counter,20)+
			resize(unsigned(winout),20)-to_unsigned(back,20));
					n_state <= Load1;
				else
					n_state <= Peak2;
				end if;
				
			end case;
	end process;
	
end Behavioral;


