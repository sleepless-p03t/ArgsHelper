#!/usr/bin/ruby

class Hash

	def has_blank?
		self.values.any?{|v| v.nil? || v.length == 0}
	end
	
	def contains_keys?(keys)
		keys.any? do |key|
			self.key?(key)
		end
	end
end

# @author sleepless-p03t
class ArgsHelper
	
	class BiHash
	
		def initialize
			@forward = {}
			@reverse = {}
		end

		def insert(k, v)
			@forward[k] = v
			@reverse[v] = k
		end

		def get_value(v)
			if @forward.has_key?(v)
				return @forward[v]
			elsif @reverse.has_key?(v)
				return @reverse[v]
			else
				return nil
			end
		end
	end

	private_constant :BiHash
	attr_reader :BiHash
	
	# Initialize the helper
	# @param args [Array] Argument array to process
	def initialize(args)
		@args_a = args
		@args = nil
		@skeys = []
		@lkeys = []
		@kvals = []
		@kdescriptions = []

		@static = {}

		@no_vals = []

		@flag_pairs = BiHash.new
	end

	# Define specific options available for a certain flag
	# @param sflag [String] Short flag
	# @param lflag [String] Long flag
	# @param opts [Array] Flag options
	def add_static_flag_opts(sflag = nil, lflag = nil, opts = [])
		if sflag != nil
			@static[sflag] = opts
		end

		if lflag != nil
			@static[lflag] = opts
		end
	end

	# Add argument keys
	# @param skey [Array, String] Short keys or short key
	# @param lkey [Array, String] Long keys or long key
	# @param kval [Array, String] Value description(s) or possible value(s)
	# @param kdescription [Array, String] Key description(s)
	def add_keys(skey = nil, lkey = nil, kval = nil, kdescription = nil)

		arrays = [ skey.is_a?(Array) || skey == nil, lkey.is_a?(Array) || lkey == nil, kval.is_a?(Array) || kval == nil, kdescription.is_a?(Array) || kdescription == nil ]
		strings = [ skey.is_a?(String) || skey == nil, lkey.is_a?(String) || lkey == nil, kval.is_a?(String) || kval == nil, kdescription.is_a?(String) || kdescription == nil ]

		if arrays.include?(true) && arrays.include?(false)
			puts "Mismatched types: Expected either Arrays or Strings"
			exit
		end

		if arrays.include?(true)
			skey = [] if skey == nil
			lkey = [] if lkey == nil
			kval = [] if kval == nil
			kdescription = [] if kdescription == nil

			if skey != []
				skey.each_with_index do |sk, i|
					if lkey != []
						@flag_pairs.insert(sk, lkey[i])
					else
						@flag_pairs.insert(sk, nil)
					end
				end
			end
			
			if lkey != [] && skey == []
				lkey.each do |lk|
					@flag_pairs.insert(lk, nil)
				end
			end

			@skeys = skey
			@lkeys = lkey
			@kvals = kval
			@kdescriptions = kdescription
			return
		end

		if strings.include?(true)
			skey = '' if skey == nil
			lkey = '' if lkey == nil
			kval = '' if kval == nil
			kdescription = '' if kdescription == nil
			@skeys.push(skey)
			@lkeys.push(lkey)
			@kvals.push(kval)
			@kdescriptions.push(kdescription)
			if skey != ''
				@flag_pairs.insert(skey, lkey)
			end
			
			if lkey != '' && skey == ''
				@flag_pairs.insert(lkey, skey)
			end
			return
		end
	end

	# Flag doesn't have a corresponding value
	# @param sflag [String] Short flag
	# @param lflag [String] Long flag
	def set_no_value(sflag = nil, lflag = nil)
		if sflag == nil && lflag == nil
			return
		end

		if sflag != nil
			if @args_a.include?(sflag)
				index = @args_a.find_index(sflag)
				@args_a = @args_a.insert(index + 1, nil)
				@no_vals.push(sflag)
			end
		end
		
		if lflag != nil
			if @args_a.include?(lflag)
				index = @args_a.find_index(lflag)
				@args_a = @args_a.insert(index + 1, nil)
				@no_vals.push(lflag)
			end
		end
	end
	
	# Main processing of argument flags
	# Handles errors in flags and flag values
	def parse_args
		@args = @args_a.each_slice(2).to_a.inject({}) { |h, k| h[k[0]] = k[1]; h }
		
		if remove_keys(@no_vals).has_blank?
			puts "Missing argument(s)"
			exit
		end			

		keys = @skeys + @lkeys

		@args.each do |k, v|
			if !keys.include?(k)
				puts "Unknown option `#{k}'"
				exit
			end

			if keys.include?(v)
				puts "Missing values for `#{k}' and `#{v}'"
				exit
			end

			if v != nil
				if v.start_with?('-')
					puts "Warning: Value of `#{k}' appears to be a flag"
				end

				if @static.has_key?(k)
					if !@static[k].include?(v)
						puts "Unknown option `#{v}' for `#{k}'"
						exit
					end
				end
			end
		end
	end
	
	# Returns whether a flag has been found
	# @param flag [String] Short or long flag
	# @return [Boolean] If argument passed from command line
	def has_arg?(flag)
		return (@args.has_key?(flag) || @args.has_key?(fp))
	end
	
	# Returns the value of a given flag
	# @param flag [String] Short or long flag
	# @return [String, nil] 
	def get_value(flag)
		fp = @flag_pairs.get_value(flag)
		if !@no_vals.include?(flag)
			if @args.has_key?(flag)
				return @args[flag]
			elsif @args.has_key?(fp) && fp != nil
				return @args[fp]
			else
				return nil
			end
		else
			return nil
		end
	end

	# Display a help table
	def show_default_table
		show_table("Options", 2, @skeys, @lkeys, @kvals, @kdescriptions)
	end
	
	# Display contents in a table
	# @param title [String] Table title
	# @param pad [Integer] Minimum space between left and right sides of column
	# @param cols [Array] Array(s) of table column data
	def show_table(title, pad, *cols)
		mlcols = []
		cols = cols.map { |x| x == [] ? nil : x }
		cols.compact!
		cols.each do |c|
			if c.is_a? Array
				mlcols.push(c.map(&:to_s).max_by(&:length).length)
			elsif c.is_a? String
				mlcols.push(c.length)
			elsif c.is_a? Numeric
				mlcols.push(c.to_s.length)
			end
		end

		clens = []
		mlcols.each { |m| clens.push((pad * 2) + m) }
		rows = cols.transpose

		sum = clens.inject(0){ |s, x| s + x }

		sum += cols.length - 1
		tlen = title.length
		tpadl = (sum - tlen) / 2
		tpadr = sum - (tlen + tpadl)

		print '+'
		print '-' * sum
		puts '+'
		print '|'
		print ' ' * tpadl
		print title
		print ' ' * tpadr
		puts '|'
		clens.each do |l|
			print '+'
			print '-' * l
		end
		puts '+'

		rows.each do |row|
			row.each_with_index do |col, i|
				len = clens[i] - col.length - pad
				print '|'
				print ' ' * pad
				print col
				print ' ' * len
			end
			puts '|'
		end

		clens.each do |l|
			print '+'
			print '-' * l
		end
		puts '+'
	end

	private
	def remove_keys(keys)
		args = @args
		keys.each { |k| args.delete(k) }
		return args
	end
end
