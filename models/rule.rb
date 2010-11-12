module TwitBlockr
  class Rule
	attr_accessor :name, :score

	def initialize(name, score, &blk)
	  @name = name
	  @score = score

	  @rule = blk
	end

	def call(user)
	  return @rule.call(user) if @rule.arity == 1
          return @rule.call(user,self) if @rule.arity == 2
	end

	def to_s
	  @name + " for " + @score.to_s + " points"
	end
  end

  class ScoreCalculator

	def initialize(user,rules = [])
	  @user = user
	  @rules = rules
	  @results = []
	end

	def calculate
	  [@rules.inject(0) do |sum,f|
		if true === f.call(@user)
		  @results << f
		  f.score + sum
		else
		  sum
		end
	  end, 
	  @results]
	end
  end
end
