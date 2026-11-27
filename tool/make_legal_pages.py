"""Makes the public Privacy Policy and Terms web pages.

Reads assets/data/legal.json (the same text the app shows) and writes
docs/index.html, docs/privacy-policy.html and docs/terms.html for GitHub
Pages. Run from the project folder:  python3 tool/make_legal_pages.py
"""
import html
import json
import os
import re

SRC = 'assets/data/legal.json'
OUT = 'docs'

STYLE = """
body { margin: 0; font-family: system-ui, -apple-system, 'Segoe UI', Roboto,
       sans-serif; background: #FFF8E7; color: #222; line-height: 1.55; }
header { background: #1B5E20; color: #fff; padding: 20px 16px; }
header a { color: #F2B705; text-decoration: none; font-weight: bold; }
main { max-width: 760px; margin: 0 auto; padding: 16px 20px 48px; }
h1 { color: #1B5E20; margin-bottom: 4px; }
h2 { color: #1B5E20; font-size: 1.15em; margin-top: 28px; }
.updated { color: #6B6B6B; font-size: 0.9em; }
a { color: #1B5E20; }
footer { text-align: center; color: #6B6B6B; font-size: 0.85em;
         padding: 24px; }
@media (prefers-color-scheme: dark) {
  body { background: #101810; color: #EDEDED; }
  h1, h2, a { color: #81C784; }
  .updated, footer { color: #B4B4B4; }
}
"""


def linkify(text):
    """Escapes text and turns web and email addresses into links."""
    safe = html.escape(text)
    safe = re.sub(r'(https?://[^\s<]+)', r'<a href="\1">\1</a>', safe)
    safe = re.sub(r'([\w.+-]+@[\w-]+\.[\w.]+)', r'<a href="mailto:\1">\1</a>',
                  safe)
    return safe


def page(title, body, data):
    return f"""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{html.escape(title)} - Assam Crossword</title>
<style>{STYLE}</style>
</head>
<body>
<header><a href="index.html">Assam Crossword</a> &middot; {html.escape(data['developer'])}</header>
<main>
{body}
</main>
<footer>&copy; {html.escape(data['developer'])} &middot; <a href="mailto:{data['email']}">{data['email']}</a></footer>
</body>
</html>
"""


def document(doc, data):
    parts = [f"<h1>{html.escape(doc['title'])}</h1>",
             f"<p class=\"updated\">Last updated: {html.escape(data['updated'])}</p>",
             f"<p>{linkify(doc['intro'])}</p>"]
    for section in doc['sections']:
        parts.append(f"<h2>{html.escape(section['heading'])}</h2>")
        for paragraph in section['paragraphs']:
            parts.append(f"<p>{linkify(paragraph)}</p>")
    return page(doc['title'], '\n'.join(parts), data)


def main():
    data = json.load(open(SRC, encoding='utf-8'))
    os.makedirs(OUT, exist_ok=True)
    files = {
        'privacy-policy.html': document(data['privacy'], data),
        'terms.html': document(data['terms'], data),
        'index.html': page('Home', """<h1>Assam Crossword</h1>
<p>An educational crossword game for Assam GK, India GK and English
vocabulary, for school, college and competitive exam preparation.</p>
<ul>
<li><a href="privacy-policy.html">Privacy Policy</a></li>
<li><a href="terms.html">Terms and Conditions</a></li>
</ul>""", data),
    }
    for name, content in files.items():
        path = os.path.join(OUT, name)
        with open(path, 'w', encoding='utf-8') as f:
            f.write(content)
        print('made', path)


main()
