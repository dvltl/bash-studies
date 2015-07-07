#!/bin/bash

#	Script for running a bunch of tests via CPAchecker

#	Run options are :
#	-help - prints help
#	-runTests - runs tests in specific location with cpachecker
#	-clean - cleans the output directory if such is provided

runTests="-runTests [ options ] - runs tests"
options="OPTIONS:
	-spec=<specification_class>
	-entry_c=<entrypoint_c>
	-entry_o_i=<entrypoint_o_i>
	-exception=<expected_exception>
	-checker_loc=<cpachecker_location>
   	-tests_loc=<tests_location>
   	-output=<checker_output_location>"
help="-help - this help message"
cleanUp="-clean <output_location> - deletes the output location"

defaults="DEFAULT VALUES:
	default <specification_class>		= sv-comp
	default <entrypoint>			= main for '.c' files and ldv_main0_sequence_infinite_withcheck_stateful for '.o.i' files
	default <cpachecker_location>		= ../cpachecker
	default <tests_location>		= ./
	default <checker_output_location>	= /dev/null (no output)
	default <expected_exception>		= Exception"

function help {
	echo ""
	echo "Options (one at a time) :"
	echo ""

	for option in "$help", "$runTests", "$options", "$defaults", "$cleanUp"
	do
		echo "$option"
		echo ""
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

	exception_type_set=0
	cpachecker_prefix_set=0
	tests_prefix_set=0
	entrypoint_c_set=0
	entrypoint_o_i_set=0
	specification_class_set=0
	output_dir_set=0

	entry_c="main"
	entry_o_i="ldv_main0_sequence_infinite_withcheck_stateful"
	exception_type="Exception"
	cpachecker_prefix="../cpachecker"
	tests_prefix="./"
	output_dir="/dev/null"
	output_option=""
	specification_class="sv-comp"

	readonly sep="="

	for arg in $1 $2 $3 $4 $5 $6
	do
		tuple=( ${arg//$sep/ } )
		case ${tuple[0]} in
			"-spec")
				if [ "$specification_class_set" = "0"  ]
				then
					specification_class_set=1
					specification_class=${tuple[1]}
				fi
				;;
			"-entry_c")
				if [ "$entrypoint_c_set" = "0" ]
				then
					entrypoint_c_set=1
					entry_c=${tuple[1]}
				fi
				;;
			"-entry_o_i")
				if [ "$entrypoint_o_i_set" = "0" ]
				then
					entrypoint_o_i_set=1
					entry_o_i=${tuple[1]}
				fi
				;;
			"-checker_loc")
				if [ "$cpachecker_prefix_set" = "0" ]
				then
					cpachecker_prefix_set=1
					cpachecker_prefix=${tuple[1]}
				fi
				;;
			"-tests_loc")
				if [ "$tests_prefix_set" = "0" ]
				then
					tests_prefix_set=1
					tests_prefix=${tuple[1]}
				fi
				;;
			"-output")
				if [ "$output_dir_set" = "0" ]
				then
					output_dir_set=1
					output_dir=${tuple[1]}
				fi
				;;
			"-exception")
				if [ "$exception_type_set" = "0" ]
				then
					exception_type_set=1
					exception_type=${tuple[1]}
				fi
				;;
		esac
	done

	echo "specification_class = $specification_class"
	echo "entry_c = $entry_c"
	echo "entry_o_i = $entry_o_i"
	echo "expected_exception = $exception_type"
	echo "cpachecker_location = $cpachecker_prefix"
	echo "tests_location = $tests_prefix"
	echo "output_dir = $output_dir"
	echo ""


	i=0

	for file in $tests_prefix/*
	do

	verification_needed=false

	if [ ${file: (-2)} = ".c" ]
	then
		verification_needed=true
		entry=$entry_c
	fi

	if [ ${file: (-4)} = ".o.i" ]
	then
		verification_needed=true
		entry=$entry_o_i
	fi

	if [ "$verification_needed" = "true" ]
	then
		$cpachecker_prefix/scripts/cpa.sh -config $cpachecker_prefix/config/ldv.properties -setprop log.consoleLevel=ALL $tests_prefix/$file -entryfunction $entry -spec $cpachecker_prefix/config/specification/$specification_class.spc  -setprop cpa.predicate.solver=SMTInterpol $output_option >$tests_prefix/"log$i.log" 2>&1

		if ls $file | grep "_exception" >/dev/null
		then
			echo "$i test name: $file, test type: FAIL_TEST, expected exception: $exception_type"
			if cat $tests_prefix/"log$i.log" | grep "$exception_type" >/dev/null
			then
				echo "FAIL_TEST cleared!"
			else
				echo "FAIL_TEST failed (no exception or not $exception_type )"
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
				else
					echo "$i test name: $file, test type: UNKNOWN_TEST"
					echo "UNKNOWN_TEST cleared!"
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
		run "$2" "$3" "$4" "$5" "$6" "$7"
		;;
	"-clean")
		clean "$2"
		;;
	"-help" | *)
		help
		;;
esac

