Þ       Q     ¤   m  ,      à   ú  á   ,  Ü   5  	   7  ?   \  w   `  Ô   u  	5   l  	«   b  
   V  
{   Y  
Ò   ~  ,     «   º  ;   %  ö          3     M   e  j     Ð     ä     û          4   $  L     q               ¯     ¸   #  ×     û               1     C     U     g   H  t     ½     ×     ö   !       6     K   (  `        #  §     Ë   $  ë        #  *   B  N   2       Ä      Ø     ù        *  6   *  a          ¬     ¼   #  Ê   #  î   &       9   ,  X             -  ³     á     ÷               +     A     O     h            û  +   0  '   -  X   <     ^  Ã   ]  "   o     s  ð   [  d   K  À   Z     _  g   j  Ç   ¹  2   '  ì          -     L   v  d     Û     î          &     ?   !  \     ~          ³     Ã     Ó     ò          '     .     A     _     }        T  ±               :   /  U             0  ³     ä          #      )   @      j         #   ¤   $   È      í   2  !	     !<     !V   1  !u   )  !§     !Ñ     !í     !ú   #  "   #  ",   "  "P   !  "s   (  "     "¾     "Õ     "ê     #     #     #2     #F     #`     #w     #     #¥   !  #¿            $           D       Q       "          !       =   E       L   B      5         ?      4   3                .               N      @         ;           2   (   :       9   %           <   	   /       C       P   '   ,   K                 M                
          #   6   +   0       1       7   F             H   *      -   >   J         O   8       &          I   )                 G      A 
If no -e, --expression, -f, or --file option is given, then the first
non-option argument is taken as the sed script to interpret.  All
remaining arguments are names of input files; if no input files are
specified, then the standard input is read.

       --help     display this help and exit
       --version  output version information and exit
   --posix
                 disable all GNU extensions.
   -R, --regexp-perl
                 use Perl 5's regular expressions syntax in the script.
   -e script, --expression=script
                 add the script to the commands to be executed
   -f script-file, --file=script-file
                 add the contents of script-file to the commands to be executed
   -i[SUFFIX], --in-place[=SUFFIX]
                 edit files in place (makes backup if extension supplied)
   -l N, --line-length=N
                 specify the desired line-wrap length for the `l' command
   -n, --quiet, --silent
                 suppress automatic printing of pattern space
   -r, --regexp-extended
                 use extended regular expressions in the script.
   -s, --separate
                 consider files as separate rather than as a single continuous
                 long stream.
   -u, --unbuffered
                 load minimal amounts of data from the input files and flush
                 the output buffers more often
 %s
This is free software; see the source for copying conditions.  There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE,
to the extent permitted by law.
 %s: -e expression #%lu, char %lu: %s
 %s: can't read %s: %s
 %s: file %s line %lu: %s
 : doesn't want any addresses E-mail bug reports to: <%s>.
Be sure to include the word ``%s'' somewhere in the ``Subject:'' field.
 GNU sed version %s
 Invalid back reference Invalid character class name Invalid collation character Invalid content of \{\} Invalid preceding regular expression Invalid range end Invalid regular expression Memory exhausted No match No previous regular expression Premature end of regular expression Regular expression too big Success Trailing backslash Unmatched ( or \( Unmatched ) or \) Unmatched [ or [^ Unmatched \{ Usage: %s [OPTION]... {script-only-if-no-other-script} [input-file]...

 `e' command not supported `}' doesn't want any addresses based on GNU sed version %s

 can't find label for jump to `%s' cannot remove %s: %s cannot rename %s: %s cannot specify modifiers on empty regexp command only uses one address comments don't accept any addresses couldn't edit %s: is a terminal couldn't edit %s: not a regular file couldn't open file %s: %s couldn't open temporary file %s: %s couldn't write %d item to %s: %s couldn't write %d items to %s: %s delimiter character is not a single-byte character error in subprocess expected \ after `a', `c' or `i' expected newer version of sed extra characters after command invalid reference \%d on `s' command's RHS invalid usage of +N or ~N as first address invalid usage of line address 0 missing command multiple `!'s multiple `g' options to `s' command multiple `p' options to `s' command multiple number options to `s' command no previous regular expression number option to `s' command may not be zero option `e' not supported read error on %s: %s strings for `y' command are different lengths super-sed version %s
 unexpected `,' unexpected `}' unknown command: `%c' unknown option to `s' unmatched `{' unterminated `s' command unterminated `y' command unterminated address regex Project-Id-Version: sed 4.1.4
Report-Msgid-Bugs-To: bug-gnu-utils@gnu.org
POT-Creation-Date: 2009-04-30 10:58+0200
PO-Revision-Date: 2005-04-20 09:37+0800
Last-Translator: Wei-Lun Chao <chaoweilun@pcmail.com.tw>
Language-Team: Chinese (traditional) <zh-l10n@linux.org.tw>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Plural-Forms: nplurals=1; plural=0;
 
å¦ææªè¨­å® -e, --expression, -f, æ --file é¸é ï¼é£éº¼ç¬¬ä¸åä¸æ¯é¸é ç
å¼æ¸å°±æè¢«ç¶å sed çå½ä»¤ç¨¿ä¾è§£è­¯ãææå©ä¸çå¼æ¸åæ¯è¼¸å¥æªçåç¨±ï¼
åå¦æªæå®è¼¸å¥æªï¼å°±æå¾æ¨æºè¼¸å¥ä¾è®åã

       --help     é¡¯ç¤ºæ¬è¼å©è¨æ¯ä¸¦é¢é
       --version  è¼¸åºçæ¬è³è¨ä¸¦é¢é
   --posix
                 åç¨ææ GNU æ´ååè½ã
   -R, --regexp-perl
                 å¨å½ä»¤ç¨¿ä¸­ä½¿ç¨ Perl 5 çæ­£è¦è¡¨ç¤ºå¼èªæ³ã
   -e å½ä»¤ç¨¿, --expression=å½ä»¤ç¨¿
                 å å¥å½ä»¤ç¨¿åçºå·è¡çå½ä»¤
   -f å½ä»¤ç¨¿æªæ¡, --file=å½ä»¤ç¨¿æªæ¡
                 å å¥å½ä»¤ç¨¿æªæ¡å§å®¹åçºå·è¡çå½ä»¤
   -i[å¯æªå], --in-place[=å¯æªå]
                 ç´æ¥ç·¨è¼¯æªæ¡ (è¥æä¾å¯æªååæç¢çåä»½)
   -l N, --line-length=N
                 æå®ä½¿ç¨ãlãå½ä»¤ææ³è¦çæåé·åº¦
   -n, --quiet, --silent
                 ææ­¢æ¨£çç©ºéçèªåé¡¯ç¤º
   -r, --regexp-extended
                 å¨å½ä»¤ç¨¿ä¸­ä½¿ç¨æ´åçæ­£è¦è¡¨ç¤ºå¼ã
   -s, --separate
                 å°æªæ¡è¦çºåèªåé¢èéå®ä¸é£çºçé·å­ä¸²ã
   -u, --unbuffered
                 å¾è¼¸å¥æªä¸­è®åæå°éçè³æä¸¦æ´å¸¸æ¸ç©ºè¼¸åºç·©è¡å
 %s
éæ¯èªç±è»é«ï¼åé±åå§ç¢¼ä»¥ç²å¾çæ¬çæãå¨æ³å¾åè¨±çç¯åå§ä¸æä¾ä»»ä½ä¿è­ï¼
å³ä½¿æ¯å°æ¼é·å®æ¬å©ææ¯çºäºé©åæ¼æç¨®ç¹æ®ç®çã
 %s: -e è¡¨ç¤ºå¼ #%luï¼å­å %lu: %s
 %s: ç¡æ³è®å %s: %s
 %s: æªæ¡ %s è¡è: %lu: %s
 : ä¸éè¦ä»»ä½ä½å å°é¯èª¤å ±åç¶ç±é»å­éµä»¶ç¼éå°: ã%sãã
è«ç¢ºå®å°å®å­ã%sãæ¾å¨ãSubject:ãæ¬çæèã
 GNU sed çæ¬ %s
 ä¸æ­£ç¢ºçè¿ååè ä¸æ­£ç¢ºçå­åç­ç´åç¨± ä¸æ­£ç¢ºçæ ¸å°å­å ä¸æ­£ç¢ºçã\{\}ãå§å®¹ ä¸æ­£ç¢ºçåå°æ­£è¦è¡¨ç¤ºå¼ ä¸æ­£ç¢ºçç¯åçµæ ä¸æ­£ç¢ºçæ­£è¦è¡¨ç¤ºå¼ è¨æ¶é«èç¡ æ²æç¬¦åè æ²æååçæ­£è¦è¡¨ç¤ºå¼ æ­£è¦è¡¨ç¤ºå¼çéæ©çµæ æ­£è¦è¡¨ç¤ºå¼å¤ªå¤§ æå æ«ç«¯æåæç· æªå¹éçã(ãæã\ã æªå¹éçã)ãæã\ã æªå¹éçã[ãæã[^ã æªå¹éçã\{ã ç¨æ³: %s [é¸é ]... {è¥ç¡å¶ä»å½ä»¤ç¨¿ååªè½æ¾å½ä»¤ç¨¿} [è¼¸å¥æª]...

 ä¸æ¯æ´å½ä»¤ãeã ã}ãä¸éè¦ä»»ä½ä½å åºæ¼ GNU sed çæ¬ %s

 ç¡æ³çºç®çæ¯ã%sãçè·³ç§»æ¾å°æ¨ç±¤ ç¡æ³ç§»é¤ %s: %s ç¡æ³æ´æ¹åç¨± %s: %s ç¡æ³æå®ä¿®é£¾å­åçµ¦ç©ºçæ­£è¦è¡¨ç¤ºå¼ å½ä»¤åªä½¿ç¨ä¸åä½å åè¨»ä¸æ¥åä»»ä½ä½å ç¡æ³ç·¨è¼¯ %s: æ¯ä¸åçµç«¯æ© ç¡æ³ç·¨è¼¯ %s: ä¸æ¯ä¸åæ­£å¸¸æªæ¡ ç¡æ³æéæªæ¡ %s: %s ç¡æ³æéæ«å­æªæ¡ %s: %s ç¡æ³å° %d åé ç®å¯«å¥ %s: %s åéå­åä¸æ¯å®ä¸ä½åå­å é¯èª¤ç¼çæ¼å¯è¡ç¨ä¸­ é æå¨ãaãããcãæãiãä¹å¾åºç¾ \ é æä½¿ç¨æ°çç sed å½ä»¤å¾å«æå¤é¤çå­å ãsãå½ä»¤ç RHS ä¸ä¸æ­£ç¢ºçåèå¼ \%d ç¡æ³å° +N æ ~N ä½çºç¬¬ä¸åä½å éæ³ä½¿ç¨ä½åç¬¬ 0 å éºæ¼å½ä»¤ å¤åã!ã å¤åãsãå½ä»¤çé¸é ãgã å¤åãsãå½ä»¤çé¸é ãpã å¤åãsãå½ä»¤çæ¸å¼é¸é  ä¸å­å¨ä¹åçæ­£è¦è¡¨ç¤ºå¼ ãsãå½ä»¤çæ¸å¼é¸é ä¸è½çºé¶ ä¸æ¯æ´é¸é ãeã è®å %s åºé¯: %s y å½ä»¤çå­ä¸²é·åº¦ä¸å è¶ç´ sed çæ¬ %s
 æªé æçã,ã æªé æçã}ã æªç¥çå½ä»¤: ã%cã ãsãçæªç¥é¸é  æªå¹éçã{ã æªçµæçãsãå½ä»¤ æªçµæçãyãå½ä»¤ æªçµæçä½åæ­£è¦è¡¨ç¤ºå¼ 