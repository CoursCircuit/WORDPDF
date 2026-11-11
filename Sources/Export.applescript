-- Resolve Word's scripting terminology from the installed copy at runtime.
on exportpdf(wordPath, inputPath, outputPath)
	set inputFile to POSIX file inputPath as alias
	set outputFile to POSIX file outputPath
	set targetDoc to missing value
	using terms from application id "com.microsoft.Word"
		tell application wordPath
			try
				with timeout of 600 seconds
					open inputFile read only true add to recent files false
					set openedDoc to active document
					if (full name of openedDoc as alias) is not inputFile then ¬
						error "Word n’a pas ouvert la copie de travail."
					set targetDoc to openedDoc
					save as targetDoc file name outputFile file format format PDF add to recent files false
				end timeout
			on error errorText number errorNumber
				if targetDoc is not missing value then
					try
						close targetDoc saving no
					end try
				end if
				error errorText number errorNumber
			end try
			close targetDoc saving no
		end tell
	end using terms from
end exportpdf
