clean:
	rm -f ami
ami:
	packer build packer.yml | tee ami
