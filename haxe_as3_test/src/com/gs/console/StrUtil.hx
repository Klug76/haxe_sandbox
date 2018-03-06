package com.gs.console;

class StrUtil
{
	static private var regexp_amp = ~/&/g;
	static private var regexp_lt = ~/</g;
	static private var regexp_gt = ~/>/g;
	static private var regexp_quot = ~/"/g;
	static private var regexp_apos = ~/'/g;
	static private var regexp_lspace = ~/^[ \t]+/gm;
	static private var regexp_br = ~/\n/g;

	static public function encode_Plain_Text(s: String): String
	{
        if (s.indexOf("&") >= 0)
        {
            s = regexp_amp.replace(s, "&amp;");
        }
        if (s.indexOf("<") >= 0)
        {
            s = regexp_lt.replace(s, "&lt;");
        }
        if (s.indexOf(">") >= 0)
        {
            s = regexp_gt.replace(s, "&gt;");
        }
        if (s.indexOf('"') >= 0)
        {
            s = regexp_quot.replace(s, "&quot;");
        }
        if (s.indexOf("'") >= 0)
        {
            s = regexp_apos.replace(s, "&apos;");
        }
        if (s.indexOf("\n") >= 0)
        {//:looks like a code
            s = regexp_lspace.map(s, escape_LSpace);
            s = regexp_br.replace(s, "<br>");
        }
        return s;
	}

	static private function escape_LSpace(re: EReg): String
	{
		var s: String = re.matched(0);
		var i: Int;
        var temp: Array<String> = [for (i in 0...s.length + 1) ""];
        return temp.join("&nbsp;");
	}

	static private var regexp_new_line = ~/<\/p>|<br>/g;
	static private var regexp_tag = ~/<.*?>/g;
	static private var regexp_lt_code = ~/&lt;/g;
	static private var regexp_gt_code = ~/&gt;/g;
	static private var regexp_quot_code = ~/&quot;/g;
	static private var regexp_apos_code = ~/&apos;/g;
	static private var regexp_amp_code = ~/&amp;/g;

	static public function strip_Tags(s: String): String
	{
		s = regexp_new_line.replace(s, '\n');
		s = regexp_tag.replace(s, "");
		s = regexp_lt_code.replace(s, '<');
		s = regexp_gt_code.replace(s, '>');
		s = regexp_quot_code.replace(s, '"');
		s = regexp_apos_code.replace(s, "'");
		//:must be last one:
		s = regexp_amp_code.replace(s, '&');
		return s;
	}

	static private var regexp_last_lf = ~/\n$/;

	static public function remove_Last_Lf(s: String): String
	{
		return regexp_last_lf.replace(s, "");
	}
}