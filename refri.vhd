library IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY refri is 
	port(
		clk	: in 	std_logic;
		reset	: in 	std_logic;
		moedas	: in std_logic_vector(3 downto 0);
		button 	: in std_logic;
		cent	: out std_logic_vector(6 downto 0);
		dez	: out std_logic_vector(6 downto 0);
		uni 	: out std_logic_vector(6 downto 0);
		led	: out std_logic_vector(2 downto 0)
	);
end refri;

architecture main of refri is 
	type estados is (init, recebe, refri, retorna);
	signal estado	: estados := init;
	
	signal atual : integer range 0 to 200 := 0;
   signal prox : integer range 0 to 200 := 0;
	signal button_pressed: bit:='0';
	
	function seven_seg(digit: integer) return std_logic_vector is
    begin
        case digit is
            when 0 => return not "1111110";
            when 1 => return not "0110000";
            when 2 => return not "1101101";
            when 3 => return not "1111001";
            when 4 => return not "0110011";
            when 5 => return not "1011011";
            when 6 => return not "1011111";
            when 7 => return not "1110000";
            when 8 => return not "1111111";
            when 9 => return not "1111011";
            when others => return not "0000000";
        end case;
    end function;
begin
	process(moedas, atual, button)
	begin
		case moedas is
				when "0001" => prox <= atual + 10;
            when "0010" => prox <= atual + 25;
            when "0100" => prox <= atual + 50;
            when "1000" => prox <= atual + 100;
            when others => prox <= atual;
        end case;
    end process;
	 
	process(clk, reset, button)
	begin
		if button='1' then
			button_pressed<='1';
		elsif clk='1' then
			button_pressed<='0';
		end if;
		if reset='1' then
			estado<=init;
			atual<=0;
		elsif button='1' then
			case estado is
				when recebe=>
					if atual=100 then	
						estado<=refri;
					else
						atual<=0;
						estado<=retorna;
					end if;
				when others=>
					null;
			end case;
		elsif rising_edge(clk) then
			case estado is
				when init=>
					if moedas /="0000" then
						estado<= recebe;
						atual<=prox;
					end if;
				when recebe=>
					if prox>100 then
						atual<=0;
						estado<=retorna;
					elsif moedas /="0000" then
						atual<= prox;
					end if;
				when retorna=>
					estado<= init;
					atual<= 0;
				when refri=>
					estado<= init;
					atual<= 0;
			end case;
		end if;
	end process;
	
	
	process(atual, button_pressed)
begin
    if button_pressed='1' then
        -- Forçar o display a mostrar zero se o botão for pressionado
        cent <= seven_seg(0);  -- Mostra 0 no centésimo
        dez <= seven_seg(0);   -- Mostra 0 na dezena
        uni <= seven_seg(0);   -- Mostra 0 na unidade
    else
        -- Caso o botão não seja pressionado, mostre o valor de 'atual'
        cent <= seven_seg(atual / 100);
        dez <= seven_seg((atual mod 100) / 10);
        uni <= seven_seg(atual mod 10);
    end if;
end process;
	
	process(estado)
	begin
		case estado is
			when recebe=>
				led<="100";
			when retorna=>
				led<="010";
			when refri=>
				led<="001";
			when others=>
				led<="000";
		end case;
	end process;
end main;