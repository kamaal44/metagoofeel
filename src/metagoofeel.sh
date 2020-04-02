start=$(date "+%s.%N")

function basic () {
	echo "Metagoofeel v1.0 ( github.com/ivan-sincek/metagoofeel )"
	echo ""
	echo "--- Crawl and download ---"
	echo "Usage:   ./metagoofeel.sh -d domain      -k keyword -r recursion"
	echo "Example: ./metagoofeel.sh -d example.com -k all     -r 10"
	echo ""
	echo "--- Download from a file ---"
	echo "Usage:   ./metagoofeel.sh -k keyword -i input"
	echo "Example: ./metagoofeel.sh -k pdf     -i metagoofeel_urls.txt"
}

function advanced () {
	basic
	echo ""
	echo "DESCRIPTION"
	echo "    Crawl through an entire website and download specific or all files"
	echo "DOMAIN"
	echo "    Specify a domain you want to crawl"
	echo "    -d <domain> - example.com | 192.168.1.10 | etc."
	echo "KEYWORD"
	echo "    Specify a keyword to download only specific files"
	echo "    Use 'all' to download all files"
	echo "    -k <keyword> - pdf | js | png | all | etc."
	echo "RECURSION"
	echo "    Specify a maximum recursion depth"
	echo "    Use '0' for infinite"
	echo "    -r <recursion> - 0 | 10 | etc."
	echo "INPUT"
	echo "    Specify an input file with already crawled URLs"
	echo "    -i <input> - metagoofeel_urls.txt | etc."
}

domain=""
keyword=""
recursion=""
input=""
proceed=true

function validate () {
	if [[ $1 == "-d" && -z $domain ]]; then
		domain=$2
	elif [[ $1 == "-k" && -z $keyword ]]; then
		keyword=$2
	elif [[ $1 == "-r" && -z $recursion ]]; then
		if [[ $2 =~ ^[0-9]+$ ]]; then
			recursion=$2
		else
			proceed=false
			echo "ERROR: Recursion depth must be numeric"
		fi
	elif [[ $1 == "-i" && -z $input ]]; then
		input=$2
		if [[ ! -e $input ]]; then
			proceed=false
			echo "ERROR: Input file does not exists"
		elif [[ ! -r $input ]]; then
			proceed=false
			echo "ERROR: Input file does not have read permission"
		elif [[ ! -s $input ]]; then
			proceed=false
			echo "ERROR: Input file is empty"
		fi
	fi
}

missing=false

function check () {
	if [[ $1 == 1 ]]; then
		if [[ $2 != "-k" && $2 != "-i" || -z $keyword || -z $input ]]; then
			missing=true
		fi
	elif [[ $1 == 2 ]]; then
		if [[ $2 != "-d" && $2 != "-k" && $2 != "-r" || -z $domain || -z $keyword || -z $recursion ]]; then
			missing=true
		fi
	fi
}

if [[ $# == 0 ]]; then
	proceed=false
	advanced
elif [[ $# == 1 ]]; then
	proceed=false
	if [[ $1 == "-h" ]]; then
		basic
	elif [[ $1 == "--help" ]]; then
		advanced
	else
		echo "ERROR: Incorrect usage"
		echo "Use -h for basic and --help for advanced info"
	fi
elif [[ $# == 4 ]]; then
	validate $1 $2
	validate $3 $4
	check 1 $1
	check 1 $3
	if [[ $missing == true ]]; then
		proceed=false
		echo "ERROR: Missing a mandatory option (-k, -i)"
		echo "Use -h for basic and --help for advanced info"
	fi
elif [[ $# == 6 ]]; then
	validate $1 $2
	validate $3 $4
	validate $5 $6
	check 2 $1
	check 2 $3
	check 2 $5
	if [[ $missing == true ]]; then
		proceed=false
		echo "ERROR: Missing a mandatory option (-d, -k, -r)"
		echo "Use -h for basic and --help for advanced info"
	fi
else
	proceed=false
	echo "ERROR: Incorrect usage"
	echo "Use -h for basic and --help for advanced info"
fi

function timestamp () {
	date=$(date "+%H:%M:%S %m-%d-%Y")
	echo "${1} -- ${date}"
}

function interrupt () {
	echo ""
	echo "[Interrupted]"
}

function crawl () {
	echo "All crawled URLs will be saved in '${3}'"
	echo "Press CTRL + C to stop early"
	timestamp "Crawling has started"
	wget $1 -e robots=off -nv --spider --random-wait -nd --no-cache -r -l $2 -o $3
	timestamp "Crawling has ended"
	grep -P -o "(?<=URL\:\ )[^\s]+?(?=\ 200\ OK)" $3 | sort -u -o $3
	count=$(grep -P "[^\s]+" $3 | wc -l)
	echo "Total URLs crawled: ${count}"
}

function download () {
	count=0
	directory="metagoofeel_${1}"
	echo "All downloaded files will be saved in '/${directory}/'"
	timestamp "Downloading has started"
	for url in $(cat $2); do
		if [[ $1 == "all" || $(echo $url | grep -P -i $1) ]]; then
			if [[ $(wget $url -e robots=off -nv -nc -nd --no-cache -P $directory 2>&1) ]]; then
				echo $url
				count=$((count + 1))
			fi
		fi
	done
	timestamp "Downloading has ended"
	echo "Total files downloaded: ${count}"
}

if [[ $proceed == true ]]; then
	echo "#######################################################################"
	echo "#                                                                     #"
	echo "#                             Metagoofeel                             #"
	echo "#                                    by Ivan Sincek                   #"
	echo "#                                                                     #"
	echo "# Crawl through an entire website and download specific or all files. #"
	echo "# GitHub repository at github.com/ivan-sincek/metagoofeel.            #"
	echo "# Feel free to donate bitcoin at 1BrZM6T7G9RN8vbabnfXu4M6Lpgztq6Y14.  #"
	echo "#                                                                     #"
	echo "#######################################################################"
	if [[ $# == 4 ]]; then
		download $keyword $input
	elif [[ $# == 6 ]]; then
		output="metagoofeel_urls.txt"
		overwrite="yes"
		if [[ -e $output ]]; then
			echo "Output file '${output}' already exists"
			read -p "Overwrite the output file (yes): " overwrite
			echo ""
		fi
		if [[ $overwrite == "yes" ]]; then
			trap interrupt INT
			crawl $domain $recursion $output
			echo ""
			download $keyword $output
		fi
	fi
	end=$(date "+%s.%N")
	runtime=$(echo "${end} - ${start}" | bc -l)
	echo ""
	echo "Script has finished in ${runtime}"
fi
