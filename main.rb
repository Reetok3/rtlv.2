require 'byebug'
class Rtl
	def initialize(code)
		# コード
		@code = code
		# コードのスペース区切り
		@chomp = @code.split(" ")
		@tokenVar = []
		@token = []
		@typeVar = []
		# tof TrueOrFalse
		# int Integer
		# char String
		# func Function
		# equl Equal
		# var Var
		@var = {}
		# @var = {a => [ "a" ,"char" ] , b => [ 123 ,"int" ]}
		srand(Time.now.to_i)
	end

	def lexer
		i=0
		if ARGV[1] == "debug"
			puts "------------------------------------------------------------------------------------------------------"
			puts "@chomp : "
			p @chomp
			puts "-------------------------------------------------------------------------------------------------------"
		end
		while true do
			if ARGV[1] == "debug"
				puts "#{i}回目："
				p @chomp[i]
				sleep 0.25
			end
			case @chomp[i]
			when /\w==\w/ || /\w!=\w/ || /\w<\w/ || /\w>\w/
				# COND 条件式
				@token.push("COND")
				@tokenVar.push(@chomp[i])
				@typeVar.push("tof")
			when "true" || "false"
				@token.push("TOF")
				@tokenVar.push(@chomp[i])
				@typeVar.push("tof")
			when /"([\w\s,!?\.=]*)"/
				# STRING 文字列
				@token.push("STRING")
				@tokenVar.push($1)
				@typeVar.push("char")
			when /(\w(\+|-))+\w/
				@token.push("EXP")
				@tokenVar.push(@chomp[i])
				@typeVar.push("int")
			when /\d+/
				# INTEGER 数値
				@token.push("INTEGER")
				@tokenVar.push(@chomp[i])
				@typeVar.push("int")
			when "print"
				# print文
				@token.push("PRINT")
				@tokenVar.push("print")
				@typeVar.push("func")
			when "integer"
				@token.push("CNV_I")
				@tokenVar.push("integer")
				@typeVar.push("func")
			when "string"
				@token.push("CNV_S")
				@tokenVar.push("STRING")
				@typeVar.push("func")
			when "random"
				# 乱数生成
				@token.push("RANDOM")
				@tokenVar.push("random")
				@typeVar.push("func")
			when "input"
				@token.push("INPUT")
				@tpkenVar.push("input")
				@typeVar.push("char")
			when "chomp"
				@token.push("CHOMP")
				@tokenVar.push("chomp")
				@typeVar.push("char")
			when "do" || "then"
				# while||if開始
				@token.push("DO")
				@tokenVar.push("do")
				@typeVar.push("func")
			when "if"
				# if文
				@token.push("IF")
				@tokenVar.push("if")
				@typeVar.push("func")
			when "endif"
				# if文Close
				@token.push("IF_END")
				@tokenVar.push("endif")
				@typeVar.push("func")
			when "while"
				@token.push("WHILE")
				@tokenVar.push("while")
				@typeVar.push("func")
			when "endwhile"
				# while文Close
				@token.push("WHILE_END")
				@tokenVar.push("endwhile")
				@typeVar.push("func")
			when "loop"
				@token.push("LOOP")
				@tokenVar.push("loop")
				@typeVar.push("func")
			when "endloop"
				@token.push("LOOP_END")
				@tokenVar.push("endloop")
				@typeVar.push("func")
			when "exit"
				@token.push("EXIT")
				@tokenVar.push("exit")
				@typeVar.push("func")
			when "="
				# 変数代入イコール
				@token.push("EQUAL")
				@tokenVar.push("=")
				@typeVar.push("equl")
			when nil
				# 終了
				break
			when "//"
				i+=1
			when "/*"
				i+=1
				while chomp[i] != "*/"
					i+=1
				end
			else
				if @chomp[i] =~ /^[a-z]\w*/ && @chomp[i] =~ /[a-zA-Z0-9]\z/
					@token.push("VAR")
					@tokenVar.push(@chomp[i])
					@typeVar.push("var")
				else
					error("字句エラー #{@chomp[i]}というメソッドはありません。")
				end
			end
			if ARGV[1] == "debug"
				p @token[i]
			end
			i+=1
		end
		if ARGV[1] == "debug"
			puts "------------------------------------------------------------------------------------------------------"
			puts "@token : "
			p @token
			puts "@tokenVar : "
			p @tokenVar
			puts "------------------------------------------------------------------------------------------------------"
		end
		return @token.size
	end

	def run(s,f)
		i=s
		while true do
			if ARGV[1] == "debug"
				puts "#{i}回目："
				p @token[i]
				sleep 0.25
			end
			case @token[i]
			when "PRINT"
				puts getVar(@token[i],@tokenVar[i],@typeVar[i],i)
			when "VAR"
				if @token[i+1] == "EQUAL"
					i+=2
					@var[@tokenVar[i-2]] = getVar(@token[i],@tokenVar[i],@typeVar[i],i)
				end
			when "EXIT"
			when "WHILE"
			when "IF"
			when "LOOP"
			when nil
				break
			end
			#			case @token[i]
			#			when "PRINT"
			#				i+=1
			#				case @token[i]
			#				when "STRING"
			#					# PRINT STRING
			#					puts @tokenVar[i]
			#				when "RANDOM"
			#					i+=1
			#					if @token[i] == "INTEGER" || @token[i] == "VAR"
			#						# PRINT RANDOM INTEGER || PRINT RANDOM VAR
			#						p @tokenVar[i]
			#						p getVar(@tokenVar[i])
			#						puts rand(getVar(@tokenVar[i]).to_i)
			#					else
			#						error("文法エラー #{@token[i]}以降の組み合わせは見つかりませんでした。1")
			#					end
			#				when "EXP"
			#					# PRINT EXP
			#					puts getValue(@tokenVar[i])
			#				when "COND"
			#					# PRINT COND
			#					puts evalCond(@tokenVar[i].split(/(==|!=|<|>)/)[0],
			#						      @tokenVar[i].split(/(==|!=|<|>)/)[1],
			#						      @tokenVar[i].split(/(==|!=|<|>)/)[2])
			#				when "VAR"
			#					# PRINT VAR
			#					puts getVar(@tokenVar[i])
			#				when "INTEGER"
			#					# PRINT INTEGER
			#					puts @tokenVar[i].to_i
			#				when "CNV_I"
			#					i+=1
			#					if @token[i] == "VAR" || @token[i] == "STRING" || @token[i] == "CNV_S"
			#						puts getVar(@tokenVar[i])
			#					end
			#				when "CNV_S"
			#					i+=1
			#					if @token[i] == "VAR" || @token[i] == "INTEGER"
			#						puts getVar(@tokeVar[i].to_a)
			#					end
			#				else
			#					error("文法エラー #{@token[i]}以降の組み合わせは見つかりませんでした。3")
			#				end
			#			when "VAR"
			#				i+=1
			#				if @token[i] == "EQUAL"
			#					i+=1
			#					case @token[i]
			#					when "STRING"
			#						# VAR EQUAL STRING
			#						@var[@tokenVar[i-2]] = @tokenVar[i]
			#					when "VAR"
			#						# VAR EQUAL VAR
			#						@var[@tokenVar[i-2]] = getVar(@tokenVar[i])
			#					when "EXP"
			#						# VAR EQUAL EXP
			#						@var[@tokenVar[i-2]] = getValue(@tokenVar[i+2])
			#					when "COND"
			#						# VAR EQUAL COND
			#						@var[@tokenVar[i-2]] = evalCond(@tokenVar[i].split(/(==|!=|<|>)/)[0],
			#										@tokenVar[i].split(/(==|!=|<|>)/)[1],
			#										@tokenVar[i].split(/(==|!=|<|>)/)[2])
			#					when "INTEGER"
			#						# VAR EQUAL INTEGER
			#						@var[@tokenVar[i-2]] = @tokenVar[i].to_i
			#					when "CNV_I"
			#						i+=1
			#						if @token[i] == "VAR" || @token[i] == "STRING" || @token[i] == "INPUT" || @token[i] == "CHOMP"
			#							puts getVar(@var[@tokenVar[i]].to_i)
			#						end
			#					when "CNV_S"
			#						i+=1
			#						if @token[i] == "VAR" || @token[i] == "INTEGER"
			#							puts getVar(@var[@tokeVar[i]].to_a)
			#
			#						end
			#					when "RANDOM"
			#						i+=1
			#						if @token[i] == "INTEGER" || @token[i] == "VAR"
			#							# VAR EQUAL RANDOM INEGER || VAR EQUAL RANDOM VAR
			#							@var[@tokenVar[i-3]] = rand(getVar(@tokenVar[i]).to_i)
			#						else
			#							error("文法エラー #{@token[i]}以降の組み合わせは見つかりませんでした。5")
			#						end
			#					else
			#						error("文法エラー #{@token[i]}以降の組み合わせは見つかりませんでした。6")
			#					end
			#				else
			#					error("文法エラー #{@token[i]}以降の組み合わせは見つかりませんでした。7")
			#
			#				end
			#			when "WHILE"
			#				i+=1
			#				if @token[i] == "COND" && @tokenVar[i+1] = "DO"
			#					start=i+2
			#					finish=0
			#					testi=i+2
			#					cntr=1
			#					cntr2=i+2
			#					while cntr != 0
			#						if @token[cntr2]=="DO"
			#							cntr+=1
			#						end
			#						if @token[cntr2] == "WHILE_END" || @token[cntr2] == "IF_END" || @token[cntr2] == "LOOP_END"
			#							cntr-=1
			#						end
			#						cntr2+=1
			#					end
			#					finish=cntr2-2
			#					# if @chomp[testi] =~ /\w+/ && @chomp[testi+1] == "=" && ( @chomp[i] =~ /\w+-\d+/ || @cjomp[i] =~ /\w+\+\d+/ )
			#					# else
			#					while evalCond(@tokenVar[i].split(/(==|!=|<|>)/)[0],
			#							@tokenVar[i].split(/(==|!=|<|>)/)[1],
			#							@tokenVar[i].split(/(==|!=|<|>)/)[2])
			#						if ARGV[1] == "debug"
			#							print "whileターン"
			#							run(start,finish)
			#						end
			#					end
			#					# end
			#
			#				end
			#			when "COMMENT"
			#				i+=1
			#				if @token[i] == "DO"
			#					i+=1
			#					while true do
			#						i+=1
			#						if @token[i] == "COMMENT_END"
			#							i+=1
			#							break
			#						end
			#					end
			#				end
			#			when "IF"
			#				i+=1
			#				if @token[i] == "COND" && @token[i+1] == "DO"
			#					start=i+2
			#					finish=0
			#					cntr=1
			#					cntr2=i+1
			#					while cntr != 0
			#						if @token[cntr2]=="DO"
			#							cntr+=1
			#						end
			#						if @token[cntr2] == "WHILE_END" || @token[cntr2] == "IF_END" || @token[cntr2] == "LOOP_END"
			#							cntr-=1
			#						end
			#						cntr2+=1
			#					end
			#					finish=cntr2-1+i
			#					if evalCond(@tokenVar[i].split(/(==|!=|<|>)/)[0],
			#							@tokenVar[i].split(/(==|!=|<|>)/)[1],
			#							@tokenVar[i].split(/(==|!=|<|>)/)[2])
			#						if ARGV[1] == "debug"
			#							puts "ifターン"
			#						end
			#						run(start,finish)
			#					end
			#					i = finish
			#				end
			#			when "LOOP"
			#				i+=1
			#				if @token[i] == "DO"
			#					start=i+1
			#					finish=0
			#					cntr=1
			#					cntr2=i+1
			#					while cntr != 0
			#						if @token[cntr2]=="DO"
			#							cntr+=1
			#						end
			#						if @token[cntr2] == "WHILE_END" || @token[cntr2] == "IF_END"
			#							cntr-=1
			#						end
			#						cntr2+=1
			#					end
			#					finish=cntr2-1+i
			#					while true
			#						run(start,finish)
			#					end
			#				end
			#			when "EXIT"
			#				exit
			#			when nil
			#				break
			#			else
			#				if i == f+1
			#					break
			#				else
			#					error("文法エラー #{@token[i]}以降の組み合わせは見つかりませんでした。6")
			#				end
			#			end
			if ARGV[1] == "debug"
				puts "\n変数："
				p @var
				puts "------------------------------------------------------------------------------------------------------"
			end
			i+=1
		end
	end
	def error(c)
		puts "エラー:#{c}"
	end

	def evalCond(l,ope,r)
		if ope == "=="
			return (getVar(l) == getVar(r))
		elsif ope == "!="
			return (getVar(l) != getVar(r))
		elsif ope == "<"
			return (getVar(l) < getVar(r))
		elsif ope == ">"
			return (getVar(l) > getVar(r))
		end
	end

	# c = 5 + 5 + 5 - 6 + 4 - 7
	def getValue(exp)
		# byebug
		if exp =~ /(\+|-)/
			exp = exp.split(/(\+|-)/)
		else
			exp = [exp]
		end
		if exp[0] == ""
			exp.delete_at(0)
		end
		i=0
		# 始め  | 数    | 演算子 | 変数
		# start | value | opr    | var
		type="start"
		acc=0
		# byebug
		while i != exp.size
			if exp[i] == "+" && type != "opr"
				type = "opr"
			elsif exp[i] == "-" && type != "opr"
				type = "opr"
			elsif exp[i] =~ /\d+/ && type != "value" && type != "var"
				type = "value"
			elsif exp[i] =~ /\w+/ && type != "var" && type != "value"
				type = "var"
				exp[i] = getVar(exp[i])
			else
			end
			i+=1
		end

		#byebug
		if exp[0] != "+" && exp[0] != "-"
			exp.unshift("+")
		end
		i=0
		while i != exp.size
			if exp[i] == "+"
				i+=1
				acc += exp[i].to_i
			elsif exp[i] == "-"
				i+=1
				acc -= exp[i].to_i
			end
			i+=1
		end
		return acc
	end
	# token = a || b (へんすうめい)
	def getVar(token,tokenVar,typeVar,i)
		case token
		when "STRING"
			if token =~ /"([\w\s,!?\.=]*)"/
				return $1
			end
		when "INTEGER"
			return tokenVar.to_i
		when "COND"
			puts evalCond(tokenVar.split(/(==|!=|<|>)/)[0],
					tokenVar.split(/(==|!=|<|>)/)[1],
					tokenVar.split(/(==|!=|<|>)/)[2])
		when "CNV_I"
			return getVar(@token[i+1],@tokenVar[i+1],@typeVar[i],i+1).to_i
		when "CNV_S"
			return getVar(@token[i+1],@tokenVar[i+1],@typeVar[i],i+1).to_i
		when "RANDOM"
			return rand(getVar(@token[i+1],@tokenVar[i+1],@typeVar[i],i+1))
		when "INPUT"
			return STDIN.gets
		when "CHOMP"
			return getVar(@token[i+1],@tokenVar[i+1],@typeVar[i],i+1).chomp
		when "VAR"
			return getVar()
		end
#		if token =~ /"([\w\s,!?\.=]*)"/
#			return $1
#		elsif token =~ /(\d+)/
#			return token.to_i
#		elsif token == "INPUT"
#			return STDIN.gets
#		elsif token == "CHOMP"
#			return STDIN.gets.chomp
#		elsif @var[token] != nil
#			return @var[token]
#		else
#			# error("そのような変数な定義されていません．")
#		end
	end
end

rtl = Rtl.new(ARGF.read)
rtl.run(0,rtl.lexer-1)
# a=1
# b=1
# tof = (a == b)
# puts tof # => true

# print "Hello"
# print  "Hello"
# スペース必須
#
# 計算式では，スペース禁止
#
# 真偽判定はスペース禁止
#
# 変数は，1文字目は，小文字．2文字目は，アンダースコア・小文字・大文字・数字．最後の文字は，小文字・大文字・数字．
