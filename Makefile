all:
	make -C ./lpc_chip_175x_6x
	make -C ./lpc_board_nxp_lpcxpresso_1769
	make -C ./app	
clean:
	make clean -C ./lpc_chip_175x_6x
	make clean -C ./lpc_board_nxp_lpcxpresso_1769
	make clean -C ./app
