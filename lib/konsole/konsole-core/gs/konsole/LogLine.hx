package gs.konsole;


class LogLine
{
    //public var id_: int;
    public var text_ : String = null;
    public var html_ : String = null;

    public function new()
    {
    }
//.............................................................................
    public function get_Text() : String
    {
        if (null == text_)
        {
            var s : String = StrUtil.strip_Tags(html_);
            s = StrUtil.remove_Last_Lf(s);
            return s;
        }
        return text_;
    }
//.............................................................................
    public function get_Html() : String
    {
        if (null == html_)
        {
            var s : String = "<p>";
            s += StrUtil.encode_Plain_Text(text_);
            s += "</p>";
            return s;
        }
        return html_;
    }
}

