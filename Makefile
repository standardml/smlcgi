all: smlcgic

smlcgic: smlcgic.sml
	mlton -output smlcgic smlcgic.sml

install: smlcgic
	mv smlcgic ../../../bin

clean:
	rm smlcgic
