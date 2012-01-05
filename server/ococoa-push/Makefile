have_private := $(wildcard PrivateInfo.py) 
 
ifeq ($(strip $(have_private)),) 
 
rule: 
	cp PrivateInfo.py.in PrivateInfo.py

else

rule:
	echo "Nothing to do."

endif 

clean:
	rm -f *.pyc PrivateInfo.py