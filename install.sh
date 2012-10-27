DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
for file in `ls $DIR | grep -v "\.sh"`;
do
	ln -s $DIR/$file ~/.$file
done
