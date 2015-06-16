PROJECTS := ./lpc_chip_175x_6x ./lpc_board_nxp_lpcxpresso_1769 ./app

all:
	@for PROJECT in $(PROJECTS) ; do \
		echo "*** Building project $$PROJECT ***" ; \
		make -C $$PROJECT ; \
		echo "" ; \
	done
clean:
	@for PROJECT in $(PROJECTS) ; do \
		echo "*** Cleaning project $$PROJECT ***" ; \
		make clean -C $$PROJECT ; \
		echo "" ; \
	done
