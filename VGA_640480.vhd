library	ieee;
use		ieee.std_logic_1164.all;
use		ieee.std_logic_unsigned.all;
use		ieee.std_logic_arith.all;
use 	ieee.numeric_std;

entity vga640480 is
	 port(
			address		:		  out STD_LOGIC_VECTOR(15 DOWNTO 0);
			reset       :         in  STD_LOGIC;
			clk50       :		  out std_logic; 
			qr, qg, qb	:		  in STD_LOGIC_VECTOR(2 downto 0);
			clk_0       :         in  STD_LOGIC; --50Mʱ������
			hs,vs       :         out STD_LOGIC; --��ͬ������ͬ���ź�
			r,g,b       :         out STD_LOGIC_vector(2 downto 0);
			wkey		:         in STD_LOGIC
	  );
end vga640480;

architecture behavior of vga640480 is
	
	signal r1,g1,b1   : std_logic_vector(2 downto 0);					
	signal hs1,vs1    : std_logic;				
	signal vector_x, posx : std_logic_vector(9 downto 0);		--X����
	signal vector_y, posy : std_logic_vector(8 downto 0);		--Y����
	signal startx, starty: std_logic_vector(7 downto 0);
	signal clk, clk1	:	 std_logic;
	signal x: std_logic_vector(7 downto 0);
begin
clk50 <= clk;

 --------------------- --------------------------------------------------
  process(clk_0)	--��50M�����źŶ���Ƶ
    begin
        if(clk_0'event and clk_0='1') then 
             clk1 <= not clk1;
        end if;
 	end process;
 	
 	process(clk1)	--??50M��?��?D?o??t��??��
    begin
        if(clk1'event and clk1='1') then 
             clk <= not clk;
        end if;
 	end process;

	process(clk, reset)
	begin
		if reset = '0' then
			x <= (others => '0');
		elsif clk'event and clk = '1' then
			if vector_x = 0 and vector_y = 0 then
				if (x = 2) then
					x <= (others => '0');
				else 
					x <= x + 1;
				end if;
			end if;
		end if;
	end process;
	
	process(clk, reset, vector_x, vector_y)
	begin
		if reset = '0' then
			startx <= (others=>'0');
		elsif clk'event and clk = '1' then
			if vector_x = 640 and vector_y = 480 and x = 1 then
				if (startx = 640-256) then
					startx <= (others => '0');
				else
					startx <= startx + 1;
				end if;
			end if;
		end if;
	end process;
	
	process(clk, reset, vector_x, vector_y)
	begin
		if reset = '0' then
			starty <= (others=>'0');
		elsif clk'event and clk = '1' then
			if vector_x = 640 and vector_y = 480 then
				if (starty = 480-256) then
					starty <= (others => '0');
				else
					starty <= starty + wkey;
				end if;
			end if;
		end if;
	end process;
 -----------------------------------------------------------------------
	 process(clk,reset)	--������������������������
	 begin
	  	if reset='0' then
	   		vector_x <= (others=>'0');
	  	elsif clk'event and clk='1' then
	   		if vector_x=799 then
	    		vector_x <= (others=>'0');
	   		else
	    		vector_x <= vector_x + 1;
	   		end if;
	  	end if;
	 end process;

  -----------------------------------------------------------------------
	 process(clk,reset)	--����������������������
	 begin
	  	if reset='0' then
	   		vector_y <= (others=>'0');
	  	elsif clk'event and clk='1' then
	   		if vector_x=799 then
	    		if vector_y=524 then
	     			vector_y <= (others=>'0');
	    		else
	     			vector_y <= vector_y + 1;
	    		end if;
	   		end if;
	  	end if;
	 end process;
 
  -----------------------------------------------------------------------
	 process(clk,reset) --��ͬ���źŲ�����ͬ������96��ǰ��16��
	 begin
		  if reset='0' then
		   hs1 <= '1';
		  elsif clk'event and clk='1' then
		   	if vector_x>=656 and vector_x<752 then
		    	hs1 <= '0';
		   	else
		    	hs1 <= '1';
		   	end if;
		  end if;
	 end process;
 
 -----------------------------------------------------------------------
	 process(clk,reset) --��ͬ���źŲ�����ͬ������2��ǰ��10��
	 begin
	  	if reset='0' then
	   		vs1 <= '1';
	  	elsif clk'event and clk='1' then
	   		if vector_y>=490 and vector_y<492 then
	    		vs1 <= '0';
	   		else
	    		vs1 <= '1';
	   		end if;
	  	end if;
	 end process;
 -----------------------------------------------------------------------
	 process(clk,reset) --��ͬ���ź����
	 begin
	  	if reset='0' then
	   		hs <= '0';
	  	elsif clk'event and clk='1' then
	   		hs <=  hs1;
	  	end if;
	 end process;

 -----------------------------------------------------------------------
	 process(clk,reset) --��ͬ���ź����
	 begin
	  	if reset='0' then
	   		vs <= '0';
	  	elsif clk'event and clk='1' then
	   		vs <=  vs1;
	  	end if;
	 end process;
	
 -----------------------------------------------------------------------	
	process(reset,clk,vector_x,vector_y) -- XY���궨λ����
	begin  
		if reset='0' then
			        r1  <= "000";
					g1	<= "000";
					b1	<= "000";	
		elsif(clk'event and clk='1')then
		 	if (vector_x - startx < 256) and (vector_y - starty < 256) and (vector_x >= startx) and (vector_y >= starty) then		
				posy <= vector_y - starty;
				posx <= vector_x - startx;
				address <= posy(7 downto 0) & posx(7 downto 0);
				r1 <= (others => qr(0));
				b1 <= (others => qb(0));
				g1 <= (others => qg(0));
			else
					r1  <= "000";
					g1	<= "100";
					b1	<= "100";
			end if;
		end if;		 
	    end process;	

	-----------------------------------------------------------------------
	process (hs1, vs1, r1, g1, b1)	--ɫ�����
	begin
		if vector_x <= 640 and vector_y <= 480 then
			r	<= r1;
			g	<= g1;
			b	<= b1;
		else
			r	<= (others => '0');
			g	<= (others => '0');
			b	<= (others => '0');
		end if;
	end process;

end behavior;
