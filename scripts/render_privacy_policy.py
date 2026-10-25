#!/usr/bin/env python3
"""Render the bundled policy into a local review page; never publish it."""
import html
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / 'output/privacy/index.html'
policies = {lang: json.loads((ROOT / f'mobile/assets/legal/privacy_{lang}.json').read_text())
            for lang in ('lv', 'en', 'es')}
parts = []
for lang, policy in policies.items():
    text = lambda value: html.escape(value)
    sections = ''.join(
        f'<section><h2>{text(s["title"])}</h2>'
        + ''.join(f'<p>{text(p)}</p>' for p in s['paragraphs']) + '</section>'
        for s in policy['sections'])
    notice = f'<p class="notice">{text(policy["reviewNotice"])}</p>' if policy['status'] == 'draft' else ''
    hidden = '' if lang == 'lv' else ' hidden'
    parts.append(f'<article lang="{lang}" id="{lang}"{hidden}><h1>Splyto — {text(policy["title"])}</h1>'
                 f'<p class="date">{text(policy["updated"])}</p>{notice}'
                 f'<p>{text(policy["intro"])}</p>{sections}</article>')
OUTPUT.parent.mkdir(parents=True, exist_ok=True)
OUTPUT.write_text('''<!doctype html><html lang="lv"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Splyto — privātuma politikas projekts</title>
<style>:root{color-scheme:light dark}*{box-sizing:border-box}body{margin:0;font:17px/1.65 system-ui;background:light-dark(#f7f9f8,#101314);color:light-dark(#182722,#e9efed)}main{max-width:850px;margin:auto;padding:24px 20px 64px}h1{font-size:30px;line-height:1.2}h2{font-size:21px;line-height:1.3;margin-top:32px}.date{opacity:.7}.notice{border-left:4px solid #25836d;padding:14px 18px;background:light-dark(#e5f3ed,#182e25)}nav{display:flex;gap:16px;flex-wrap:wrap}button{font:inherit;padding:8px 16px;cursor:pointer}p{overflow-wrap:anywhere}</style>
<main><nav aria-label="Valoda"><button data-lang="lv">Latviski</button><button data-lang="en">English</button><button data-lang="es">Español</button></nav>
''' + ''.join(parts) + '''</main><script>document.querySelectorAll('button[data-lang]').forEach(b=>b.onclick=()=>{document.documentElement.lang=b.dataset.lang;document.querySelectorAll('article').forEach(a=>a.hidden=a.id!==b.dataset.lang);document.querySelectorAll('button[data-lang]').forEach(x=>x.setAttribute('aria-pressed',String(x===b)));});document.querySelector('button[data-lang="lv"]').click();</script></html>''')
print(OUTPUT)
