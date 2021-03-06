��       W     �     �      �   �  �   ,  �   5  �   N  �   7  	6   \  	n   _  	�   `  
+   u  
�   l     b  o   V  �   Y  )   ~  �   �     �  �   %  M     s     �     �   e  �     '     ;     R     o     �   $  �     �     �     �             #  .     R     m     u     �     �     �     �   H  �          .     M   !  k     �     �   (  �     �     �   #       5     O   $  o     �     �   #  �   B  �   2  4     g      {     �     �   *  �   *       /     O     _   #  m   #  �   &  �     �     �   ,  
     7     P   -  e     �     �     �     �     �     �               3  �  N  5  �   .     @  ;   Z  |   C  �   z     y  �   d     �  u   �     }  �   _     _  s   �  �   �  Z   �  "   (  �            8      V   }   t      �     !   $  !&   !  !K     !m   %  !�     !�     !�     !�     !�   #  "   '  ")   "  "Q     "t     "z     "�     "�     "�     "�   L  "�      #'     #H     #h   4  #�     #�     #�   F  #�   4  $<   $  $q   ,  $�     $�   &  $�   /  %   -  %8   #  %f   ,  %�   U  %�   9  &     &G   '  &^   +  &�   $  &�   :  &�   .  '   '  'A     'i     'x   (  '�   (  '�   .  '�     (   #  (#   7  (G   !  (     (�   :  (�     (�     )
     )     )(     )@     )\     )k     )�   +  )�             >          	   0                 7      D   %   J             L      
   .   F   M           @   G       ;   =                      S   9   5          ,   C                 B   (   O       -                          :                      K   4               N   /              +       V                '             Q                     A   8       &   P   W   I   2   H      $              "   #   6   <   U       R      )   *       E   ?      3   T   !   1       
If no -e, --expression, -f, or --file option is given, then the first
non-option argument is taken as the sed script to interpret.  All
remaining arguments are names of input files; if no input files are
specified, then the standard input is read.

       --help     display this help and exit
       --version  output version information and exit
   --follow-symlinks
                 follow symlinks when processing in place
   --posix
                 disable all GNU extensions.
   -R, --regexp-perl
                 use Perl 5's regular expressions syntax in the script.
   -b, --binary
                 open files in binary mode (CR+LFs are not processed specially)
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

 can't find label for jump to `%s' cannot remove %s: %s cannot rename %s: %s cannot specify modifiers on empty regexp cannot stat %s: %s command only uses one address comments don't accept any addresses couldn't attach to %s: %s couldn't edit %s: is a terminal couldn't edit %s: not a regular file couldn't follow symlink %s: %s couldn't open file %s: %s couldn't open temporary file %s: %s couldn't write %d item to %s: %s couldn't write %d items to %s: %s delimiter character is not a single-byte character error in subprocess expected \ after `a', `c' or `i' expected newer version of sed extra characters after command invalid reference \%d on `s' command's RHS invalid usage of +N or ~N as first address invalid usage of line address 0 missing command multiple `!'s multiple `g' options to `s' command multiple `p' options to `s' command multiple number options to `s' command no input files no previous regular expression number option to `s' command may not be zero option `e' not supported read error on %s: %s strings for `y' command are different lengths super-sed version %s
 unexpected `,' unexpected `}' unknown command: `%c' unknown option to `s' unmatched `{' unterminated `s' command unterminated `y' command unterminated address regex Project-Id-Version: sed 4.2.0
Report-Msgid-Bugs-To: bug-gnu-utils@gnu.org
POT-Creation-Date: 2009-04-30 10:58+0200
PO-Revision-Date: 2008-01-18 21:10-0600
Last-Translator: Cristian Oth�n Mart�nez Vera <cfuga@itam.mx>
Language-Team: Spanish <es@li.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8-bit
Plural-Forms: nplurals=2; plural=(n != 1);
 
Si no se proporciona una opci�n -e, --expression, -f, � --file option,
entonces se toma el primer argumento que no sea opci�n como el gui�n sed
a interpretar.  Todos los argumentos restantes son nombres de ficheros
de entrada; si no se especifican ficheros de entrada, entonces se lee
la entrada est�ndard.

       --help     muestra esta ayuda y termina
       --version  muestra la informaci�n de la versi�n y termina
   --follow-symlinks
                 sigue los enlaces simb�licos al procesar en el lugar
   --posix
                 desactiva todas las extensiones de GNU.
   -R, --regexp-perl
                 utiliza la sintaxis de expresiones regulares de Perl 5
                 en el gui�n.
   -b, --binary
                 abre ficheros en modo binario (los RC+FLs no se procesan
                 especialmente)
   -e gui�n, --expression=gui�n
                 agrega el gui�n a la lista de �rdenes para ejecutar
   -f fichero-gui�n, --file=fichero-gui�n
                 agrega el contenido del fichero gui�n a la lista de �rdenes
                 para ejecutar
   -i[SUFIJO], --in-place[=SUFIJO]
                 edita ficheros en el lugar (crea un respaldo si se da
                 una extensi�n)
   -l N, --line-length=N
                 especifica la longitud de corte de l�nea deseado para
                 la orden `l'
   -n, --quiet, --silent
                 suprime la muestra autom�tica del espacio de patrones
   -r, --regexp-extended
                 utiliza expresiones regulares extendidas en el gui�n.
   -s, --separate
                 considera los ficheros como separados en lugar de un solo
                 flujo, largo y continuo.
   -u, --unbuffered
                 carga cantidades m�nimas de datos de los ficheros de entrada
                 y vac�a los almacenamientos temporales de salida con m�s
                 frecuencia
 %s
Esto es software libre; vea el c�digo fuente para las condiciones de copia.
No hay NINGUNA garant�a; ni siquiera de COMERCIABILIDAD o IDONEIDAD PARA UN
FIN DETERMINADO, en la extensi�n permitida por ley.
 %s: -e expresi�n #%lu, car�cter %lu: %s
 %s: no se puede leer %s: %s
 %s: fichero %s l�nea %lu: %s
 : no acepta ninguna direcci�n Env�e reportes de bichos por e-mail a: <%s>.
Aseg�rese de incluir la palabra ``%s'' en alg�n lugar en el campo ``Subject:''.
 GNU sed versi�n %s
 Referencia hacia atr�s inv�lida Car�cter de nombre de clase inv�lido Car�cter de ordenamiento inv�lido Contenido inv�lido de \{\} Expresi�n regular precedente inv�lida Final de rango inv�lido Expresion regular inv�lida Memoria agotada No hay coincidencia No hay una expresi�n regular previa Final prematuro de la expresi�n regular Expresi�n regular demasiado grande �xito Diagonal invertida al final ( � \( sin pareja ) � \) sin pareja [ � [^ sin pareja \{ sin pareja Uso: %s [OPCI�N]... {gui�n-s�lo-si-no-hay-otro-gui�n} [fichero-entrada]...

 no hay soporte para la orden `e' `}' no acepta ninguna direcci�n basado en GNU sed versi�n %s

 no se puede encontrar la etiqueta para saltar a `%s' no se puede eliminar %s: %s no se puede renombrar %s: %s no se pueden especificar modificadores en expresiones regulares vac�as no se puede obtener la informaci�n de stat de %s: %s la orden solamente usa una direcci�n los comentarios no aceptan ninguna direcci�n no se puede conectar a %s: %s no se puede editar %s: es una terminal no se puede editar %s: no es un fichero regular no se puede seguir el enlace simb�lico %s: %s no se puede abrir el fichero %s: %s no se puede abrir el fichero temporal %s: %s no se puede escribir %d elemento a %s: %s no se pueden escribir %d elementos a %s: %s el car�cter delimitador no es un car�cter de un solo byte error en el subproceso se esperaba \ despu�s de `a', `c' � `i' se esperaba una versi�n m�s reciente de sed caracteres extra despu�s de la orden referencia \%d inv�lida en el lado derecho de la orden `s' uso inv�lido de +N o ~N como primera direcci�n uso inv�lido de la direcci�n de l�nea 0 orden faltante `!'s m�ltiples m�ltiples opciones `g' para la orden `s' m�ltiples opciones `p' para la orden `s' m�ltiples opciones num�ricas para la orden `s' no hay ficheros de entrada no hay una expresi�n regular previa una opci�n num�rica para la orden `s' no puede ser cero no hay soporte para la opci�n `e' error al leer de %s: %s las cadenas para la orden `y' son de longitudes diferentes super-sed versi�n %s
 `,' inesperada `}' inesperado orden desconocida: `%c' opci�n desconocida para `s' `{' sin pareja orden `s' sin terminar orden `y' sin terminar direcci�n de expresi�n regular sin terminar 