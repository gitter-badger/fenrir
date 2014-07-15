Loki
====
Lowki.rb
 > Story class
	-establishes links between fields and the algorithms used to clean them
	-has routing method for taking raw data from one dataset and inserting it somewhere else as clean data
	-loads and holds mysql connection and any structures that will be used so they do not need to be loaded multiple times during the task.
 > Targetfile class
	-loads a tsv or txt file into a structure similar to a mysql query return, that may be used in much the same ways.  This is how Loki handles non-database inputs.
 > Rules class [DEPRECATED]
 > loose methods are demonstration tools that may never be used, given how things are going.

data_sanitation.rb
 > sanitation modules and methods [REQUIRES CLEANUP][some redundancy] - many of these are adapted from NS versions.  We are in the process of weeding out the redundancy and merging like with like.  Anything done frequently is being isolated and called as a method to reduce code duplication.

storycreator.rb
 > Gen7logic class
	-this creates a logic object, essentially a nested hash, that can be manipulated to extract meaning from filthy inputs.
 > rungen7 method
	-this automates the process of returning results from a Gen7logic object.  It must be passed the Gen7logic object as an argument (rather, a reference to the object).
 > assorted testing tools that still require unification and standardization.
	-these will, once standardized, do what the current NS testing system does.  I'm hoping the speed increases (over the NS versin) will permit these to be integrated more aptly into the production process, so that any data we've ever seen before will be flagged if it begins to return different results.

<procedures>
 > contains trigger.rb
 > contains Loki.rb
INSTRUCTIONS FOR USE:

./Loki.rb [:county@configuration] [local] [-t] [everything else]

to use simplified :county@configuration syntax, a procedure must be stored in the c13.core.Loki_procedures table.

/// some of the below is deprecated.  I'll clean this up soonish.

the arguments being fed to the "Story" class below are the arguments that must be filled by command line argument.
any target_.* not filled manually will be automatically filled by the equivalent source_.* [however if source_host == target_host, source_db == target_db, source_table == target_table and the keys of sanitation_assignments are self referential, the run will abort, as this would cause Loki to cannibalize raw data] example of self-reference: grantor_big=>{grantor_big=>:algorithm}

<tale = Story.new(source_host, target_host, source_db, target_db, source_table, target_table, sanitation_assignments, export_arguments, login_credentials, cluster)>

example assignments(quotes are optional):

"source_host"="c3"
"source_db"="newtown_ct_tagging"
"source_table"="deeds"
"source_user"="data_miner"
"source_pass"="data_miner"

"target_host"="db04"
"target_db"="newtown_ct_imaginary"
"target_table"="deedz"
"target_user"="data_miner"
"target_pass"="data_miner"

"export_arguments"="where grantor_big like '%stuff%' and updated_at > 1234"

cluster=100 #this skips the first 99 items that match the export arguments

example assignment of sanitation_assignments:

"args{grantee_together=>{grantee_together=>:Name.cook_county_names_noflip}, grantor_together => {grantor_together => :normalize}, unique_key => doc_number}"

Here, syntax can bite you.  If you are going to include spaces for readability, the entire args{} portion must be contained in double-quotes, which will let the ruby interpreter know the entire thing is one argument.

:this_is_a_ruby_method

:Namespace.this_is_a_ruby_method

anything in your sanitation hash which looks like the above will be 'fetched' as an object in the trigger file, then passed to the story as an object.method or Namespace.method object.  If you do not put the ":" before your methods (algorithms) then you will pass strings instead, which will not have the desired result.

#unique_key tells Loki which field to use to associate lines between the source dataset and the target one.  The key you name here should be -shared-.  Do -not- use the unique integer IDs in HLE, as these are not shared between raw and SC datasets.  There is presently no method for running Loki without a unique identifier, and if the source and target tables are different, the unique identifier must be shared between 'raw' and 'clean'.

example complete run command:

ruby trigger.rb "args{grantee_together => {grantee_big => :Name.cook_county_names_noflip}, grantor_together => {grantor_big => :normalize}, unique_key => doc_number}" source_user=data_miner "source_pass"="data_miner" export_arguments="where grantor_big like 'hello kitty'" source_db=newtown_ct_tagging source_host=c3 source_table=deeds target_host=db04

result of run:

Loki will look in c3.newtown_ct_tagging.deeds for the grantee_big field and grantor_big fields.  It will run "select * where grantor_big like 'hello kitty'" and all qualifying lines of data will have their grantee_big fields passed to the Name.cook_county_names_noflip algorithm.  The grantor_big field will be passed to the normalize algorithm.  The results of these processes will be inserted in db04.newtown_ct_tagging.deeds in the grantee_together field and grantor_together field respectively, where the 'doc_number' fields match between the source and target table.

///algorithm notes (namespace{algorithm})

Name{
	cook_county_names: assumes it is receiving a list of ||-separated LAST FIRST MIDDLE names.
		example: DOWD ROBERT S||DOWD MARY C
		example: BATES BARSTOW,TR||BATES ALICE H,TR||BATES FAMILY TRUST
	cook_county_names_noflip: same as above but assumes FIRST MIDDLE LAST

	darien_county_names_noflip: assumes it is receiving a list of and-separated FIRST MIDDLE LAST names
		example: ANDREW A. BARNETT AND VICTORIA U. BARNETT
		example: JANET WADDINGTON CLARK TRUST AND JAMES HOWE WADDINGTON  JR. ETALS.

	newcanaan_county_names: use this if names are ||-separated and last names are mostly denoted by commas.
		example: BIEDERMANN, BARBARA M
		example: SHARMA, KRISHN M||SHARMA, SARA C

	broward_county_names: use this if names are &-separated and last names are mostly denoted by commas
		example: SCARDINO,VINCENT J & SCARDINO,KATHERINE 
		example: JOHNS,JUDITH H JOHNS,ROBERT B
		example: ALLY,BASHEER & INDRAWATTEE
		example: RIGGIO,DOLORES S SALVATORE & D RIGGIO REV LIV TR
	
	sherman_minimal: assumes what it is receiving is mostly AP style optimized.  Will attempt to normalize any input string that is completely all-caps, will attempt to dot middle names, converts & to 'and', trims + signs, handles parentheticals and other similarly low-logic functions.
		example: William T Whitenack +
		example: Patricia DaSilva & Daniel Lobo-Berg
		example: Robert & Elaine Erichson
			::if you see this, where family groupings are already being made, you can be pretty sure sherman_minimal is what you want to use.

	hampton_county_names: assumes LAST FIRST MIDDLE &-separated, tries to account for businesses and not over-aggressively convert &.  Accounts for name lists like LAST FIRST M & FIRST M & DIFFERENT_LAST FIRST M
		example: SQUIZZERO JOSEPH L & RHONDA A
		example: BRANCH BANKING & TRUST COMPANY
		example: SUMPTER JULIAN & MORRIS AARON
		example: SUMPTER JULIAN & AARON & JESSIE N & MORRIS AARON

	newportnews_county_names: assumes First Middle Last &-separated without family groupings.
		example: CCOP Thimble Shoals One LLC
		example: Christopher Perry & Jessica Perry
		example: Debra S Trueman & Deborah L Posey
		example: Newport News Redevelopment & Housing Authority

	seymour_county_names: don't use this.  This is designed to correct for the broad range of formats used in seymour_ct, and hopefully this won't happen anywhere else.  Also, tests will never be perfect here, resolve them to the lowest number of errors possible, but don't try to zero those out.
		example: CONNORS RICHARD C & PATRICIA H 
		example: LINSKEY,S.C. 
		example: KRUPA DAVID R (2/3) & JANET L (1/3)
		example: DRUGONIS BARBARA 80% &||WOZNIAK LYNNE 20%

	hamilton_grantee_names: try not to use this if you don't know what it does.  Some of the principles here may be generalizeable... but I haven't tested them sufficiently yet beyond knowing that they work for hamilton.

	baltimore_county_names: assumes the names are || separated and FML, and that parentheticals are demarcated by |
		example: CHRISTINE W EYLER| PER REP||LLOYD DAVID EYLER| DECEASED
