#begin global declarations these can be isolated by method and called from
#storycreator as needed if their loading time ever becomes a number greater
#than zero seconds rounded down. do not put values here that you anticipate
#changing during algorithm runs.

# encoding: utf-8

require_relative('./global_declarations.rb')


#floating methods:

#Abbreviate US in AP style

def abbreviate_US(line)
	line = line.gsub( /\bU(nited)?\.?\s*S(tates)?\b\.?/i, 'U.S.' )
end

def double_space_elimination(line)
	line.gsub!( /  /, ' ' )
	return line
end

#method to replace html entities
def html_entities(line)
	line = line.gsub( /&amp;?|&\#38;/, '&' ).gsub( /&nbsp;|&\#160;/, ' ' ).gsub( /&lt;|&\#60;/, '<' ).gsub( /&gt;|&#62;/, '>' ).gsub( /&\#34;|&quot;/, '"' ).gsub( /&\#?39;?|&apos;/, '\'' ).gsub(/&\#?39;/, "'")
end

#Method to turn arrays into regular expressions where each element of the array is a disjunt in the regexp. So, [1, 2, 3] becomes 1|2|3
def var_to_regex(array)
	regex_prep = ""
	array.each do |element|
		regex_prep += "#{element}|"
	end		
		regex_prep = regex_prep.gsub(/\|\Z/, '')		#removes final '|'
		$var_regex = Regexp.new(regex_prep)
end		

#Ordinal abbreviation
def ordinals(line)
	#style guide says don't spell out ordinals in military or political divisions.
	look_ahead_reg = /\s(Canadian\sDivision|Canadian\sInfantry\sDivision|Armored\sDivision|Cavalry\sDivision|Infantry\sDivision|Marine\sDivision|Canadian\sDivision|Canadian\sInfantry\sDivision|Air\sDivision|Armored\sDivision|Cavalry\sDivision|Infantry\sDivision|Marine\sDivision|Canadian\sInfantry\sDivision|Armored\sDivision|Infantry\sDivision|Marine\sDivision|Canadian\sDivision|Canadian\sArmoured\sDivision|Air\sDivision|Armored\sDivision|Infantry\sDivision|Marine\sDivision|Canadian\sArmoured\sDivision|Air\sDivision|Armored\sDivision|Infantry\sDivision|Marine\sDivision|Armored\sDivision|Infantry\sDivision|Marine\sDivision|Canadian\sInfantry\sDivision|Air\sDivision|Armored\sDivision|Infantry\sDivision|Canadian\sInfantry\sDivision|Armored\sDivision|Infantry\sDivision|Armored\sDivision|Infantry\sDivision|Congressional\sDistrict|precinct)/i
	line = line.gsub( /\b1st\b(?!#{look_ahead_reg})/i, 'first' ).gsub( /\b2n?d\b(?!#{look_ahead_reg})/i, 'second' ).gsub(/\b3r?d\b(?!#{look_ahead_reg})/i, 'third' ).gsub( /\b4th\b(?!#{look_ahead_reg})/i, 'fourth' ).gsub( /\b5th\b(?!#{look_ahead_reg})/i, 'fifth' ).gsub( /\b6th\b(?!#{look_ahead_reg})/i, 'sixth' ).gsub( /\b7th\b(?!#{look_ahead_reg})/i,'seventh' ).gsub( /\b8th\b(?!#{look_ahead_reg})/i, 'eighth' ).gsub( /\b9th\b(?!#{look_ahead_reg})/i, 'ninth' ).gsub( /\d{2,}(th\b|rd\b|st\b|nd\b)/i) {|ordinal| ordinal.downcase}
	return line
end

def normalize(value)
	value = value.gsub(/(?<!\()\b([A-Za-z]+)\b(?!\)|[^\(]+\))/i){|m|	m.capitalize }
	value = value.gsub(/(?<=\')\bs\b/i, 's')
	value = value.gsub(/\bmac([A-Za-z]+)/i){|m| "Mac"+m.sub(/^mac/i, '').capitalize}
	value = value.gsub(/\bmc([A-Za-z]+)/i){|m| "Mc"+m.sub(/^mc/i, '').capitalize}
	value = value.gsub(/\b(of|and|or|the|is|at|an|as|in|to|from|for)\b/i){|m| m.downcase} #UCLC exceptions
	value = value.gsub(/\ba\b(?!\.|\&|$)/i){|m| m.downcase}
	value = value.gsub(/\b(westbound|eastbound|northbound|southbound)\b/i){|m| m.downcase}
	$business_acronyms_subs.each do |k, v|
	  value = value.gsub(k, v)
	end
	return value
end

def downcase(value)
	value.gsub!(/\b([A-Za-z\'\-]+)\b/){|m| m.downcase}
	return value
end

def capitalize_first_letter(value)
	value = value.sub(/\A[a-z]/){|m| m.capitalize}
	return value
end


#begin methods
def nameswap(value)
	#humor - this is a lazy way to fix sql injection without escaping it.  This is why NS does this across all fields.  
	#Which, when I asked why NS does this across all fields, should probably have been the reply.
	#It wasn't.
	return '-BLANK-' if value == nil
	value.gsub!(/\//, ', ')
	
	#common formats
	value.sub!(/^\s*([A-Za-z\'\-]+)((?:, |\s{2,}|\t)[A-Za-z\'\-]+)\b\s*(\s\b[A-Za-z\'\-]+)?\s*$/, '\2\3 \1')
	value = normalize(value)
	value.sub!(/\b([A-Z])\b\.*/){|m|  $1.capitalize+'.'} unless value =~ $business_flags
	value.sub!(/^\s*,\s*/, '')
	return value
	#placeholder
end

def sub_array(test)
	p $array_test
	p test
	time1 = Time.now
	100000.times do
		$array_test.each {|thing| test.gsub!(/(#{thing})/, '\1')}
	end
	time1 = Time.now - time1
	p "array: #{time1}"
	time1 = Time.now
	regex = Regexp.new(('('+$string_test+')' ), Regexp::IGNORECASE)
	100000.times do    
		test.gsub!(regex, '\1')
	end
	time1 = Time.now - time1
	p "string: #{time1}"
end

def test
	time1 = Time.now
	100000.times{Dates.month_to_AP('01')}
	puts Time.now - time1
	time1 = Time.now
	100000.times{Dates.month_to_AP_regex('01')}
	puts Time.now - time1
end

def downcase_and_quotes(line)
	line = line.downcase.sub( /(.*)/, '"\1"' )
end



def sort_incidents(file)

File.open(file, 'r') do |input|
File.open("#{file}_output.txt", 'w') do |output|
	unique = Hash.new
	input.each do |line|
		components = line.chomp.split(/(?:\d*-\d*|,{2,}|\.{2,}|\:)/, 2)
		p components
		if (components[0] =~ /miscellaneous|multiple|permitted uses?|standard housing/) and components[1] != nil
			unless unique.has_key?(components[1])
				output.puts components[1]
				unique[components[1]] = 1
			end 	
		else
			unless unique.has_key?(components[0])
				output.puts components[0]
				unique[components[0]] = 1
			end
		end
	end
	
end
end

end

#end floating methods.
#-------------------------------------------------------------------

#-------------------------------------------------------------------
#Begin module for gen7-related test methods
module Gen7
	def self.police_incidents(string)
		incident_type = $police_logic.parse(string)
		incident_type = incident_type == nil ? "\"#{line['LokiRaw_incident_type']}\"" : incident_type
	end
end

module Tweaks
	def self.harrison_structures(string)
		output = case string
			when /^commercial$/i
				'a commercial structure'
			when /^comm-/i
				"#{string.sub(/^comm-/i, '').capitalize}"
			when /^commercial[^$]/i
				"#{string.sub(/^commercial\s*/i, '').capitalize}"
			when /^residential/i
				'a residential structure'
			else
				"#{string.sub(/(.*)/, 'a \1 structure').downcase.gsub(/^\s*/, '').gsub(/\s*$/, '').gsub(/\s{2,}/, ' ')}"
			end
		return output
	end
end

#Begin module for address-related methods.
module Address

	#Remove useless info before addresses
	def Address.delete_pre_address(address)
		address = address.gsub( /.*\,\s+(\d+\b\s+\w)/i, '\1' )
		return address
	end

	#Abbreviate compass points
	def Address.compass_pt_abbr(address)
		address = address.gsub( /\bN(orth)?\b\.*/i, 'N.' ).gsub( /\bE(ast)?\b\.*/i, 'E.' ).gsub( /\bW(est)?\b\.*/i, 'W.' ).gsub( /\bN(orth)?\.*\s*e(ast)?\b\.*/i, 'N.E.' ).gsub( /\bN(orth)?\.*\s*w(est)?\b\.*/i, 'N.W.' ).gsub( /\bS(outh)?\.*\s*e(ast)?\b\.*/i, 'S.E.' ).gsub( /\bS(outh)?\.*\s*w(est)?\b\.*/i, 'S.W.' ).gsub( /\b(?<!')S(outh)?\b\.*/i, 'S.' )
		return address
	end

	#Spell out and capitalize compass points
	def Address.compass_pt_full_cap(address)
		address = address.gsub( /\bN(orth)?\b\.*/i, 'North' ).gsub( /\bE(ast)?\b\.*/i, 'East' ).gsub( /\bW(est)?\b\.*/i, 'West' ).gsub( /\bN(orth)?\.*\s*e(ast)?\b\.*/i, 'Northeast' ).gsub( /\bN(orth)?\.*\s*w(est)?\b\.*/i, 'Northwest' ).gsub( /\bS(outh)?\.*\s*e(ast)?\b\.*/i, 'Southeast' ).gsub( /\bS(outh)?\.*\s*w(est)?\b\.*/i, 'Southwest' ).gsub( /\b(?<!')S(outh)?\b\.*/i, 'South' )
		return address
	end

	#Streets spelled out (except Ave., Blvd., and St.)
	def Address.street_types(line)
		$street_types.each do |key, value|
			line = line.gsub(key, value)
		end
		#line = line.gsub( /(\bALLEE\b|\bALY\b|\bALLE?Y\b)\.*/i, 'Alley' ).gsub( /(\bANX\b|\bANN?EX\b)\.*/i, 'Annex' ).gsub( /\bB(EA)?CH\b\.*/i, 'Beach' ).gsub( /\bBE?ND\b\.*/i, 'Bend' ).gsub( /\bBLU?F?F\b\.*/i, 'Bluff' ).gsub( /\bBLFS\b\.*/i, 'Bluffs' ).gsub( /(\bBOT(TO?M)?\b|\bBTM\b)\.*/i, 'Bottom' ).gsub( /\bBRA?NCH\b\.*/i, 'Branch' ).gsub( /\bBRD?GE?\b\.*/i, 'Bridge' ).gsub( /\bBRK\b\.*/i, 'Brook' ).gsub( /\bBR(OO)?KS\b\.*/i, 'Brooks' ).gsub( /\bBYPA?S?\b\.*/i, 'Bypass' ).gsub( /(\bCYN\b|\bCANYO?N\b|\bCNYN\b)\.*/i, 'Canyon' ).gsub( /\bCA?PE\b\.*/i, 'Cape' ).gsub( /\bC(AU)?SE?WA?Y\b\.*/i, 'Causeway' ).gsub( /(\bCE?N?TE?R\b|\bCEN\b)\.*/i, 'Center' ).gsub( /(\bCE?N?TE?RS\b|\bCEN\b)\.*/i, 'Centers' ).gsub( /(\bCIRC?\b|\bCI?RCLE?\b)\.*/i, 'Circle' ).gsub( /(\bCIRC?S\b|\bCI?RCLE?S\b)\.*/i, 'Circles' ).gsub( /\bCLI?F?F\b\.*/i, 'Cliff' ).gsub( /\bCLI?F?FS\b\.*/i, 'Cliffs' ).gsub( /\bCO?MM?O?N\b\.*/i, 'Common' ).gsub( /\bCOR(NER)?\b\.*/i, 'Corner' ).gsub( /\bCOR(NER)?S\b\.*/i, 'Corners' ).gsub( /\bC(OU)?RSE\b\.*/i, 'Course' ).gsub( /(\bC(OU)?RT\b|\bCT\b)\.*/i, 'Court' ).gsub( /(\bC(OU)?RTS\b|\bCTS\b)\.*/i, 'Courts' ).gsub( /\bCO?VE?\b\.*/i, 'Cove' ).gsub( /\bCO?VE?S\b\.*/i, 'Coves' ).gsub( /\bCR?(EE)?K?\b\.*/i, 'Creek' ).gsub( /(\bCRES(CE?NT)?\b|\bCRSC?E?NT\b)\.*/i, 'Crescent' ).gsub( /\bCREST?\b\.*/i, 'Crest' ).gsub( /(\bXING\b|\bCRST\b|\bCRO?SSI?NG\b)\.*/i, 'Crossing' ).gsub( /\bXR(OA)?D\b\.*/i, 'Crossroad' ).gsub( /\bCURVE?\b\.*/i, 'Curve' ).gsub( /\bDA?LE?\.*/i, 'Dale' ).gsub( /\bDA?M\b\.*/i, 'Dam' ).gsub( /\bDI?V(IDE)?D?\b\.*/i, 'Divide' ).gsub( /\bDR(IVE?)?\b\.*/i, 'Drive' ).gsub( /\bDR(IVE?)?S\b\.*/i, 'Drives' ).gsub( /\bEST(ATE)?\b\.*/i, 'Estate' ).gsub( /\bEST(ATE)?S\b\.*/i, 'Estates' ).gsub( /\bEXPR?(ESS)?W?A?Y?\b\.*/i, 'Expressway' ).gsub( /\bEXTE?N?S?(IO)?N?\b\.*/i, 'Extension' ).gsub( /\bEXTE?N?S?(IO)?N?S\b\.*/i, 'Extensions' ).gsub( /\bFA?L?LS\b\.*/i, 'Falls' ).gsub( /(\bF(ER)?RY\b|\bFRRY\b)\.*/i, 'Ferry' ).gsub( /\bF(IE)?LD\b\.*/i, 'Field' ).gsub( /\bF(IE)?LDS\b\.*/i, 'Fields' ).gsub( /\bFLA?T\b\.*/i, 'Flat' ).gsub( /\bFLA?TS\b\.*/i, 'Flats' ).gsub( /\bFO?RD\b\.*/i, 'Ford' ).gsub( /\bFO?RDS\b\.*/i, 'Fords' ).gsub( /\bFO?RE?ST\b\.*/i, 'Forest' ).gsub( /\bFO?RGE?\b\.*/i, 'Forge' ).gsub( /\bFO?RGE?S\b\.*/i, 'Forges' ).gsub( /\bFO?RK\b\.*/i, 'Fork' ).gsub( /\bFO?RKS\b\.*/i, 'Forks' ).gsub( /\bF(OR|R)?T\b\.*/i, 'Fort' ).gsub( /\bFR?E?E?WA?Y\b\.*/i, 'Freeway' ).gsub( /(\bG(AR)?DE?N\b|\bGRDE?N\b)\.*/i, 'Garden' ).gsub( /(\bG(AR)?DE?NS\b|\bGRDE?NS\b)\.*/i, 'Gardens' ).gsub( /(\bGA?TE?WA?Y\b)\.*/i, 'Gateway' ).gsub( /\bGLE?N\b\.*/i, 'Glen' ).gsub( /\bGLE?NS\b\.*/i, 'Glens' ).gsub( /\bGR(EE)?N\b\.*/i, 'Green' ).gsub( /\bGR(EE)?NS\b\.*/i, 'Greens' ).gsub( /\bGRO?VE?\b\.*/i, 'Grove' ).gsub( /\bGRO?VE?S\b\.*/i, 'Groves' ).gsub( /(\bHA?R?BO?R\b|\bHARB\b)\.*/i, 'Harbor' ).gsub( /(\bHA?R?BO?RS\b|\bHARBS\b)\.*/i, 'Harbors' ).gsub( /\bHA?VE?N?\b\.*/i, 'Haven' ).gsub( /\bH(EI)?G?H?TS?\b\.*/i, 'Heights' ).gsub( /\bHI?(GH)?WA?Y\b\.*/i, 'Highway' ).gsub( /\bHI?L?L\b\.*/i, 'Hill' ).gsub( /\bHI?L?LS\b\.*/i, 'Hills' ).gsub( /\bHO?L?LO?W\b\.*/i, 'Hollow' ).gsub( /\bHO?L?LO?WS\b\.*/i, 'Hollows' ).gsub( /\bINLE?T\b\.*/i, 'Inlet' ).gsub( /\bI\s*-?\s*(\d+)\s*/i, 'Interstate \1 ' ).gsub( /\bIS(LA?ND)?\b\.*/i, 'Island' ).gsub( /\bIS(LA?ND)?S\b\.*/i, 'Islands' ).gsub( /\bJU?N?CTI?O?N?\b\.*/i, 'Junction' ).gsub( /\bJU?N?CTI?O?N?S\b\.*/i, 'Junctions' ).gsub( /\bKE?YS\b\.*/i, 'Keys' ).gsub( /\bKNO?L?L\b\.*/i, 'Knoll' ).gsub( /\bKNO?L?LS\b\.*/i, 'Knolls' ).gsub( /\bLA?KE?\b\.*/i, 'Lake' ).gsub( /\bLA?KE?S\b\.*/i, 'Lakes' ).gsub( /\bLA?NDI?N?G\b\.*/i, 'Landing' ).gsub( /(\bLA?NE?\b|\bLA\b)\.*/i, 'Lane' ).gsub( /\bLA?NE?S\b\.*/i, 'Lanes' ).gsub( /\bLI?GH?T\b\.*/i, 'Light' ).gsub( /\bLI?GH?TS\b\.*/i, 'Lights' ).gsub( /\bL(OA)?F\b\.*/i, 'Loaf' ).gsub( /\bLO?CK\b\.*/i, 'Lock' ).gsub( /\bLO?CKS\b\.*/i, 'Locks' ).gsub( /\bLO?DGE?\b\.*/i, 'Lodge' ).gsub( /\bMA?NO?R\b\.*/i, 'Manor' ).gsub( /\bMA?NO?RS\b\.*/i, 'Manors' ).gsub( /\bM(EA?)?DO?W\b\.*/i, 'Meadow' ).gsub( /\bM(EA?)?DO?WS\b\.*/i, 'Meadows' ).gsub( /\bMI?L?L\b\.*/i, 'Mill' ).gsub( /\bM(IL)?LS\b\.*/i, 'Mills' ).gsub( /(\bMI?SS(IO)?N\b|\bMSN\b)\.*/i, 'Mission' ).gsub( /\bMO?TO?R?WA?Y\b\.*/i, 'Motorway' ).gsub( /\bMN?T\b\.*/i, 'Mount' ).gsub( /(\bMNTA?I?N\b|\bMTI?N\b)\.*/i, 'Mountain' ).gsub( /\bMNTA?I?NS\b\.*/i, 'Mountains' ).gsub( /\bNE?CK\b\.*/i, 'Neck' ).gsub( /\bORCH(A?RD)?\b\.*/i, 'Orchard' ).gsub( /\bOVA?L\b\.*/i, 'Oval' ).gsub( /\bO(VER)?PASS?\b\.*/i, 'Overpass' ).gsub( /\bPA?R?K\b\.*/i, 'Park' ).gsub( /\bPA?R?KS\b\.*/i, 'Parks' ).gsub( /\bPA?R?KW?A?Y\b\.*/i, 'Parkway' ).gsub( /\bPA?R?KW?A?YS\b\.*/i, 'Parkways' ).gsub( /\bPA?S?SA?GE\b\.*/i, 'Passage' ).gsub( /\bPI?NE\b\.*/i, 'Pine' ).gsub( /\bPI?NES\b\.*/i, 'Pines' ).gsub( /\bPL(ACE)?\b\.*/i, 'Place' ).gsub( /\bPL(AI)?N\b\.*/i, 'Plain' ).gsub( /\bPL(AI)?NS\b\.*/i, 'Plains' ).gsub( /\bPLA?ZA?\b\.*/i, 'Plaza' ).gsub( /\bP(OIN)?T\b\.*/i, 'Point' ).gsub( /\bP(OIN)?TS\b\.*/i, 'Points' ).gsub( /\bPO?RT\b\.*/i, 'Port' ).gsub( /\bPO?RTS\b\.*/i, 'Ports' ).gsub( /\bPRA?I?R?I?E?\b\.*/i, 'Prairie' ).gsub( /\bRAD(I(A|E))?L?\b\.*/i, 'Radial' ).gsub( /\bRA?NCH\b\.*/i, 'Ranch' ).gsub( /\bRA?NCHE?S\b\.*/i, 'Ranches' ).gsub( /\bRA?PI?DS\b\.*/i, 'Rapids' ).gsub( /\bRE?ST\b\.*/i, 'Rest' ).gsub( /\bRI?DGE?\b\.*/i, 'Ridge' ).gsub( /\bRI?DGE?S\b\.*/i, 'Ridges' ).gsub( /(\bRIVE?R?\b|\bRVR\b)\.*/i, 'River' ).gsub( /\bR(OA)?D\b\.*/i, 'Road' ).gsub( /\bR(OA)?DS\b\.*/i, 'Roads' ).gsub( /\bR(OU)?TE\b\.*/i, 'Route' ).gsub( /\bSH(OA)?L\b\.*/i, 'Shoal' ).gsub( /\bSH(OA)?LS\b\.*/i, 'Shoals' ).gsub( /\bSHO?RE?\b\.*/i, 'Shore' ).gsub( /\bSHO?RE?S\b\.*/i, 'Shores' ).gsub( /\bSKY?WA?Y\b\.*/i, 'Skyway' ).gsub( /\bSPR?I?N?G\b\.*/i, 'Spring' ).gsub( /\bSPR?I?N?GS\b\.*/i, 'Springs' ).gsub( /\bSQU?A?R?E?\b\.*/i, 'Square' ).gsub( /\bSQU?A?R?E?S\b\.*/i, 'Squares' ).gsub( /\bs(tate)?\.*r(oute)?\b\.*/i, 'State Route' ).gsub( /(\bSTAT?I?O?N?\b|\bSTN\b)\.*/i, 'Station' ).gsub( /\bSTRA?V?E?N?U?E?\b\.*/i, 'Stravenue' ).gsub( /\bSTR(EA)?M\b\.*/i, 'Stream' ).gsub( /(\bSTS\b|\bSUM?MITT?\b|\bSMT\b)\.*/i, 'Summit' ).gsub( /\bTERR?A?C?E?\b\.*/i, 'Terrace' ).gsub( /\bTH?R(OUGH)?WA?Y\b\.*/i, 'Throughway' ).gsub( /\bTRA?CE\b\.*/i, 'Trace' ).gsub( /\bTRA?C?K\b\.*/i, 'Track' ).gsub( /\bTRA?C?KS\b\.*/i, 'Tracks' ).gsub( /\bTRA?FF?I?C?W?A?Y\b\.*/i, 'Trafficway' ).gsub( /\bTR(AI)?L?\b\.*/i, 'Trail' ).gsub( /\bTR(AI)?LS\b\.*/i, 'Trails' ).gsub( /\bTUNN?E?L\b\.*/i, 'Tunnel' ).gsub( /\bTUNN?E?L?\b\.*/i, 'Tunnels' ).gsub( /\bTU?R?N?PI?KE?\b\.*/i, 'Turnpike' ).gsub( /\bUN?D?E?RPAS?S\b\.*/i, 'Underpass' ).gsub( /\bUN(ION)?\b\.*/i, 'Union' ).gsub( /\bUN(ION)?S\b\.*/i, 'Unions' ).gsub( /\bVA?L?LE?Y\b\.*/i, 'Valley' ).gsub( /\bVA?L?LE?YS\b\.*/i, 'Valleys' ).gsub( /\b(VI?A?DU?CT|VIA)\b\.*/i, 'Viaduct' ).gsub( /\bV(IE)?W\b\.*/i, 'View' ).gsub( /\bV(IE)?WS\b\.*/i, 'Views' ).gsub( /(\bVI?L?LA?GE?\b|\bVILL\b)\.*/i, 'Village' ).gsub( /\bVI?L?LA?GE?S\b\.*/i, 'Villages' ).gsub( /\bVI?ST?A?\b\.*/i, 'Vista' ).gsub( /\bWA?Y\b\.*/i, 'Way' ).gsub( /\bWELL?\b\.*/i, 'Well' ).gsub( /\bWE?L?LS\b\.*/i, 'Wells' )
		return line
	end
	
	def Address.lions_addresses(street)
		street = street.sub(/,.*/, '')
		return abbreviated_streets(street)
	end

	#method corresponding to abbreviated_streets algo
	def Address.abbreviated_streets(street)
		street = '' if street == nil
		street = street.sub(/^\s*NULL\s*$/, '')
		street = street.gsub(/(?<! )\(/, ' (')
		street = street.gsub(/([NESW])\.FM/, '\1. FM')
		street = street.gsub(/\bapt\b\.(\b[A-Za-z0-9]{1,2}\b)/i, 'Apt. \1')
		street = street.sub(/([\,][\.\,]*)\s*$/, '')
		street = street.gsub(/\//, ' and ')
		street = street.gsub(/\bwb\b/i, 'westbound')
		street = street.gsub(/\beb\b/i, 'eastbound')
		street = street.gsub(/\bnb\b/i, 'northbound')
		street = street.gsub(/\bsb\b/i, 'southbound')
		
		#Replaces html entities
		abb_street = html_entities(street)

		#P.O. Boxes handled
		#abb_street = abb_street.gsub( /((?:P\.?\s*O\.?)?\s+Box\s+[0-9A-Za-z]+)\,\s+(.+)/i, '\2, \1' ).gsub( /(?:P\.?\s*O\.?\s?)?\sbox\s+([0-9A-Za-z]+)/i, 'P.O. Box \1' )
		abb_street = abb_street.gsub(/\bP\.?\s*O\b\.? box\b/i, 'P.O. Box')
		abb_street = abb_street.gsub(/\bP\.?\s*O\b\.? drawer\b/i, 'P.O. Drawer')
		#U.S.
		abb_street = abbreviate_US(abb_street)

		#ordinals
		abb_street = ordinals(abb_street)

		#St. to Saint
		abb_street = Name.to_saint(abb_street)

		#Abbreviates Ave., St., and Blvd. according to AP guidelines.
		abb_street = Address.street_types(abb_street)
		abb_street = abb_street.gsub(/(\d+\b.+\b)(\bave?nue\b|\bavn?\b\.*|\bave\b\.*)/i, '\1Ave.').gsub(/(\d+\b.+\b)(\bBo?u?le?va?r?d\b\.*|\bBoulv?\b\.*)/i, '\1Blvd.').gsub(/(\d+\b.+\b)\bst(reet)?\b\.*/i, '\1St.')
		abb_street = abb_street.gsub(/\bst\b(?!\.)/i, 'Street')
		abb_street = abb_street.gsub(/\bave\b(?!\.)/i, 'Avenue')
		#Spells out all remaining street names according to AP guidelines.

		abb_street = normalize(abb_street)

		abb_street = abb_street.gsub(/\ba\b/, 'A')
		

		#Eliminates hashes in addresses.
		abb_street = abb_street.gsub( /(^\s*#*\s*)(?=\d+)/, '' ).gsub( /##/, 'No.' ).gsub( /(\bUnit\b|\bs(?:ui)?te\b|\bap(?:artmen)?t\b)\.?(?:\,)?\s*(?:#|No\.)?\s*(\b\d+\b)/i, '\1 \2' ).gsub( /#unit/, 'Unit' ).gsub( /#\s*(\d+\w{0,1})\s*(?:&|and)\s*(\d+\w{0,1})/i, 'Units \1 and \2' ).gsub( /#\s*(\d+)\b/, 'No. \1' ).gsub(/(?<=.|\s)(?:#|No\.)\s*(\b\d+\b)/i, 'No. \1' ).gsub( /(?:#|No\.)\s*(\d+\-?[a-zA-Z]|[a-zA-Z]\-?\d+)/i, 'Unit \1' ).gsub( /(?:#|No\.)\s*([A-Za-z])\s*(\d+\-?[a-zA-Z]?)/i, 'Unit \1\2' )

		$street_types.each do |key, value|
			abb_street = abb_street.gsub(/(#{value}) #\s*([A-Za-z]+)/, '\1, No. \2')
		end
		abb_street = abb_street.gsub(/ #\s*([A-Za-z])\b/, ', No. \1')
		#Add comma before 'Unit', 'No.', or 'Lot'
		abb_street = abb_street.gsub( /,?\s*\b(Unit\b|No\b\.|Lot\b)/i, ', \1' )
		abb_street = abb_street.gsub(/(\bUnit\b|\bs(?:ui)?te\b|\bap(?:artmen)?t\b)\.?, No. ([A-Za-z])\b/i, '\1 \2')

		#Eliminates unnecessary information from before an address.
		abb_street = Address.delete_pre_address(abb_street)

		#Suites and apartments
		#abb_street = abb_street.gsub( /(?<=\,)\s*\bs(ui)?te\.*/i, ' Suite' ).gsub( /(?<!\,)\s\bs(ui)?te\.*/i, ', Suite' ).gsub( /(?<!\,)\bs(ui)?te\.*/i, ', Suite' ).gsub( /(?<=\,)\s*\bap(artmen)?t\.*/i, ' Apt.' ).gsub( /(?<!\,)\s\bap(artmen)?t\.*/i, ', Apt.' ).gsub( /(?<!\,)\bap(artmen)?t\.*/i, ', Apt.' ).gsub( /\bSuite\s*([A-Za-z0-9\-]{1,5})\s(?:&|and)\s([A-Za-z0-9\-]{1,5})/i, 'Suites \1 and \2' )
		abb_street = abb_street.gsub(/,?\s*\bs(ui)?te\b\.?/i, ', Suite').gsub(/,?\s*\bap(artmen)?t\b\.?/i, ', Apt.').gsub( /\bSuite\s*([A-Za-z0-9\-]{1,5})\s(?:&|and)\s([A-Za-z0-9\-]{1,5})/i, 'Suites \1 and \2' )

		#Abbreviating compass points
		abb_street = Address.compass_pt_abbr(abb_street)
		
		#remove periods from suites, units, etc where they've been mistaken for cardinal directions
		abb_street = abb_street.gsub(/(\bUnit\b|\bs(?:ui)?te\b|\bap(?:artmen)?t\b)\.? ([NESWnesw])\./i, '\1 \2')

		#Exits
		abb_street = abb_street.gsub( /\(?Exit\s(\d+)\)?/i, 'at exit \1' )
		#Finishing touches (Or: things that need to be done near the end of the street abbreviation process)
		abb_street = abb_street.gsub( /P\.o\./, 'P.O.' )				#capitalizes 'o' in 'P.o.'
		if abb_street =~ /\b\d+\-?[a-z]\b/							#capitalizes, e.g., 'c' in '7c'
			unit = abb_street[ /\b\d+\-?[a-z]\b/ ].upcase
			abb_street = abb_street.gsub( /\b\d+\-?[a-z]\b/, unit )
		end
		abb_street = abb_street.gsub( /\bUs\b/, 'US' )					#Us to US
		abb_street = abb_street.gsub( /\bS\.e\./, 'S.E.' ).gsub( /\bS\.w\./, 'S.W.' ).gsub( /\bN\.e\./, 'N.E.' ).gsub( /\bN\.w\./, 'N.W.' )

		#'Saint' to 'St.'
		abb_street = Name.from_saint(abb_street)

		$states_to_AP.each do |key, value|
			abb_street = abb_street.gsub(/,?\s*(#{key})\s*$/, ', \1')
		end
		
		abb_street = states_to_AP(abb_street)
		

		return abb_street

	end
	
	def Address.block_address(line)
		line = abbreviated_streets(line)
		line = line.sub(/^(\d+)(\d{2})\.?\d*\b/, 'in the \100 block of')
		line = line.sub(/^(\d{1,2})\.?\d*\b/, 'in the 0 block of')
		if !line[/^in/] and !line[/^\s*$/]
			line = "at #{line}"
		end
		line = line.sub(/^\s*|\s*$/, '')
		return line
	end
	
	def Address.erlanger_pd_adjustments(line)
		line = line.sub(/ (erlanger(?! rd| road)|crescent springs(?! ro?a?d)|elsmere|kenton county).*/i, '')
		return block_address(line)
	end

	def Address.crime_address(line)

		#Replaces html entities
		crime_address = html_entities(line)
		
		#Normalize before adding "in the...block of"
		crime_address = normalize(crime_address)

		#Odd stuff
		crime_address = crime_address.gsub( /CFRC/i, 'Central Florida Racing Complex' ).gsub( /\bHOMELESS\s+LKA\b/i, 'last known as homeless' ).gsub( /\bHOMELESS\b/i, 'homeless' )

		#P.O. Boxes handled
		crime_address = crime_address.gsub( /((?:P\.?O\.?)?\s+Box\s+[0-9A-Za-z]+)\,\s+(.+)/i, '\2, \1' ).gsub( /(?:P\.?O\.?\s?)?\sbox\s+([0-9A-Za-z]+)/i, 'P.O. Box \1' )

		#U.S.
		crime_address = abbreviate_US(crime_address)

		#ordinals
		crime_address = ordinals(crime_address)

		#St. to Saint
		crime_address = Name.to_saint(crime_address)
		
		#Spell out and capitalize compass points
		crime_address = Address.compass_pt_full_cap(crime_address)
		
		#Spell out and capitalize street names
		crime_address = Address.street_types(crime_address)
		crime_address = crime_address.gsub(/(\bave?nue\b|\baven?\b|\bave\b)\.*/i, 'Avenue').gsub(/(\bBo?u?le?va?r?d\b\.*|\bBoulv?\b\.*)/i, 'Boulevard').gsub(/\bst(reet)?\b\.*/i, 'Street')

		#Delete across from
		crime_address = crime_address.gsub( /^\s*across\sfrom\s+/i, '' )
		
		#Delete block range
		crime_address = crime_address.gsub( /\^s*(\d+)\-\d+\s/i, '\1 ' )
		
		#Delete city, state and apartment number
		if crime_address != /fm\s\d+\s*\Z|P\.O\./im and crime_address != /\b(SR|State Route|I-?)\s*\d+\s*\Z/im
			crime_address = crime_address.gsub(/(?:[A-Z]{1,})?\.?\d+,?\s*\Z/, '' )
		end
		crime_address = crime_address.gsub( /\bAPT(\b|\.).*/i, ' ).gsub( /,?\s*Apt-\d+\s*/im, '' ).gsub( /,\s*[A-Z]{2}\s*$/im, ' ).gsub( /\bapartment.*/i, ' ).gsub( /,[^,]*\Z/i, ' )
		
		#Main stuff here
		if crime_address =~ /\A\d+\b/
			crime_address = crime_address.gsub( /\A(\d+)\d{2}\b\s+(.*)\Z/i, 'in the \100 block of \2' ).gsub( /\A\b\d{1,2}\b/i, 'on' )
		end
		
		#Remove 'Lot', 'Unit', 'Suite' at end of crime address
		crime_address = crime_address.gsub( /(?<=#{$street_suffixes})(Lot|Unit|S(ui)?te).*/i, '' )

		#'Saint' to 'St.'
		crime_address = Name.from_saint(crime_address)

		#Finishing touches
		crime_address = crime_address.gsub( /\Aon\s(?=(last\sknown|homeless))/i, '' )
		
		return crime_address
		
	end

	def Address.states_to_AP(state)
		#State name, abbreviation or mispelling to AP
		#state = state.gsub(/\b(?:U\.?S\.?-)?(?:Ala?(bama)?|All?abamm?a)\b\.?/i, 'Ala.').gsub(/\b(?:U\.?S\.?-)?(?:A(?:las|(?:lask|k))a?|Alsaka)\b\.?/i, 'Alaska').gsub(/\b(?:U\.?S\.?-)?(?:A(?:riz|z)(?:ona)?|Ar(?:zinoa|izonia))\b\.?/i, 'Ariz.').gsub(/\b(?:U\.?S\.?-)?Ark?(?:ansas)?\b\.?/i, 'Ark.').gsub(/\b(?:U\.?S\.?-)?(?:(?:Ca|CF|cal|cali|calif)(?:ornia)?|Califronia)\b\.?/i, 'Calif.' ).gsub(/\b(?:U\.?S\.?-)?(?:(?:Co|Colo?|CL)(lorado)?|C(?:alo|ola|ala)rado)\b\.?/i, 'Colo.' ).gsub(/\b(?:U\.?S\.?-)?(?:(?:Conn|Ct)(?:ecticut)?|connec?tt?icut?t)\b\.?/i, 'Conn.' ).gsub(/\b(?:U\.?S\.?-)?(?:(?:Del?|DL)(?:aware)?|delawere)\b\.?/i, 'Del.' ).gsub(/\b(?:U\.?S\.?-)?(?:Wash(ington)\b\.?)?\s*\bD\.?(?:istrict\s+of\s+)?C\.?(?:olumbia)?\b\.?/i, 'D.C.' ).gsub(/\b(?:U\.?S\.?-)?(?:Fl(?:or(?!a\b))?(?:id?)?a?|Flori?y?di?as?)\b\.?/i, 'Fla.').gsub(/\b(?:U\.?S\.?-)?(?:G(?:eorgi)?a|Georgei?a)\b\.?/i, 'Ga.' ).gsub(/\b(?:U\.?S\.?-)?(?:(?:Hi|HA|Hawaii)|Ha?o?wa?a?ii?)\b\.?/i, 'Hawaii' ).gsub(/\b(?:U\.?S\.?-)?(?:Ida?(?:ho)?|ida?e?hoe?)\b\.?/i, 'Idaho' ).gsub(/\b(?:U\.?S\.?-)?(?:Ill?(?:inoi)?\'?s?|illi?a?noise)\b\.?/i, 'Ill.' ).gsub(/\b(?:U\.?S\.?-)?Ind?(?:iana)?\b\.?/i, 'Ind.' ).gsub(/\b(?:U\.?S\.?-)?(?:I(?:ow?)?a|Iowha|ioaw|iwoa)\b\.?/i, 'Iowa' ).gsub(/\b(?:U\.?S\.?-)?(?:ka|ks|kans?)(as?)?\b\.?/i, 'Kan.' ).gsub(/\b(?:U\.?S\.?-)?(?:K(?:ent?|y)(?:ucky)?|kentuc?k?y)\b\.?/i, 'Ky.' ).gsub(/\b(?:U\.?S\.?-)?(?:L(?:ouisian)?a|louiseiana)\b\.?/i, 'La.' ).gsub(/\b(?:U\.?S\.?-)?(?:M(?:ain)?e|Mi?ai?ne?)\b\.?/i, 'Maine' ).gsub(/\b(?:U\.?S\.?-)?(?:M(?:arylan)?d|Marr?y\s*land)\b\.?/i, 'Md.' ).gsub(/\b(?:U\.?S\.?-)?(?:(?:Ma|Mass)(achusetts)?|mass?achuss?ett?s)\b\.?/i, 'Mass.' ).gsub(/\b(?:U\.?S\.?-)?(?:(?:Mi(?:ch)?|Mc)(?:igan)?|michi?a?ga?i?n)\b\.?/i, 'Mich.' ).gsub(/\b(?:U\.?S\.?-)?(?:(?:Mn|Minn)(?:esota)?|Minesota)\b\.?/i, 'Minn.' ).gsub(/\b(?:U\.?S\.?-)?(?:(?:MS|Miss)(?:issippi)?|mississipi)\b\.?/i, 'Miss.' ).gsub(/\b(?:U\.?S\.?-)?(?:M(?:iss)?o(?:uri)?|Miss?ouri?y?)\b\.?/i, 'Mo.' ).gsub(/\b(?:U\.?S\.?-)?M(?:on)?t(?:ana)?\b\.?/i, 'Mont.' ).gsub(/\b(?:U\.?S\.?-)?(?:(?:Ne(b|br)?|Nb)(?:aska)?|nebrasck?a)\b\.?/i, 'Nebr.' ).gsub(/\b(?:U\.?S\.?-)?(?:(?:Ne?v)(?:ada)?|new?vadaa?)\b\.?/i, 'Nev.' ).gsub(/\b(?:U\.?S\.?-)?N(?:ew\s+)?\.?\s*H(?:ampshire)?\b\.?/i, 'N.H.' ).gsub(/\b(?:U\.?S\.?-)?N(?:ew\s+)?\.?\s*J(?:ersey)?\b\.?/i, 'N.J.' ).gsub(/\b(?:U\.?S\.?-)?N(?:ew\s+)?\.?\s*M(?:ex|exico)?\b\.?/i, 'N.M.' ).gsub(/\b(?:U\.?S\.?-)?N(?:ew\s+)?Y(?:ork)?\b\.?/i, 'N.Y.' ).gsub(/\b(?:U\.?S\.?-)?N(?:orth\s+)?\.?\s*C(?:ar|arole?ina)?\b\.?/i, 'N.C.' ).gsub(/\b(?:U\.?S\.?-)?N(?:o|orth\s+)?\.?\s*D(?:ak|akota)?\b\.?/i, 'N.D.' ).gsub(/\b(?:U\.?S\.?-)?(?:O(?:hio)|oiho)\b\.?/i, 'Ohio' ).gsub(/\b(?:U\.?S\.?-)?(?:Ok(?:la)?(?:homa)?|okalahoma)\b\.?/i, 'Okla.' ).gsub(/\b(?:U\.?S\.?-)?(?:Or(?:e|eg)?(?:on)?|orgon)\b\.?/i, 'Ore.' ).gsub(/\b(?:U\.?S\.?-)?(?:(?:PA|Penna?)(?:sylvania)?|pensylvania)\b\.?/i, 'Pa.' ).gsub(/\b(?:U\.?S\.?-)?(?:R(?:hode\s+)\.?\s*I(?:sland)?|rh?oa?de?\sisland)\b\.?/i, 'R.I.' ).gsub(/\b(?:U\.?S\.?-)?S(?:outh\s+)?\.?\s*C(?:ar)?(?:olin?a?)?\b\.?/i, 'S.C.' ).gsub(/\b(?:U\.?S\.?-)?S(?:o\s*|outh\s+)?\.?\s*D(?:ak|akota)?\b\.?/i, 'S.D.' ).gsub(/\b(?:U\.?S\.?-)?(?:Tn|Tenn)(?:i?e?ss?ee?)?\b\.?/i, 'Tenn.' ).gsub(/\b(?:U\.?S\.?-)?(?:Te?x)(a?e?i?s)?\b\.?/i, 'Texas' ).gsub(/\b(?:U\.?S\.?-)?Ut(?:ah|es|ar)?\b\.?/i, 'Utah' ).gsub(/\b(?:U\.?S\.?-)?V(?:ermon)?t\b\.?/i, 'Vt.' ).gsub(/\b(?:U\.?S\.?-)?(?:Wash|Wa|Wn)(?:ington)?\b\.?/i, 'Wash.' ).gsub(/\b(?:U\.?S\.?-)?W(?:est\s+)?\.?\s*V(?:irg|a)?(?:i?ni?a)?\b\.?/i, 'W.Va.' ).gsub(/\b(?:U\.?S\.?-)?V(?:irg|a)(?:i?ni?a)?\b\.?/i, 'Va.' ).gsub(/\b(?:U\.?S\.?-)?(?:(?:Wis?c?(?:onsin)?)|wisconson)\b\.?/i, 'Wis.' ).gsub(/\b(?:U\.?S\.?-)?(?:Wyo?(?:ming)?|wh?y?i?oming)\b\.?/i, 'Wyo.' )
		$states_to_AP.each do |key, value|
			unless state == nil
				state = state.gsub(key, value)
			end
		end
		
		#exceptions
		unless state == nil
			state = state.gsub(/del\.(\s*[^\s\d$])/i, 'Del\1')
		end
		
		return state
	end
	
	def Address.states_to_postal(state)
		#State name, abbreviation or mispelling to AP
		#state = state.gsub(/\b(?:U\.?S\.?-)?(?:Ala?(bama)?|All?abamm?a)\b\.?/i, 'Ala.').gsub(/\b(?:U\.?S\.?-)?(?:A(?:las|(?:lask|k))a?|Alsaka)\b\.?/i, 'Alaska').gsub(/\b(?:U\.?S\.?-)?(?:A(?:riz|z)(?:ona)?|Ar(?:zinoa|izonia))\b\.?/i, 'Ariz.').gsub(/\b(?:U\.?S\.?-)?Ark?(?:ansas)?\b\.?/i, 'Ark.').gsub(/\b(?:U\.?S\.?-)?(?:(?:Ca|CF|cal|cali|calif)(?:ornia)?|Califronia)\b\.?/i, 'Calif.' ).gsub(/\b(?:U\.?S\.?-)?(?:(?:Co|Colo?|CL)(lorado)?|C(?:alo|ola|ala)rado)\b\.?/i, 'Colo.' ).gsub(/\b(?:U\.?S\.?-)?(?:(?:Conn|Ct)(?:ecticut)?|connec?tt?icut?t)\b\.?/i, 'Conn.' ).gsub(/\b(?:U\.?S\.?-)?(?:(?:Del?|DL)(?:aware)?|delawere)\b\.?/i, 'Del.' ).gsub(/\b(?:U\.?S\.?-)?(?:Wash(ington)\b\.?)?\s*\bD\.?(?:istrict\s+of\s+)?C\.?(?:olumbia)?\b\.?/i, 'D.C.' ).gsub(/\b(?:U\.?S\.?-)?(?:Fl(?:or(?!a\b))?(?:id?)?a?|Flori?y?di?as?)\b\.?/i, 'Fla.').gsub(/\b(?:U\.?S\.?-)?(?:G(?:eorgi)?a|Georgei?a)\b\.?/i, 'Ga.' ).gsub(/\b(?:U\.?S\.?-)?(?:(?:Hi|HA|Hawaii)|Ha?o?wa?a?ii?)\b\.?/i, 'Hawaii' ).gsub(/\b(?:U\.?S\.?-)?(?:Ida?(?:ho)?|ida?e?hoe?)\b\.?/i, 'Idaho' ).gsub(/\b(?:U\.?S\.?-)?(?:Ill?(?:inoi)?\'?s?|illi?a?noise)\b\.?/i, 'Ill.' ).gsub(/\b(?:U\.?S\.?-)?Ind?(?:iana)?\b\.?/i, 'Ind.' ).gsub(/\b(?:U\.?S\.?-)?(?:I(?:ow?)?a|Iowha|ioaw|iwoa)\b\.?/i, 'Iowa' ).gsub(/\b(?:U\.?S\.?-)?(?:ka|ks|kans?)(as?)?\b\.?/i, 'Kan.' ).gsub(/\b(?:U\.?S\.?-)?(?:K(?:ent?|y)(?:ucky)?|kentuc?k?y)\b\.?/i, 'Ky.' ).gsub(/\b(?:U\.?S\.?-)?(?:L(?:ouisian)?a|louiseiana)\b\.?/i, 'La.' ).gsub(/\b(?:U\.?S\.?-)?(?:M(?:ain)?e|Mi?ai?ne?)\b\.?/i, 'Maine' ).gsub(/\b(?:U\.?S\.?-)?(?:M(?:arylan)?d|Marr?y\s*land)\b\.?/i, 'Md.' ).gsub(/\b(?:U\.?S\.?-)?(?:(?:Ma|Mass)(achusetts)?|mass?achuss?ett?s)\b\.?/i, 'Mass.' ).gsub(/\b(?:U\.?S\.?-)?(?:(?:Mi(?:ch)?|Mc)(?:igan)?|michi?a?ga?i?n)\b\.?/i, 'Mich.' ).gsub(/\b(?:U\.?S\.?-)?(?:(?:Mn|Minn)(?:esota)?|Minesota)\b\.?/i, 'Minn.' ).gsub(/\b(?:U\.?S\.?-)?(?:(?:MS|Miss)(?:issippi)?|mississipi)\b\.?/i, 'Miss.' ).gsub(/\b(?:U\.?S\.?-)?(?:M(?:iss)?o(?:uri)?|Miss?ouri?y?)\b\.?/i, 'Mo.' ).gsub(/\b(?:U\.?S\.?-)?M(?:on)?t(?:ana)?\b\.?/i, 'Mont.' ).gsub(/\b(?:U\.?S\.?-)?(?:(?:Ne(b|br)?|Nb)(?:aska)?|nebrasck?a)\b\.?/i, 'Nebr.' ).gsub(/\b(?:U\.?S\.?-)?(?:(?:Ne?v)(?:ada)?|new?vadaa?)\b\.?/i, 'Nev.' ).gsub(/\b(?:U\.?S\.?-)?N(?:ew\s+)?\.?\s*H(?:ampshire)?\b\.?/i, 'N.H.' ).gsub(/\b(?:U\.?S\.?-)?N(?:ew\s+)?\.?\s*J(?:ersey)?\b\.?/i, 'N.J.' ).gsub(/\b(?:U\.?S\.?-)?N(?:ew\s+)?\.?\s*M(?:ex|exico)?\b\.?/i, 'N.M.' ).gsub(/\b(?:U\.?S\.?-)?N(?:ew\s+)?Y(?:ork)?\b\.?/i, 'N.Y.' ).gsub(/\b(?:U\.?S\.?-)?N(?:orth\s+)?\.?\s*C(?:ar|arole?ina)?\b\.?/i, 'N.C.' ).gsub(/\b(?:U\.?S\.?-)?N(?:o|orth\s+)?\.?\s*D(?:ak|akota)?\b\.?/i, 'N.D.' ).gsub(/\b(?:U\.?S\.?-)?(?:O(?:hio)|oiho)\b\.?/i, 'Ohio' ).gsub(/\b(?:U\.?S\.?-)?(?:Ok(?:la)?(?:homa)?|okalahoma)\b\.?/i, 'Okla.' ).gsub(/\b(?:U\.?S\.?-)?(?:Or(?:e|eg)?(?:on)?|orgon)\b\.?/i, 'Ore.' ).gsub(/\b(?:U\.?S\.?-)?(?:(?:PA|Penna?)(?:sylvania)?|pensylvania)\b\.?/i, 'Pa.' ).gsub(/\b(?:U\.?S\.?-)?(?:R(?:hode\s+)\.?\s*I(?:sland)?|rh?oa?de?\sisland)\b\.?/i, 'R.I.' ).gsub(/\b(?:U\.?S\.?-)?S(?:outh\s+)?\.?\s*C(?:ar)?(?:olin?a?)?\b\.?/i, 'S.C.' ).gsub(/\b(?:U\.?S\.?-)?S(?:o\s*|outh\s+)?\.?\s*D(?:ak|akota)?\b\.?/i, 'S.D.' ).gsub(/\b(?:U\.?S\.?-)?(?:Tn|Tenn)(?:i?e?ss?ee?)?\b\.?/i, 'Tenn.' ).gsub(/\b(?:U\.?S\.?-)?(?:Te?x)(a?e?i?s)?\b\.?/i, 'Texas' ).gsub(/\b(?:U\.?S\.?-)?Ut(?:ah|es|ar)?\b\.?/i, 'Utah' ).gsub(/\b(?:U\.?S\.?-)?V(?:ermon)?t\b\.?/i, 'Vt.' ).gsub(/\b(?:U\.?S\.?-)?(?:Wash|Wa|Wn)(?:ington)?\b\.?/i, 'Wash.' ).gsub(/\b(?:U\.?S\.?-)?W(?:est\s+)?\.?\s*V(?:irg|a)?(?:i?ni?a)?\b\.?/i, 'W.Va.' ).gsub(/\b(?:U\.?S\.?-)?V(?:irg|a)(?:i?ni?a)?\b\.?/i, 'Va.' ).gsub(/\b(?:U\.?S\.?-)?(?:(?:Wis?c?(?:onsin)?)|wisconson)\b\.?/i, 'Wis.' ).gsub(/\b(?:U\.?S\.?-)?(?:Wyo?(?:ming)?|wh?y?i?oming)\b\.?/i, 'Wyo.' )
		$states_to_postal.each do |key, value|
			unless state == nil
				state = state.gsub(key, value)
			end
		end
		
		return state
	end

end
#End Address module.
#-------------------------------------------------------------------


#-------------------------------------------------------------------
#Begin module for name-related methods.
module Name

	def Name.hyperlocal_basketball_premieryouthleague_teams(string)
		string = '' if string == nil
		string = string.sub(/\b[A-Za-z\-\']+\s*\b([\d]+[\w]+)(?=\s+(Boys|Girls)($|\s*\(\d+\)\s*$))/i, '\1')
		grade = string.sub(/.*\b(\d+(?:st|nd|rd|th))\b(?=\s+(?:Boys|Girls)($|\s*\(\d+\)\s*$)).*/i, '\1')
		$num_to_words_tagged.each do |k, v|
			grade = grade.sub(k, v)
		end
		string = string.sub(/(.*)\b([\d]+[\w]+)(?=\s+(Boys|Girls)($|\s*\(\d+\)\s*$))/i, "\\1 #{grade}-grade")
		string = string.sub(/\b(Girls|Boys)\b\s*($|\s*\(\d+\)\s*$)/){|m| m.downcase}
		string = string.gsub(/\s{2,}/, ' ')
		return string
	end
	
	def Name.retest_campaign_name_corrections(string)
		first_name = ''
		last_name = ''
		string = '' if string == nil
		if string[$business_flags]
			last_name = business_only_standardization(string)
		elsif string[/^([^,]+),([^,]+)(?: and |\&)([^,]+),?\s*$/]
			string=string.sub(/^([^,]+),([^,]+)(?: and |\&)([^,]+),?\s*$/, '\2 \1||and \3')
		elsif string[/^([^,]+),([^,]+),([^,]+),?\s*$/]
			last_name=string.sub(/^([^,]+),([^,]+),([^,]+),?\s*$/, '\3 \2 \1')
		elsif string[/^([^,]+),([^,]+),?\s*$/]
			string=string.sub(/^([^,]+),([^,]+),?\s*$/, '\2||\1')
		else
			last_name = sherman_minimal(string)
		end
		
		if string[/\|\|/]
			(first_name, last_name) = string.split(/\|\|/)
		else
			first_name = ''
		end
		first_name = first_name.gsub(/\s{2,}/, ' ')
		last_name = last_name.gsub(/\s{2,}/, ' ')
		first_name = first_name.sub(/(^\s*|\s*$)/, '')
		last_name = last_name.gsub(/(^\s*|\s*$)/, '')
		return first_name, last_name
	end
	
	def Name.lastfirst_firstlast(string)
		#in the event of a 'LAST FIRST' format being reliable, this will correct for it.
		string.sub!(/^\s*de\s+la\s+([A-Za-z\-\']+)\b/i, 'xxdelaxx\1')
		string.sub!(/^\s*de\s+([A-Za-z\-\']+)\b/i, 'xxdexx\1')
		if !string[$first_first_names] or string[$first_last_names]
			string = string.sub(/^([A-Za-z\-\']+)\s*(.*)/i, '\2 \1').gsub(/\s{2,}/, ' ')
		end
		return string
	end
	
	def Name.disabled_veterans(string)
		array=string.split(/\#/)
		return "Disabled American Veterans - #{newportnews_county_names(array[0])}, No. #{array[1]}"
	end
	
	def Name.purple_heart_chapters(string)
		string = string.sub(/\bpfc\b/i, 'Private First Class')
		string = string.sub(/\blcpl\b/i, 'Lieutenant Corporal')
		string = "The #{middle_initial(string)} chapter of the Military Order of the Purple Heart"
		return string
	end
	
	def Name.koc_chapters(string)
		string = "The #{cook_county_names_noflip(string)} chapter of the Knights of Columbus"
		string = string.gsub(/\bfr\b/i, 'Father')
		string = string.gsub(/\brev\b/i, 'Reverend')
		return string
	end
	
	def Name.ncaa_schools(string)
		string = '' if string == nil
		string = normalize(string)
		string = string.sub(/^\s*([A-Za-z]{2,}) ([A-Za-z]{2,}) ([A-Za-z])\.? Scho?o?l?\s*$/i, '\2 \3. \1 School')
		$school_abbreviation_swaps.each do |key, value|
			string = string.gsub(key, value)
		end
		return string
	end
	
	def Name.stitchnbitch(string)
		string = business_only_standardization(string)
		string = string.gsub(/\bs(titch)?\s*\'?\s*n\s*\'?\s*b(itch)?\b/i, 'Stitch \'n Bitch')
		string = string + ' Stitch \'n Bitch' if !string[/Stitch \'n Bitch/i]
		string = string.gsub(/\s{2,}/, ' ')
		return string 
	end
	
	def Name.smocking_guild(string)
		string = string.sub(/\s*\b(chapter)?\s*$/i, ' Chapter of the Smocking Arts Guild of America')
		return string
	end
	
	def Name.triathlon_clubs(string)
		string = string.sub(/\bTRI Club\b/i, 'Triathlon Club')
		string = string.sub(/\bTriathalon\b/i, 'Triathlon')
		string = string.sub(/((?<!Triathlon Club|Triathlon Team)$|Triatha?lon\s*$)/i, ' Triathlon Club') if !string[/Triatha?lon Club|Triatha?lon Team/i]
		string = string.sub(/\s{2,}/, ' ')
		return string
	end
	
	def Name.embroiderers_of_america(string)
		string = string.sub(/[^-]+-\s*/, '').sub(/^Delta\//, '')
		string = "Embroiderer's Guild of America, #{string}"
		string = string.sub(/( chapt?e?r?)?\s*$/i, ' Chapter')
		if string[/\band\b/]
			string = string.sub(/\bchapter$/i, 'Chapters')
		end
		return string
	end
	
	def Name.upc(string)
		string = string.sub(/UPC/i, 'United Pentecostal Church')
		return string
	end
	
	def Name.library_corrections(string)
		if !string[/\blib(rary|raries|\b\.?)/i]
			string = "#{string} Library";
		elsif string[/\bpub lib\b/i]
			string = string.sub(/\bpub(lic?) lib(rary)?\b/i, 'Public Library')
		elsif string[/\blib\s*$/i]
			string = string.sub(/\blib\s*$/i, 'Library')
		end
		string = string.gsub(/\bcen sch dis\b/i, 'Central School District')
		return string
	end
	
	def Name.episcopal_churches(string)
		string = string.sub(/([^,]+),.*/i, '\1')
		return string
	end
	
	def Name.newcomers_clubs(string)
		array=string.split(/, (?=[A-Za-z]{2}\s*$)/)
		name = "#{newportnews_county_names(array[0])}, #{Address::states_to_AP(array[1])}"
		name = name.sub(/,\s*$/, '')
		return name
	end
	
	def Name.append_freemason_lodge(string)
		output = "#{string} Freemason Lodge"
		return output
	end
	
	def Name.baptist_churches(string)
		string = string.sub(/\bMBC\b/i, 'Missionary Baptist Church')
		string = string.sub(/\bBC\b/i, 'Baptist Church')
		
		string = normalize(string)
		return string
	end
	
	def Name.append_pcg(string)
		output = normalize(string.sub(/\bPC\/?G\b/i, 'Pentecostal Church of God'))
		output = output.sub(/\/Oil City/i, ' (Oil City)')
		output = output.gsub(/\bfe?ll?o?wshi?p\b/i, 'Fellowship')
	end
	
  def Name.prepend_families_anonymous(string)
    return "Families Anonymous at #{string}";
  end
	
	def Name.prepend_overeaters_anonymous(string)
    return "Overeaters Anonymous at #{string}";
  end
  
  def Name.prepend_nonviolent_communication(string)
		string = string.gsub(/\(?(?<!intro to |introduction to )\bNVC\b\)?/i, 'Center for Non-Violent Communication')
		string = string.gsub(/\(?intro(duction)? to NVC\)?/i, 'Introduction to Non-Violent Communication')
		string = string.gsub(/\bnon(| |-)violent\b/i, 'Non-Violent')
		string = string.gsub(/\bpracti.e\b/i, 'Practice')
		string = normalize(string)
		string = string.sub(/\bnlp\b/i, 'NLP')
		string = string.gsub(/\b(i(i|v|x)i?|v(ii?))\b/i){|w| w.upcase}
		if !string[/Communication/i]
			string = "Center for Non-Violent Communication, #{string}"
		end
		string = string.gsub(/\s{2,}/, ' ')
		return string
  end
	
	def Name.cinci_freemason_lodge(string)
		number = string.sub(/.*\#(\d+)\s*$/, '\1')
		name = string.sub(/(.*) LODGE \#\d+\s*$/i, '\1')
		output = "#{normalize(name)} Freemason Lodge No. #{number}"
		return output
	end
  
  def Name.sherman_minimal(string)
		#this algorithm is for names requiring only basic maintenance operations.
		string = '' if string == nil
		string = string.sub(/\+\s*$/, '')
		string = string.sub(/,?\s*$/, '')
		string = string.sub(/\bUND\b/, '')
		string = string.sub(/(?<!\d )(?<!^)\b1\/2\b/, '')
    string = normalize(string) unless string.match(/[a-z]/)
    string = format_suffixes(string)
    
    string.gsub!(/\s+(\&|\+|\&amp\;)\s+/, ' and ')
    string.gsub!(/\binc\b\.?/i, 'Inc.')
    string.gsub!(/\bcorp\b\.?/i, 'Corp.')
    string.gsub!(/,?\s*\bJr\b\.?/i, ' Jr.')
    string.gsub!(/,?\s*\bSr\b\.?/i, ' Sr.')
    $business_acronyms_subs.each do |key, value|
      string.gsub!(key, value)
    end
    
    unless string.match($business_flags)
	    $parentheticals.each do |key, value|
	      string.gsub!(key, value)
	      value = 'not#a#real#value' if value == ''
	      string.gsub!(/\s*,/, ',')
				string.gsub!(/(.*)(#{value.gsub(/\(/, '\\(').gsub(/\)/, '\\)')})((?:[^$](?!\band\b|(?<=,) |\())+)(.*)/, '\1 \3 \2 \4')
				string.gsub!(/\s*$/, '')
				string.gsub!(/^\s*/, '')
	    end
		end
    
    string.gsub!(/\b([a-zA-Z]\b\.?(?!\'|-))/i){|w| 
      if w != 'a' and !string.match($business_flags)
        w.capitalize.sub(/\.+\s*$/, '') + '.'
      else
        if string.match($business_flags) and !string.match($parentheticals_regex)
          w
        else
          w.capitalize.sub(/\.+\s*$/, '') + '.'
        end
      end
    }
    string.sub!(/, Jr.\s*$/, ' Jr.')
    string.sub!(/, (II?I?V?)\s*$/, ' \1')
    while(string =~ /\band\b.*\band\b/)
      string.sub!(/\s*\band\b\s*(.*)\s*\band\b\s*/, ', \1 and ')
    end
    string.gsub!(/\s{2,}/, ' ')
    string.sub!(/\s*$/, '')
    string.sub!(/^\s*/, '')
    
  end
  
  def Name.complex_dedupe(array)
		#this algorithm identifies duplicates even if the names are in different orders, i.e. "SAMSON, JEFFREY" and "JEFFREY SAMSON"
		array.each_index do |index_a|
			dupe_check = Hash.new
			alpha_list = array[index_a].split(/\s/)
			
			alpha_list.each_index do |i|
				if alpha_list[i] =~ /^\(/
					until alpha_list[i] =~ /\)$/ or !alpha_list[i+1] or alpha_list[i+1] == nil
						alpha_list[i] = "#{alpha_list[i]} #{alpha_list[i+1]}"
						alpha_list.delete_at(i+1)
					end
				end
			end
						
			array.each_index do |index_b|
				next if index_a == index_b
				array.delete_at(index_b) && next if array[index_a] == array[index_b]
				
				beta_list = array[index_b].split(/\s/)
				
				beta_list.each_index do |i|
					if beta_list[i] =~ /^\(/
						until beta_list[i] =~ /\)$/ or !beta_list[i+1] or beta_list[i+1] == nil
							beta_list[i] = "#{beta_list[i]} #{beta_list[i+1]}"
							beta_list.delete_at(i+1)
						end
					end
				end
				
				alpha_list.each{|aa| dupe_check[aa] = beta_list.index(aa)}
				array.delete_at(index_a) if dupe_check.key(nil) == nil

			end
		end
		return array
	end
	
	def Name.ap_couples_and_families(array)
		#this algorithm finds people with the same last name and groups them together in lists.
		#this prepares "JAMESON, RHONDA||JACKSON, JOHN||JAMESON, JIM" for becoming "Rhonda and Jim Jameson and John Jackson"
		combine = ''
		output = Array.new
		parsed = Array.new
		derp = Hash.new(0)
		
		
		array.reject!{|item|
			derp[item] += 1
			derp[item] > 1
			}
			
		def Name.p_check(name)
			$parentheticals.each do |key, value|
				if key.match(name)
					return true
				end
			end
			return false
		end
		
		array.each do |first_name|
			#p "407:#{array}"
			#p "408:#{first_name}"
			if first_name !~ $business_flags and first_name !~ $business_acronyms and p_check(first_name) == false and first_name !~ /\b(jr|sr)\b/i
				last_name = first_name.sub(/.*(?<!-|\')\b([A-Za-z\-\']+)\s*$/, '\1')
				combine = ''
				array.each do |second_name|
					next if second_name =~ $business_flags or second_name =~ $business_acronyms or p_check(second_name) == true or second_name =~ /\b(jr|sr)\b/i
					next if second_name == first_name
					#p "414:#{second_name}"
					if last_name == second_name.sub(/.*(?<!-)\b([A-Za-z\-\']+)\s*$/, '\1')
						#p "inside"
						if combine == ''
							combine = "#{first_name.sub(/(.*)#{last_name}\s*$/, '\1')} xandx #{second_name}"
							parsed << second_name
						else
							combine = combine.sub(/(.*)#{last_name}\s*$/, '\1') + " xandx #{second_name}"
							parsed << second_name
						end
						#p "424:#{combine}"
					end
					#p "426:#{combine}"
				end
				combine = combine.sub(/^\s*xandx\s*/, '')
				#p "429:#{combine}"
				while(combine =~ /\bxandx\b (.*) \bxandx\b/)
					combine = combine.sub(/\bxandx\b (.*) \bxandx\b/, ', \1 xandx')
				end
				
				combine = combine.gsub(/\bxandx\b/, 'and')
				combine = combine.gsub(/\s{2,}/, ' ')
				combine = combine.sub(/^\s*/, '')
				combine = combine.sub(/\s*$/, '')
				
				if combine == ''
					output << first_name
				else
					combine.gsub!(/(?<!\'|-)\b(\w)\b(?!\.)/, "#{'\1'.capitalize}.")
					output << combine
				end
			else
				output << first_name
			end
			parsed.each do |name|
				array.delete(name)
			end
			
		end
		#p "454:#{output}"
		return output
	end
	
	def Name.preflip(string)
		string = string.gsub(/\b(mrs\b\.?|mr\b\.?|miss\b)/i, '')
		string = string.gsub(/\(([A-Za-z]+)\)/i, 'zZz\1zZz')
		string = string.sub(/\bUND\b/, '')
		string = string.sub(/\bEX\s*$/i, 'EXEC')
		string = string.sub(/(?<!\d |^)\b1\/2\b/, '')
		string = html_entities(string)
		string = string.sub(/\s*\|\s*$/, '')
		string = string.sub(/\s*\&\s*$/, '')
		string = string.sub(/^\s*(NULL|NIL)\s*$/, '')
		string = string.sub(/\\+C/, 'C')
		list = string.split(/(?<=[^\|])\|{1,2}(?=[^\|])/)
		#parenthetical_storage = ''
		prepared = Array.new
		list.each do |name|
			if !$bank_abbreviations.has_key?(name.sub(/^(.*)\s([^\s]+)$/, '\2')) and !$bank_abbreviations.has_value?(name)
				prepared << name
			elsif $bank_abbreviations.has_key?(name.sub(/^\s*(.*)\s*\s([^\s]+)\s*$/, '\2')) and !$bank_abbreviations.has_value?(name.sub(/^\s*(.*)\s*\s([^\s]+)\s*$/, '\1'))
				prepared << name
			elsif $bank_abbreviations.has_value?(name)
			  prepared << name
			elsif $bank_abbreviations.has_value?(name.sub(/^\s*(.*)\s*\s([^\s]+)\s*$/, '\1'))
				prepared << name.sub(/^\s*(.*)\s*\s([^\s]+)$/, '\1')
			else
				$bank_abbreviations.each do |key, value|
					if /\b#{key}\b/i.match(name)
						list.each do |longname|
							if longname == name
							  next
							elsif /\b#{value}\b/i.match(longname)
								#prepared << longname
								prepared << name.sub(/^(.*)\s(#{key})/, '(trust no. \1)')
							elsif
								prepared << name.sub(/^(.*)\s(#{key})/, '\1')
							end
						end
					end
				end
			end
		end
		string = prepared.join('|').gsub(/\|(\([^\)]+\)\s*($|\|))/i, '\1')
		#while(string =~ /(.*)\|(?!\|)((?:\w*)\d{2,}(?:\w*)(?:\d*))\b [^|]+(\||$)/i)
		#	string = string.gsub(/(.*)\|((?:\w*)\d{2,}(?:\w*)(?:\d*))\b [^|]+(\||$)/i, '\1 (trust No. \2)\3')
		#end
		prepared = string.split(/(?<=[^\|])\|{1,2}(?=[^\|])/)
		sorting = Array.new
		prepared.each do |name|
			unless name =~ /\(trust no/i
				sorting << name
			end
		end
		prepared.each do |name|
			if name =~ /\(trust no/i
				sorting << name
			end
		end
		prepared = sorting
		
		sorting = Array.new
		prepared.each do |name|
			derf = name.sub(/.*(\(trust no[^\)]+\)).*/i, '\1').gsub(/\(/, '\(').gsub(/\)/, '\)').gsub(/\[/, '\[').gsub(/\]/, '\]').gsub(/\*/, '\*')
			if name =~ /\(#{derf}\)/i and prepared[prepared.index(name) + 1] =~ /#{derf}/i
				name = name.sub(/\(#{derf}\)/i, '')
			end
		end
		fixed = parenthetical_application(prepared)
		fixed = complex_dedupe(fixed)
		return fixed
	end
	
	def Name.postflip(array)
		string = array.join('|')
		string = string.gsub(/\s*\|\s*/, '|')
		string = string.gsub(/\s{2,}/, ' ')
		string = string.sub(/\|$/, '')
		string = string.sub(/^\s*/, '')
		string = Name::logic_separated_names(string)
		string.sub!(/^a\b/, 'A')
		string.gsub!(/\ba\./, 'A.')
		string = string.sub(/\bChicago(\s*$|\s*\()/i, ', Chicago\1')
		string = string.gsub(/\s*,/, ',')
    string = string.sub(/^([A-Za-z])/){|m| m.upcase}
    string = string.gsub(/\bZzz([^\s]+)zzz/){|m| '(' + m.sub(/\bZzz([^\s]+)zzz/, '\1').capitalize + ')'}
		return string
	end
	
	def Name.baltimore_county_names(string)
		array = string.split(/\|\|/)
		phase = Array.new
		fixed = Array.new
		array.each do |set|
			set_array = set.split(/\|/)
			phase << parenthetical_application(set_array).join(' ')
			phase.each do |trinket|
				unless trinket[/,/]
					fixed << trinket
				  next
				end
				fixed << broward_county_names(trinket)
			end
		end
		string = fixed.join('|')
		output = cook_county_names_noflip(string)
		return output
	end
		
	def Name.cook_county_names_noflip(string)
		string = string.gsub(/\d{2}\/\d{2}\/\d{2,4}\s*($|\|\|)/, '\1')
		string = string.gsub(/TR [\d\-\/]+\s*($|\|\|)/, 'TR \1')
		array = preflip(string)
		array = ap_couples_and_families(array)
		output = postflip(array)
		return output
	end
	
	def Name.mchenry_county_names(string)
		array = string.split(/(?<=trust),\s*/i)
		array.each do |name|
			if !name[$business_flags]
				name.sub!(/\s*\&amp\;\s*/, '||') 
			end
		end
		string = array.join('||')
		string.gsub!(/\s*-?PER SELLING OFFICER\s*($|-)/, ' PSO||')
		string.gsub!(/(?:\|\|)?\s*-?(AKA|FKA|NKA)-?\s*/, '||\1 ')
		string.gsub!(/\s*-?PER ATTO?R?N?E?Y\s*($|-)/, ' BY ATT||')
		string.sub!(/\s*\|\|\s*$/, '')
		output = newcanaan_county_names(string)
		return output
	end
	
	def Name.darien_county_names_noflip(string)
		string.gsub!(/ and |, /i, '||')
		string.gsub!(/ aka /i, '|| AKA ')
		output = cook_county_names_noflip(string)
		return output
	end
	
	def Name.first_names_first(array)
		fixed = Array.new
		array.each_index do |index|
			known_last = array[index].gsub(/(.*)\t.*/, '\1')
			known_first = array[index].gsub(/.*\t\s*([A-Za-z\-\']+)\b.*/, '\1')
			array.each_index do |index_inner|
				next if index == index_inner
				if array[index_inner][/#{known_last.gsub(/\(/, '\(').gsub(/\)/, '\)')}\s*#{known_first.gsub(/\(/, '\(').gsub(/\)/, '\)')}/]
					array[index_inner].sub!(/(#{known_last.gsub(/\(/, '\(').gsub(/\)/, '\)')})\s*(#{known_first.gsub(/\(/, '\(').gsub(/\)/, '\)')}.*)/, '\2 \1 ')
					array[index_inner].gsub!(/\s{2,}/, ' ')
				end
			end
			array[index] = array[index].gsub(/(.*)\t([^\(]+)\s*($|\()/, '\2 \1 \3')
			array[index].gsub!(/\s{2,}/, ' ')
			fixed << array[index]
		end
		return fixed
	end
	
	def Name.last_names_first_broken(array)
		fixed = Array.new
		first = Array.new
		last = Array.new
		array.each_index do |index|
			first << array[index].sub(/([A-Za-z\'\-]+)\s+.*/, '\1')
			last << array[index].sub(/[A-Za-z\'\-]+\s+(?:\b[A-Za-z]\b\.? )*\b([A-Za-z\'\-]+)\b.*/, '\1')
			p "first: #{first}"
			p "last:  #{last}"
		end
		first.each_index do |index|
			first.each_index do |indent|
				next if index == indent
				if first[index] != first[indent]
					first.delete_at(indent)
					first.delete_at(index)
				end
			end
			p first
		end
		last.each_index do |index|
			last.each_index do |indent|
				next if index == indent
				if last[index] != last[indent]
					last.delete_at(indent)
					last.delete_at(index)
				end
			end
			p last
		end
		return fixed
	end
	
	def Name.lake_county_names(string, structure)
	
	end
	
	def Name.broward_county_names(string)
		#specials
		string = string.sub(/^\s*([^\s,]+), ([^\s]+)( [A-Za-z])? CUSTOM BUILDERS, LLC?\s*$/, '\1, \2\3||CUSTOM BUILDERS LLC')
		#and on to the main event
		string.gsub!(/\&,\s*/, '& ')
		if string[/\,[^\|\&]+\,/]
			x=0
			while string[/,[^\|]+,/]
				#string.gsub!(/([^\s,]+),(.*)\s([^\s,]+),(.*)/, '\1, \2||\3, \4')
				x+=1
				string.gsub!(/(\b[^\s,\|]+\b),\s*([^,\|]+)\s*(?:\|\||$|(\b[^\s,\|]+\b,))/, '\1, \2||\3')
				string.gsub!(/,(JR|SR|LLC|INC)\b/, ' \1')
				string.gsub!(/,([^,\s\|]+),/, '||\1')
				string.gsub!(/,\s*,/, ',')
				if x > 100
					puts "slaying infinite loop"
					string.gsub!(/,([^\|]+),/,' \1,')
				end
			end
			string.sub!(/\s*\|\|\s*$/, '')
			string.gsub!(/\s*\|\|\s*/, '||')
		end
		string.gsub!(/\s*,\s*/, ', ')
		string.gsub!(/\s*\&\s*/, '||') unless string[$business_flags]
		array = string.split(/\|\|/)
		returned = hampton_family_corrections(array)
		string = array.join('||')
		return newcanaan_county_names(string)
	end
	
	def Name.westchester_county_names(string)
		string.gsub!(/(?<!\|)\|(?!\|)/, '||')
		return (newcanaan_county_names(string))
	end
		
	def Name.newcanaan_county_names(string)
		string = string.gsub(/,\s*\b(JR\b|SR\b|L\.?L\.?C\b\.?|L\.?P\b\.?|P\.?A\b\.?)/, ' \1')
		string = string.sub(/\+\s*$/, '')
		string.gsub!(/,/, "\t")
		array = preflip(string)
		fixed = first_names_first(array)
		fixed = complex_dedupe(fixed)
		fixed = ap_couples_and_families(fixed)
		output = postflip(fixed)
		return output
	end
	
	def Name.clark_public_schools(string)
		schoolhash = {
			'MS' => 'Middle School',
			'HS' => 'High School',
			'ES' => 'Elementary School',
			'JHS' => 'Junior High School',
			'MS/HS' => 'Middle School and High School'
			}
		array = string.split(/\s(\w{2}|JHS|MS\/HS)$/i)
		string = newcanaan_county_names(array[0])
		string = "#{string} #{schoolhash[array[1]]}"
		string = string.sub(/^([A-Za-z])\b /, '\1. ')
		string = string.sub('P. a Diskin', 'P. A. Diskin')
		return string
	end
	
	def Name.hampton_family_corrections(array)
		return array if array[0] == nil
		last_name = array[0].sub(/^\s*([^\s]+)\s.*/, '\1')
		array.each_index do |i|
			next if i==0
			next if array[i].sub(/^\s*([^\s]+)\s.*/, '\1') == last_name
			if array[i] =~ /^\s*[^\s]+\s[A-Za-z]\s*$/ or array[i] =~ /^\s*[^\s]+\s*$/ or array[i] =~ /^\s*[^\s]+\s[A-Za-z]?\s*(\bJR\b\.?|\bSR\b\.?|\(.*\))?\s*$/
				array[i].sub!(/(.*)/, "#{last_name} \\1")
			elsif array[i] =~ /^\s*([^\s]+(\s|$)){3,}/
				last_name = array[i].sub(/^\s*([^\s]+)\s.*/, '\1')
			end
			
		end
		return array
	end
	
	def Name.parenthetical_application(prepared)
			fixed = Array.new
			prepared.each do |name|
			$parentheticals.each do |key, value|
				name.gsub!(key, value)
				name.gsub!(/(.*)(#{value.sub(/\(/, '\\(').sub(/\)/, '\\)')})(.*)/, '\1 \3 \2')
			end
			name = name.sub(/\s*\+\s*$/i, '')
			name = name.sub(/^\s*de\s+la\s+([A-Za-z\-\']+)\b/i, 'xxdelaxx\1')
			name = name.sub(/^\s*de\s+([A-Za-z\-\']+)\b/i, 'xxdexx\1')
			name = name.sub(/^\s*van\s+([A-Za-z\-\']+)\b/i, 'xxvanxx\1')
			name = name.sub(/^mc\s*([A-Za-z])/i){|m| "Mc"+m.sub(/^mc\s*/i, '').capitalize}
			name = name.sub(/^mac\s*-?\s*([A-Za-z])/i){|m| "Mac"+m.sub(/^mac\s*-?/i, '').capitalize}
			name = name.sub(/^o\'?\s+([A-Za-z])/i){|m| "O\'"+m.sub(/^o\s*/i, '').capitalize}
			name = name.sub(/(.*)(?<! )(DECD|EXTR|DECL OF TRUST)\s*$/, '\1 \2')
			name = name.sub(/^\s*/, '')
			name = name.sub(/\s*$/, '')
			fixed << name
		end
		return fixed
	end
	
	def Name.concat_array(fixit)
		string = ''
		fixit.each do |item|
			string = "#{string}\|\|#{item}"
		end
		string.sub!(/^\s*\|\|\s*/, '')
		string.gsub!(/\|\|C\/O/, ' C/O ')
		string.gsub!(/\(L(ife)?\s*U(se)?\)/, ' LIFEUSE ')
		string.gsub!(/\(and others\)/, ' ETAL ')
		string.gsub!(/\(\d\/\d\)/, '')
		return string
	end
	
	def Name.hamilton_grantee_names(string)
		array = string.split(/\&?\|\|/)
		name_array = Array.new
		business_array = Array.new
		holder = ''
		array.each_index do |i|
			iminus = i-1
			if iminus < 0
				iminus = i
			end
			array[i].sub!(/\s*\@\s*\d\b\s*/, ' ')
			if holder != ''
				business_array << holder + ' ' + array[i]
				holder = ''
				next
			end
			if array[i][/\s*\bof\b\s*$/i]
				holder = array[i]
				next
			end
			if array[i][/\bLLC\b|\bLTD\b|\bINC\b/] and iminus != i and array[iminus][$business_flags]
				array[iminus] = array[iminus] + ' ' + array[i]
				business_array << array[iminus]
			elsif array[i][/\bLLC\b|\bLTD\b|\bINC\b/] or array[i][$business_flags]
				business_array << array[i]
			end
			if !array[i][$business_flags]
				
				if i > 0 and array[i][/^\s*[^\s]+\s[^\s]\s[^\s]+\b/]
					array[i].sub!(/^(.*)\s([^\s]+)\s*$/, '\2 \1')
					array[i].gsub!(/\s{2,}/, ' ')
					array[i].sub!(/^\s*/, '')
					array[i].sub!(/\s*$/, '')
				elsif i > 0 and array[i][/^\s*[^\s]+\s[^\s]{2,}\b/]
					#if array[0].sub(/^\s*([^\s]+)\s.*/, '\1') == array[i].sub(/.*\s([^\s]+)\s*$/, '\1')
						array[i].sub!(/^(.*)\s([^\s]{2,})\s*$/, '\2 \1')
						array[i].gsub!(/\s{2,}/, ' ')
						array[i].sub!(/^\s*/, '')
						array[i].sub!(/\s*$/, '')
					#end
				end
				name_array << array[i]
			end
		end
		name_array = hampton_family_corrections(name_array)
		if !name_array.empty? and !business_array.empty?
			array = name_array.concat(business_array)
		elsif !business_array.empty?
			array = business_array
		elsif !name_array.empty?
			array = name_array
		end
		string = concat_array(array)
		return cook_county_names(string)
	end
	
	def Name.hampton_county_names(string)
		string.gsub!(/\&\s*$/, '')
		string.gsub!(/\s*(\&\|\|)\s*/, '||')
		unless string[$business_acronyms] or string[$business_flags]
			string.gsub!(/\s*\&\s*/, '||')
		end
		string.gsub!(/(#{$business_terminators})\s*\&\s*/, '\1||')
		fixit = hampton_family_corrections(parenthetical_application(string.split(/\|\|/)))
		string = concat_array(fixit)
		return cook_county_names(string)
	end
	
	def Name.newportnews_county_names(string)
		string.gsub!(/\&\s*$/, '')
		string.gsub!(/\s*(\&\|\|)\s*/, '||')
		unless string[$business_acronyms] or string[$business_flags]
			string.gsub!(/\s*\&\s*/, '||')
		end
		string.gsub!(/(#{$business_terminators})\s*\&\s*/, '\1||')
		fixit = string.split(/\|\|/)
		string = ''
		fixit.each do |item|
			string = "#{string}\|\|#{item}"
		end
		string.sub!(/^\s*\|\|\s*/, '')
		string.gsub!(/\|\|C\/O/, ' C/O ')
		string.gsub!(/\(L(ife)?\s*U(se)?\)/, ' LIFEUSE ')
		string.gsub!(/\(and others\)/, ' ETAL ')
		string.gsub!(/\(\d\/\d\)/, '')
		return cook_county_names_noflip(string)
	end
	
	def Name.seymour_county_names(string)
		string.gsub!(/\s*(\&\|\|)\s*/, '||')
		string.gsub!(/\|\|C\/O/, ' C/O ')
		string.gsub!(/\(L(ife)?\s*U(se)?\)/, ' LIFEUSE ')
		string.gsub!(/\(and others\)/, ' ETAL ')
		string.gsub!(/\(\d\/\d\)/, '')
		return cook_county_names(string)
	end

	def Name.cook_county_names(string)
		string = string.gsub(/,/, ' ')
		string = string.gsub(/\/?\\?\|\|/, '||')
		$parentheticals.each do |key, value|
			string = string.gsub(/\|\|(#{key})/, ' \1')
		end
		array = preflip(string)
		fixed = Array.new
		array.each do |name|
			parenthetical_storage = []
			while name =~ /^(?:[^\(\)]+)(\([^\)\(]+\)\s*){1,}$/
				glib = name.sub(/^(?:[^\(\)]+)(\([^\)\(]+\)\s*){0,}$/, '\1')
				parenthetical_storage << glib
			
				name = name.sub(glib, '')
			end
		  name = Name::lastfirst_firstlast(name) unless name.match($business_flags)
		  parenthetical_storage.each do |parenth|
		    name = name + ' ' + parenth
		  end
		  name = name.gsub(/\s{2,}/, ' ')
			fixed << name
			parenthetical_storage = []
		end
		fixed = ap_couples_and_families(fixed)
		fixed.each do |name|
			if(name =~ /( and |\&)/)
				name.sub!(/\(trustee\)\s*$/, '(trustees)')
			end
		end
		output = postflip(fixed)
		return output
	end
	
	def Name.logic_separated_names(string)
		if string[$business_acronyms] or string[$business_flags]
			list = string.split(/(?<=[^\|])\|{1,2}(?=[^\|])/i)
		else
			list = string.split(/(?<=[^\|])(?:\|| \& ){1,2}(?=[^\|])/i)
		end
		fixed = Array.new
		list.each do |name|
			fixed << Name::business_normalization_weston(name)
		end
		output = ''
		fixed.each do |name|
			output = output + "\|#{name}"
		end
		output.sub!(/^\s*\|/, '')
		while(output =~ /([^\|]+)\|(.*\|)?\1(\||$)/)
			output = output.gsub(/([^\|]+)\|(.*\|)?\1(\||$)/, '\1|\2')
		end
		output.sub!(/\s*\|\s*$/, '')
		output.gsub!(/\|/, ' xandx ')
		output.sub!(/^ xandx /, '')
		while(output =~ / xandx (.*) xandx /i)
			output.sub!(/ xandx (.*) xandx /, ', \1 xandx ')
		end
		output.gsub!(/\bxandx\b/, 'and')
		output.gsub!(/\s{2,}/, ' ')
		
		return output
	end
	
	def Name.business_weak_assessment(business)
		unless business[/[a-z]/]
			business = business_only_standardization(business)
		end
		return business
	end
	
	def Name.business_only_standardization(business)
		business = '' if business == nil
		splitter = business.split(/ (?:and|&) /i)
		business = ''
		splitter.each do |m|
			m = business_normalization(m)
			business = "#{business} and #{m}"
		end
		business = business.sub(/^\s*and\b\s*/i, '')
		business = business.sub(/\s{2,}/, ' ')
		business = business.sub(/\s*$/, '')
		$business_troublemakers.each do |k, v|
			business = business.gsub(k, v)
		end
		business = business.sub(/^[a-z]/){|m| m.capitalize}
		return business
	end

	def Name.business_normalization(business)
	  #Drop % to end for cases like this: "Enterprise Avenue Investor % Deloitte & Touche LLP"
		business = business.gsub(/\\'/, "'")
	  business = business.gsub(/\s%\s.*/, '')
	  business = business.gsub(/\bint\'l\b/i, 'International')
	  business = business.gsub(/\s*\bD\/?\.?B\/?\.?A\b\/?\.?\s*(.*)/i){|m|
			m = m.sub(/\bD\/?\.?B\/?\.?A\b\/?\.?\s*(.*)/i, '\1')
			m = Name::business_normalization(m)
			" (doing business as #{m})" 
		}
		business = business.sub(/\bColdwell Banker Residential Real Estate\s*-\s*(.*)\s*$/i, 'Coldwell Banker Residential Real Estate (\1)')
		business = business.gsub(/\s*\)/, ')').gsub(/\(\s*/, '(')
	  business = business.gsub(/\s*\bvia (.*)/i, ' (via \1)')
	  business = business.gsub(/\s*\(\bdoing business as\b\s*\)/i, ' (doing business as)')
	  
	  #delete parenthesis
	  #we apparently don't want to do this universally anymore
	  #business = business.gsub(/\([^\)]+(\)|\Z)/, '') unless business.match(/\(Truste?e?\)/)
	  #dealing with semicolon to end
	  business = business.gsub(/;\s+(#{$business_suffixes})/i, ', \1').gsub(/\;.*\Z/, '')
	  #replace ', Texas #nn' with ' No. nn'
	  business = business.gsub(/\,\s+Texas\s+\#(\d+)/i, ' No. \1')
	  #remove spaces around -
	  business = business.gsub(/\s*\-\s*/, '-')
	  business = normalize(business)
	  business = Name.format_suffixes(business)
	  business = business.gsub(/\(U\.?S\.?A?\.?\)/i, '')
	  #substitutes values in $business_acronyms hash for keys.
	  $business_acronyms_subs.each do |k, v|
	    business = business.gsub(k, v)
	  end
	  #delete comma after 'jr.'
	  business = business.gsub(/(?<=jr\.),/i, '')
	  
	  #.com, etc.
	  business = Name.domain_name(business)
	  #dangling commas and a letter or two--deleted
	  #business = business.gsub(/,(?:(.{0,3}|\s+#{$states_full}))\Z/, '')
	  return business #+ " BUSINESS"
	end

	def Name.business_normalization_weston(input)
	  #deal with html entities
	  input = html_entities(input)
	  #drop ', et al' of dangling 'and'
	  input = input.gsub(/,\s+et\s+al/i, '').gsub(/\s+and\s{0,}\Z/i, '')
	  input.sub!(/^\s*de\s+la\s+([A-Za-z\-\']+)\b/, 'xxdelaxx\1')
	  input.sub!(/^\s*de\s+([A-Za-z\-\']+)\b/i, 'xxdexx\1')
	  if input[$business_indicators] or input[$business_names] or input[$business_types] or input[$business_acronyms] or input[$business_flags] or input[$business_suffixes]
	    input = Name.business_normalization(input)
	  else
	    input = Name.name_normalization(input)
	  end
	  #capitalize letter immediately after hyphen, e.g., T-Mobile
	  input = input.gsub(/(?<=\-)([a-z])/){|letter| letter.upcase}
	  
	  #Adding parantheses around 'Trust', as needed.
	  #input = input.gsub(/\bTR\s*\Z/, '(trust)').gsub(/\bTrustt\b/, '(trust)').gsub(/\bTrust\s*\Z/, '(trust)')

	  #dotting saints
	  input = input.gsub(/\bst\b\.?/i, 'St.')
	  #Adding parantheticals
		$parentheticals.each do |key, value|
			input.gsub!(key, value)
			input.gsub!(/(.*)(#{value.sub(/\(/, '\\(').sub(/\)/, '\\)')} )(.*)/i, '\1 \3 \2')
		end
		#while input =~ /[^\(\)]+\([\)\(]+\)\s*[^\(\)$]/
		#	$parentheticals.each do |key, value|
		#	while input =~ /[^\)\(]+#{value.gsub(/\(/, '\\(').gsub(/\)/, '\\)')}[^$\)\(]/
		#		puts input
		#		puts value
		#		input = input.sub(/([^\)\(]+)(#{value.gsub(/\(/, '\\(').gsub(/\)/, '\\)')})(.*)$/, '\1 \3 \2')
		#		puts input
		#	end
		#end
		input = input.sub(/([^\)\(]+)(\(Trust No[^\)\(]+\))(.*)$/, '\1 \3 \2')

	  while(input.match(/\(Trust\)(.*)\(Trust\)\s*$/))
			input = input.gsub(/\(Trust\)(.*)\(Trust\)\s*$/, '\1 (trust)')
		end
		
		while(input.match(/\(Deceased\)(.*)\(Deceased\)\s*$/))
			input = input.gsub(/\(Deceased\)(.*)\(Deceased\)\s*$/, '\1 (deceased)')
		end
		
	  input = input.gsub(/\s{2,}/, ' ')
		
	  if(input.match($parentheticals_regex) or input.match(/\btrust(ee)?\b/i))
			input.gsub!(/(?<!\'|-)\b([a-zA-Z])\b(?!\'|\.)/){|m| m.upcase + '.'}
		end
		if(input.match(/^#{$first_names}/i))
			input.gsub!(/(?<!\'|-)\b([a-zA-Z])\b(?!\'|\.)/){|m| m.upcase + '.'}
		end
		input.gsub!(/\(trustee\) \(successor\)|\(successor\) \(trustee\)/, '(successor trustee)')
		input.gsub!(/\(trustee\)\s*(\(Trust No.*\))/, '\1')
		unless input.match(/\(Trust No\./)
			input.gsub!(/(.*)(\(.*\))(.*)/){|m|
				first = m.sub(/(.*)(\(.*\))(.*)/, '\1')
				second = m.sub(/(.*)(\(.*\))(.*)/, '\2')
				third = m.sub(/(.*)(\(.*\))(.*)/, '\3')
				"#{first} #{third} #{second.downcase}"
			}
		end
		input.gsub!(/\b(#{$plural_without_s})s\b/i, '\1\'s')
		input.sub!(/\bxxdelaxx([A-Za-z\-\']+)\b/i){|m| 'De La ' + m.sub(/xxdelaxx/i, '').capitalize }
		input.sub!(/\bxxdexx([A-Za-z\-\']+)\b/i){|m| 'De ' + m.sub(/xxdexx/i, '').capitalize }
		input.sub!(/\bxxvanxx([A-Za-z\-\']+)\b/i){|m| 'Van ' + m.sub(/xxvanxx/i, '').capitalize }
		input.sub!(/,? NA($|\s+\()/i, ', NA \1')
		input.sub!(/\s*$/, '')
		input.sub!(/^\s*/, '')
		input.gsub!(/\s{2,}/, ' ')
	  return input
	end

	def Name.domain_name(value)
	  value = value.gsub(/(?<=\w)\.(com|net|org|info|biz|mobi|asia|eu|xxx|us|co|mx|tw|gov|edu)\b/i){|capture| capture.downcase}
	end

	#Format suffixes--professional or otherwise--so that they do or don't have commas, periods, etc., as required by AP.
	def Name.format_suffixes(suffix)
		parenthetical_reservation = Array.new
		while suffix[/\([^\)]+\)/]
			parenthetical_reservation << suffix.sub(/.*(\([^\)]+\)).*/, '\1')
			suffix = suffix.sub(/(.*)\([^\)]+\)(.*)/, '\1 \2')
		end
	  #personal suffix
	  var = ''
	  suffix = suffix.gsub( /(.*),?\s*\bJR\b\.?((?:[^$](?!\band\b))+|\s*$)(.*)/i, '\1 \2 Jr. \3' ).gsub( /(.*),?\s*\bSR\b\.?((?:[^$](?!\band\b))+|\s*$)(.*)/i, '\1 \2 Sr. \3' ).gsub(/(.*),?\s*\bM\.?\s*D\b\.?((?:[^$]*(?!\band\b))+)(.*)/i, '\1 \2, M.D. \3' ).gsub( /(.*),?\s*\bPh\b\.?\s*D\b\.?((?:[^$](?!\band\b))+)(.*)/i, '\1 \2, Ph.D. \3' ).gsub( /(.*),?\s*\bJ\.?\s*D\b\.?((?:[^$](?!\band\b))+)(.*)/i, '\1 \2, J.D. \3' ).gsub( /(.*),?\s*\bPharm\.?\s*D\b\.?((?:[^$](?!\band\b))+)(.*)/i, '\1 \2, Pharm.D. \3' ).gsub( /,?\s+D\.*O\b\.*/i, ', D.O.' ).gsub( /,?\s+M\.*B\.*A\.*/i, ', M.B.A.' ).gsub( /(.*),?\s*\b(iii?)\b((?:[^$](?!\band\b))+)(.*)/i, '\1 \3 \2 \4' ).gsub( /(.*),?\s*\biv\b((?:[^$](?!\band\b))+)(.*)/i, '\1 \2 IV \3' ).gsub( /(.*),?\s*\b(vii?i?)\b((?:[^$](?!\band\b))+)(.*)/i, '\1 \3 \2 \4' ).gsub( /(.*),?\s*\bix\b((?:[^$](?!\band\b))+)(.*)/i, '\1 \2 IX \3' ).gsub(/(.*),?\s*\b(xvii?i?)\b((?:[^$](?!\band\b))+)(.*)/i, '\1 \3 \2 \4')
	  suffix = suffix.gsub(/\b(iii?|iv|vii?i?|xv?ii?i?|xv|xiv|xix|xxi)\b/i){|m| m.upcase}
	  suffix = suffix.gsub( /,?\s*\b((?:jr|sr)\.?)/i, ' \1')
	  #business suffix
	  suffix = suffix.gsub(/(?:\sa\sTexas)?,?\s+\bLimited\s+Liabil?i?t?y?\s*C?o?m?p?a?n?y?\b/i, ' LLC').gsub( /,?\s+\bco(?:mpany)?\b\.{0,1}(?![^\,\s])/i, ' Co.' ).gsub( /(?:\,\s+a\s+#{$states_full})?,?\s+\bcorp(?:oration)?\b\.{0,1}/i, ' Corp.' ).gsub( /,?\s+\bInc(?:orporated?)?\b\.{0,1}/i, ' Inc.' ).gsub( /(?:\,\s+a\s+#{$states_full}\s+series\s*)?,?\s+\b(?:Limited?|Ltd)\b\.?/i, ' Ltd.' ).gsub( /\bBros\b\.{0,1}/i, 'Bros.' ).gsub( /,?\s+\bL\.{0,1}\s{0,1}L\.{0,1}\s{0,1}C\b\.{0,1}/i, ' LLC' ).gsub( /,?\s+\bL\.{0,1}\s{0,1}L\.{0,1}\s{0,1}P\b\.{0,1}/i, ' LLP' ).gsub(/,?\s+\bL\.*C\.*L\b\.{0,1}/i, ' LCL').gsub(/,?\s+\bL\.*P\b\.{0,1}/i, ' LP').gsub(/,?\s+\bL\.*P\.*C\b\.{0,1}/i, ' LPC').gsub(/,?\s+\bL\.*\s*C\b\.{0,1}/i, ' LC').gsub(/,?\s+\bP\.*C\b\.{0,1}/i, ' PC').gsub(/,?\s*(#{$suffixes})?,?\s*(#{$suffixes})?,?\s+\bP\.*A\b\.{0,1}(?:,\s+a\s+#{$states_full}\s+pro?f?e?s?s?i?o?n?a?l?)?/i, ' PA').gsub(/,?\s+Professional\s+Associat?i?o?n?$|,?\s*\bP\.?A\b\.?\s*$/i, ' PA').gsub(/(?:\,\s+a\s+#{$states_full})?\,?\s+N(?:on)?\.{0,1}\s*p(?:roi?fi?t)?\.{0,1}\s*C(?:o(?:mpany)?)?\.{0,1}\s*(?=(\s|\Z))/i, ' NPC')
	  suffix = suffix.gsub(/(.*),?\s*\b(LLC\b|Inc\b\.|LP|LLP)(?!\s*-)(?! of\b)\s*(.*)/, '\1 \3 \2')
	  suffix = suffix.gsub(/LLC\s*-\s*/, 'LLC - ')
	  suffix = suffix.gsub(/\s*,\s*,?\s*/, ', ')
	  suffix = suffix.gsub(/\s{2,}/, ' ')
	  parenthetical_reservation.each do |thing|
			suffix = "#{suffix} #{thing}"
		end
	  return suffix
	end

#Takes lines of one or two names of persons and returns them like this: First M(iddle)? Last and First M(iddle)? Last
	def Name.name_normalization(line)
		#move dr to beginning
		line = line.sub(/(.*)\s*\bdr\b\s*$/i, 'Dr. \1') 
	  #Eliminate &
	  line = line.gsub(/\s*&\s*$/, '').gsub(/(?<=\s)&(?=\s)/, 'and')
	  #Eliminate H/E
	  line = line.gsub(/\bH\/E\b/i, 'and')
	  #Add 'and' in space
	  line = line.gsub(/\A([^,]+\,.+)(?:\s+|\t)(\S+\,\S+)\Z/i, '\1 and \2') unless line[/\b(and|\&|H\/E)\b/]
		#Add 'and' in different space:
		line = line.gsub(/([\w\s\.]+,\s+(?:#{$first_names})\s[a-z]\.)\s+([\w\s\.]+,\s+(?:#{$first_names})(?:\s[a-z]\.)?)/i, '\1 and \2' ) unless line[$business_suffixes] or line[/and/i] or line[$suffixes]
		#Replace semicolon with 'and'
		line = line.gsub(/\A(\w+\s+[a-z]\.\s+\w+(?:,?\s+(?:#{$suffixes}))?);\s*((\w+\s+[a-z]\.\s+\w+(?:,?\s+(?:#{$suffixes}))?))/i, '\1 and \2')	
		#replace comma with and in names like 'Joe C. Velasquez, Vanancio Sanchez, Jr.
	  line = line.gsub(/\A(#{$first_names}[^,]+),\s+([^,]+(,\s+(#{$suffixes}))?)\Z/i, '\1 and \3')
	  #normalize
	  line = normalize(line)
		#This conditional will allow decide whether an input line contains one or two names. If it has one name, it will it through name_format() so that it is formatted properly. If it has two names, it does whatever is contained in the elsif consequents.
		if !line.match(/\band\b/i)
			line = name_format(line)
		elsif !line.match(/,.+\band\b.+,/)
      #turns 'Last, First (Middle)? Suffix and First (Middle)? Suffix' to 'First (Middle)? Last Suffix and First (Middle)? Last Suffix'
      line = line.gsub( /\A([^,]+),\s*([\w\s\.]+)\s+(#{$suffixes})\s?(?=and)and\s+(.*)\s+(#{$suffixes})\Z/i, '\2 \1 \3 and \4 \1 \5' )
      #turns 'Last, First (Middle)? and First (Middle)? Suffix' to 'First (Middle)? Last and First (Middle)? Last Suffix'
      line = line.gsub( /\A([^,]+),\s*([\w\s\.]+)\s+(?=and)and\s+(.*)\s+(#{$suffixes})\Z/i, '\2 \1 and \3 \1 \4' )
      #turns 'Last, First (Middle)? Suffix and First (Middle)?' to 'First (Middle)? Last Suffix and First (Middle)? Last'
      line = line.gsub( /\A([^,]+),\s*([\w\s\.]+)\s+(#{$suffixes})\s?(?=and)and\s+(.*)\Z/i, '\2 \1 \3 and \4 \1' )
      #turns 'Last, First (Middle)? and First (Middle)?' to 'First (Middle)? Last and First (Middle)? Last'
      line = line.gsub( /\A([^,]+),\s*([\w\s\.]+)\s(?=and)and\s+(.*)\Z/i, '\2 \1 and \3 \1' )
    elsif !line.match(/,\s+(#{$suffixes})/i)
      #Last1, First1 Jr. and Last2, First2 Jr. => First1 Last1 Suffix and First2 Last2 Suffix
      line = line.gsub( /\A([^,]+),\s+([\w\s\.]+)\s+(#{$suffixes})\s?(?=and)and\s+(.*),\s+(.*)\s+(#{$suffixes})\Z/i, '\2 \1 \3 and \5 \4 \6' )
      #Last1, First1 and Last2, First2 Jr. => First1 Last1 and First2 Last2 Suffix
      line = line.gsub( /\A([^,]+),\s+([\w\s\.]+)\s+\s?(?=and)and\s+(.*),\s+(.*)\s+(#{$suffixes})\Z/i, '\2 \1 and \4 \3 \5' )
      #Last1, First1 Jr. and Last2, First2 => First1 Last1 Suffix and First2 Last2 
      line = line.gsub( /\A([^,]+),\s*([\w\s\.]+)\s+(#{$suffixes})\s?(?=and)and\s+(.*),\s*(.*)\Z/i, '\2 \1 \3 and \5 \4' )
      #Last1, First1 and Last2, First2 => First1 Last1 and First2 Last2
      line = line.gsub( /\A([^,]+),\s*([\w\s\.]+)\s+\s?(?=and)and\s+(.*),\s*(.*)\Z/i, '\2 \1 and \4 \3' )
    end
		#Period with middle initial
		line = Name.middle_initial(line)
		#Capitalize middle initial
		line = line.gsub(/(\s|^)([a-z])\.\s/){|initial| initial.upcase}
		
		#Format suffixes according to AP style
		line = Name.format_suffixes(line)
		line = line.gsub(/\ba\b\.?/i, 'A.')
		line = line.gsub(/(?<=\bmc)([A-Za-z])/i){|m| m.upcase}
		return line #+ " NAME!"
	end

	def Name.middle_initial(line)
	  #Period with middle initial
		line = line.gsub( /(?<!\bfor |\bto |\'|-)\b([A-Z])\b(?!(\.|\S))/i){|m| "#{m.upcase}."}
	end


	#Takes names of individual persons and returns them like this: First M(iddle)? Last
	def Name.name_format(line)
		#; semicolon issues
		line = line.gsub(/;\s+IND\Z/i, '' ).gsub(/;\s+(#{$suffixes})\Z/i, ', \1')
		
		#Things to drop
		line = line.gsub(/,\s+F\.{0,1}A\.{0,1}\Z/i, '' ).gsub(/,\s+Facoog\Z/i, '') 
		
		#correct word ordernig when like this: 'Leonard, (+MD)?, George(, suffix)?'
		line = line.gsub(/([^,]+),(?:\s+|\t|\s+\+[^,]{0,3}),\s+([^,]+)(,?\s(?:#{$suffixes}))?/i, '\2 \1\3') unless line[$business_suffixes] or line[/and/i] or line[/\A(#{$first_names})/]
		
		#Correct word ordering when like this: 'Last, Suffix, First Middle'
		line.gsub!( /\A([\w\s\.]+(?:,\s+(?:#{$suffixes}))),\s*([\w\s\.]+)/i, '\2 \1') unless line[$business_suffixes] or line[/and/i] or line[/\A(#{$first_names})/]#line.match(/\b(LLC|Inc|Co(rp)?s?|Ltd|and)\b\.{0,1}/)

		#Correct word ordering when like this: 'Last, First Middle(, suffix)?'
		line.gsub!( /\A\b([\w\s\.]+),\s*([\w\s\.]+)(,?\s+(?:#{$suffixes}))/i, '\2 \1\3') unless line[$business_suffixes] or line[/and/i] or line[/\A(#{$first_names})/]#line.match(/\b(LLC|Inc|Co(rp)?s?|Ltd|and)\b\.{0,1}/)

		#removing comma from before jr. or sr.
		line.gsub!( /,\s+(jr|sr)\b\.*/i, ' \1.' )
		
		#Normalize the line by capitalizing the first letter of each word
		line = normalize(line)
		
		#Capitalize 'the', etc., if first word of line put through this method.
		line = capitalize_first_letter(line)
		
		#Remove comma before III, IV, V, VI, etc., and upcase
		line = line.gsub( /,\s+(iii|iv|v|vi|vii|viii|ix|x)\b\.*/i, ' \1' ).gsub( /\b(iii?|iv|v|vi|vii?i?|ix|xi?i?)\b\.*/i) {|match| "#{match.upcase}"}
		
		#Correct word ordering when like this: 'Last, First Middle'
		line.gsub!( /\A(\S+\b(?:\s+#{$suffixes})?),\s*(.*)/i, '\2 \1') unless line[$business_suffixes] or line[/and/i] or line[/\A(#{$first_names})/]#line.match(/\b(LLC|Inc|Co(rp)?s?|Ltd|and)\.{0,1}\b/)
		
		#~ (?:van|de(?:\slos)?|la|da)
		
		#Correcting word order like this: 'Last    First    Middle'
		line = line.gsub( /\A(\b[^\t]+\b)(?:\s{4}|\t)+(\b\S+\b)(?:\s{4}|\t)+(\b[\S\.]+)\Z/i, '\2 \3 \1' ).gsub( /\A(\b[^\t]+\b)(?:\s{4}|\t)+(\b\S+\b)/i, '\2 \1' ) unless line[/\A(#{$first_names})/]
		
		#Period with middle initial
		line = Name.middle_initial(line)
    #Capitalize middle initial
		line = line.gsub(/\s([a-z])\.\s/){|initial| initial.upcase}
		
		
		#double-space elimination
		line = double_space_elimination(line)
		
		#Format suffixes according to AP style
		line = Name.format_suffixes(line)
		
		return line
		
	end

	def Name.real_estate_names(name)
		name.gsub!('&amp;', '&')
		name.gsub!('&#39;', "'")
		name = name.sub(/^\b([A-Za-z\-\']+)\b,? \b([A-Za-z\-\']+)\b \b([A-Za-z])\b\s*\&\s*\b([A-Za-z\-\']+)\b \b([A-Za-z]+)\b/i, '\1 \2 \3 & \1 \4 \5')
		components = name.split(/\b(etux|etals?|tru?st?e?e?|etvir)\b|(\&)/i)
		output = ''
		components.each do |name|
			name = normalize(name)
			if(name !~ /\b(etux|etals?|tru?st?e?e?|etvir)\b/i) and !name.match($business_flags) and !name.match(/^\s*[A-Za-z]\s*$/)
				name.sub!(/^\s*\b([A-Za-z\-\']+)\b,?\s*/i, '\1, ')
				name.sub!(/^\s*\b([A-Za-z\-\']+), (.*)$/i, '\2 \1')
				name.gsub!(/\b([A-Za-z])\b(?!\')/){|m| m.capitalize + '.'}
				name.gsub!(/(.*)\b(Jr\b\.?|Sr\b\.?|III?\b|IV\b|IX\b|VI\b)(.*)/i, '\1 \3 \2')
				name.gsub!(/\b(Jr\b|Sr\b)\.?/){|c| c.capitalize + '.'}
				name.gsub!(/(?<=\')s\b/, "'s")
				name.gsub!(/\s{2,}/, ' ')

			else
				name.sub!(/\s*\betux\b\s*/i, '(and wife)')
				name.sub!(/\s*\betvir\b\s*/i, '(and husband)')
				name.sub!(/\s*\btru?st?e?e?\b\s*/i, '(trustee)')
				name.sub!(/\s*\betals?\b\s*/i, '(and others)')
			end
			output = output + '; ' + name
		end
		output.sub!(/\s*\&\s*/, 'and')
		output.sub!(/\s*\;/, ';')
		while(output =~ /\;\s*\(/i)
			output.gsub!(/\s*\;\s*\(/, ' (')
		end
		output.gsub!(/\;\s*and\b\s*\;?\s*/, ' and ')
		output.sub!(/^\s*\;\s*/, '')
		output = output.sub(/(.*)\s*\bestate(?: of)?\b\s*$/i){|c| c.sub!(/\s*\bestate(?: of)?\b\s*$/i, ''); "Estate of " + real_estate_names(c)}
		output.gsub!(/\s{2,}/, ' ')
		output.gsub!(/\binc\b\.?/i, 'Inc.')
		output.gsub!(/\bLLC\b/i, 'LLC')
		output.gsub!(/\b(III?|IV|IX|VI|NA)\b/i){|c| c.upcase}
		if(output =~ / and /)
			output.sub!(/\(trustee\)\s*$/, '(trustees)')
		end 
		return output
	end

#'St.' to 'Saint'
def Name.to_saint(line)
	line = line.gsub( $saint_regex, 'Saint \1' )
	return line
end

#'Saint' to 'St.'
def Name.from_saint(line)
	line = line.gsub( /\bsaint\b/i, 'St.')
	return line
end

end
#End Name module.
#-------------------------------------------------------------------

#-------------------------------------------------------------------
#Begin date module
module Dates
	def Dates.date_standardization (date)
		#common formats
		output = date
		output.sub!(/(\d{4})(?:-|\/|\\| |\#)(\d{1,2})(?:-|\/|\\| |\#)(\d{1,2})/, '\1-\2-\3')
		output.sub!(/(\d{1,2})(?:-|\/|\\| |\#)(\d{1,2})(?:-|\/|\\| |\#)(\d{4})/, '\3-\1-\2')
		output.gsub!(/\b(\d{1})\b/, '0\1')
		output.sub!(/^\s*(\d{4})-(\d{2})-(\d{2})\s*$/){|string| "#{month_to_AP($2)} #{$3}, #{$1}"}
		return output
	end

	def Dates.month_to_AP(number)
		return $months[number]
	end

	def Dates.month_to_AP_regex(number)
		number.sub!(/\b0?1\b/, 'Jan.')
		number.sub!(/\b0?2\b/, 'Feb.')
		number.sub!(/\b0?3\b/, 'Mar.')
		number.sub!(/\b0?4\b/, 'Apr.')
		number.sub!(/\b0?5\b/, 'May')
		number.sub!(/\b0?6\b/, 'June')
		number.sub!(/\b0?7\b/, 'July')
		number.sub!(/\b0?8\b/, 'Aug.')
		number.sub!(/\b0?9\b/, 'Sept.')
		number.sub!(/\b10\b/, 'Oct.')
		number.sub!(/\b11\b/, 'Nov.')
		number.sub!(/\b12\b/, 'Dec.')
		return number
	end

end
#End dates module
#-------------------------------------------------------------------

#-------------------------------------------------------------------
#Begin jobs module
module Jobs
	#Method for handling Canada Job Listings
	def Jobs.canada_jobs(job)
		
		#Put quotation marks around them
		if !job.match(/\-(?!time)|\,|\d+\Z|\bk\b|Enterprise/)		
			#html entities
			job = html_entities(job)

			#Lowercase all words in job title
			job = job.downcase

			#& to 'and'
			job = job.gsub( /\b\&\b/i, 'and' )

			#Slashes replaced with 'or'
			job = job.gsub(/\s*\/\s*/, ' or ' )

			#part-time, full-time considerations
			job = job.gsub( /\bp(art)?\s*\-?\/?\s*t(ime)?\b/i, 'part-time' ).gsub( /\bf(ull)?\s*\-?\/?\s*t(ime)?\b/i, 'full-time' ).gsub( /\btemp(?:orary)?\b\.?\s*(\bpart-time|full-time)/i, 'temporary, \1' )

			#Remove what's in parentheses
			job = job.gsub( /\([\w\s]+\)/i, '' )

			#miscellaneous changes, acronyms, recapitalization, etc.
			job = job.gsub( /\bsr\b/i, 'senior' ).gsub( /\*/i, '' ).gsub( /\bi\b/i, 'I' ).gsub( /\b([^aeiouy\s]{2,})\b/i) {|w| w.upcase}.gsub( /\bsqa\b/i) {|w| w.upcase}.gsub( /^(it|is)\b/i) {|w| w.upcase}.gsub( /(\biii?\b)/i) {|w| w.upcase}.gsub( /\bRN\b/i, 'registered nurse' ).gsub( /\bvp\b/i, 'vice president' ).gsub( /\bcoo\b/i, 'chief operating officer' ).gsub( /\bj(ava|avascript)\b/i, 'J\1' ).gsub( /\bunix\b/i, 'Unix' ).gsub( /ascii/i) {|w| w.upcase}.gsub( /\binternet\b/i, 'Internet' ).gsub( /\burl\b/i, 'URL' ).gsub( /\bandroid\b/i, 'Android' ).gsub( /\bu(nited)?\s*\.?\s*s(tates)?\b\.?(?=..)/, 'U.S.' )

		else 
			job = job.sub( /(.*)/, '\"\1\"' )
		end
	end

	#Method for selecting job categories formatted like this: 'Business,Transportation and Logistics,Trucking' => 'trucking'
	def Jobs.dc_job_category(category)
		
		#lowercase all characters
		category = category.downcase

		#drop all categories except the most specific
		category = category.gsub(/(?:.*)\,([^\,]+)\Z/i, '\1' )
	end

	def Jobs.job_type(type)

		#part-time, full-time considerations
		type = type.gsub( /p(art)?\s*\-?\/?\s*t(ime)?/i, 'part-time' ).gsub( /f(ull)?\s*\-?\/?\s*t(ime)?/i, 'full-time')
	end

end
#End jobs module
#-------------------------------------------------------------------

#-------------------------------------------------------------------
#Module for money and numbers
module Numbers
	def Numbers.num_to_words(number)
		number = number.to_i
		return $single_digit[number]
	end

	#take a number -- "234233542" or "234345323.2343" -- and separate by commas, leaving decimal unchanged.
	def Numbers.numbers_add_commas(value)
		value = value.to_s

	  #shield the decimals from comma introduction (store separate, add again at the end)
	  decimal = ""
	  decimal = value[/\.\d+\Z/]
	  value = value.sub(/\.\d+\Z/, '')
	  
	  #add commas in correct places
	  value.reverse!
	  ary = value.scan(/.{1,3}/)
	  output = ary.join(",")
	  value = output.reverse
	  
	  #reintroduce decimal
	  value = value << decimal.to_s
	  
	  return value
	end
	
	def Numbers.phone_formatting(input)
		input = '' if input == nil
		output = Array.new
		array = input.split(/,/)
		array.each do |input|
	    input = input.sub(/^\s*\+1\s*/, '')
	    input = input.gsub(/\.+\s*$/, '')
	    input = input.gsub(/^\s*\.\s*/, '')
			input = input.sub(/^\s*none\s*$/i, '').sub(/^\s*no phone\s*$/i, '').sub(/^\s*N\/A\s*$/i, '').sub(/^\s*NULL\s*$/, '').sub(/\((\d+)\)\s*$/, ' EXT \1')
			input = input.sub(/^(phone:?|fax:?|office:?)\s*/i, '').sub(/(phone:?|fax:?|office:?)\s*$/i, '').sub(/^\s*\(\s*\)\s*$/, '').sub(/\(\s*$/, '')
			input = input.gsub(/^(\b1\b)?(?: +|-+|\.+|)?\(?(\d{3})(?:\)| +|-+|\) |\.+|)(\d{3})(?:\.+| +|-+|)(\d{4})\s*(\b(?:ext|x)\.?\s*\d+)?\s*$/i, '\1-\2-\3-\4 \5').sub(/^\s*-\s*/, '').sub(/^800-/, '1-800-').sub(/\s*$/, '').sub(/^\s*/, '')
			input = input.gsub(/ (?:ext|x)\.?\s*(\d+)\s*$/i, ' ext. \1')
			output << input
		end
		input = ''
		output.each do |out|
			input = input + ', ' + out
		end
		input = input.sub(/^\s*,\s*/, '')
		input = input.sub(/\s,\s*$/, '')
		input = input.gsub(/\s{2,}/, ' ')
		return input
	end
	
	def Numbers.overeaters_meetings(string)
		string = string.sub(/(.*) at (.*)/, '\2, \1').sub(/^0/, '')
		return string
	end

	#Format quantities of money *if* originally formatted in one of the following ways:
	#1. Any combination of only numbers, commas, and/or a decimal point (21323423423, 23423423324.000, 23423423.59684, 234,234.00, 234,234,234,234)
	#2. The above surrounded surrounded by other characters (sdf23434345234fjdka, ADS234,234,234.00KFDAE---)
	#3. The value prepended by a dollar sign ($234345345)
	def Numbers.money(input)
		puts input
		if input == nil or input == '' or input[/^[\$]+$/]
			return ''
		end
	  #convert to string:
	  monetary_value = input.to_s

	  #remove letters before or after value.
	  monetary_value = monetary_value.sub(/\A(?:[^\d]{0,})(\d[\,\d]+(?:\.{0,1}\d{0,}))(?:\D{0,})/i, '\1')

	  #remove commas
	  monetary_value = monetary_value.gsub(/\,/, '')

	  #dele decimals with only zeros
	  monetary_value = monetary_value.sub(/\.0+\Z/, '')

	  #Add commas
	  monetary_value = Numbers.numbers_add_commas(monetary_value)

	  #decimal formatting
	  monetary_value = monetary_value.gsub(/\.(\d{2})\d+\Z/, '.\1').gsub(/\.(\d)\Z/, '.\10')

	  #add dollar sign before input
	  monetary_value.prepend("$")
	  return monetary_value  
	end

end
#End module for money and numbers
#-------------------------------------------------------------------

#-------------------------------------------------------------------
#Begin module for charges
module Charges
	def Charges.crimelist(crimes, logic)
	output = 'arrested on charges of '
	counts = Hash.new(0)
	crimes.each do |crime|
		counts[crime] += 1
	end
	crimes.each do |crime|
		holder = crime
		if counts[crime] < 2
			crime = rungen7(logic, crime)
			if crime == 'INSUFFICIENT'
				output = output + "\"#{holder}\"~ "
			elsif crime != nil
				output = output + crime + "~ "
			elsif crime == nil
			end
		else
			crime = rungen7(logic, crime)
			if crime == 'INSUFFICIENT'
				output = output + "#{num_to_words(counts[holder])} counts of \"#{holder}\"~ "
			elsif crime != nil
				output = output + "#{num_to_words(counts[holder])} counts of #{crime}~ "
			elsif crime == nil
			end
		end
	end
	while(output =~ /(~|^|^arrested on charges of)([^~]+)~(.*)~\2~ /)
		output = output.gsub(/(~|^|^arrested on charges of)([^~]+)~(.*)~\2~ /, '\1\2~\3~ ')
	end
	output = output.sub(/\~\s*$/, '')
	output = output.sub(/\~([^\~]+)$/, ' and \1')
	puts ">>>#{output}"
	output = output.gsub(/\~/, ', ')
	output = output.gsub(/\s{2,}/, ' ')
	return output
end
end
#End module for charges
#-------------------------------------------------------------------
