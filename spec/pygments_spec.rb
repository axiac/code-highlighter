require 'spec_helper'

describe Octopress::CodeHighlighter do
  let(:wrapper) do
    Proc.new do |stuff, numbers|
      [
        "<figure class='code-highlight-figure'>",
        "<div class='code-highlight'>",
        "<pre class='code-highlight-pre'>#{stuff}</pre>",
        "</div></figure>"
      ].join
    end
  end

  let(:expected_output_no_options) do
    stuff = <<-EOF
<figure class='code-highlight-figure'><div class='code-highlight'><pre class='code-highlight-pre'><div data-line='1' class='code-highlight-row numbered'><div class='code-highlight-line'>require "hi-there-honey"
</div></div><div data-line='2' class='code-highlight-row numbered'><div class='code-highlight-line'> </div></div><div data-line='3' class='code-highlight-row numbered'><div class='code-highlight-line'>def hi-there-honey
</div></div><div data-line='4' class='code-highlight-row numbered'><div class='code-highlight-line'>  HiThereHoney.new("your name")
</div></div><div data-line='5' class='code-highlight-row numbered'><div class='code-highlight-line'>end
</div></div><div data-line='6' class='code-highlight-row numbered'><div class='code-highlight-line'> </div></div><div data-line='7' class='code-highlight-row numbered'><div class='code-highlight-line'>hi-there-honey
</div></div><div data-line='8' class='code-highlight-row numbered'><div class='code-highlight-line'># =>  "Hi, your name"
</div></div></pre></div></figure>
EOF
    stuff.strip
  end

  let(:expected_output_lang_ruby) do
    stuff = <<-EOF
{% raw %}<figure class='code-highlight-figure awesome'><div class='code-highlight'><pre class='code-highlight-pre'><div data-line='1' class='code-highlight-row numbered'><div class='code-highlight-line'><span class="nb">require</span> <span class="s2">"hi-there-honey"</span>
</div></div><div data-line='2' class='code-highlight-row numbered'><div class='code-highlight-line'> </div></div><div data-line='3' class='code-highlight-row numbered'><div class='code-highlight-line'><span class="k">def</span> <span class="nf">hi</span><span class="o">-</span><span class="n">there</span><span class="o">-</span><span class="n">honey</span>
</div></div><div data-line='4' class='code-highlight-row numbered'><div class='code-highlight-line'>  <span class="no">HiThereHoney</span><span class="p">.</span><span class="nf">new</span><span class="p">(</span><span class="s2">"your name"</span><span class="p">)</span>
</div></div><div data-line='5' class='code-highlight-row numbered'><div class='code-highlight-line'><span class="k">end</span>
</div></div><div data-line='6' class='code-highlight-row numbered'><div class='code-highlight-line'> </div></div><div data-line='7' class='code-highlight-row numbered'><div class='code-highlight-line'><span class="n">hi</span><span class="o">-</span><span class="n">there</span><span class="o">-</span><span class="n">honey</span>
</div></div><div data-line='8' class='code-highlight-row numbered'><div class='code-highlight-line'><span class="c1"># =&gt;  "Hi, your name"</span>
</div></div></pre></div></figure>{% endraw %}
EOF
  end

  let(:expected_output_lang_shell) do
    stuff = <<-EOF
{% raw %}<figure class='code-highlight-figure awesome'><div class='code-highlight'><pre class='code-highlight-pre'><div data-line='1' class='code-highlight-row numbered'><div class='code-highlight-line'><span class="c">#!/bin/bash</span>
</div></div><div data-line='2' class='code-highlight-row numbered'><div class='code-highlight-line'> </div></div><div data-line='3' class='code-highlight-row numbered'><div class='code-highlight-line'><span class="nv">PROJECT</span><span class="o">=</span><span class="nv">$1</span>
</div></div><div data-line='4' class='code-highlight-row numbered'><div class='code-highlight-line'><span class="k">if</span> <span class="o">[</span> <span class="nt">-z</span> <span class="s2">"</span><span class="nv">$PROJECT</span><span class="s2">"</span> <span class="o">]</span><span class="p">;</span> <span class="k">then</span>
</div></div><div data-line='5' class='code-highlight-row numbered'><div class='code-highlight-line'>    <span class="nb">echo</span> <span class="s2">"Missing project name."</span>
</div></div><div data-line='6' class='code-highlight-row numbered'><div class='code-highlight-line'>    <span class="nb">exit </span>1
</div></div><div data-line='7' class='code-highlight-row numbered'><div class='code-highlight-line'><span class="k">fi</span>
</div></div><div data-line='8' class='code-highlight-row numbered'><div class='code-highlight-line'> </div></div><div data-line='9' class='code-highlight-row numbered'><div class='code-highlight-line'><span class="nv">BASH_ENV</span><span class="o">=</span>~/.bashrc bash ~/bin/sismo <span class="nt">--quiet</span> build <span class="nv">$PROJECT</span> <span class="k">$(</span>git log <span class="nt">-1</span> HEAD <span class="nt">--pretty</span><span class="o">=</span><span class="s2">"%H"</span><span class="k">)</span> <span class="o">&gt;</span>/dev/null 2&gt;&amp;1 &amp;
</div></div></pre></div></figure>{% endraw %}
    EOF
  end

  let(:code) do
    <<-EOF
require "hi-there-honey"

def hi-there-honey
  HiThereHoney.new("your name")
end

hi-there-honey
# =>  "Hi, your name"
    EOF
  end

  let(:shell) do
    <<-EOF
#!/bin/bash

PROJECT=$1
if [ -z "$PROJECT" ]; then
    echo "Missing project name."
    exit 1
fi

BASH_ENV=~/.bashrc bash ~/bin/sismo --quiet build $PROJECT $(git log -1 HEAD --pretty="%H") >/dev/null 2>&1 &
    EOF
  end

  let(:markup) do
    [
      "lang:abc",
      'title:"Hello"',
      "url:http://something.com/hi/fuaiofnioaf.html",
      "link_text:'get it here'",
      "mark:5,8-10,15",
      "linenos: yes",
      "start: 5",
      "end: 15",
      "range: 5-15"
    ].join(" ")
  end

  let(:bad_markup) do
    [
      "lang:ruby",
      'title:"Hello"',
      "url:http://something.com/hi/fuaiofnioaf.html",
      "link_text: get it here",
      "mark:5,8-10,15",
      "linenos: yes",
      "start: 5",
      "end: 15",
      "range: 5-15"
    ].join(" ")
  end

  let(:options) do
    {
      lang: "abc",
      url:  "http://something.com/hi/fuaiofnioaf.html",
      title: "Hello",
      linenos: true,
      marks: [5, 8, 9, 10, 15],
      link_text: "get it here",
      start: 5,
      end: 15
    }
  end

  describe ".highlight" do
    it "returns HTML for an empty code block" do
      expect(described_class.highlight("", {})).to eql(wrapper.call("", ""))
    end

    context "with no options" do
      it "returns the right HTML for a given set of code" do
        expect(described_class.highlight(code, {})).to eql(expected_output_no_options)
      end
    end

    context "with a language" do
      it "returns the right HTML for a given set of code" do
        expect(described_class.highlight(code, { lang: 'abc', aliases: {'abc'=>'ruby'}, escape: true, class: 'awesome' })).to eql(expected_output_lang_ruby.chop)
      end
    end

    context "shell script" do
      it "returns the right HTML for multi-line shell scripts" do
        actual   = described_class.highlight(shell, {lang: 'sh', escape: true, class: 'awesome'})
        expected = expected_output_lang_shell.chop
        expect(actual).to eql(expected)
      end
    end
  end

  describe ".highlight_failed" do
    #described_class.highlight_failed(error, syntax, markup, code, file = nil)
  end

  describe ".parse_markup" do
    context "with no defaults" do
      it "parses the defaults correctly" do
        expect(described_class.parse_markup(markup, {})).to eql(options)
      end
    end

    context "with defaults with a nil value" do
      it "overrides the nil values" do
        expect(described_class.parse_markup(markup, { lang: nil })).to eql(options)
      end
    end
  end

  describe ".clean_markup" do

    it "returns an empty string with good markup" do
      expect(described_class.clean_markup(markup)).to eql("")
    end

    it "returns erroneous text that isn't part of the markup" do
      expect(described_class.clean_markup(bad_markup)).to eql(" it here")
    end
  end
end
