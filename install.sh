for file in `ls . | grep -v "\.sh"`;
do
	cp -r $file ~/.$file
done
