#	Script for running a bunch of tests via CPAchecker
#	For now it works only with hardcoded names of tests
#	But maybe someday i will improve it

#	Run options are : 
#	-help - prints help
#	-runTests - runs tests in specific location with cpachecker 
#	-clean - cleans the output directory if such is provided

runTests="-runTests <cpachecker_location> <tests_location> <checker_output_location> <expected_exception_if_any> - runs tests"
help="-help - this help message"
cleanUp="-clean <output_location> - deletes the output location"

defaultCheckerLoc="	default <cpachecker_location> 		= ../cpachecker"
defaultTestsLoc="	default <tests_location> 		= ./"
defaultOutputDir="	default <checker_output_location> 	= /dev/null (no output)"

function help {
	echo ""
	echo "Options (one at a time) :"

	for option in "$help", "$runTests", "$defaultCheckerLoc", "$defaultTestsLoc", "$defaultOutputDir", "$cleanUp"
	do
		echo "$option"
	done	
	echo ""
}

function clean {
	if [ $1 ] 
	then
		echo "Deleting catalog $1"	
		rm -rf $1
		echo "Done!"
	else
		echo "<output_location> is not defined"
		help
		exit 0
	fi
}

function run {
	echo ""
	echo "Running tests"
	echo ""

	if [ $1 ]
	then
		cpachecker_prefix=$1
	else
		cpachecker_prefix="../cpachecker"
	fi

	echo "cpachecker_location = $cpachecker_prefix"

	if [ $2 ]
	then
		tests_prefix=$2
	else
		tests_prefix="./"
	fi

	echo "tests_location = $tests_prefix"

	if [ $3 ]
	then
		output_dir=$3
	else
		output_dir="/dev/null"
	fi

	if [ $4 ]
	then
		exceptionType=$4
	else
		exceptionType="Exception"
	fi


	echo "output_dir = $output_dir"
	echo ""

	i=0

	for file in $tests_prefix/* 
	do
	
	verificationNeeded=false

	if [ ${file: (-2)} = ".c" ]
	then
		verificationNeeded=true
	fi

	if [ ${file: (-4)} = ".o.i" ]
	then
		verificationNeeded=true
	fi

	if "$verificationNeeded" = "true"	
	then	
		$cpachecker_prefix/scripts/cpa.sh -config $cpachecker_prefix/config/ldv.properties -setprop log.consoleLevel=ALL $tests_prefix/$file -entryfunction main -spec $cpachecker_prefix/config/specification/sv-comp.spc  -setprop cpa.predicate.solver=SMTInterpol -setprop output.disable=false -outputpath $output_dir >$tests_prefix/"log$i.log" 2>&1

		if ls $file | grep "_exception" >/dev/null
		then
			echo "$i test name: $file, test type: FAIL_TEST, expected exception: $exceptionType"
			if cat $tests_prefix/"log$i.log" | grep "$exceptionType" >/dev/null
			then
				echo "FAIL_TEST cleared!"
			else
				echo "FAIL_TEST failed (no exception or not $exceptionType )"
			fi

		else 
			if ls $file | grep "_true" >/dev/null
			then
				echo "$i test name: $file, test type: TRUE_TEST, expected result: TRUE"
				if cat $tests_prefix/"log$i.log" | grep "TRUE" >/dev/null
				then
					echo "TRUE_TEST cleared!"
				else
					echo "TRUE_TEST failed..."
				fi
			else 
				if ls $file | grep "_false" >/dev/null
				then
					echo "$i test name: $file, test type: FALSE_TEST, expected result: FALSE"
					if cat $tests_prefix/"log$i.log" | grep "FALSE" >/dev/null
					then
						echo "FALSE_TEST cleared!"
					else
						echo "FALSE_TEST failed..."
					fi
				fi
			fi
		fi

		(( ++i ))
	fi

	done

	echo ""	
	echo "All done!"
	echo ""
}

case "$1" in
	"-runTests")
		run "$2" "$3" "$4"
		;;
	"-clean")
		clean "$2"
		;;
	"-help" | *)
		help
		;;
esac

