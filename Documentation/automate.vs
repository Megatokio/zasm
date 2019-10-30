#!/usr/local/bin/vipsi


/* ----	command line arguments ? -------------------------------
*/
var verbose = 0
var i = 0
do
	while ++i <= count globals && name globals[i]==""
	if globals[i]=="-v" del globals[i--] verbose=1 next then
loop



include "/usr/local/lib/vipsi/BOOK.vl"


/*	Template.Index		für die Startseite
	Template.Split		für die TOC-Seite von gesplitteten Kapiteln
	Template.Page 		für normale Seiten
*/
Template.Page =
«<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html><head>
<META http-equiv=Content-Type content="text/html; charset=UTF-8">
<title>%%TITLE%%</title>
<meta name="author"      content="kio@little-bat.de">
<meta name="copyright"   content="1998-2015 Kio (Günter Woigk)">
<meta name="robots"      content="index,follow">
<meta name="keywords"    content="%%KEYWORDS%%">
<meta name="description" content="%%TITLE%%  ((online book))">
<link rel="stylesheet" type="text/css" href="b/all.css">
<script type="text/javascript">
  var o="";
  function S(n) { H(); document.getElementById(n).style.visibility='visible'; o=n; }
  function H() { if(o!="") document.getElementById(o).style.visibility='hidden'; o=""; }
  window.addEventListener('mouseup', function(event){H();});
</script>
</head><body id="A">

<table style="width:100%;background-color:#ffff55;"><tr>
  <td> <a href="javascript:history.back()"><img src="b/left.gif" style="border:hidden;" width=11 height=20 alt="&lt;--"></a> </td>
  <td> &nbsp;<a href="javascript:history.back()">back</a> </td>
  <td width="100%"> &nbsp; </td>
  <td style="white-space:nowrap;"> <i>Last regenerated: »#datestr(now)#« kio</i> </td>
</tr></table>


%%HEADLINE0%%%%HEADLINE1%%
<p class="pglinks_o"><a href="%%PREV%%">[&lt;prev]</a> &nbsp; &nbsp; <a href="%%NEXT%%">[next&gt;]</a></p>

<table width="100%"><tr><td width="10%"></td><td width=500>
%%HEADLINE2%%%%HEADLINE3%%%%HEADLINE4%%%%HEADLINE5%%%%HEADLINE6%%
%%TOC%%%%BODY%%
</td><td width="10%"></td></tr></table>

<p class="pglinks_u"><a href="%%PREV%%">[&lt;prev]</a> &nbsp; <a href="#A">[top]</a> &nbsp; <a href="%%NEXT%%">[next&gt;]</a></p>
<p class="foot"><a href="http://validator.w3.org/check/referer">
<img border=0 src="b/html401.png" alt="Valid HTML" height=31 width=88></a>
&nbsp; <a href="http://jigsaw.w3.org/css-validator/check/referer"><img border=0 src="b/css.png" alt="Valid CSS" height=31 width=88></a></p>
</body></html>
»



Doit()


put nl,nl,"--- finished ---",nl,nl


end 0








