# :nodoc:
module Veritrans
	# hold version number of this library
	# it use class methods to generate it 
	#
  # Example:
  #
	#   Veritrans::Version.to_s
	class Version

		class <<self

	    private

			# :nodoc:
			def major
				1
			end

			# :nodoc:
			def minor
				0
			end

			# :nodoc:
			def patch
				0
			end

			# :nodoc:
			def pre
				nil
			end
		end

		# ==== Return:
		#
		# * <tt>String</tt> - version information
		def self.to_s
			[major, minor, patch, pre].compact.join('.')
		end
  end
end
