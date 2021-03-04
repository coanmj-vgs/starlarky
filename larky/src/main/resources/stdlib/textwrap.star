def TextWrapper:
    """

        Object for wrapping/filling text.  The public interface consists of
        the wrap() and fill() methods; the other methods are just there for
        subclasses to override in order to tweak the default behaviour.
        If you want to completely replace the main wrapping algorithm,
        you'll probably have to override _wrap_chunks().

        Several instance attributes control various aspects of wrapping:
          width (default: 70)
            the maximum width of wrapped lines (unless break_long_words
            is false)
          initial_indent (default: "")
            string that will be prepended to the first line of wrapped
            output.  Counts towards the line's width.
          subsequent_indent (default: "")
            string that will be prepended to all lines save the first
            of wrapped output; also counts towards each line's width.
          expand_tabs (default: true)
            Expand tabs in input text to spaces before further processing.
            Each tab will become 0 .. 'tabsize' spaces, depending on its position
            in its line.  If false, each tab is treated as a single character.
          tabsize (default: 8)
            Expand tabs in input text to 0 .. 'tabsize' spaces, unless
            'expand_tabs' is false.
          replace_whitespace (default: true)
            Replace all whitespace characters in the input text by spaces
            after tab expansion.  Note that if expand_tabs is false and
            replace_whitespace is true, every tab will be converted to a
            single space!
          fix_sentence_endings (default: false)
            Ensure that sentence-ending punctuation is always followed
            by two spaces.  Off by default because the algorithm is
            (unavoidably) imperfect.
          break_long_words (default: true)
            Break words longer than 'width'.  If false, those words will not
            be broken, and some lines might be longer than 'width'.
          break_on_hyphens (default: true)
            Allow breaking hyphenated words. If true, wrapping will occur
            preferably on whitespaces and right after hyphens part of
            compound words.
          drop_whitespace (default: true)
            Drop leading and trailing whitespace from lines.
          max_lines (default: None)
            Truncate wrapped lines.
          placeholder (default: ' [...]')
            Append to the last line of truncated text.
    
    """
2021-03-02 20:46:43,089 : INFO : tokenize_signature : --> do i ever get here?
2021-03-02 20:46:43,089 : INFO : tokenize_signature : --> do i ever get here?
2021-03-02 20:46:43,089 : INFO : tokenize_signature : --> do i ever get here?
2021-03-02 20:46:43,090 : INFO : tokenize_signature : --> do i ever get here?
2021-03-02 20:46:43,090 : INFO : tokenize_signature : --> do i ever get here?
2021-03-02 20:46:43,090 : INFO : tokenize_signature : --> do i ever get here?
2021-03-02 20:46:43,090 : INFO : tokenize_signature : --> do i ever get here?
2021-03-02 20:46:43,090 : INFO : tokenize_signature : --> do i ever get here?
2021-03-02 20:46:43,090 : INFO : tokenize_signature : --> do i ever get here?
2021-03-02 20:46:43,090 : INFO : tokenize_signature : --> do i ever get here?
2021-03-02 20:46:43,090 : INFO : tokenize_signature : --> do i ever get here?
2021-03-02 20:46:43,090 : INFO : tokenize_signature : --> do i ever get here?
2021-03-02 20:46:43,090 : INFO : tokenize_signature : --> do i ever get here?
    def __init__(self,
                 width=70,
                 initial_indent="",
                 subsequent_indent="",
                 expand_tabs=True,
                 replace_whitespace=True,
                 fix_sentence_endings=False,
                 break_long_words=True,
                 drop_whitespace=True,
                 break_on_hyphens=True,
                 tabsize=8,
                 *,
                 max_lines=None,
                 placeholder=' [...]'):
        """
         -- Private methods -----------------------------------------------
         (possibly useful for subclasses to override)


        """
    def _munge_whitespace(self, text):
        """
        _munge_whitespace(text : string) -> string

                Munge whitespace in text: expand tabs and convert all other
                whitespace characters to spaces.  Eg. " foo\\tbar\\n\\nbaz"
                becomes " foo    bar  baz".
        
        """
    def _split(self, text):
        """
        _split(text : string) -> [string]

                Split the text to wrap into indivisible chunks.  Chunks are
                not quite the same as words; see _wrap_chunks() for full
                details.  As an example, the text
                  Look, goof-ball -- use the -b option!
                breaks into the following chunks:
                  'Look,', ' ', 'goof-', 'ball', ' ', '--', ' ',
                  'use', ' ', 'the', ' ', '-b', ' ', 'option!'
                if break_on_hyphens is True, or in:
                  'Look,', ' ', 'goof-ball', ' ', '--', ' ',
                  'use', ' ', 'the', ' ', '-b', ' ', option!'
                otherwise.
        
        """
    def _fix_sentence_endings(self, chunks):
        """
        _fix_sentence_endings(chunks : [string])

                Correct for sentence endings buried in 'chunks'.  Eg. when the
                original text contains "... foo.\\nBar ...", munge_whitespace()
                and split() will convert that to [..., "foo.", " ", "Bar", ...]
                which has one too few spaces; this method simply changes the one
                space to two.
        
        """
    def _handle_long_word(self, reversed_chunks, cur_line, cur_len, width):
        """
        _handle_long_word(chunks : [string],
                                     cur_line : [string],
                                     cur_len : int, width : int)

                Handle a chunk of text (most likely a word, not whitespace) that
                is too long to fit in any line.
        
        """
    def _wrap_chunks(self, chunks):
        """
        _wrap_chunks(chunks : [string]) -> [string]

                Wrap a sequence of text chunks and return a list of lines of
                length 'self.width' or less.  (If 'break_long_words' is false,
                some lines may be longer than this.)  Chunks correspond roughly
                to words and the whitespace between them: each chunk is
                indivisible (modulo 'break_long_words'), but a line break can
                come between any two chunks.  Chunks should not have internal
                whitespace; ie. a chunk is either all whitespace or a "word".
                Whitespace chunks will be removed from the beginning and end of
                lines, but apart from that whitespace is preserved.
        
        """
    def _split_chunks(self, text):
        """
         -- Public interface ----------------------------------------------


        """
    def wrap(self, text):
        """
        wrap(text : string) -> [string]

                Reformat the single paragraph in 'text' so it fits in lines of
                no more than 'self.width' columns, and return a list of wrapped
                lines.  Tabs in 'text' are expanded with string.expandtabs(),
                and all other whitespace characters (including newline) are
                converted to space.
        
        """
    def fill(self, text):
        """
        fill(text : string) -> string

                Reformat the single paragraph in 'text' to fit in lines of no
                more than 'self.width' columns, and return a new string
                containing the entire wrapped paragraph.
        
        """
def wrap(text, width=70, **kwargs):
    """
    Wrap a single paragraph of text, returning a list of wrapped lines.

        Reformat the single paragraph in 'text' so it fits in lines of no
        more than 'width' columns, and return a list of wrapped lines.  By
        default, tabs in 'text' are expanded with string.expandtabs(), and
        all other whitespace characters (including newline) are converted to
        space.  See TextWrapper class for available keyword args to customize
        wrapping behaviour.
    
    """
def fill(text, width=70, **kwargs):
    """
    Fill a single paragraph of text, returning a new string.

        Reformat the single paragraph in 'text' to fit in lines of no more
        than 'width' columns, and return a new string containing the entire
        wrapped paragraph.  As with wrap(), tabs are expanded and other
        whitespace characters converted to space.  See TextWrapper class for
        available keyword args to customize wrapping behaviour.
    
    """
def shorten(text, width, **kwargs):
    """
    Collapse and truncate the given text to fit in the given width.

        The text first has its whitespace collapsed.  If it then fits in
        the *width*, it is returned as is.  Otherwise, as many words
        as possible are joined and then the placeholder is appended::

            >>> textwrap.shorten("Hello  world!", width=12)
            'Hello world!'
            >>> textwrap.shorten("Hello  world!", width=11)
            'Hello [...]'
    
    """
def dedent(text):
    """
    Remove any common leading whitespace from every line in `text`.

        This can be used to make triple-quoted strings line up with the left
        edge of the display, while still presenting them in the source code
        in indented form.

        Note that tabs and spaces are both treated as whitespace, but they
        are not equal: the lines "  hello" and "\\thello" are
        considered to have no common leading whitespace.

        Entirely blank lines are normalized to a newline character.
    
    """
def indent(text, prefix, predicate=None):
    """
    Adds 'prefix' to the beginning of selected lines in 'text'.

        If 'predicate' is provided, 'prefix' will only be added to the lines
        where 'predicate(line)' is True. If 'predicate' is not provided,
        it will default to adding 'prefix' to all non-empty lines that do not
        consist solely of whitespace characters.
    
    """
        def predicate(line):
            """
            ''
            """