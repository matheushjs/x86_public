clean:
	find -name "*~" -exec rm -vf '{}' \;
	find -name "*.o" -exec rm -vf '{}' \;
