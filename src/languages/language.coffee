_ = window?._ ? self?._ ? global?._ ? require 'lodash'  # rely on lodash existing, since it busts CodeCombat to browserify it--TODO

module.exports = class Language
  name: 'Abstract Language'  # Display name of the programming language
  id: 'abstract-language'  # Snake-case id of the programming language
  parserID: 'abstract-parser'
  runtimeGlobals: {}  # Like {__lua: require('lua2js').runtime}

  constructor: (@version) ->

  # Return true if we can very quickly identify a syntax error.
  obviouslyCannotTranspile: (rawCode) ->
    false

  # Return true if there are significant (non-whitespace) differences in the ASTs for a and b.
  hasChangedASTs: (a, b) ->
    true

  # Return true if a and b have the same number of lines after we strip trailing comments and whitespace.
  hasChangedLineNumbers: (a, b) ->
    # This implementation will work for languages with comments starting with //
    # TODO: handle /* */
    unless String.prototype.trimRight
      String.prototype.trimRight = -> String(@).replace /\s\s*$/, ''
    a = a.replace(/^[ \t]+\/\/.*/g, '').trimRight()
    b = b.replace(/^[ \t]+\/\/.*/g, '').trimRight()
    return a.split('\n').length isnt b.split('\n').length

  # Return an array of UserCodeProblems detected during linting.
  lint: (rawCode, aether) ->
    []

  # Return a beautified representation of the code (cleaning up indentation, etc.)
  beautify: (rawCode, aether) ->
    rawCode

  # Wrap the user code in a function. Store @wrappedCodePrefix and @wrappedCodeSuffix.
  wrap: (rawCode, aether) ->
    @wrappedCodePrefix ?= ''
    @wrappedCodeSuffix ?= ''
    @wrappedCodePrefix + rawCode + @wrappedCodeSuffix

  # Hacky McHack step for things we can't easily change via AST transforms (which preserve statement ranges).
  # TODO: Should probably refactor and get rid of this soon.
  hackCommonMistakes: (rawCode, aether) ->
    rawCode

  # Using a third-party parser, produce an AST in the standardized Mozilla format.
  parse: (code, aether) ->
    throw new Error "parse() not implemented for #{@id}."

  # Optional: if parseDammit() is implemented, then if parse() throws an error, we'll try again using parseDammit().
  # Useful for parsing incomplete code as it is being written without giving up.
  # This should never throw an error and should always return some sort of AST, even if incomplete or empty.
  #parseDammit: (code, aether) ->
