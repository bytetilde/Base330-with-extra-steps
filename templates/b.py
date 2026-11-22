import re
import os
import sys
from decimal import Decimal
_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BA = os.path.join(_ROOT, 'shaders')
BB = os.path.join(_ROOT, 'templates')
def _err(fn, ln, msg):
  print(f"{fn}:{ln}: error: {msg}", file=sys.stderr)
  sys.exit(1)
def _tabw(s):
  s = s.expandtabs(8)
  return len(s) - len(s.lstrip())

def _parse_for(l, fn, ln):
  rest = l[5:].strip()
  if(not rest): _err(fn, ln, '!for missing iteration variable')
  if(not (rest[0].isalpha() or rest[0] == '%')): _err(fn, ln, '!for missing iteration variable')
  parts = rest.split(maxsplit=1)
  vp = parts[0]
  vs = parts[1] if(len(parts) > 1) else ''
  if(vp.startswith('%')): var = vp[1:]
  else: _err(fn, ln, 'for variable missing %')
  if(not var): _err(fn, ln, '!for missing iteration variable')
  if(not vs): _err(fn, ln, '!for missing iteration values')
  vals = [x.strip() for x in vs.split(',')]
  if(not vals or all(not v for v in vals)): _err(fn, ln, '!for missing iteration values')
  return var, vals
def _parse_map(l, fn, ln):
  p = l[5:].split()
  if(len(p) < 1): _err(fn, ln, 'map missing source variable')
  if(len(p) < 2): _err(fn, ln, 'map missing source values')
  if(len(p) < 3): _err(fn, ln, 'map missing output variable')
  if(len(p) < 4): _err(fn, ln, 'map missing output values')
  kv, kr, mv, mr = p[0], p[1], p[2], p[3]
  if(not kv.startswith('%')): _err(fn, ln, 'map source variable must start with %')
  if(not mv.startswith('%')): _err(fn, ln, 'map output variable must start with %')
  kvs = [x.strip() for x in kr.split(',')]
  mvs = [x.strip() for x in mr.split(',')]
  if(len(kvs) != len(mvs)): _err(fn, ln, f"mismatched map source/output values length ({len(kvs)} vs {len(mvs)})")
  return kv[1:], kvs, mv[1:], mvs
def _valid_range(sr, fn, ln):
  out = []
  num = r'[+-]?(?:\d+(?:\.\d*)?|\.\d+)'
  for part in sr.split(';'):
    part = part.strip()
    if(not part): _err(fn, ln, 'empty range segment')
    if((m := re.fullmatch(r'(-?\d+)-(-?\d+)', part)) is not None):
      lo, hi = int(m.group(1)), int(m.group(2))
      if(lo > hi): _err(fn, ln, f'min ({lo}) must not exceed max ({hi})')
      out.extend(map(str, range(lo, hi + 1)))
      continue
    if((m := re.fullmatch(rf'({num})\.\.({num})\s+(e{num}(?:i\d+)?|{num})', part)) is not None):
      mn, mx = Decimal(m.group(1)), Decimal(m.group(2))
      st = m.group(3)
      if(mn >= mx): _err(fn, ln, 'range min must be less than max')
      isint = all(re.fullmatch(r'[+-]?\d+', x) for x in (m.group(1), m.group(2), st.lstrip('e').split('i')[0]))
      vals = []
      if(st.startswith('e')):
        factor, _, between = st[1:].partition('i')
        factor = Decimal(factor)
        count = int(between) if(between) else 0
        if(mn <= 0 or factor <= 1): _err(fn, ln, 'exponential range requires positive min and factor > 1')
        at = mn
        while(at <= mx):
          vals.append(at)
          nxt = at * factor
          for j in range(1, count + 1):
            v = at + (nxt - at) * j / (count + 1)
            if(v <= mx): vals.append(v)
          at = nxt
      else:
        step = Decimal(st)
        if(step <= 0): _err(fn, ln, 'step must be positive')
        at = mn
        while(at <= mx):
          vals.append(at)
          at += step
      for v in vals:
        x = format(v.normalize(), 'f')
        if(not isint and '.' not in x): x += '.0'
        out.append(x)
      continue
    out.append(part)
  return ' '.join(out)
def process_settings(lines, vars=None, fn='<unknown>', bl=1):
  if(vars is None): vars = {}
  nc = []
  i = 0
  while(i < len(lines)):
    l = lines[i]
    ln = bl + i
    if(l.startswith('!for ')):
      var, vals = _parse_for(l, fn, ln)
      block = []
      i += 1
      d = 1
      first = i
      while(i < len(lines) and d):
        l2 = lines[i]
        if(l2.startswith('!for ')): d += 1
        elif(l2.startswith('!endfor')): d -= 1
        if(d): block.append(l2)
        i += 1
      if(d): _err(fn, 0, 'unclosed !for block (missing !endfor)')
      for val in vals:
        m2 = {**vars, var: val}
        nc.extend(process_settings(block, m2, fn, bl + first))
      continue
    elif(l.startswith('!endfor')): _err(fn, ln, 'unexpected !endfor (no matching !for)')
    elif(l.startswith('!map ')):
      kv, kvs, mv, mvs = _parse_map(l, fn, ln)
      if(kv in vars):
        if(vars[kv] in kvs): vars[mv] = mvs[kvs.index(vars[kv])]
        else: _err(fn, ln, f"key <{vars[kv]}> not in source value list")
      i += 1
      continue
    for k, v in sorted(vars.items(), key=lambda x: -len(x[0])): l = l.replace('%' + k, v)
    if(l.startswith('!?')):
      rest = l[2:]
      head, _, tail = rest.partition(' ')
      if(head in ('int', 'float', 'bool')): ctype, rest = head, tail
      else: ctype = 'float'
      parts = rest.split(maxsplit=2)
      if(len(parts) < 3): _err(fn, ln, 'malformed const declaration, expected: !?[int|float|bool] name default [range]')
      name, default, sr = parts
      if(not (sr.startswith('[') and sr.endswith(']'))): _err(fn, ln, 'malformed range brackets')
      sr = sr[1:-1]
      vs = _valid_range(sr, fn, ln)
      if(default not in vs.split()): print(f'{fn}:{ln}: warning: default <{default}> not in range [{vs}] for {name}', file=sys.stderr)
      nc.append(f'const {ctype} {name} = {default}; // [{vs}]')
    elif(l.startswith('!toggle ')):
      parts = l.split()
      if(len(parts) != 3 or parts[2] not in ('on', 'off')): _err(fn, ln, 'expected !toggle NAME on|off')
      nc.append(f'#define {parts[1]}' if(parts[2] == 'on') else f'// #define {parts[1]}')
    elif(l.startswith('!')):
      rest = l[1:]
      parts = rest.split(maxsplit=1)
      if(len(parts) < 2): _err(fn, ln, 'malformed range brackets')
      p1, sr = parts
      if(':' not in p1): _err(fn, ln, 'missing : in option declaration')
      name, default = p1.split(':', 1)
      if(not (sr.startswith('[') and sr.endswith(']'))): _err(fn, ln, 'malformed range brackets')
      sr = sr[1:-1]
      vs = _valid_range(sr, fn, ln)
      if(default not in vs.split()): print(f'{fn}:{ln}: warning: default <{default}> not in range [{vs}] for {name}', file=sys.stderr)
      nc.append(f'#define {name} {default} // [{vs}]')
    else: nc.append(l)
    i += 1
  return nc
def do_settings(basep = 'lib/settings'):
  if(os.path.isdir(os.path.join(BB, basep))):
    for f in os.listdir(os.path.join(BB, basep)): do_settings(os.path.join(basep, f))
    return
  ffp = os.path.join(BB, basep)
  fffp = os.path.join(BA, basep)
  if(fffp.endswith('.txt')): fffp = fffp.removesuffix('.txt') + '.glsl'
  with open(ffp, 'r') as f: c = f.read()
  nc = process_settings(c.splitlines(), {}, ffp)
  nc = '\n'.join(nc).strip() + '\n'
  guard = 'LIB_SETTINGS_' + re.sub(r'[^0-9A-Za-z]+', '_', os.path.relpath(fffp, os.path.join(BA, 'lib/settings')).removesuffix('.glsl')).upper()
  nc = f'#ifndef {guard}\n#define {guard}\n\n' + nc + '\n#endif\n'
  os.makedirs(os.path.dirname(fffp), exist_ok=True)
  with open(fffp, 'w') as f: f.write(nc)

def _format(x):
  # bad practice final boss
  fmts = {'bold': False, 'italic': False, 'underline': False, 'strikethrough': False, 'code': False, 'color': None}
  tokenized = re.split(r"(\\?(?:&[0-9A-Fa-f&]|\*\*|__|~~|\*|_|`))", x)
  fcodes = {'reset': '§r', 'black': '§0', 'darkblue': '§1', 'darkgreen': '§2', 'darkcyan': '§3', 'darkred': '§4', 'darkpurple': '§5', 'gold': '§6', 'gray': '§7', 'darkgray': '§8', 'blue': '§9', 'green': '§a', 'aqua': '§b', 'red': '§c', 'lightpurple': '§d', 'yellow': '§e', 'white': '§f', 'obf': '§k', 'bold': '§l', 'strikethrough': '§m', 'underline': '§n', 'italic': '§o'}
  res = ''
  def _repush():
    nonlocal res
    if(fmts['code']):
      res += fcodes['blue']
      return
    elif(fmts['color'] is not None): res += fmts['color']
    else: res += fcodes['reset']
    if(fmts['bold']): res += fcodes['bold']
    if(fmts['italic']): res += fcodes['italic']
    if(fmts['underline']): res += fcodes['underline']
    if(fmts['strikethrough']): res += fcodes['strikethrough']
  humblemap = {
    '**': 'bold',
    '*': 'italic',
    '__': 'underline',
    '_': 'italic',
    '~~': 'strikethrough'
  }
  for tkn in tokenized:
    if(tkn.startswith('\\')):
      res += tkn[1:]
      continue
    if(not fmts['code'] and re.fullmatch(r"^&[0-9A-Fa-f&]$", tkn)):
      fmts['color'] = ('§' + tkn[1].lower()) if tkn[1] != '&' else None
      _repush()
      continue
    if(tkn == '`'):
      fmts['code'] = not fmts['code']
      _repush()
    elif(tkn in humblemap and not fmts['code']):
      d = humblemap[tkn]
      fmts[d] = not fmts[d]
      if(fmts[d]): res += fcodes[d]
      else: _repush()
    else: res += tkn
  res = re.sub(r'(?<!\\)\. ', '.\u00A0', res)
  if('§' in res and not res.endswith('§r') and '§' not in x): res += '§r'
  return res
def _dot(vn):
  m = re.search(r'§[0-9a-f]', vn)
  return m.group(0) if m else '§8'
def _flush_option(out, cur, vals, comms):
  if(not cur): return
  out.append(f'option.{cur[0]}={cur[1]}')
  if(comms or vals):
    cp = list(comms)
    for num, vn, vd in vals:
      if(vn.startswith('§')): pass
      elif('§' in vn): vn = f'§f{vn}'
      else: vn = f'§f{vn}§r'
      out.append(f'value.{cur[0]}.{num}={vn}')
      if(vd): cp.append(f'{_dot(vn)}• §r{vn}: {vd}')
    out.append(f'option.{cur[0]}.comment={"\\n".join(cp)}')
def _flush_screen(out, scr, scomms):
  if(not scr): return
  if(scomms): out.append(f'screen.{scr}.comment={"\\n".join(scomms)}')
def process_lang(lines, vars=None, fn='<unknown>', bl=1):
  if(vars is None): vars = {}
  out = []
  cur = None
  vals = []
  comms = []
  scr = None
  scomms = []
  istk = []
  i = 0
  while(i < len(lines)):
    l = lines[i]
    ln = bl + i
    if(not l.strip()):
      i += 1
      continue
    if(l != l.rstrip()): print(f'{fn}:{ln}: warning: trailing whitespace', file=sys.stderr)
    if('  ' in s if (s := l.lstrip()) else False): print(f'{fn}:{ln}: warning: double space', file=sys.stderr)
    if(l.startswith('!for ')):
      _flush_option(out, cur, vals, comms)
      _flush_screen(out, scr, scomms)
      cur, vals, comms = None, [], []
      scr, scomms = None, []
      var, vl = _parse_for(l, fn, ln)
      block = []
      i += 1
      d = 1
      first = i
      while(i < len(lines) and d):
        l2 = lines[i]
        if(l2.startswith('!for ')): d += 1
        elif(l2.startswith('!endfor')): d -= 1
        if(d): block.append(l2)
        i += 1
      if(d): _err(fn, 0, 'unclosed !for block (missing !endfor)')
      for val in vl: out.extend(process_lang(block, {**vars, var: val}, fn, bl + first))
      continue
    elif(l.startswith('!endfor')): _err(fn, ln, 'unexpected !endfor (no matching !for)')
    elif(l.startswith('!map ')):
      kv, kvs, mv, mvs = _parse_map(l, fn, ln)
      if(kv in vars):
        if(vars[kv] in kvs): vars[mv] = mvs[kvs.index(vars[kv])]
        else: _err(fn, ln, f"key <{vars[kv]}> not in source value list")
      i += 1
      continue
    for k, v in sorted(vars.items(), key=lambda x: -len(x[0])): l = l.replace('%' + k, v)
    rw = l[:len(l) - len(l.lstrip())]
    s = l.lstrip()
    if(rw == ''):
      level = 0
      istk = []
    else:
      mi = None
      for ix, (is_, lv) in enumerate(istk):
        if(is_ == rw):
          mi = ix
          break
      if(mi is not None):
        istk = istk[:mi + 1]
        level = istk[-1][1]
      else:
        cw = _tabw(istk[-1][0]) if istk else 0
        nw = _tabw(rw)
        if(nw > cw and len(istk) < 3):
          level = (istk[-1][1] if istk else 0) + 1
          istk.append((rw, level))
        else: _err(fn, ln, 'inconsistent indentation')
    if(level > 3): _err(fn, ln, 'too many indentation levels (max 3)')
    if(level == 0):
      _flush_option(out, cur, vals, comms)
      _flush_screen(out, scr, scomms)
      cur, vals, comms = None, [], []
      scr, scomms = None, []
      if(s.startswith('screen.')):
        parts = s.split(maxsplit=1)
        out.append(f'{parts[0]}={_format(parts[1] if len(parts) > 1 else "")}')
        scr = parts[0].split('.', 1)[1]
      else:
        parts = s.split(maxsplit=1)
        cur = (parts[0], _format(parts[1] if len(parts) > 1 else ''))
        vals = []
        comms = []
    elif(level == 1):
      if(s == '!empty'):
        if(cur): comms.append('')
        elif(scr is not None): scomms.append('')
      elif(s.startswith('!prefix')):
        if(cur):
          pfx = s.split(maxsplit=1)
          if(len(pfx) > 1): out.append(f'prefix.{cur[0]}={_format(pfx[1])}')
      elif(s.startswith('!suffix')):
        if(cur):
          sfx = s.split(maxsplit=1)
          if(len(sfx) > 1): out.append(f'suffix.{cur[0]}={sfx[1]}')
      elif(cur): comms.append(_format(s))
      elif(scr is not None): scomms.append(_format(s))
    elif(level == 2):
      if(cur):
        parts = s.split(maxsplit=1)
        vals.append((parts[0], _format(parts[1] if len(parts) > 1 else ''), ''))
    elif(level == 3):
      if(vals): vals[-1] = (vals[-1][0], vals[-1][1], _format(s))
    i += 1
  _flush_option(out, cur, vals, comms)
  _flush_screen(out, scr, scomms)
  return out
def do_lang():
  for loc in os.listdir(os.path.join(BB, 'lang')):
    locd = os.path.join(BB, 'lang', loc)
    if(not os.path.isdir(locd)): continue
    out = []
    for fn in sorted(os.listdir(locd)):
      if(not fn.endswith('.txt')): continue
      fp = os.path.join(locd, fn)
      with open(fp) as f: c = f.read()
      out.extend(process_lang(c.splitlines(), {}, fp))
    op = os.path.join(BA, 'lang', f'{loc}.lang')
    os.makedirs(os.path.dirname(op), exist_ok=True)
    with open(op, 'w') as f: f.write('\n'.join(out) + '\n')

if(__name__ == '__main__'):
  do_settings()
  do_lang()
