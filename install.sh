DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
for file in `ls $DIR | grep -v "\.sh"`;
do
	if [ -e "$HOME/.$file" ];
	then
		echo "Skipping $HOME/.$file: file exists"
	else
		echo "Symlinking $HOME/.$file to $Dir/$file"
		ln -s "$DIR/$file" "$HOME/.$file"
	fi
done
echo "Installation complete"
